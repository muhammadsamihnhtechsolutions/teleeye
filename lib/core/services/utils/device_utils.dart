import 'dart:math';
import 'package:display_metrics/display_metrics.dart';
import 'package:flutter/material.dart';

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
    final double diagonalResolution =
        sqrt(pow(screenWidthPx, 2) + pow(screenHeightPx, 2));

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
