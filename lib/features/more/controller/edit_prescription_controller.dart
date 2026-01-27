import 'dart:convert';

import 'package:eye_buddy/core/models/common_api_response_model.dart';
import 'package:eye_buddy/core/services/api/repo/api_repo.dart';
import 'package:eye_buddy/features/more/controller/more_controller.dart';
import 'package:get/get.dart';

class EditPrescriptionController extends GetxController {
  final ApiRepo _apiRepo = ApiRepo();
  final isLoading = false.obs;

  Future<CommonResponseModel> _updateClinicalInternal(String payload) async {
    return _apiRepo.updateClinicalPrescription(payload);
  }

  Future<CommonResponseModel> _updatePatientInternal(String payload) async {
    return _apiRepo.updatePatientPrescription(payload);
  }

  Future<(bool success, String message)> updateClinicalPrescription({
    required String id,
    required String title,
  }) async {
    isLoading.value = true;
    try {
      final payload = jsonEncode({'id': id, 'title': title});

      final response = await _updateClinicalInternal(payload);
      final success = response.status == 'success';
      final message = response.message ?? '';

      if (success) {
        if (Get.isRegistered<MoreController>()) {
          await Get.find<MoreController>().fetchClinicalResults();
        }
      }

      return (success, message.isNotEmpty ? message : '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<(bool success, String message)> updatePatientPrescription({
    required String id,
    required String title,
  }) async {
    isLoading.value = true;
    try {
      final payload = jsonEncode({'id': id, 'title': title});

      final response = await _updatePatientInternal(payload);
      final success = response.status == 'success';
      final message = response.message ?? '';

      if (success) {
        if (Get.isRegistered<MoreController>()) {
          await Get.find<MoreController>().fetchPrescriptions(remoteOnly: true);
        }
      }

      return (success, message.isNotEmpty ? message : '');
    } finally {
      isLoading.value = false;
    }
  }
}
