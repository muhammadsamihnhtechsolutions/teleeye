import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eye_buddy/core/services/api/repo/api_repo.dart';
import 'package:eye_buddy/core/services/api/model/loginModels.dart';
import 'package:eye_buddy/core/services/api/data/api_data.dart';
import '../../global_widgets/toast.dart';

class LoginController extends GetxController {
  final ApiRepo _apiRepo = ApiRepo();

  RxBool isLoading = false.obs;
  Rx<LoginApiResponseDataModel?> loginData = Rx<LoginApiResponseDataModel?>(
    null,
  );

  /// Reset state after navigating to OTP screen
  void resetState() {
    loginData.value = null;
    isLoading.value = false;
  }

  Future<void> loginUser({
    required String phone,
    required String dialCode,
    required BuildContext context,
  }) async {
    try {
      isLoading.value = true;

      final response = await _apiRepo.loginUser(
        phone: phone,
        dialCode: dialCode,
      );

      if (response.status == "success" && response.data != null) {
        loginData.value = response.data;
      } else {
        showToast(
          message: response.message ?? "Something went wrong",
          context: context,
        );
      }
    } catch (err) {
      showToast(message: "An error occurred", context: context);
    } finally {
      isLoading.value = false;
    }
  }
}
