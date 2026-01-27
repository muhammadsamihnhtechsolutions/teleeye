import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/services/api/model/doctor_list_response_model.dart';
import '../../../core/services/api/model/patient_list_model.dart';
import '../../../core/services/api/repo/api_repo.dart';
import '../../../core/controler/app_state_controller.dart';
import '../../reason_for_visit/view/reason_for_visit_screen.dart';
import '../../create_patient_profile/view/create_patient_profile_screen.dart';

class PatientSelectController extends GetxController {
  final ApiRepo _apiRepo = ApiRepo();

  final isLoading = false.obs;
  final patients = <MyPatient>[].obs;
  final selectedProfile = Rx<XFile?>(null);
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    getPatientListFromStorage();
    getPatientList();
  }

  Future<void> resetState() async {
    patients.clear();
    selectedProfile.value = null;
    errorMessage.value = '';
  }

  Future<void> savePatientListToStorage({
    required GetPatientListApiResponse getPatientListApiResponse,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        "my-patient-list",
        getPatientListApiResponse.toJson(),
      );
    } catch (e) {
      log('savePatientListToStorage error: $e');
    }
  }

  Future<void> getPatientListFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? getPatientListApiResponseJson = prefs.getString(
        "my-patient-list",
      );
      if (getPatientListApiResponseJson != null) {
        final GetPatientListApiResponse apiResponse =
            GetPatientListApiResponse.fromJson(getPatientListApiResponseJson);
        if (apiResponse.data != null) {
          patients.assignAll(apiResponse.data!);
        }
      }
    } catch (e) {
      log('getPatientListFromStorage error: $e');
    }
  }

  Future<void> getPatientList() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final GetPatientListApiResponse apiResponse = await _apiRepo
          .getMyPatientList();

      await savePatientListToStorage(getPatientListApiResponse: apiResponse);

      if (apiResponse.status == "success" && apiResponse.data != null) {
        patients.assignAll(apiResponse.data!);
      } else {
        patients.clear();
        errorMessage.value = apiResponse.message;
      }
    } catch (e, s) {
      log('getPatientList error: $e', stackTrace: s);
      patients.clear();
      errorMessage.value = 'Failed to load patients';
    } finally {
      isLoading.value = false;
    }
  }

  Future<String> xFileToBase64(XFile file) async {
    try {
      final bytes = await file.readAsBytes();
      final base64Image = base64Encode(bytes);
      return base64Image;
    } catch (e) {
      log('xFileToBase64 error: $e');
      rethrow;
    }
  }

  String getFileExtension(String filePath) {
    try {
      final extensionIndex = filePath.lastIndexOf('.');
      if (extensionIndex != -1 && extensionIndex < filePath.length - 1) {
        return "." + filePath.substring(extensionIndex + 1);
      } else {
        return '.jpg';
      }
    } catch (e) {
      log('getFileExtension error: $e');
      return '.jpg';
    }
  }

  Future<void> saveMyPatient({required MyPatient myPatient}) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final Map<String, dynamic> data = myPatient.toMap();

      if (selectedProfile.value != null) {
        data.addAll({
          "profilePhoto": {
            "base64String": await xFileToBase64(selectedProfile.value!),
            "fileExtension": getFileExtension(selectedProfile.value!.path),
          },
        });
      }

      final GetPatientListApiResponse apiResponse = await _apiRepo
          .saveMyPatient(params: data);

      if (apiResponse.status == "success") {
        await getPatientList();
        selectedProfile.value = null;
      } else {
        errorMessage.value = apiResponse.message;
      }
    } catch (e, s) {
      log('saveMyPatient error: $e', stackTrace: s);
      errorMessage.value = 'Failed to save patient';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> selectProfileImage(BuildContext context) async {
    try {
      final appStateController = Get.find<AppStateController>();

      await showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return Dialog(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              width: MediaQuery.of(context).size.width,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () async {
                      Navigator.pop(context);
                      await _pickImage(ImageSource.camera, appStateController);
                    },
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.camera_alt, size: 40),
                        SizedBox(height: 12),
                        Text('Capture\nImage', textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      Navigator.pop(context);
                      await _pickImage(ImageSource.gallery, appStateController);
                    },
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.image, size: 40),
                        SizedBox(height: 12),
                        Text('Select\nImage', textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } catch (e, s) {
      log('selectProfileImage error: $e', stackTrace: s);
    }
  }

  Future<void> _pickImage(
    ImageSource source,
    AppStateController appStateController,
  ) async {
    try {
      appStateController.setPickingImage(true);
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: source,
        imageQuality: 50,
        maxHeight: 700,
        maxWidth: 700,
      );
      if (image != null) {
        selectedProfile.value = image;
      }
    } catch (e, s) {
      log('_pickImage error: $e', stackTrace: s);
    } finally {
      appStateController.setPickingImage(false);
    }
  }

  void onPatientSelected(MyPatient patient, Doctor doctor) {
    Get.to(
      () => ReasonForVisitScreen(patientData: patient, selectedDoctor: doctor),
    );
  }

  void onCreateNewPatient() {
    Get.to(
      () => const CreatePatientProfileScreen(),
      arguments: {'isCreateNewPatientProfile': true},
    )?.then((result) {
      if (result == true) {
        getPatientList();
        return;
      }

      if (result is Map) {
        final saved = result['saved'] == true;
        final message = (result['message'] ?? '').toString();
        if (saved) {
          if (message.isNotEmpty) {
            Get.snackbar('Success', message);
          }
          getPatientList();
        }
      }
    });
  }
}
