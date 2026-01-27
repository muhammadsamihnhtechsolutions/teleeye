import 'package:eye_buddy/core/services/utils/config/app_colors.dart';
import 'package:flutter/material.dart';

class InterText extends StatelessWidget {
  const InterText({
    super.key,
    required this.title,
    this.textColor = AppColors.color001B0D,
    this.fontWeight = FontWeight.normal,
    this.fontSize = 16,
    this.textAlign = TextAlign.start,
    this.maxLines = 10,
  });

  final String title;
  final Color textColor;
  final FontWeight fontWeight;
  final double fontSize;
  final TextAlign textAlign;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontFamily: 'Inter',
        color: textColor,
        fontWeight: fontWeight,
        overflow: TextOverflow.ellipsis,
        fontSize: fontSize,
      ),
      maxLines: maxLines,
      textAlign: textAlign,
    );
  }
}

TextStyle interTextStyle = const TextStyle(
  fontFamily: 'Inter',
  color: Colors.black,
  fontWeight: FontWeight.w500,
  fontSize: 14,
);
