// import 'dart:math';
// import 'package:display_metrics/display_metrics.dart';
// import 'package:flutter/material.dart';

// class DeviceUtils {
//   static double getDevicePPI(BuildContext context) {
//     final Size screenSize = MediaQuery.of(context).size;
//     final double pixelRatio = MediaQuery.of(context).devicePixelRatio;

//     // Get the screen width and height in pixels
//     final double screenWidthPx = screenSize.width * pixelRatio;
//     final double screenHeightPx = screenSize.height * pixelRatio;

//     print("Screen Width: $screenWidthPx");
//     print("Screen Height: $screenHeightPx");
//     print("Screen Size: $screenSize");

//     // Get diagonal resolution in pixels
//     final double diagonalResolution =
//         sqrt(pow(screenWidthPx, 2) + pow(screenHeightPx, 2));

//     print("Diagnosis Resolution: $diagonalResolution");

//     final metrics = DisplayMetrics.of(context);

//     // Get the screen size in inches dynamically
//     double screenSizeInInches = metrics.diagonal;

//     print("Screen Sizes Inches: ${metrics.diagonal}");

//     // Calculate PPI
//     return diagonalResolution / screenSizeInInches;
//   }

//   static double mmToPixels(double mm, double ppi) {
//     return (ppi / 25.4) * mm;
//   }
// }

import 'package:flutter/widgets.dart';
import 'package:display_metrics/display_metrics.dart';
import 'package:flutter/foundation.dart';

class DeviceUtils {
  /// Convert millimeters to pixels
  static double mmToPixels(double mm, double ppi) {
    if (ppi <= 0) {
      if (kDebugMode) {
        debugPrint('[DeviceUtils] Invalid PPI ($ppi). Using fallback 160.');
      }
      return mm * 160 / 25.4;
    }
    return mm * ppi / 25.4;
  }

  /// Safe PPI getter (NO CRASH GUARANTEE)
  static double getDevicePPI(BuildContext context) {
    try {
      final metrics = DisplayMetrics.of(context);

      if (metrics == null) {
        if (kDebugMode) {
          debugPrint('[DeviceUtils] DisplayMetrics.of(context) == null');
        }
        return 160.0;
      }

      if (metrics.displays.isEmpty) {
        if (kDebugMode) {
          debugPrint('[DeviceUtils] DisplayMetrics.displays is EMPTY');
        }
        return 160.0;
      }

      final display = metrics.displays.first;

      if (kDebugMode) {
        debugPrint('[DeviceUtils] Display detected → ppi=${display.ppi}');
      }

      if (display.ppi > 0) {
        return display.ppi;
      } else {
        if (kDebugMode) {
          debugPrint('[DeviceUtils] Display PPI <= 0 → fallback 160');
        }
      }
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[DeviceUtils] Exception in getDevicePPI');
        debugPrint(e.toString());
        debugPrint(st.toString());
      }
    }

    if (kDebugMode) {
      debugPrint('[DeviceUtils] Final fallback PPI = 160');
    }

    return 160.0;
  }
}

