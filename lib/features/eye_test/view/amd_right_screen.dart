import 'package:eye_buddy/core/services/utils/config/app_colors.dart';
import 'package:eye_buddy/core/services/utils/size_config.dart';
import 'package:eye_buddy/features/eye_test/controller/eye_test_controller.dart';
import 'package:eye_buddy/features/eye_test/view/amd_result_screen.dart';
import 'package:eye_buddy/features/global_widgets/common_app_bar.dart';
import 'package:eye_buddy/features/global_widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AmdRightScreen extends StatelessWidget {
  const AmdRightScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final controller = Get.isRegistered<EyeTestController>()
        ? Get.find<EyeTestController>()
        : Get.put(EyeTestController());

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: CommonAppBar(
          title: 'AMD Right',
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
                  width: SizeConfig.screenWidth * 0.8,
                  child: Image.asset(
                    'assets/images/amdtest.PNG',
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(30.0),
                child: Text(
                  'Concentrate on the central point in the grid without moving your gaze. Do you see any strong distortions in certain lines?',
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
                          Get.to(() => const AmdResultScreen());
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
                          controller.incrementAmdRight();
                          Get.to(() => const AmdResultScreen());
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
