// import 'package:eye_buddy/core/services/utils/config/app_colors.dart';
// import 'package:eye_buddy/core/services/utils/size_config.dart';
// import 'package:eye_buddy/features/bootom_navbar_screen/views/bottom_navbar_screen.dart';
// import 'package:eye_buddy/features/eye_test/controller/eye_test_controller.dart';
// import 'package:eye_buddy/features/eye_test/view/amd_left_screen.dart';
// import 'package:eye_buddy/features/eye_test/view/eye_test_list_screen.dart';
// import 'package:eye_buddy/features/eye_test/view/send_eye_test_result_screen.dart';
// import 'package:eye_buddy/features/global_widgets/custom_button.dart';
// import 'package:eye_buddy/features/global_widgets/inter_text.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:lottie/lottie.dart';

// class AmdResultScreen extends StatefulWidget {
//   const AmdResultScreen({super.key});

//   @override
//   State<AmdResultScreen> createState() => _AmdResultScreenState();
// }

// class _AmdResultScreenState extends State<AmdResultScreen> {
//   late final EyeTestController _controller;

//   @override
//   void initState() {
//     super.initState();
//     _controller = Get.isRegistered<EyeTestController>()
//         ? Get.find<EyeTestController>()
//         : Get.put(EyeTestController());
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _controller.submitAmdResults();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     SizeConfig().init(context);

//     final total =
//         _controller.amdLeftCounter.value + _controller.amdRightCounter.value;
//     final isGood = total >= 10;
//     final isOk = total >= 1 && total <= 9;

//     final message = isGood
//         ? 'Congratulations, you do not seem to have any symptoms of age-related macular degeneration (AMD).'
//         : isOk
//         ? "You saw distortions in the grid with one of your eyes. It's possible that this symptom is potentially linked to age-related macular degeneration (AMD)"
//         : "You saw distortions in the grid with both eyes. It's possible that this symptom is potentially linked to age-related macular degeneration (AMD).";

//     final subMessage = isGood
//         ? 'Do not hesitate to take a further vision exam with an eye care professional.'
//         : 'We recommend visiting an eye care professional.';

//     final lottiePath = isGood
//         ? 'assets/1.json'
//         : isOk
//         ? 'assets/2.json'
//         : 'assets/3.json';

//     final imagePath = isGood
//         ? 'assets/images/good.png'
//         : isOk
//         ? 'assets/images/ok.png'
//         : 'assets/images/sad.png';

//     return WillPopScope(
//       onWillPop: () async {
//         Get.offAll(() => const BottomNavBarScreen());
//         return false;
//       },
//       child: Scaffold(
//         body: SafeArea(
//           child: LayoutBuilder(
//             builder: (context, constraints) {
//               double heroHeight = constraints.maxHeight * 0.42;
//               if (heroHeight < 220) heroHeight = 220;
//               if (heroHeight > 360) heroHeight = 360;

//               return SingleChildScrollView(
//                 child: ConstrainedBox(
//                   constraints: BoxConstraints(minHeight: constraints.maxHeight),
//                   child: IntrinsicHeight(
//                     child: Column(
//                       children: [
//                         SizedBox(
//                           height: heroHeight,
//                           child: Stack(
//                             alignment: Alignment.center,
//                             children: [
//                               Lottie.asset(lottiePath),
//                               Image.asset(imagePath),
//                             ],
//                           ),
//                         ),
//                         const Padding(
//                           padding: EdgeInsets.all(25.0),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Text(
//                                 'Your Result',
//                                 style: TextStyle(
//                                   fontSize: 30,
//                                   fontFamily: 'TTCommons',
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.all(25.0),
//                           child: Column(
//                             children: [
//                               Text(
//                                 message,
//                                 style: const TextStyle(
//                                   fontSize: 14,
//                                   fontFamily: 'TTCommons',
//                                 ),
//                                 textAlign: TextAlign.center,
//                               ),
//                               InterText(
//                                 title: subMessage,
//                                 fontSize: 14,
//                                 textAlign: TextAlign.center,
//                               ),
//                             ],
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 25),
//                           child: Row(
//                             children: [
//                               Expanded(
//                                 child: InkWell(
//                                   onTap: () {
//                                     _controller.resetAmd();
//                                     Get.offAll(() => const AmdLeftScreen());
//                                   },
//                                   child: Container(
//                                     padding: const EdgeInsets.all(10),
//                                     decoration: BoxDecoration(
//                                       borderRadius: BorderRadius.circular(8),
//                                       color: AppColors.primaryColor,
//                                     ),
//                                     child: const Center(
//                                       child: InterText(
//                                         textColor: AppColors.white,
//                                         title: 'Retry Test',
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(width: 20),
//                               Expanded(
//                                 child: InkWell(
//                                   onTap: () {
//                                     Get.offAll(() => const EyeTestListScreen());
//                                   },
//                                   child: Container(
//                                     padding: const EdgeInsets.all(10),
//                                     decoration: BoxDecoration(
//                                       borderRadius: BorderRadius.circular(8),
//                                       color: AppColors.color888E9D,
//                                     ),
//                                     child: const Center(
//                                       child: InterText(
//                                         textColor: AppColors.white,
//                                         title: 'Exit',
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         const Spacer(),
//                         Padding(
//                           padding: const EdgeInsets.only(
//                             left: 25,
//                             right: 25,
//                             bottom: 20,
//                           ),
//                           child: CustomButton(
//                             title: 'Send to Doctor',
//                             callBackFunction: () {
//                               Get.to(() => const SendEyeTestResultScreen());
//                             },
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:eye_buddy/core/services/utils/config/app_colors.dart';
import 'package:eye_buddy/core/services/utils/size_config.dart';
import 'package:eye_buddy/features/bootom_navbar_screen/views/bottom_navbar_screen.dart';
import 'package:eye_buddy/features/eye_test/controller/eye_test_controller.dart';
import 'package:eye_buddy/features/eye_test/view/visual_acuity_instructions_screen.dart';
import 'package:eye_buddy/features/eye_test/model/visual_acuity_test_model.dart';
import 'package:eye_buddy/features/global_widgets/custom_button.dart';
import 'package:eye_buddy/features/global_widgets/inter_text.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart'; // ✅ For opening links

class AmdTestFailedScreen extends StatefulWidget {
  const AmdTestFailedScreen({super.key, required this.currentPage});

  final int currentPage;

  @override
  State<AmdTestFailedScreen> createState() => _AmdTestFailedScreenState();
}

class _AmdTestFailedScreenState extends State<AmdTestFailedScreen> {
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

  // ✅ Function to open Learn More link
  Future<void> _openLearnMore(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
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
                // ✅ Replaced "Send to Doctor" with "Learn More"
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
                      title: 'Learn More',
                      callBackFunction: () {
                        _openLearnMore(visualAcuityModel.link);
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
