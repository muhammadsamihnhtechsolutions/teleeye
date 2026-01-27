import 'package:eye_buddy/core/services/utils/assets/app_assets.dart';
import 'package:eye_buddy/core/services/utils/config/app_colors.dart';
import 'package:eye_buddy/core/services/utils/dimentions.dart';
import 'package:eye_buddy/features/global_widgets/inter_text.dart';
import 'package:eye_buddy/features/more/view/live_support_screen.dart';
import 'package:eye_buddy/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

// import '../../../../../l10n/app_localizations.dart'; // File not found

// import '../views/live_support/view/live_support_screen.dart'; // File not found

class SupportBottomNavBar extends StatelessWidget {
  const SupportBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        Container(
          height: 1.5,
          width: getWidth(context: context),
          color: AppColors.primaryColor,
        ),
        Container(
          height: kToolbarHeight * 1.5,
          color: AppColors.colorCCE7D9,
          child: Row(
            children: [
              const SizedBox(width: 20),

              // 📞 CALL
              Flexible(
                child: GestureDetector(
                  onTap: () => _makePhoneCall("09666787878"),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.phone_rounded,
                        color: AppColors.primaryColor,
                      ),
                      const SizedBox(width: 8),
                      FittedBox(
                        child: InterText(
                          title: '09666787878',
                          fontSize: 12,
                          textColor: AppColors.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 💬 LIVE CHAT
              Flexible(
                child: GestureDetector(
                  onTap: () {
                    Get.to(() => const LiveSupportScreen()); // GetX NAVIGATION
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(AppAssets.chatHelp),
                      const SizedBox(width: 8),
                      InterText(
                        title: l10n.live_chat,
                        fontSize: 12,
                        textColor: AppColors.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 20),
            ],
          ),
        ),
      ],
    );
  }
}

Future<void> _makePhoneCall(String phoneNumber) async {
  final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
  await launchUrl(launchUri);
}
