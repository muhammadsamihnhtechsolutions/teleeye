import 'package:eye_buddy/core/services/utils/config/app_colors.dart';
import 'package:eye_buddy/core/services/utils/size_config.dart';
import 'package:eye_buddy/features/bootom_navbar_screen/views/bottom_navbar_screen.dart';
import 'package:eye_buddy/features/eye_test/controller/eye_test_controller.dart';
import 'package:eye_buddy/features/eye_test/view/near_vision_left_screen.dart';
import 'package:eye_buddy/features/eye_test/view/eye_test_list_screen.dart';
import 'package:eye_buddy/features/eye_test/view/send_eye_test_result_screen.dart';
import 'package:eye_buddy/features/global_widgets/custom_button.dart';
import 'package:eye_buddy/features/global_widgets/inter_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';

class NearVisionResultScreen extends StatefulWidget {
  const NearVisionResultScreen({super.key});

  @override
  State<NearVisionResultScreen> createState() => _NearVisionResultScreenState();
}

class _NearVisionResultScreenState extends State<NearVisionResultScreen> {
  late final EyeTestController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<EyeTestController>()
        ? Get.find<EyeTestController>()
        : Get.put(EyeTestController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.submitNearVisionResults();
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    final leftScore = _controller.nearVisionLeftCounter.value;
    final rightScore = _controller.nearVisionRightCounter.value;
    final leftPassed = leftScore >= 10;
    final rightPassed = rightScore >= 10;

    final isGood = leftPassed && rightPassed;
    final isOk = !isGood && (leftPassed || rightPassed);

    final title = 'Your Result';

    final message = isGood
        ? 'Congratulations, you can read all the text from 40cm away.'
        : isOk
        ? 'You can read some text from 40cm away.'
        : 'You cannot read all the text from 40cm away.';

    final subMessage = isGood
        ? 'Do not hesitate to take a further vision exam with an eye care professional.'
        : 'We recommend visiting an eye care professional to find out about different corrective solutions.';

    final lottiePath = isGood
        ? 'assets/1.json'
        : isOk
        ? 'assets/2.json'
        : 'assets/3.json';

    final imagePath = isGood
        ? 'assets/images/good.png'
        : isOk
        ? 'assets/images/ok.png'
        : 'assets/images/sad.png';

    return WillPopScope(
      onWillPop: () async {
        Get.offAll(() => const BottomNavBarScreen());
        return false;
      },
      child: Scaffold(
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              double heroHeight = constraints.maxHeight * 0.42;
              if (heroHeight < 240) heroHeight = 240;
              if (heroHeight > 360) heroHeight = 360;

              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        SizedBox(
                          height: heroHeight,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Lottie.asset(lottiePath),
                              Image.asset(imagePath),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(25.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontFamily: 'TTCommons',
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(25.0),
                          child: Column(
                            children: [
                              Text(
                                message,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'TTCommons',
                                ),
                                textAlign: TextAlign.center,
                              ),
                              InterText(
                                title: subMessage,
                                fontSize: 14,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25),
                          child: Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    _controller.resetNearVision();
                                    Get.offAll(
                                      () => const NearVisionLeftScreen(),
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
                                    Get.offAll(() => const EyeTestListScreen());
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
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 25,
                            right: 25,
                            bottom: 20,
                          ),
                          child: CustomButton(
                            title: 'Send to Doctor',
                            callBackFunction: () {
                              Get.to(() => const SendEyeTestResultScreen());
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 25,
                            right: 25,
                            bottom: 20,
                          ),
                          child: CustomButton(
                            title: 'Learn More',
                            callBackFunction: () async {
                              final url = Uri.parse(
                                'https://medlineplus.gov/ency/article/003446.html',
                              );
                              await launchUrl(url);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
