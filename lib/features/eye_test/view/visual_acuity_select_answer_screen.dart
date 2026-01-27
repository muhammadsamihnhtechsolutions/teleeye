import 'package:eye_buddy/core/services/utils/assets/app_assets.dart';
import 'package:eye_buddy/core/services/utils/config/app_colors.dart';
import 'package:eye_buddy/core/services/utils/size_config.dart';
import 'package:eye_buddy/features/eye_test/model/visual_acuity_test_model.dart';
import 'package:eye_buddy/features/eye_test/view/visual_acuity_test_failed_screen.dart';
import 'package:eye_buddy/features/eye_test/view/visual_acuity_instructions_screen.dart';
import 'package:eye_buddy/features/eye_test/view/visual_acuity_test_screen.dart';
import 'package:eye_buddy/features/global_widgets/inter_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class VisualAcuitySelectAnswerScreen extends StatelessWidget {
  const VisualAcuitySelectAnswerScreen({super.key, required this.currentPage});

  final int currentPage;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appBackground,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Get.offAll(() => const VisualAcuityInstructionsScreen());
          },
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
        ),
      ),
      backgroundColor: AppColors.appBackground,
      body: Container(
        height: SizeConfig.screenHeight,
        width: SizeConfig.screenWidth,
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            const Row(
              children: [
                InterText(title: 'Which direction was the letter facing?'),
              ],
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _AnswerTile(currentPage: currentPage, numberOfTurns: 0),
                      const SizedBox(width: 10),
                      _AnswerTile(currentPage: currentPage, numberOfTurns: 1),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _AnswerTile(currentPage: currentPage, numberOfTurns: 2),
                      const SizedBox(width: 10),
                      _AnswerTile(currentPage: currentPage, numberOfTurns: 3),
                    ],
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

class _AnswerTile extends StatelessWidget {
  const _AnswerTile({required this.currentPage, required this.numberOfTurns});

  final int currentPage;
  final int numberOfTurns;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final isCorrect =
            visualAcuityEyeTestList[currentPage].numberOfturns == numberOfTurns;

        if (isCorrect) {
          if (currentPage != 6) {
            Get.off(() => VisualAcuityTestScreen(currentPage: currentPage + 1));
          } else {
            Get.off(
              () => VisualAcuityTestFailedScreen(currentPage: currentPage),
            );
          }
        } else {
          Get.off(() => VisualAcuityTestFailedScreen(currentPage: currentPage));
        }
      },
      child: Material(
        elevation: 60,
        shadowColor: Colors.black.withOpacity(.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        child: Container(
          height: SizeConfig.screenWidth / 2.5,
          width: SizeConfig.screenWidth / 2.5,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: Colors.white,
          ),
          child: Align(
            child: RotatedBox(
              quarterTurns: numberOfTurns,
              child: SvgPicture.asset(AppAssets.visualAcuityTestE),
            ),
          ),
        ),
      ),
    );
  }
}
