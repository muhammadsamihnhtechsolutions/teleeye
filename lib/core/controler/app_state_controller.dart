import 'package:get/get.dart';

class AppStateController extends GetxController {
  final isPickingImage = false.obs;
  final isPaymentVerificationInProgress = false.obs;

  void setPickingImage(bool value) {
    isPickingImage.value = value;
  }

  void setPaymentVerificationInProgress(bool value) {
    isPaymentVerificationInProgress.value = value;
  }
}
