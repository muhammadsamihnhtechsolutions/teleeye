import 'dart:developer';

//import 'package:eye_buddy/app/utils/config/app_colors.dart';
//import 'package:eye_buddy/app/views/global_widgets/inter_text.dart';
import 'package:eye_buddy/core/services/utils/config/app_colors.dart';
//import 'package:eye_buddy/lib/features/global_widgets/inter_text.dart';
import 'package:eye_buddy/features/global_widgets/inter_text.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class LoginOtpPinCodeWidget extends StatelessWidget {
  const LoginOtpPinCodeWidget({super.key, required this.otpCodeController});

  final TextEditingController otpCodeController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: PinCodeTextField(
        appContext: context,
        length: 6,
        keyboardType: TextInputType.number,
        animationType: AnimationType.fade,
        cursorColor: AppColors.primaryColor,
        pinTheme: PinTheme(
          shape: PinCodeFieldShape.box,
          borderRadius: BorderRadius.circular(10),
          borderWidth: 2,
          fieldHeight: 50,
          fieldWidth: 40,
          activeColor: AppColors.primaryColor,
          selectedColor: AppColors.primaryColor,
          inactiveColor: AppColors.primaryColor,
          disabledColor: AppColors.primaryColor,
          activeFillColor: Colors.transparent,
          selectedFillColor: Colors.transparent,
          inactiveFillColor: Colors.transparent,
          errorBorderColor: AppColors.primaryColor,
        ),
        animationDuration: const Duration(milliseconds: 300),
        enableActiveFill: true,
        textStyle: interTextStyle.copyWith(fontSize: 22),
        controller: otpCodeController,
        onCompleted: (v) {
          // OTP completed - but do NOT auto-verify
          // User must click Verify button manually
          log('OTP entered: $v');
        },
        onChanged: (value) {
          // Just log the change, don't auto-verify
          log('OTP changed: $value');
        },
        beforeTextPaste: (text) {
          print('Allowing to paste $text');
          //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
          //but you can show anything you want here, like your pop up saying wrong paste format or etc
          return true;
        },
      ),
    );
  }
}
