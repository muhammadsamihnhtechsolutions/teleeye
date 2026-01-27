import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/services/api/model/appointment_doctor_model.dart';
import '../../../core/services/api/model/init_payment_response_model.dart';
import '../../../core/services/api/model/prescription_list_response_model.dart';
import '../../../core/services/api/repo/api_repo.dart';
import '../../../core/services/api/service/api_constants.dart';
import '../../../core/controler/app_state_controller.dart';
import '../../appointments/controller/appointment_controller.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/services/utils/keys/shared_pref_keys.dart';
import '../../../core/services/utils/keys/token_keys.dart';

class ReasonForVisitController extends GetxController {
  final ApiRepo _apiRepo = ApiRepo();
  final Dio _dio = Dio();

  final isLoading = false.obs;
  final eyePhotoList = <XFile>[].obs;
  final reportAndPrescriptionList = <File>[].obs;
  final errorMessage = ''.obs;
  final successMessage = ''.obs;
  final selectedAppointment = Rx<Appointment?>(null);
  final gatewayUrl = ''.obs;

  void _setPickingImage(bool value) {
    try {
      if (!Get.isRegistered<AppStateController>()) return;
      final appStateController = Get.find<AppStateController>();
      appStateController.setPickingImage(value);
    } catch (_) {
      // ignore
    }
  }

