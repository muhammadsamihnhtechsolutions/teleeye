import 'dart:async';
import 'package:get/get.dart';

class TimerController extends GetxController {
  Timer? _timer;
  var countdown = 5.obs;

  void startStopwatch() {
    resetStopwatch();
    if (_timer != null && _timer!.isActive) {
      return;
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (countdown.value > 0) {
        countdown.value--;
      } else {
        _timer?.cancel();
      }
    });
  }

  void resetStopwatch() {
    _timer?.cancel();
    countdown.value = 5;
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
