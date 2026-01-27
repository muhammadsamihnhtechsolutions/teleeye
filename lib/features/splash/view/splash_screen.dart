// import 'package:eye_buddy/core/services/api/data/api_data.dart';
// import 'package:eye_buddy/core/services/utils/assets/app_assets.dart';
// import 'package:eye_buddy/core/services/utils/config/app_colors.dart';
// import 'package:eye_buddy/core/services/utils/keys/shared_pref_keys.dart';
// import 'package:eye_buddy/features/agora_call/view/agora_call_room_screen.dart';
// import 'package:eye_buddy/features/bootom_navbar_screen/views/bottom_navbar_screen.dart';
// import 'package:eye_buddy/features/global_widgets/inter_text.dart';
// import 'package:eye_buddy/features/login/view/login_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:eye_buddy/features/agora_call/controller/agora_singleton.dart';
// import 'package:eye_buddy/features/agora_call/controller/call_controller.dart';

// import '../../../l10n/app_localizations.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     _start();
//   }

//   Future<void> _start() async {
//     await Future<void>.delayed(const Duration(seconds: 2));

//     final token = await getToken();
//     final prefs = await SharedPreferences.getInstance();

//     // If a call is already connecting/in-call, don't override the UI by navigating
//     // away from the call screen (common when accepting from lock screen while app launches).
//     try {
//       if (Get.isRegistered<CallController>() &&
//           CallController.to.isCallUiVisible.value) {
//         return;
//       }
//     } catch (_) {
//       // ignore
//     }
//     try {
//       if (Get.isRegistered<AgoraSingleton>()) {
//         final agora = AgoraSingleton.to;
//         if (agora.isInCall.value || agora.isConnecting.value) {
//           return;
//         }
//       }
//     } catch (_) {
//       // ignore
//     }

//     bool? isFirstBoot = prefs.getBool('isFirstBoot');
//     if (isFirstBoot == null) {
//       await prefs.setBool('isFirstBoot', false);
//     }

//     if (!mounted) return;

//     // Match bloc-code navigation rules:
//     // - First boot -> IntroFlow (not present in GetX features folder), fallback to Login.
//     // - Logged in -> BottomNavBar, then if call accepted flag -> open call screen.
//     // - Otherwise -> Login.
//     if (isFirstBoot == null) {
//       Get.offAll(() => LoginScreen(showBackButton: false));
//       return;
//     }

//     if (token != null && token.isNotEmpty) {
//       await _handleAcceptedCallOrHome(prefs);
//       return;
//     }

//     Get.offAll(() => LoginScreen(showBackButton: false));
//   }

//   Future<void> _handleAcceptedCallOrHome(SharedPreferences prefs) async {
//     final bool accepted = prefs.getBool(isCallAccepted) ?? false;
//     if (accepted) {
//       // If call UI is already visible, do not navigate.
//       try {
//         if (Get.isRegistered<CallController>() &&
//             CallController.to.isCallUiVisible.value) {
//           return;
//         }
//       } catch (_) {
//         // ignore
//       }

//       final name = prefs.getString(agoraDocName) ?? '';
//       final image = prefs.getString(agoraDocPhoto) ?? '';
//       final appointmentId = prefs.getString(agoraChannelId) ?? '';

//       if (appointmentId.isNotEmpty) {
//         Get.offAll(
//           () => AgoraCallScreen(
//             name: name,
//             image: image,
//             appointmentId: appointmentId,
//           ),
//         );
//         return;
//       }
//     }

//     // Default: go to home
//     Get.offAll(() => const BottomNavBarScreen());
//   }

//   @override
//   Widget build(BuildContext context) {
//     final l10n = AppLocalizations.of(context)!;

//     return Scaffold(
//       backgroundColor: AppColors.color008541,
//       body: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 25),
//         height: MediaQuery.of(context).size.height,
//         width: MediaQuery.of(context).size.width,
//         child: Column(
//           children: [
//             Expanded(
//               child: Center(
//                 child: Image.asset(AppAssets.splashLogo, fit: BoxFit.contain),
//               ),
//             ),
//             SizedBox(
//               height: kToolbarHeight * 1.5,
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const SizedBox(
//                     height: 14,
//                     width: 14,
//                     child: CircularProgressIndicator(
//                       color: AppColors.colorFFFFFF,
//                       strokeWidth: 1.5,
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   InterText(
//                     title: l10n.loading,
//                     textColor: AppColors.colorFFFFFF,
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }



import 'package:eye_buddy/core/services/api/data/api_data.dart';
import 'package:eye_buddy/core/services/utils/assets/app_assets.dart';
import 'package:eye_buddy/core/services/utils/config/app_colors.dart';
import 'package:eye_buddy/features/bootom_navbar_screen/views/bottom_navbar_screen.dart';
import 'package:eye_buddy/features/global_widgets/inter_text.dart';
import 'package:eye_buddy/features/login/view/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../l10n/app_localizations.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    await Future<void>.delayed(const Duration(seconds: 2));

    final token = await getToken();
    final prefs = await SharedPreferences.getInstance();

    bool? isFirstBoot = prefs.getBool('isFirstBoot');
    if (isFirstBoot == null) {
      await prefs.setBool('isFirstBoot', false);
    }

    if (!mounted) return;

    /// First boot → Login
    if (isFirstBoot == null) {
      Get.offAll(() => LoginScreen(showBackButton: false));
      return;
    }

    /// Logged in → Home
    if (token != null && token.isNotEmpty) {
      Get.offAll(() => const BottomNavBarScreen());
      return;
    }

    /// Default → Login
    Get.offAll(() => LoginScreen(showBackButton: false));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.color008541,
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Image.asset(
                  AppAssets.splashLogo,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            SizedBox(
              height: kToolbarHeight * 1.5,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 14,
                    width: 14,
                    child: CircularProgressIndicator(
                      color: AppColors.colorFFFFFF,
                      strokeWidth: 1.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  InterText(
                    title: l10n.loading,
                    textColor: AppColors.colorFFFFFF,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