  void _showNoPrescriptionsDialog() {
    final context = Get.context;
    final message = context == null
        ? "You don't have any prescription"
        : AppLocalizations.of(context)!.you_dont_have_any_prescription;

    Get.dialog(
      AlertDialog(
        title: const Text('No prescriptions'),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('OK')),
        ],
      ),
    );
  }

  Future<Options?> _buildDownloadOptions() async {
    try {
      var token = patientToken.trim();
      if (token.isEmpty) {
        final prefs = await SharedPreferences.getInstance();
        token = (prefs.getString(userTokenKey) ?? '').trim();
        if (token.isNotEmpty) {
          patientToken = token;
        }
      }
      if (token.isEmpty) return null;
      return Options(headers: <String, String>{
        'Authorization': 'Bearer $token',
      });
    } catch (_) {
      return null;
    }
  }

  Future<void> selectLastPrescriptionFromLibrary({
    required String patientId,
  }) async {
    try {
      final safePatientId = patientId.trim();
      if (safePatientId.isEmpty) return;

      _setPickingImage(true);

      final resp = await _apiRepo.getPrescriptionList({
        'patient': safePatientId,
      });
      final items =
          resp.prescriptionListData?.prescriptionList ?? <Prescription>[];
      items.sort((a, b) {
        try {
          final ad = DateTime.tryParse((a.createdAt ?? '').toString());
          final bd = DateTime.tryParse((b.createdAt ?? '').toString());
          if (ad == null && bd == null) return 0;
          if (ad == null) return 1;
          if (bd == null) return -1;
          return bd.compareTo(ad);
        } catch (_) {
          return 0;
        }
      });
      if (items.isEmpty) {
        errorMessage.value = 'No prescriptions found';
        _showNoPrescriptionsDialog();
        return;
      }

      final latest = items.first;
      final file = await _downloadToTempFile(latest.file);
      if (file == null) {
        errorMessage.value = 'Failed to attach prescription';
        return;
      }

      addPatientPrescriptionFile(file: file);
    } catch (e, s) {
      log('selectLastPrescriptionFromLibrary error: $e', stackTrace: s);
      errorMessage.value = 'Failed to attach prescription';
    } finally {
      _setPickingImage(false);
    }
  }

  String _resolveS3Url(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return '';
    if (v.startsWith('http://') || v.startsWith('https://')) return v;
    return '${ApiConstants.imageBaseUrl}$v';
  }

  Future<File?> _downloadToTempFile(String? url) async {
    final resolved = _resolveS3Url(url);
    final uri = Uri.tryParse(resolved);
    if (uri == null) return null;

    final directory = await getTemporaryDirectory();
    final ext = p.extension(uri.path);
    final safeExt = ext.isNotEmpty ? ext : '.jpg';
    final fileName =
        'prescription_${DateTime.now().millisecondsSinceEpoch}$safeExt';
    final path = p.join(directory.path, fileName);

    try {
      final options = await _buildDownloadOptions();
      await _dio.download(resolved, path, options: options);
      return File(path);
    } on DioException catch (e, s) {
      log('download prescription failed: $e', stackTrace: s);
      return null;
    } catch (e, s) {
      log('download prescription failed: $e', stackTrace: s);
      return null;
    }
  }

  Future<void> selectPrescriptionFromLibrary({
    required String patientId,
  }) async {
    try {
      final safePatientId = patientId.trim();
      if (safePatientId.isEmpty) return;

      _setPickingImage(true);

      final resp = await _apiRepo.getPrescriptionList({
        'patient': safePatientId,
      });
      final items =
          resp.prescriptionListData?.prescriptionList ?? <Prescription>[];
      items.sort((a, b) {
        try {
          final ad = DateTime.tryParse((a.createdAt ?? '').toString());
          final bd = DateTime.tryParse((b.createdAt ?? '').toString());
          if (ad == null && bd == null) return 0;
          if (ad == null) return 1;
          if (bd == null) return -1;
          return bd.compareTo(ad);
        } catch (_) {
          return 0;
        }
      });
      if (items.isEmpty) {
        errorMessage.value = 'No prescriptions found';
        _showNoPrescriptionsDialog();
        return;
      }

      await Get.bottomSheet(
        Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  height: 4,
                  width: 44,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 12),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Choose a prescription',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return ListTile(
                        leading: const Icon(
                          Icons.description,
                          color: Colors.black54,
                        ),
                        title: Text((item.title ?? 'Prescription').toString()),
                        subtitle: Text((item.createdAt ?? '').toString()),
                        onTap: () async {
                          try {
                            final file = await _downloadToTempFile(item.file);
                            if (file != null) {
                              addPatientPrescriptionFile(file: file);
                            }
                          } catch (e, s) {
                            log(
                              'selectPrescriptionFromLibrary download error: $e',
                              stackTrace: s,
                            );
                            errorMessage.value =
                                'Failed to attach prescription';
                          } finally {
                            Get.back();
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        isScrollControlled: true,
      );
    } catch (e, s) {
      log('selectPrescriptionFromLibrary error: $e', stackTrace: s);
      errorMessage.value = 'Failed to load prescriptions';
    } finally {
      _setPickingImage(false);
    }
  }

  void resetState() {
    eyePhotoList.clear();
    reportAndPrescriptionList.clear();
    errorMessage.value = '';
    successMessage.value = '';
    selectedAppointment.value = null;
    gatewayUrl.value = '';
  }

  void clearState() {
    eyePhotoList.clear();
    reportAndPrescriptionList.clear();
    errorMessage.value = '';
    successMessage.value = '';
    selectedAppointment.value = null;
    gatewayUrl.value = '';
  }

  void addEyePhoto({required XFile eyePhoto}) {
    eyePhotoList.add(eyePhoto);
  }

  void deleteEyePhoto({required int position}) {
    if (position >= 0 && position < eyePhotoList.length) {
      eyePhotoList.removeAt(position);
    }
  }

  Future<bool> _ensureImagePickerPermission(ImageSource source) async {
    try {
      if (source == ImageSource.camera) {
        final status = await Permission.camera.request();
        return status.isGranted || status.isLimited;
      }

      // Gallery
      if (Platform.isIOS) {
        final status = await Permission.photos.request();
        return status.isGranted || status.isLimited;
      }

      // Android: try both legacy storage and modern media permission.
      final statuses = await [Permission.photos, Permission.storage].request();

      final photosOk = statuses[Permission.photos]?.isGranted ?? false;
      final storageOk = statuses[Permission.storage]?.isGranted ?? false;
      return photosOk || storageOk;
    } catch (e, s) {
      log('_ensureImagePickerPermission error: $e', stackTrace: s);
      return false;
    }
  }

  void addPatientPrescriptionFile({required File file}) {
    reportAndPrescriptionList.add(file);
  }

  void deletePatientPrescriptionFile({required int position}) {
    if (position >= 0 && position < reportAndPrescriptionList.length) {
      reportAndPrescriptionList.removeAt(position);
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

  Future<String> fileToBase64(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final base64Image = base64Encode(bytes);
      return base64Image;
    } catch (e) {
      log('fileToBase64 error: $e');
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

  Future<void> saveAppointment(Map<String, dynamic> params) async {
    isLoading.value = true;
    errorMessage.value = '';
    successMessage.value = '';
    var didNavigate = false;

    try {
      List<Map<String, dynamic>> eyePhotos = [];
      for (int i = 0; i < eyePhotoList.length; i++) {
        eyePhotos.add({
          "base64String": await xFileToBase64(eyePhotoList[i]),
          "fileExtension": getFileExtension(eyePhotoList[i].path),
        });
      }
      params.addAll({"eyePhotos": eyePhotos});

      List<Map<String, dynamic>> reports = [];
      for (int i = 0; i < reportAndPrescriptionList.length; i++) {
        reports.add({
          "base64String": await fileToBase64(reportAndPrescriptionList[i]),
          "fileExtension": getFileExtension(reportAndPrescriptionList[i].path),
        });
      }
      params.addAll({"prescriptions": reports});

      // Match BLoC: do not send Flutter objects in API body
      final apiParams = Map<String, dynamic>.from(params)
        ..remove('patientData')
        ..remove('selectedDoctor');

      SaveAppointmentApiResponse apiResponse = await _apiRepo.saveAppointments(
        apiParams,
      );

      if (apiResponse.status == "success") {
        selectedAppointment.value = apiResponse.appointment;
        successMessage.value = "Appointment created.";

        // Navigate to appointment overview screen
        // Turn off loader before navigating, otherwise the next screen may
        // show its own loader and the user sees a "double loader" effect.
        isLoading.value = false;
        didNavigate = true;
        Get.toNamed(
          '/appointment-overview',
          arguments: {
            'patientData': params['patientData'],
            'selectedDoctor': params['selectedDoctor'],
            'appointment': apiResponse.appointment,
          },
        );
      } else {
        errorMessage.value = apiResponse.message;
      }
    } catch (e, s) {
      log('saveAppointment error: $e', stackTrace: s);
      errorMessage.value = 'Failed to save appointment';
    } finally {
      if (!didNavigate) {
        isLoading.value = false;
      }
    }
  }

  Future<void> initiatePayment(Map<String, dynamic> params) async {
    isLoading.value = true;
    errorMessage.value = '';
    var didNavigate = false;
    final sw = Stopwatch()..start();

    try {
      // Match BLoC: only send appointment + paymentGateway to API
      final apiParams = Map<String, dynamic>.from(params)
        ..remove('patientData')
        ..remove('selectedDoctor');

      InitPaymentApiResponseModel apiResponse = await _apiRepo.initiatePayment(
        apiParams,
      );
      sw.stop();
      log('initiatePayment API time: ${sw.elapsedMilliseconds}ms');
      log("Appointment ID: ${selectedAppointment.value?.id ?? "NO-ID"}");

      if (apiResponse.status == "success") {
        gatewayUrl.value = apiResponse.url ?? '';
        successMessage.value = "Payment initiated.";

        // Navigate to in-app payment gateway screen when URL is available
        if (gatewayUrl.value.isNotEmpty) {
          log('Payment URL: ${gatewayUrl.value}');
          // Turn off loader before navigating, otherwise the payment screen's
          // webview loader can appear together with this screen's overlay.
          isLoading.value = false;
          didNavigate = true;
          Get.toNamed(
            '/payment-gateway',
            arguments: {
              'url': gatewayUrl.value,
              'appointmentId': params['appointment'],
              'patientData': params['patientData'],
              'selectedDoctor': params['selectedDoctor'],
            },
          );
        }
      } else {
        errorMessage.value = apiResponse.message ?? "Payment initiation failed";
      }
    } catch (e, s) {
      sw.stop();
      log('initiatePayment error: $e', stackTrace: s);
      errorMessage.value = 'Failed to initiate payment';
    } finally {
      if (!didNavigate) {
        isLoading.value = false;
      }
    }
  }

  Future<void> updateAppointmentWithPromoData({
    required num vat,
    required num grandTotal,
    required num totalAmount,
    num? discount,
    String? promoCode,
  }) async {
    try {
      if (selectedAppointment.value != null) {
        final appointment = selectedAppointment.value!;
        appointment.vat = vat.toDouble();
        appointment.grandTotal = grandTotal.toDouble();
        appointment.totalAmount = totalAmount.toDouble();
        if (discount != null) {
          appointment.discount = discount.toInt();
        }
        if ((promoCode ?? '').trim().isNotEmpty) {
          appointment.promoCode = promoCode;
        }

        // Ensure GetX listeners rebuild even if we're mutating the same instance.
        selectedAppointment.refresh();
        successMessage.value = "Appointment updated with promo data.";
      }
    } catch (e, s) {
      log('updateAppointmentWithPromoData error: $e', stackTrace: s);
      errorMessage.value = 'Failed to update appointment';
    }
  }

  Future<void> selectPrescriptionFile() async {
    try {
      _setPickingImage(true);

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowedExtensions: ["pdf", "jpg", "png"],
        type: FileType.custom,
      );

      if (result != null) {
        PlatformFile file = result.files.first;
        log('Selected file: ${file.name}');

        final fileObj = File(result.paths.first!);
        addPatientPrescriptionFile(file: fileObj);
      }
    } catch (e, s) {
      log('selectPrescriptionFile error: $e', stackTrace: s);
      errorMessage.value = 'Failed to select prescription file';
    } finally {
      _setPickingImage(false);
    }
  }

  Future<void> selectImage(BuildContext context) async {
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
      log('selectImage error: $e', stackTrace: s);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      _setPickingImage(true);

      final hasPermission = await _ensureImagePickerPermission(source);
      if (!hasPermission) {
        errorMessage.value = 'Permission denied';
        log('Image picker permission denied for source: $source');
        return;
      }

      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: source,
        imageQuality: 50,
        maxWidth: 700,
        maxHeight: 700,
      );

      if (image != null) {
        addEyePhoto(eyePhoto: image);
      }
    } on PlatformException catch (e, s) {
      log(
        '_pickImage PlatformException: code=${e.code} message=${e.message} details=${e.details}',
        stackTrace: s,
      );
      errorMessage.value = e.message ?? 'Failed to open camera/gallery';
    } catch (e, s) {
      log('_pickImage error: $e', stackTrace: s);
    } finally {
      _setPickingImage(false);
    }
  }

  Future<void> refreshAppointments() async {
    // Refresh appointments after payment success like BLoC's AppointmentCubit.getAppointments
    // This will update the appointment list with latest status using AppointmentController
    try {
      final appointmentController = Get.isRegistered<AppointmentController>()
          ? Get.find<AppointmentController>()
          : Get.put(AppointmentController());

      // Force a fresh fetch from API (no storage cache) similar to BLoC refresh
      await appointmentController.refreshScreen();
    } catch (e) {
      log('refreshAppointments error: $e');
    }
  }
}
