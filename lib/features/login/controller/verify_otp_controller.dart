// lib/features/login/controller/verify_otp_controller.dart
import 'dart:async';
import 'dart:developer';
import 'package:eye_buddy/core/services/api/data/api_data.dart';
import 'package:get/get.dart';
import 'package:eye_buddy/core/services/api/repo/api_repo.dart';
import 'package:eye_buddy/features/global_widgets/toast.dart';
import 'package:eye_buddy/l10n/app_localizations.dart';
import 'package:eye_buddy/core/services/utils/services/navigator_services.dart';
import 'package:eye_buddy/features/bootom_navbar_screen/views/bottom_navbar_screen.dart';
import 'package:eye_buddy/features/login/view/save_user_data_screen.dart';
import 'package:eye_buddy/features/login/controller/profile_controller.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:eye_buddy/core/services/utils/keys/token_keys.dart';
import 'package:eye_buddy/core/services/utils/services/notification_permission_guard.dart';

class VerifyOtpController extends GetxController {
  final String phoneNumber;
  final String traceId;
  final bool isForChangePhoneNumber;

  VerifyOtpController({
    required this.phoneNumber,
    required this.traceId,
    this.isForChangePhoneNumber = false,
  });

  final ApiRepo _apiRepo = ApiRepo();

  RxBool isLoading = false.obs;
  RxInt secondsLeft = 0.obs;
  RxBool canResend = false.obs;
  RxBool isResending = false.obs;
  RxInt resendCount = 0.obs;
  final int maxResends = 3;
  Timer? _timer;
  final int _cooldownSeconds = 30;

  @override
  void onInit() {
    super.onInit();
    startTimer();
  }

