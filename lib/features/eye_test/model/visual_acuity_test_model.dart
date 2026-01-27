import 'dart:math';
import 'package:flutter/material.dart';
import 'package:display_metrics/display_metrics.dart';

class VisualAcuityTestModel {
  String myRange;
  String averageHumansRange;
  int numberOfturns;
  String title;
  String message;
  double sizeInMM;

  VisualAcuityTestModel({
    required this.myRange,
    required this.averageHumansRange,
    required this.numberOfturns,
    required this.title,
    required this.sizeInMM,
    required this.message,
  });
}

List<VisualAcuityTestModel> visualAcuityEyeTestList = [
  VisualAcuityTestModel(
    myRange: "20",
    averageHumansRange: "200",
    numberOfturns: 0,
    sizeInMM: 12,
    title: "Severe Vision Loss",
    message:
        "The object you can see from 20 feet distance , a normal human eye can see it from 200 feet distance",
  ),
  VisualAcuityTestModel(
    myRange: "20",
    averageHumansRange: "120",
    numberOfturns: 3,
    sizeInMM: 9,
    title: "Moderate Vision Loss",
    message:
        "The object you can see from 20 feet distance , a normal human eye can see it from 120 feet distance",
  ),
  VisualAcuityTestModel(
    myRange: "20",
    averageHumansRange: "80",
    numberOfturns: 2,
    sizeInMM: 5,
    title: "Moderate Vision Loss",
    message:
        "The object you can see from 20 feet distance , a normal human eye can see it from 80 feet distance",
  ),
  VisualAcuityTestModel(
    myRange: "20",
    averageHumansRange: "60",
    numberOfturns: 1,
    sizeInMM: 4,
    title: "Moderate Vision Loss",
    message:
        "The object you can see from 20 feet distance , a normal human eye can see it from 60 feet distance",
  ),
  VisualAcuityTestModel(
    myRange: "20",
    averageHumansRange: "40",
    numberOfturns: 3,
    sizeInMM: 3,
    title: "Mild Vision Loss",
    message:
        "The object you can see from 20 feet distance , a normal human eye can see it from 40 feet distance",
  ),
  VisualAcuityTestModel(
    myRange: "20",
    averageHumansRange: "30",
    numberOfturns: 0,
    sizeInMM: 2.5,
    title: "Mild Vision Loss",
    message:
        "The object you can see from 20 feet distance , a normal human eye can see it from 30 feet distance",
  ),
  VisualAcuityTestModel(
    myRange: "20",
    averageHumansRange: "20",
    numberOfturns: 1,
    sizeInMM: 2,
    title: "Perfect Vision",
    message:
        "The object you can see from 20 feet distance , a normal human eye can see it from 20 feet distance",
  ),
];

class DeviceUtils {
  static double getDevicePPI(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double pixelRatio = MediaQuery.of(context).devicePixelRatio;

    // Get the screen width and height in pixels
    final double screenWidthPx = screenSize.width * pixelRatio;
    final double screenHeightPx = screenSize.height * pixelRatio;

    print("Screen Width: $screenWidthPx");
    print("Screen Height: $screenHeightPx");
    print("Screen Size: $screenSize");

    // Get diagonal resolution in pixels
    final double diagonalResolution = sqrt(
      pow(screenWidthPx, 2) + pow(screenHeightPx, 2),
    );

    print("Diagnosis Resolution: $diagonalResolution");

    final metrics = DisplayMetrics.of(context);

    // Get the screen size in inches dynamically
    double screenSizeInInches = metrics.diagonal;

    print("Screen Sizes Inches: ${metrics.diagonal}");

    // Calculate PPI
    return diagonalResolution / screenSizeInInches;
  }

  static double mmToPixels(double mm, double ppi) {
    return (ppi / 25.4) * mm;
  }
}
