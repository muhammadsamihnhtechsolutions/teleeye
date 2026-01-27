import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eye_buddy/features/eye_test/controller/eye_test_controller.dart';
import 'package:eye_buddy/features/eye_test/model/eye_test_model.dart';
import 'package:eye_buddy/features/eye_test/widgets/eye_test_list_item.dart';
import 'package:eye_buddy/features/eye_test/view/near_vision_left_screen.dart';
import 'package:eye_buddy/features/eye_test/view/near_vision_left_instruction_screen.dart';
import 'package:eye_buddy/features/eye_test/view/color_vision_left_screen.dart';
import 'package:eye_buddy/features/eye_test/view/amd_left_screen.dart';
import 'package:eye_buddy/features/eye_test/view/visual_acuity_instructions_screen.dart';
import 'package:eye_buddy/core/services/utils/config/app_colors.dart';
import 'package:eye_buddy/core/services/utils/size_config.dart';
import 'package:eye_buddy/features/global_widgets/common_size_box.dart';
import 'package:eye_buddy/features/global_widgets/inter_text.dart';
import 'package:eye_buddy/features/global_widgets/common_app_bar.dart';
import 'package:eye_buddy/l10n/app_localizations.dart';
import 'package:eye_buddy/features/bootom_navbar_screen/views/bottom_navbar_screen.dart';

class EyeTestListScreen extends StatelessWidget {
  const EyeTestListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final localLanguage = AppLocalizations.of(context)!;

    Future<bool> handleBack() async {
      Get.offAll(() => const BottomNavBarScreen());
      return false;
    }

    return WillPopScope(
      onWillPop: handleBack,
      child: Scaffold(
        backgroundColor: AppColors.appBackground,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          leading: IconButton(
            onPressed: () {
              handleBack();
            },
            icon: const Icon(Icons.arrow_back, color: AppColors.black),
          ),
          title: InterText(title: localLanguage.eye_test),
        ),
        body: ListView.builder(
          itemCount: EyeTestListData.eyeTestList.length,
          padding: EdgeInsets.only(
            bottom: getProportionateScreenHeight(50),
            top: getProportionateScreenHeight(10),
          ),
          physics: const BouncingScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            final eyeTest = EyeTestListData.eyeTestList[index];
            return EyeTestListItem(
              iconName: eyeTest.iconName,
              title: eyeTest.title,
              shortDetails: eyeTest.shortDetails,
              callBackFunction: () {
                final EyeTestController eyeTestController =
                    Get.isRegistered<EyeTestController>()
                    ? Get.find<EyeTestController>()
                    : Get.put(EyeTestController());

                switch (eyeTest.type) {
                  case EyeTestType.visualAcuity:
                    eyeTestController.resetScore();
                    Get.to(() => const VisualAcuityInstructionsScreen());
                    break;
                  case EyeTestType.nearVision:
                    eyeTestController.resetNearVision();
                    Get.to(() => const NearVisionLeftInstructionScreen());
                    break;
                  case EyeTestType.colorVision:
                    eyeTestController.resetColorVision();
                    Get.to(() => const ColorVisionLeftScreen());
                    break;
                  case EyeTestType.amd:
                    eyeTestController.resetAmd();
                    Get.to(() => const AmdLeftScreen());
                    break;
                }
              },
            );
          },
        ),
      ),
    );
  }
}

// Visual Acuity Select Eye Screen
class VisualAcuitySelectEyeScreen extends StatelessWidget {
  const VisualAcuitySelectEyeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final EyeTestController eyeTestController =
        Get.isRegistered<EyeTestController>()
        ? Get.find<EyeTestController>()
        : Get.put(EyeTestController());

    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: CommonAppBar(
        title: 'Select Eye',
        elevation: 0,
        icon: Icons.arrow_back,
        finishScreen: true,
        isTitleCenter: false,
        context: context,
      ),
      body: Padding(
        padding: EdgeInsets.all(getProportionateScreenWidth(20)),
        child: Column(
          children: [
            // Left Eye Selection
            Expanded(
              child: Container(
                margin: EdgeInsets.only(
                  bottom: getProportionateScreenWidth(16),
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: eyeTestController.isLeftEye.value
                        ? AppColors.primaryColor
                        : AppColors.colorEDEDED,
                    width: 2,
                  ),
                ),
                child: InkWell(
                  onTap: () {
                    eyeTestController.updateCurrentEye(true);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: EdgeInsets.all(getProportionateScreenWidth(20)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.remove_red_eye,
                          size: 64,
                          color: eyeTestController.isLeftEye.value
                              ? AppColors.primaryColor
                              : AppColors.color888E9D,
                        ),
                        CommonSizeBox(height: getProportionateScreenWidth(16)),
                        InterText(
                          title: 'Left Eye',
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          textColor: eyeTestController.isLeftEye.value
                              ? AppColors.primaryColor
                              : AppColors.black,
                        ),
                        CommonSizeBox(height: getProportionateScreenWidth(8)),
                        InterText(
                          title:
                              'Score: ${eyeTestController.leftEyeScore.value}',
                          fontSize: 16,
                          textColor: AppColors.color888E9D,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Right Eye Selection
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: !eyeTestController.isLeftEye.value
                        ? AppColors.primaryColor
                        : AppColors.colorEDEDED,
                    width: 2,
                  ),
                ),
                child: InkWell(
                  onTap: () {
                    eyeTestController.updateCurrentEye(false);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: EdgeInsets.all(getProportionateScreenWidth(20)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.remove_red_eye,
                          size: 64,
                          color: !eyeTestController.isLeftEye.value
                              ? AppColors.primaryColor
                              : AppColors.color888E9D,
                        ),
                        CommonSizeBox(height: getProportionateScreenWidth(16)),
                        InterText(
                          title: 'Right Eye',
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          textColor: !eyeTestController.isLeftEye.value
                              ? AppColors.primaryColor
                              : AppColors.black,
                        ),
                        CommonSizeBox(height: getProportionateScreenWidth(8)),
                        InterText(
                          title:
                              'Score: ${eyeTestController.rightEyeScore.value}',
                          fontSize: 16,
                          textColor: AppColors.color888E9D,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            CommonSizeBox(height: getProportionateScreenWidth(16)),

            // Start Test Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.to(() => const VisualAcuityInstructionsScreen());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: AppColors.white,
                  padding: EdgeInsets.symmetric(
                    vertical: getProportionateScreenWidth(16),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: InterText(
                  title: 'Start Test',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  textColor: AppColors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
