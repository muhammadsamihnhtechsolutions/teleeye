import 'package:flutter/material.dart';
import 'package:eye_buddy/core/services/utils/config/app_colors.dart';
import 'package:eye_buddy/core/services/utils/size_config.dart';
import 'package:eye_buddy/features/bootom_navbar_screen/views/bottom_navbar_screen.dart';
import 'package:eye_buddy/features/eye_test/controller/eye_test_controller.dart';
import 'package:eye_buddy/features/eye_test/view/visual_acuity_instructions_screen.dart';
import 'package:eye_buddy/features/eye_test/view/send_eye_test_result_screen.dart';
import 'package:eye_buddy/features/eye_test/model/visual_acuity_test_model.dart';
import 'package:eye_buddy/features/global_widgets/custom_button.dart';
import 'package:eye_buddy/features/global_widgets/inter_text.dart';
import 'package:get/get.dart';

class VisualAcuityTestFailedScreen extends StatefulWidget {
  const VisualAcuityTestFailedScreen({super.key, required this.currentPage});

  final int currentPage;

  @override
  State<VisualAcuityTestFailedScreen> createState() =>
      _VisualAcuityTestFailedScreenState();
}

class _VisualAcuityTestFailedScreenState
    extends State<VisualAcuityTestFailedScreen> {
  late final EyeTestController _eyeTestController;

  @override
  void initState() {
    super.initState();
    _eyeTestController = Get.isRegistered<EyeTestController>()
        ? Get.find<EyeTestController>()
        : Get.put(EyeTestController(), permanent: true);

    final visualAcuityModel = visualAcuityEyeTestList[widget.currentPage];
    final currentScore =
        '${visualAcuityModel.myRange}/${visualAcuityModel.averageHumansRange}';

    _eyeTestController.updateScore(currentScore);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_eyeTestController.isLeftEye.value) {
        _eyeTestController.submitVisualAcuityResults();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final visualAcuityModel = visualAcuityEyeTestList[widget.currentPage];

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: AppBar(),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 33),
        width: double.infinity,
        height: double.infinity,
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InterText(
                    title: visualAcuityModel.title,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                  const SizedBox(height: 12),
                  InterText(
                    title: visualAcuityModel.message,
                    fontSize: 14,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            _eyeTestController.resetScore();
                            Get.offAll(
                              () => const VisualAcuityInstructionsScreen(),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: AppColors.primaryColor,
                            ),
                            child: const Center(
                              child: InterText(
                                textColor: AppColors.white,
                                title: 'Retry Test',
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Get.offAll(() => const BottomNavBarScreen());
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: AppColors.color888E9D,
                            ),
                            child: const Center(
                              child: InterText(
                                textColor: AppColors.white,
                                title: 'Exit',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Obx(() {
                  final showContinue = _eyeTestController.isLeftEye.value;
                  if (!showContinue) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: CustomButton(
                      title: 'Continue for right eye',
                      callBackFunction: () {
                        _eyeTestController.updateCurrentEye(false);
                        Get.off(() => const VisualAcuityInstructionsScreen());
                      },
                    ),
                  );
                }),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 25,
                    right: 25,
                    bottom: 20,
                  ),
                  child: Obx(() {
                    if (_eyeTestController.isLeftEye.value) {
                      return const SizedBox.shrink();
                    }
                    return CustomButton(
                      title: 'Send to Doctor',
                      callBackFunction: () {
                        Get.to(() => const SendEyeTestResultScreen());
                      },
                    );
                  }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