  void startTimer() {
    secondsLeft.value = _cooldownSeconds;
    _recomputeCanResend();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsLeft.value > 0) {
        secondsLeft.value--;
        _recomputeCanResend();
      } else {
        timer.cancel();
      }
    });
  }

  void _recomputeCanResend() {
    final allowed =
        secondsLeft.value == 0 &&
        !isResending.value &&
        resendCount.value < maxResends;
    canResend.value = allowed;
  }

  Future<void> resendOtp() async {
    try {
      // Server needs traceId; block if missing.
      if (traceId.trim().isEmpty) {
        final ctx = Get.context;
        if (ctx != null) {
          showToast(message: "TraceId missing", context: ctx);
        }
        return;
      }

      // Enforce resend limit per session.
      if (resendCount.value >= maxResends) {
        final ctx = Get.context;
        if (ctx != null) {
          showToast(
            message: "Resend limit reached. Try later.",
            context: ctx,
          );
        }
        return;
      }

      // Enforce cooldown even if UI triggers resend.
      if (secondsLeft.value > 0) {
        final ctx = Get.context;
        if (ctx != null) {
          showToast(
            message: "Please wait ${secondsLeft.value}s to resend",
            context: ctx,
          );
        }
        return;
      }

      if (isResending.value) {
        return;
      }

      isResending.value = true;
      isLoading.value = true;
      await _apiRepo.resendOtp(traceId: traceId);
      resendCount.value++;
      startTimer();
      final ctx = Get.context;
      if (ctx != null) {
        showToast(message: AppLocalizations.of(ctx)!.otp_resent, context: ctx);
      }
    } catch (e) {
      log("Resend OTP error: $e");
      final ctx = Get.context;
      if (ctx != null) {
        showToast(
          message: AppLocalizations.of(ctx)!.failed_to_resend_otp,
          context: ctx,
        );
      }
    } finally {
      isLoading.value = false;
      isResending.value = false;
      _recomputeCanResend();
    }
  }

  Future<void> _requestNotificationPermissions() async {
    try {
      // Check current permission status
      final settings = await FirebaseMessaging.instance
          .getNotificationSettings();

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        log("Notification permissions already granted");
        return;
      }

      if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        log("Notification permissions are provisional");
        return;
      }

      // Request permission
      final result = await NotificationPermissionGuard.requestPermission();

      if (defaultTargetPlatform == TargetPlatform.iOS) {
        try {
          await FlutterCallkitIncoming.requestNotificationPermission({
            'title': 'Notifications required',
            'rationaleMessagePermission':
                'Enable notifications to receive incoming calls on the lock screen.',
            'postNotificationMessageRequired':
                'Please enable notifications in Settings to receive incoming calls.',
          });
        } catch (e) {
          log("CallKit notification permission request failed: $e");
        }
      }

      if (result.authorizationStatus == AuthorizationStatus.authorized) {
        log("Notification permissions granted after request");
      } else if (result.authorizationStatus ==
          AuthorizationStatus.provisional) {
        log("Notification permissions granted provisionally");
      } else {
        log("Notification permissions denied");
        // Show user a message to enable in settings
        showToast(
          message: "Please enable notifications in settings to receive calls",
          context: Get.context!,
        );
      }

      if (kDebugMode) {
        log("Notification permission status: ${result.authorizationStatus}");
      }
    } catch (e) {
      log("Error requesting notification permissions: $e");
    }
  }

  Future<void> verifyOtp({required String otpCode}) async {
    try {
      if (traceId.trim().isEmpty) {
        final ctx = Get.context;
        if (ctx != null) {
          showToast(message: "TraceId missing", context: ctx);
        }
        return;
      }

      // Ensure FCM token is available before sending to backend
      try {
        final fcmToken = await FirebaseMessaging.instance.getToken();
        if (fcmToken != null && fcmToken.trim().isNotEmpty) {
          pushNotificationTokenKey = fcmToken;
          userDeviceToken = fcmToken;
          print("FCM TOKEN before OTP verify: $fcmToken");
        } else {
          print("FCM TOKEN before OTP verify: empty");
        }
      } catch (e) {
        log("FCM token fetch failed during OTP verify: $e");
      }

      // Prevent multiple simultaneous verifications
      if (isLoading.value) {
        return;
      }

      final trimmedOtp = otpCode.trim();

      if (trimmedOtp.isEmpty) {
        final ctx = Get.context;
        if (ctx != null) {
          showToast(
            message: AppLocalizations.of(ctx)!.please_enter_otp,
            context: ctx,
          );
        }
        return;
      }

      if (trimmedOtp.length != 6) {
        final ctx = Get.context;
        if (ctx != null) {
          showToast(
            message: AppLocalizations.of(
              ctx,
            )!.please_enter_complete_6_digit_otp,
            context: ctx,
          );
        }
        return;
      }

      isLoading.value = true;

      final response = await _apiRepo.verifyOtp(
        traceId: traceId,
        otpCode: trimmedOtp,
        isForChangePhoneNumber: isForChangePhoneNumber,
      );

      // ✅ Access object properties safely
      final isSuccess = (response.status ?? '').toLowerCase() == 'success';
      final token = response.data?.token;
      final hasToken = token != null && token.trim().isNotEmpty;

      // For change-phone verification, backend may not always return a token.
      // BLoC flow treats success as success and moves forward.
      if (isSuccess && (hasToken || isForChangePhoneNumber)) {
        // Save token only when backend provides one
        if (hasToken) {
          await saveToken(token: token!);
        }

        // Request notification permissions after login
        await _requestNotificationPermissions();

        if (isForChangePhoneNumber) {
          try {
            final profileCtrl = Get.isRegistered<ProfileController>()
                ? Get.find<ProfileController>()
                : Get.put(ProfileController());
            await profileCtrl.getProfileData();
          } catch (_) {
            // ignore
          }
        }

        showToast(
          message: isForChangePhoneNumber
              ? AppLocalizations.of(
                  Get.context!,
                )!.phone_number_successfully_changed
              : response.message ??
                    AppLocalizations.of(Get.context!)!.login_successful,
          context: Get.context!,
        );

        // Navigate based on new user or not - BLoC version logic
        if (Get.context != null) {
          final isNewUser = isForChangePhoneNumber
              ? false
              : (response.data?.isNewUser ?? false);

          if (isNewUser) {
            // New user - go to SaveUserDataScreen
            NavigatorServices().toPushAndRemoveUntil(
              context: Get.context!,
              widget: SaveUserDataScreen(),
            );
          } else {
            // Existing user - go to BottomNavBarScreen (home page) - same as BLoC version
            NavigatorServices().toPushAndRemoveUntil(
              context: Get.context!,
              widget: const BottomNavBarScreen(),
            );
          }
        }
      } else {
        // Show the actual error message from server
        String errorMessage = AppLocalizations.of(
          Get.context!,
        )!.invalid_otp_please_try_again;
        if (response.message != null && response.message!.isNotEmpty) {
          errorMessage = response.message!;
        } else if (response.status == "unknown_error") {
          errorMessage = AppLocalizations.of(
            Get.context!,
          )!.server_error_occurred_please_try_again_later;
        }
        log(
          "OTP verification failed: Status=${response.status}, Message=$errorMessage",
        );
        showToast(message: errorMessage, context: Get.context!);
      }
    } catch (e) {
      log("OTP verification error: $e");
      // Show more specific error message
      String errorMessage = AppLocalizations.of(
        Get.context!,
      )!.something_went_wrong_please_try_again;
      if (e.toString().contains("No internet")) {
        errorMessage = AppLocalizations.of(
          Get.context!,
        )!.no_internet_connection_please_check_your_network;
      } else if (e.toString().contains("timeout")) {
        errorMessage = AppLocalizations.of(
          Get.context!,
        )!.request_timeout_please_try_again;
      }
      showToast(message: errorMessage, context: Get.context!);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
