import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/services/api/model/patient_list_model.dart';
import '../../../core/services/api/repo/api_repo.dart';
import '../../../core/controler/app_state_controller.dart';
import 'package:eye_buddy/features/patient_select/controller/patient_select_controller.dart';
import 'package:eye_buddy/features/appointments/controller/appointment_controller.dart';
import 'package:eye_buddy/l10n/app_localizations.dart';

class CreatePatientProfileController extends GetxController {
  final ApiRepo _apiRepo = ApiRepo();

  final isLoading = false.obs;
  final selectedProfile = Rx<XFile?>(null);
  final errorMessage = ''.obs;
  final successMessage = ''.obs;

  // Form controllers
  final nameController = TextEditingController();
  final dobController = TextEditingController();
  final weightController = TextEditingController();
  final genderController = TextEditingController();
  final relationWithYouController = TextEditingController();

  final genderValue = ''.obs;
  final isCreateNewPatientProfile = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize with arguments if provided
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      isCreateNewPatientProfile.value =
          args['isCreateNewPatientProfile'] ?? false;
    }

    // Reset selected profile
    selectedProfile.value = null;
  }

  @override
  void onClose() {
    nameController.dispose();
    dobController.dispose();
    weightController.dispose();
    genderController.dispose();
    relationWithYouController.dispose();
    super.onClose();
  }

  void selectGender(String value) {
    genderValue.value = value;
    genderController.text = value;
  }

  Future<void> selectProfileImage(BuildContext context) async {
    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.white,
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
                      await _pickImage(ImageSource.camera);
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
                      await _pickImage(ImageSource.gallery);
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

  Future<void> _pickImage(ImageSource source) async {
    try {
      final appStateController = Get.find<AppStateController>();
      appStateController.setPickingImage(true);

      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: source,
        imageQuality: 50,
        maxWidth: 700,
        maxHeight: 700,
      );

      if (image != null) {
        selectedProfile.value = image;
      }
    } catch (e, s) {
      log('_pickImage error: $e', stackTrace: s);
    } finally {
      final appStateController = Get.find<AppStateController>();
      appStateController.setPickingImage(false);
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

  Future<void> savePatient() async {
    if (isLoading.value) {
      return;
    }
    if (nameController.text.isEmpty) {
      final ctx = Get.context;
      if (ctx != null) {
        final l10n = AppLocalizations.of(ctx)!;
        Get.snackbar(l10n.error, l10n.please_enter_patient_name);
      }
      return;
    }
    if (dobController.text.isEmpty) {
      final ctx = Get.context;
      if (ctx != null) {
        final l10n = AppLocalizations.of(ctx)!;
        Get.snackbar(l10n.error, l10n.please_enter_date_of_birth);
      }
      return;
    }
    if (weightController.text.isEmpty) {
      final ctx = Get.context;
      if (ctx != null) {
        final l10n = AppLocalizations.of(ctx)!;
        Get.snackbar(l10n.error, l10n.please_enter_weight);
      }
      return;
    }
    final weightValue = int.tryParse(weightController.text.trim());
    if (weightValue == null || weightValue > 999) {
      final ctx = Get.context;
      if (ctx != null) {
        final l10n = AppLocalizations.of(ctx)!;
        Get.snackbar(l10n.error, l10n.weight_max_999);
      }
      return;
    }
    if (genderValue.value.isEmpty) {
      final ctx = Get.context;
      if (ctx != null) {
        final l10n = AppLocalizations.of(ctx)!;
        Get.snackbar(l10n.error, l10n.please_select_gender);
      }
      return;
    }
    if (relationWithYouController.text.isEmpty) {
      final ctx = Get.context;
      if (ctx != null) {
        final l10n = AppLocalizations.of(ctx)!;
        Get.snackbar(l10n.error, l10n.please_enter_relation);
      }
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';
    successMessage.value = '';

    try {
      final patient = MyPatient(
        name: nameController.text,
        dateOfBirth: dobController.text,
        weight: weightController.text,
        gender: genderValue.value.toLowerCase(),
        relation: relationWithYouController.text,
      );

      Map<String, dynamic> data = patient.toMap();

      // Add profile photo if selected
      if (selectedProfile.value != null) {
        data.addAll({
          "profilePhoto": {
            "base64String": await xFileToBase64(selectedProfile.value!),
            "fileExtension": getFileExtension(selectedProfile.value!.path),
          },
        });
      }

      final response = await _apiRepo.saveMyPatient(params: data);

      if (response.status == 'success') {
        // refresh patient list in PatientSelectController if available
        try {
          final patientSelectController = Get.find<PatientSelectController>();
          await patientSelectController.getPatientList();
        } catch (_) {
          // controller not in memory, ignore
        }

        // refresh patient list in AppointmentController (dropdown in appointments)
        try {
          final appointmentController = Get.find<AppointmentController>();
          await appointmentController.getPatients();
        } catch (_) {
          // controller not in memory, ignore
        }

        final ctx = Get.context;
        successMessage.value = ctx != null
            ? AppLocalizations.of(ctx)!.patient_added
            : 'Patient added!';
        Get.back(result: {'saved': true, 'message': successMessage.value});
      } else {
        errorMessage.value = response.message;
        final ctx = Get.context;
        if (ctx != null) {
          Get.snackbar(AppLocalizations.of(ctx)!.error, errorMessage.value);
        }
      }
    } catch (e, s) {
      log('savePatient error: $e', stackTrace: s);
      final ctx = Get.context;
      errorMessage.value = ctx != null
          ? AppLocalizations.of(ctx)!.failed_to_save_patient_profile
          : 'Failed to save patient profile';
      if (ctx != null) {
        Get.snackbar(AppLocalizations.of(ctx)!.error, errorMessage.value);
      }
    } finally {
      isLoading.value = false;
    }
  }

  void resetForm() {
    nameController.clear();
    dobController.clear();
    weightController.clear();
    genderController.clear();
    relationWithYouController.clear();
    selectedProfile.value = null;
    genderValue.value = '';
    errorMessage.value = '';
    successMessage.value = '';
  }
}
