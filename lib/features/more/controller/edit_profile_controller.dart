import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:path/path.dart' as p;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:selectcropcompressimage/selectcropcompressimage.dart';
import 'package:eye_buddy/core/services/api/model/profile_reponse_model.dart';
import 'package:eye_buddy/features/login/controller/profile_controller.dart';
import 'package:eye_buddy/features/more/view/profile_screen.dart';
import 'package:eye_buddy/core/services//api/repo/api_repo.dart'; // tumhara repo
import 'package:eye_buddy/features/global_widgets/toast.dart';
import 'package:eye_buddy/l10n/app_localizations.dart';

class EditProfileController extends GetxController {
  // ===== Controllers =====
  final nameController = TextEditingController();
  final dobController = TextEditingController();
  final weightController = TextEditingController();
  final genderController = TextEditingController();
  final emailController = TextEditingController();

  // ===== Variables =====
  RxBool isLoading = false.obs;
  Rx<File?> selectedImage = Rx<File?>(null);
  late Profile profile;

  bool _isPickingImage = false;

  final ApiRepo _repo = ApiRepo(); // API repository

  Future<File> _bytesToTempFile(Uint8List bytes) async {
    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final file = File(path);
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  String _formatDateOfBirth(String? raw) {
    final value = (raw ?? '').trim();
    if (value.isEmpty) return '';

    final parsed = DateTime.tryParse(value);
    if (parsed != null) {
      final y = parsed.year.toString().padLeft(4, '0');
      final m = parsed.month.toString().padLeft(2, '0');
      final d = parsed.day.toString().padLeft(2, '0');
      return '$y-$m-$d';
    }

    // Fallback for values like "2024-01-01T00:00:00.000Z" or "2024-01-01 00:00:00.000"
    final tSplit = value.split('T');
    final spaceSplit = (tSplit.isNotEmpty ? tSplit.first : value).split(' ');
    return spaceSplit.isNotEmpty ? spaceSplit.first : value;
  }

  void setProfile(Profile data) {
    profile = data;
    nameController.text = data.name ?? "";
    dobController.text = _formatDateOfBirth(data.dateOfBirth);
    weightController.text = data.weight ?? "";
    genderController.text = (data.gender ?? '').trim();
    emailController.text = data.email ?? "";
  }

  /// ===== Pick Image from gallery =====
  Future<void> pickImage({
    ImageSource source = ImageSource.gallery,
    BuildContext? context,
  }) async {
    if (_isPickingImage) return;
    _isPickingImage = true;
    if (source == ImageSource.camera) {
      try {
        final picked = await ImagePicker().pickImage(
          source: source,
          imageQuality: 40,
          maxWidth: 700,
          maxHeight: 700,
        );
        if (picked != null) {
          selectedImage.value = File(picked.path);
        }
      } on PlatformException catch (e) {
        Get.snackbar(
          'Error',
          e.message ?? 'Unable to access camera',
          snackPosition: SnackPosition.BOTTOM,
        );
      } catch (_) {
        // ignore
      }
      _isPickingImage = false;
      return;
    }

    final ctx = context ?? Get.context;
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
          selectedImage.value = result;
          _isPickingImage = false;
          return;
        }
        if (result is Uint8List) {
          selectedImage.value = await _bytesToTempFile(result);
          _isPickingImage = false;
          return;
        }

        // User cancelled cropper/picker (e.g. pressed cross). Do nothing and
        // allow future attempts to open the cropper again.
        _isPickingImage = false;
        return;
      } on PlatformException catch (e) {
        Get.snackbar(
          'Error',
          e.message ?? 'Unable to access camera/gallery',
          snackPosition: SnackPosition.BOTTOM,
        );
        _isPickingImage = false;
        return;
      } catch (_) {
        // ignore
        _isPickingImage = false;
        return;
      }
    }

    // If we don't have a context, fall back to plain picker.
    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        imageQuality: 40,
        maxWidth: 700,
        maxHeight: 700,
      );
      if (picked != null) {
        selectedImage.value = File(picked.path);
      }
    } catch (_) {
      // ignore
    } finally {
      _isPickingImage = false;
    }
  }

  /// ===== Save Profile with API =====
  Future<void> saveProfile() async {
    final dob = dobController.text.trim();
    if (dob.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select date of birth',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final gender = genderController.text.trim();
    if (gender.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select gender',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final weightText = weightController.text.trim();
    if (weightText.isNotEmpty) {
      final weightValue = int.tryParse(weightText);
      if (weightValue == null || weightValue > 999) {
        Get.snackbar(
          'Error',
          AppLocalizations.of(Get.context!)!.weight_max_999,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
    }

    final email = emailController.text.trim();
    if (email.isNotEmpty &&
        !RegExp(
          r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@"
          r"[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?"
          r"(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$",
        ).hasMatch(email)) {
      Get.snackbar(
        'Error',
        'Enter proper email',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;

    try {
      // 1️⃣ Upload image if selected
      String? uploadedImagePath;
      if (selectedImage.value != null) {
        final file = selectedImage.value!;
        final bytes = await file.readAsBytes();
        if (bytes.length > 900 * 1024) {
          Get.snackbar(
            'Error',
            'Image is too large. Please choose a smaller photo and try again.',
            snackPosition: SnackPosition.BOTTOM,
          );
          isLoading.value = false;
          return;
        }
        final base64Image = base64Encode(bytes);
        final ext = p.extension(file.path).isNotEmpty
            ? p.extension(file.path)
            : '.jpg';
        final imageResponse = await _repo.uploadProfileImageInBase64(
          base64Image,
          fileExtension: ext,
        );
        final imageSuccess =
            (imageResponse.status ?? '').toLowerCase() == 'success';
        if (imageSuccess) {
          uploadedImagePath = imageResponse.profile?.photo ?? '';
        } else {
          Get.snackbar(
            "Error",
            imageResponse.message ?? "Failed to upload image",
            snackPosition: SnackPosition.BOTTOM,
          );
          isLoading.value = false;
          return;
        }
      }

      // 2️⃣ Prepare profile update parameters
      final Map<String, dynamic> parameters = {
        "name": nameController.text,
        "dateOfBirth": _formatDateOfBirth(dobController.text),
        "weight": weightController.text,
        "gender": gender,
        "email": email,
      };
      if (uploadedImagePath != null) {
        parameters["photo"] = uploadedImagePath;
      }

      // 3️⃣ Call update profile API
      final response = await _repo.updateProfileData(parameters);

      final isSuccess = (response.status ?? '').toLowerCase() == 'success';
      if (isSuccess) {
        // Update local profile object
        profile.name = nameController.text;
        profile.dateOfBirth = _formatDateOfBirth(dobController.text);
        profile.weight = weightController.text;
        profile.gender = genderController.text;
        profile.email = emailController.text;
        if (uploadedImagePath != null) {
          profile.photo = uploadedImagePath;
        }

        final ctx = Get.context;
        if (ctx != null) {
          showToast(message: 'Profile updated successfully', context: ctx);
        }

        try {
          final profileCtrl = Get.isRegistered<ProfileController>()
              ? Get.find<ProfileController>()
              : Get.put(ProfileController());
          await profileCtrl.getProfileData();
        } catch (_) {
          // ignore
        }

        Get.off(() => const ProfileScreen());
      } else {
        Get.snackbar(
          "Error",
          response.message ?? "Failed to update profile",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar("Error", e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
}
