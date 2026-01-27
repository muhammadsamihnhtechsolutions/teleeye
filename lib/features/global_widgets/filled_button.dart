import 'package:eye_buddy/core/services/utils/config/app_colors.dart';
import 'package:eye_buddy/core/services/utils/dimentions.dart';
import 'package:eye_buddy/features/global_widgets/inter_text.dart';
import 'package:flutter/material.dart';

class GetFilledButton extends StatelessWidget {
  GetFilledButton({
    required this.title,
    required this.callBackFunction,
    super.key,
    this.transparentBackground = false,
    this.buttonHeight = 55,
    this.buttonColor = AppColors.color008541,
    this.buttonRadius = 8,
    this.buttonWidth,
    this.titleColor = Colors.white,
    this.isEnabled = true,
    this.disabledColor = AppColors.colorBBBBBB,
  });

  final String title;
  final Color titleColor;
  final VoidCallback callBackFunction;
  final bool transparentBackground;
  final double buttonHeight;
  final double? buttonWidth;
  final Color buttonColor;
  final double buttonRadius;
  final bool isEnabled;
  final Color disabledColor;

  @override
  Widget build(BuildContext context) {
    final resolvedWidth = buttonWidth ?? getWidth(context: context);
    return Align(
      child: GestureDetector(
        onTap: isEnabled
            ? () {
                callBackFunction();
              }
            : null,
        child: Container(
          height: buttonHeight,
          width: resolvedWidth,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(buttonRadius),
            color: transparentBackground
                ? Colors.transparent
                : (isEnabled ? buttonColor : disabledColor),
          ),
          alignment: Alignment.center,
          child: InterText(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            textColor: transparentBackground
                ? AppColors.color888E9D
                : (isEnabled ? titleColor : titleColor.withOpacity(.7)),
            title: title,
          ),
        ),
      ),
    );
  }
}
