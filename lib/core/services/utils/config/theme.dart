import 'package:eye_buddy/core/services/utils/config/app_colors.dart';
import 'package:flutter/material.dart';

class CustomTheme {
  static ThemeData lightTheme = ThemeData.light().copyWith(
    visualDensity: VisualDensity.compact,
    primaryColor: AppColors.color008541,
    scaffoldBackgroundColor: AppColors.appBackground,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.color008541,
      onPrimary: AppColors.colorFBFBFB,
      secondary: AppColors.colorFBFBFB,
      onSecondary: AppColors.color008541,
      error: AppColors.colorF14F4A,
      onError: AppColors.colorFBFBFB,
      background: AppColors.colorFBFBFB,
      onBackground: AppColors.color008541,
      surface: AppColors.colorFBFBFB,
      onSurface: AppColors.color008541,
    ),
    appBarTheme: const AppBarTheme(
      color: AppColors.appBackground,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
    ),
  );
}
