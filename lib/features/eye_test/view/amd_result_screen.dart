import 'package:eye_buddy/core/services/utils/config/app_colors.dart';
import 'package:eye_buddy/core/services/utils/size_config.dart';
import 'package:eye_buddy/features/bootom_navbar_screen/views/bottom_navbar_screen.dart';
import 'package:eye_buddy/features/eye_test/controller/eye_test_controller.dart';
import 'package:eye_buddy/features/eye_test/view/amd_left_screen.dart';
import 'package:eye_buddy/features/eye_test/view/eye_test_list_screen.dart';
import 'package:eye_buddy/features/eye_test/view/send_eye_test_result_screen.dart';
import 'package:eye_buddy/features/global_widgets/custom_button.dart';
import 'package:eye_buddy/features/global_widgets/inter_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class AmdResultScreen extends StatefulWidget {
  const AmdResultScreen({super.key});

  @override
  State<AmdResultScreen> createState() => _AmdResultScreenState();
}

class _AmdResultScreenState extends State<AmdResultScreen> {
  late final EyeTestController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<EyeTestController>()
        ? Get.find<EyeTestController>()
        : Get.put(EyeTestController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.submitAmdResults();
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    final total =
        _controller.amdLeftCounter.value + _controller.amdRightCounter.value;
    final isGood = total >= 10;
    final isOk = total >= 1 && total <= 9;

    final message = isGood
        ? 'Congratulations, you do not seem to have any symptoms of age-related macular degeneration (AMD).'
        : isOk
        ? "You saw distortions in the grid with one of your eyes. It's possible that this symptom is potentially linked to age-related macular degeneration (AMD)"
        : "You saw distortions in the grid with both eyes. It's possible that this symptom is potentially linked to age-related macular degeneration (AMD).";

    final subMessage = isGood
        ? 'Do not hesitate to take a further vision exam with an eye care professional.'
        : 'We recommend visiting an eye care professional.';

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
              if (heroHeight < 220) heroHeight = 220;
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
                        const Padding(
                          padding: EdgeInsets.all(25.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Your Result',
                                style: TextStyle(
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
                                    _controller.resetAmd();
                                    Get.offAll(() => const AmdLeftScreen());
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
                        const Spacer(),
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
