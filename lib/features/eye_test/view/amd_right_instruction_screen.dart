import 'package:eye_buddy/core/services/utils/assets/app_assets.dart';
import 'package:eye_buddy/core/services/utils/size_config.dart';
import 'package:eye_buddy/features/eye_test/view/amd_right_screen.dart';
import 'package:eye_buddy/features/global_widgets/common_app_bar.dart';
import 'package:eye_buddy/features/global_widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class AmdRightInstructionScreen extends StatelessWidget {
  const AmdRightInstructionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CommonAppBar(
        title: 'Instruction',
        elevation: 0,
        icon: Icons.arrow_back,
        finishScreen: true,
        isTitleCenter: false,
        context: context,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: SizeConfig.screenHeight * 0.15),
            Center(child: SvgPicture.asset(AppAssets.instruction_17)),
            SizedBox(height: SizeConfig.screenHeight * 0.3),
            const Center(
              child: Text(
                'Close your right eye',
                style: TextStyle(
                  color: Color(0xFF181D3D),
                  fontFamily: 'TTCommons',
                  fontSize: 26,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const Spacer(),
            CustomButton(
              title: 'Next',
              callBackFunction: () {
                Get.off(() => const AmdRightScreen());
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
