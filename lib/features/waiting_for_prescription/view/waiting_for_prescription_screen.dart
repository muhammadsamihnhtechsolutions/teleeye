import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../../core/services/utils/assets/app_assets.dart';
import '../../../core/services/utils/config/app_colors.dart';
import '../../../core/services/utils/dimentions.dart';
import '../../../core/services/utils/size_config.dart';
import '../../../core/services/widgets/support_bottom_nav_bar.dart';
import '../../../features/global_widgets/inter_text.dart';
import '../../../l10n/app_localizations.dart';
import '../../bootom_navbar_screen/views/bottom_navbar_screen.dart';

class WaitingForPrescriptionScreen extends StatelessWidget {
  const WaitingForPrescriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final l10n = AppLocalizations.of(context)!;

    return WillPopScope(
      onWillPop: () async {
        Get.offAll(() => const BottomNavBarScreen());
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: Colors.black,
            onPressed: () => Get.offAll(() => const BottomNavBarScreen()),
          ),
          title: InterText(title: l10n.waiting_for_prescription),
        ),
        body: SizedBox(
          height: getHeight(context: context),
          width: getWidth(context: context),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 200,
                          child: LottieBuilder.asset(AppAssets.onlineDoctor),
                        ),
                        const SizedBox(height: 10),
                        InterText(
                          title: l10n.please_wait_doctor_will_send_prescription,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        InterText(
                          title: l10n
                              .you_can_leave_prescription_will_show_under_all_prescriptions,
                          fontSize: 14,
                          textColor: AppColors.color888E9D,
                          textAlign: TextAlign.justify,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () =>
                              Get.offAll(() => const BottomNavBarScreen()),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: InterText(
                            title: l10n.go_back,
                            textColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SupportBottomNavBar(),
            ],
          ),
        ),
      ),
    );
  }
}
