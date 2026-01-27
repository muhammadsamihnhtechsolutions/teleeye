import 'package:eye_buddy/core/services/utils/config/app_colors.dart';
import 'package:eye_buddy/features/global_widgets/custom_button.dart';
import 'package:eye_buddy/features/global_widgets/inter_text.dart';
import 'package:eye_buddy/features/global_widgets/toast.dart';
import 'package:eye_buddy/features/login/controller/verify_otp_controller.dart';
import 'package:eye_buddy/features/login/view/widgets/login_otp_pin_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/svg.dart';

import '../../../l10n/app_localizations.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  final String traceId;
  final bool isForChangePhoneNumber;

  OtpScreen({
    required this.phoneNumber,
    required this.traceId,
    this.isForChangePhoneNumber = false,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  late VerifyOtpController controller;
  late TextEditingController otpCodeController;
  bool _isVerifying = false; // Prevent multiple verifications

  @override
  void initState() {
    super.initState();
    controller = Get.put(
      VerifyOtpController(
        phoneNumber: widget.phoneNumber,
        traceId: widget.traceId,
        isForChangePhoneNumber: widget.isForChangePhoneNumber,
      ),
    );
    otpCodeController = TextEditingController();
  }

  @override
  void dispose() {
    // Avoid disposing otpCodeController because PinCodeTextField may still
    // reference it briefly during widget teardown. We rely on screen disposal
    // to release it.
    if (Get.isRegistered<VerifyOtpController>()) {
      Get.delete<VerifyOtpController>();
    }
    super.dispose();
  }

  void _verifyOtp() {
    // Prevent multiple simultaneous verifications
    if (_isVerifying || controller.isLoading.value) {
      return;
    }

    final otpCode = otpCodeController.text.trim();

    if (otpCode.isEmpty) {
      showToast(
        message: AppLocalizations.of(context)!.please_enter_otp,
        context: context,
      );
      return;
    }

    if (otpCode.length != 6) {
      showToast(
        message: AppLocalizations.of(
          context,
        )!.please_enter_complete_6_digit_otp,
        context: context,
      );
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    controller
        .verifyOtp(otpCode: otpCode)
        .then((_) {
          setState(() {
            _isVerifying = false;
          });
        })
        .catchError((_) {
          setState(() {
            _isVerifying = false;
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: InterText(title: AppLocalizations.of(context)!.verify_it_s_you),
      ),
      backgroundColor: AppColors.appBackground,
      body: Obx(() {
        return Stack(
          children: [
            _buildUI(context),

            /// FULL SCREEN LOADER
            if (controller.isLoading.value)
              Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.white.withOpacity(0.8),
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildUI(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset("assets/svgs/otp_lock.svg"),
              const SizedBox(height: 20),

              InterText(
                title: AppLocalizations.of(
                  context,
                )!.an_SMS_with_OTP_has_been_sent_to,
                textColor: AppColors.color888E9D,
              ),

              const SizedBox(height: 10),

              InterText(
                title: widget.phoneNumber,
                textColor: AppColors.primaryColor,
                fontWeight: FontWeight.bold,
              ),

              const SizedBox(height: 25),

              /// OTP WIDGET - No auto-verification, only manual button click
              LoginOtpPinCodeWidget(otpCodeController: otpCodeController),

              const SizedBox(height: 15),

              /// RESEND OTP
              Obx(
                () => GestureDetector(
                  onTap: controller.canResend.value
                      ? () => controller.resendOtp()
                      : null,
                  child: InterText(
                    title: controller.secondsLeft.value > 0
                        ? "Resend OTP in ${controller.secondsLeft.value}s"
                        : AppLocalizations.of(context)!.resend_OTP,
                    textColor: controller.secondsLeft.value > 0
                        ? AppColors.color888E9D
                        : AppColors.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              /// VERIFY BUTTON - Only way to verify OTP
              CustomButton(
                title: AppLocalizations.of(context)!.verify,
                callBackFunction: _verifyOtp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
