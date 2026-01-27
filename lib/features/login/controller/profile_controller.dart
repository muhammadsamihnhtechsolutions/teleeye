import 'dart:developer';
import 'dart:convert';

import 'package:eye_buddy/core/services/api/model/profile_reponse_model.dart';
import 'package:eye_buddy/core/services/api/service/api_constants.dart';
import 'package:eye_buddy/core/services/api/service/api_service.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ProfileController extends GetxController {
  final ApiService _apiService = ApiService();

  /// Observables
  var profileData = ProfileResponseModel().obs;
  var isLoading = false.obs;
  var selectedProfileImagePath = ''.obs;

  /// -----------------------------
  /// GET PROFILE DATA
  /// -----------------------------
  Future<void> getProfileData() async {
    try {
      // If this is triggered while the framework is building widgets (e.g.
      // during keep-alive/tab rebuild), updating Rx values can throw
      // "markNeedsBuild called during build". Deferring by one tick prevents it.
      if (SchedulerBinding.instance.schedulerPhase != SchedulerPhase.idle) {
        await Future<void>.delayed(Duration.zero);
      }

      isLoading.value = true;

      final rawResponse = await _apiService.getGetResponse(
        ApiConstants.profileMe,
      );

      dynamic normalizedResponse = rawResponse;
      if (rawResponse is String) {
        try {
          normalizedResponse = jsonDecode(rawResponse);
        } catch (_) {
          log('Get Profile Data Error: invalid JSON string response');
          profileData.value = ProfileResponseModel(
            status: 'error',
            message: 'Invalid server response while fetching profile data',
          );
          return;
        }
      }

      Map<String, dynamic>? map;
      if (normalizedResponse is Map<String, dynamic>) {
        map = normalizedResponse;
      } else if (normalizedResponse is List && normalizedResponse.isNotEmpty) {
        final first = normalizedResponse.first;
        if (first is Map<String, dynamic>) {
          map = first;
        }
      }

      if (map != null) {
        profileData.value = ProfileResponseModel.fromJson(map);
      } else {
        log(
          'Get Profile Data Error: unexpected response type ${normalizedResponse.runtimeType}',
        );
        profileData.value = ProfileResponseModel(
          status: 'error',
          message: 'Invalid server response while fetching profile data',
        );
      }
    } catch (err) {
      log("Get Profile Data Error: $err");
    } finally {
      isLoading.value = false;
    }
  }

  /// -----------------------------
  /// UPDATE PROFILE DATA
  /// -----------------------------
  Future<void> updateProfileData(Map<String, dynamic> parameters) async {
    try {
      isLoading.value = true;

      final rawResponse = await _apiService.getPatchResponse(
        ApiConstants.profileUpdate,
        parameters,
      );

      Map<String, dynamic>? map;
      if (rawResponse is Map<String, dynamic>) {
        map = rawResponse;
      } else if (rawResponse is List && rawResponse.isNotEmpty) {
        final first = rawResponse.first;
        if (first is Map<String, dynamic>) {
          map = first;
        }
      }

      if (map != null) {
        profileData.value = ProfileResponseModel.fromJson(map);
      } else {
        log(
          'Update Profile Data Error: unexpected response type ${rawResponse.runtimeType}',
        );
        profileData.value = ProfileResponseModel(
          status: 'error',
          message: 'Invalid server response while updating profile data',
        );
      }
    } catch (err) {
      log("Update Profile Data Error: $err");
    } finally {
      isLoading.value = false;
    }
  }

  /// -----------------------------
  /// UPLOAD PROFILE IMAGE
  /// -----------------------------
  Future<void> uploadProfileImageInBase64(String imageAsBase64) async {
    try {
      isLoading.value = true;

      final rawResponse = await _apiService.getPostResponse(
        '${ApiConstants.baseUrl}/api/patient/profile/uploadProfilePhoto',
        {"base64String": imageAsBase64, "fileExtension": "jpg"},
      );

      dynamic normalizedResponse = rawResponse;
      if (rawResponse is String) {
        try {
          normalizedResponse = jsonDecode(rawResponse);
        } catch (_) {
          final lower = rawResponse.toLowerCase();
          final isTooLarge =
              lower.contains('413') ||
              lower.contains('request entity too large') ||
              lower.contains('entity too large');
          profileData.value = ProfileResponseModel(
            status: 'error',
            message: isTooLarge
                ? 'Image is too large. Please choose a smaller photo and try again.'
                : 'Invalid server response while uploading profile image',
          );
          return;
        }
      }

      Map<String, dynamic>? map;
      if (normalizedResponse is Map<String, dynamic>) {
        map = normalizedResponse;
      } else if (normalizedResponse is List && normalizedResponse.isNotEmpty) {
        final first = normalizedResponse.first;
        if (first is Map<String, dynamic>) {
          map = first;
        }
      }

      if (map != null) {
        profileData.value = ProfileResponseModel.fromJson(map);
      } else {
        log(
          'Upload Profile Image Error: unexpected response type ${normalizedResponse.runtimeType}',
        );
        profileData.value = ProfileResponseModel(
          status: 'error',
          message: 'Invalid server response while uploading profile image',
        );
      }
    } catch (err) {
      log("Upload Profile Image Error: $err");
    } finally {
      isLoading.value = false;
    }
  }

  /// -----------------------------
  /// PICK IMAGE FUNCTION
  /// -----------------------------
  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      selectedProfileImagePath.value = file.path;
    }
  }
}
