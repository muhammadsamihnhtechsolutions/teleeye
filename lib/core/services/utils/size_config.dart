import 'package:flutter/material.dart';

// class SizeConfig {
//   static late MediaQueryData _mediaQueryData;
//   static late double screenWidth;
//   static late double screenHeight;
//   static double? defaultSize;
//   static Orientation? orientation;
//
//   void init(BuildContext context) {
//     _mediaQueryData = MediaQuery.of(context);
//     screenWidth = _mediaQueryData.size.width;
//     screenHeight = _mediaQueryData.size.height;
//     orientation = _mediaQueryData.orientation;
//   }
// }
//
// // Get the proportionate height as per screen size
// double getProportionateScreenHeight(double inputHeight) {
//   final screenHeight = SizeConfig.screenHeight;
//   // 812 is the layout height that designer use
//   return (inputHeight / screenHeight) * screenHeight;
// }
//
// // Get the proportionate height as per screen size
// double getProportionateScreenWidth(double inputWidth) {
//   final screenWidth = SizeConfig.screenWidth;
//   // 375 is the layout width that designer use
//   return (inputWidth / screenWidth) * screenWidth;
// }

class SizeConfig {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static double? defaultSize;
  static Orientation? orientation;
  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    orientation = _mediaQueryData.orientation;
  }
}

// Get the proportionate height as per screen size
double getProportionateScreenHeight(double inputHeight) {
  final screenHeight = SizeConfig.screenHeight;
  // 812 is the layout height that designer use
  if (screenHeight <= 0) {
    return inputHeight; // Return original if not initialized
  }
  return (inputHeight / 812.0) * screenHeight;
}

// Get the proportionate width as per screen size
double getProportionateScreenWidth(double inputWidth) {
  final screenWidth = SizeConfig.screenWidth;
  // 375 is the layout width that designer use
  if (screenWidth <= 0) {
    return inputWidth; // Return original if not initialized
  }
  return (inputWidth / 375.0) * screenWidth;
}
