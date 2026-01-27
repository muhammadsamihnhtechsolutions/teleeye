import 'package:eye_buddy/core/services/utils/config/app_colors.dart';
import 'package:eye_buddy/core/services/utils/size_config.dart';
import 'package:eye_buddy/features/eye_test/controller/eye_test_controller.dart';
import 'package:eye_buddy/features/eye_test/model/visual_acuity_test_model.dart';
import 'package:eye_buddy/features/eye_test/view/near_vision_right_instruction_screen.dart';
import 'package:eye_buddy/features/eye_test/view/near_vision_result_screen.dart';
import 'package:eye_buddy/features/global_widgets/common_app_bar.dart';
import 'package:eye_buddy/features/global_widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NearVisionLeftScreen extends StatelessWidget {
  const NearVisionLeftScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    if (!Get.isRegistered<EyeTestController>()) {
      Get.put(EyeTestController());
    }
    final controller = Get.find<EyeTestController>();

    final ppi = DeviceUtils.getDevicePPI(context);
    const letterHeightMm = 0.582;
    final letterHeightPx = DeviceUtils.mmToPixels(letterHeightMm, ppi);

    return Scaffold(
      appBar: CommonAppBar(
        title: 'Near Vision',
        elevation: 0,
        icon: Icons.arrow_back,
        finishScreen: true,
        isTitleCenter: false,
        context: context,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: SizedBox(
                height: 220,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Being able to see well at any distance',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: letterHeightPx + 6,
                        wordSpacing: letterHeightPx,
                      ),
                    ),
                    Text(
                      'Being able to see well at any distance',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: letterHeightPx + 3,
                        wordSpacing: letterHeightPx,
                      ),
                    ),
                    Text(
                      'Being able to see well at any distance',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: letterHeightPx,
                        wordSpacing: letterHeightPx,
                      ),
                    ),
                    Text(
                      'Being able to see well at any distance',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: letterHeightPx - 3,
                        wordSpacing: letterHeightPx,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(30.0),
              child: Text(
                'Can you read all the 4 lines of text, including the smallest one?',
                style: TextStyle(
                  fontFamily: 'DemiBold',
                  color: Color(0xFF181D3D),
                  fontSize: 22,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
              child: SizedBox(
                height: 40,
                child: CustomButton(
                  title: 'Yes',
                  callBackFunction: () {
                    controller.incrementNearVisionLeft();
                    Get.to(() => const NearVisionRightInstructionScreen());
                  },
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: SizedBox(
                height: 40,
                child: CustomButton(
                  title: 'No',
                  backGroundColor: AppColors.color888E9D,
                  callBackFunction: () {
                    // Move to right eye even if left failed
                    Get.to(() => const NearVisionRightInstructionScreen());
                  },
                ),
              ),
            ),
          ],
        ),
          ],
        ),
      ),
    );
  }
}
