import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as p;
import 'package:eye_buddy/core/services/api/repo/api_repo.dart';
import 'package:eye_buddy/core/services/utils/services/navigator_services.dart';
import 'package:eye_buddy/features/bootom_navbar_screen/views/bottom_navbar_screen.dart';
import 'package:eye_buddy/features/login/controller/profile_controller.dart';
import 'package:eye_buddy/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:selectcropcompressimage/selectcropcompressimage.dart';

class SaveUserDataController extends GetxController {
  // Controllers
  final nameController = TextEditingController();
  final dobController = TextEditingController();
  final weightController = TextEditingController();
  final genderController = TextEditingController();

  // Profile Image
  final selectedProfileImage = Rx<File?>(null);

  // Loading state
  final isLoading = false.obs;

  final ApiRepo _apiRepo = ApiRepo();

  Future<File> _bytesToTempFile(Uint8List bytes) async {
    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final file = File(path);
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  @override
  void onClose() {
    nameController.dispose();
    dobController.dispose();
    weightController.dispose();
    genderController.dispose();
    super.onClose();
  }

  /// Pick Image
  Future<void> pickImage({ImageSource source = ImageSource.gallery}) async {
    if (source == ImageSource.camera) {
      try {
        final pickedFile = await ImagePicker().pickImage(
          source: source,
          imageQuality: 40,
          maxWidth: 700,
          maxHeight: 700,
        );
        if (pickedFile != null) {
          selectedProfileImage.value = File(pickedFile.path);
        }
      } catch (_) {
        // ignore
      }
      return;
    }

    final ctx = Get.context;
    if (ctx != null) {
      try {
        final selector = SelectCropCompressImage();
        final dynamic result = source == ImageSource.camera
            ? await selector.selectCropCompressImageFromCamera(
                compressionAmount: 30,
                context: ctx,
              )
            : await selector.selectCropCompressImageFromGallery(
                compressionAmount: 30,
                context: ctx,
              );
        if (result is File) {
          selectedProfileImage.value = result;
          return;
        }
        if (result is Uint8List) {
          selectedProfileImage.value = await _bytesToTempFile(result);
          return;
        }
      } catch (_) {
        // ignore
      }
    }

    final pickedFile = await ImagePicker().pickImage(
      source: source,
      imageQuality: 40,
      maxWidth: 700,
      maxHeight: 700,
    );
    if (pickedFile != null) {
      selectedProfileImage.value = File(pickedFile.path);
    }
  }

  /// Save User Data
  Future<void> saveUserData() async {
    if (nameController.text.isEmpty ||
        dobController.text.isEmpty ||
        weightController.text.isEmpty ||
        genderController.text.isEmpty) {
      final ctx = Get.context;
      if (ctx != null) {
        final l10n = AppLocalizations.of(ctx)!;
        Get.snackbar(l10n.error, l10n.enter_all_fields_and_try_again);
      }
      return;
    }

    final weightValue = int.tryParse(weightController.text.trim());
    if (weightValue == null || weightValue > 999) {
      final ctx = Get.context;
      if (ctx != null) {
        Get.snackbar(
          AppLocalizations.of(ctx)!.error,
          AppLocalizations.of(ctx)!.weight_max_999,
        );
      }
      return;
    }

    isLoading.value = true;

    Map<String, dynamic> parameters = {
      "name": nameController.text,
      "dateOfBirth": dobController.text,
      "weight": weightController.text,
      "gender": genderController.text,
    };

    try {
      // 1) Always update profile data first (same idea as BLoC flow)
      final updateResponse = await _apiRepo.updateProfileData(parameters);
      final isSuccess =
          (updateResponse.status ?? '').toLowerCase() == 'success';
      if (!isSuccess) {
        final ctx = Get.context;
        if (ctx != null) {
          final l10n = AppLocalizations.of(ctx)!;
          Get.snackbar(
            l10n.error,
            updateResponse.message ?? l10n.failed_to_save_profile_data,
          );
        }
        isLoading.value = false;
        return;
      }

      // 2) Upload image (optional). If upload fails, do not block onboarding.
      if (selectedProfileImage.value != null) {
        try {
          final file = selectedProfileImage.value!;
          final bytes = await file.readAsBytes();
          if (bytes.length > 900 * 1024) {
            final ctx = Get.context;
            if (ctx != null) {
              final l10n = AppLocalizations.of(ctx)!;
              Get.snackbar(
                l10n.error,
                'Image is too large. Please choose a smaller photo and try again.',
              );
            }
            // do not block onboarding; just skip upload
          } else {
            final base64Image = base64Encode(bytes);
            final ext = p.extension(file.path).isNotEmpty
                ? p.extension(file.path)
                : '.jpg';

            final imageResponse = await _apiRepo.uploadProfileImageInBase64(
              base64Image,
              fileExtension: ext,
            );

            final imageSuccess =
                (imageResponse.status ?? '').toLowerCase() == 'success';
            if (!imageSuccess) {
              final ctx = Get.context;
              if (ctx != null) {
                final l10n = AppLocalizations.of(ctx)!;
                Get.snackbar(
                  l10n.error,
                  imageResponse.message ?? l10n.failed_to_save_profile_data,
                );
              }
            }
          }
        } catch (_) {
          // ignore image upload errors (profile data already saved)
        }
      }

      try {
        final profileCtrl = Get.isRegistered<ProfileController>()
            ? Get.find<ProfileController>()
            : Get.put(ProfileController());
        await profileCtrl.getProfileData();
      } catch (_) {
        // ignore
      }
      isLoading.value = false;

      // Navigate to bottom nav
      final ctx = Get.context;
      if (ctx != null) {
        NavigatorServices().toPushAndRemoveUntil(
          context: ctx,
          widget: const BottomNavBarScreen(),
        );
      } else {
        Get.offAll(() => const BottomNavBarScreen());
      }
    } catch (e) {
      isLoading.value = false;
      final ctx = Get.context;
      if (ctx != null) {
        final l10n = AppLocalizations.of(ctx)!;
        Get.snackbar(l10n.error, l10n.failed_to_save_profile_data);
      }
    }
  }

  /// Select DOB
  Future<void> pickDate(BuildContext context) async {
    final currentDate = DateTime.now();
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(1900),
      lastDate: currentDate,
    );

    dobController.text = selectedDate != null
        ? "${selectedDate.month}/${selectedDate.day}/${selectedDate.year}"
        : "${currentDate.month}/${currentDate.day}/${currentDate.year}";
  }
}
