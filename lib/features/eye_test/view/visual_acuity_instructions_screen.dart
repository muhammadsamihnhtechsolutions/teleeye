import 'package:eye_buddy/core/services/utils/assets/app_assets.dart';
import 'package:eye_buddy/core/services/utils/config/app_colors.dart';
import 'package:eye_buddy/core/services/utils/size_config.dart';
import 'package:eye_buddy/features/eye_test/controller/eye_test_controller.dart';
import 'package:eye_buddy/features/eye_test/view/eye_test_list_screen.dart';
import 'package:eye_buddy/features/eye_test/view/visual_acuity_test_screen.dart';
import 'package:eye_buddy/features/global_widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VisualAcutyTestAssetModel {
  VisualAcutyTestAssetModel({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.index,
  });

  final String title;
  final String description;
  final String imagePath;
  final int index;
}

class VisualAcuityInstructionsScreen extends StatefulWidget {
  const VisualAcuityInstructionsScreen({super.key});

  @override
  State<VisualAcuityInstructionsScreen> createState() =>
      _VisualAcuityInstructionsScreenState();
}

class _VisualAcuityInstructionsScreenState
    extends State<VisualAcuityInstructionsScreen> {
  final List<VisualAcutyTestAssetModel> _rightInstructions = [
    VisualAcutyTestAssetModel(
      title: 'Cover your Right eye',
      description: 'Cover your left eye and test your right eye',
      imagePath: AppAssets.va21,
      index: 0,
    ),
  ];

  final List<VisualAcutyTestAssetModel> _leftInstructions = [
    VisualAcutyTestAssetModel(
      title: 'Visual Acuity Test',
      description:
          'Welcome to the Visual Acuity Test. This quick test helps assess your vision',
      imagePath: AppAssets.va1,
      index: 0,
    ),
    VisualAcutyTestAssetModel(
      title: 'Test preparation and Device Positioning',
      description:
          "Find a quiet, well-lit area to take the test.Position your device at eye level, about arm's length away. Ensure the screen is unobstructed.",
      imagePath: AppAssets.va2,
      index: 1,
    ),
    VisualAcutyTestAssetModel(
      title: 'Cover One Eye Instruction',
      description: 'Cover one eye with your hand or use an eye patch.',
      imagePath: AppAssets.va3,
      index: 2,
    ),
    VisualAcutyTestAssetModel(
      title:
          'Focus on the direction of the “E” and Select the Correct  Response',
      description:
          "Focus on the 'E' chart displayed on the screen. Select the correct direction the 'E' is facing.",
      imagePath: AppAssets.va4,
      index: 3,
    ),
    VisualAcutyTestAssetModel(
      title: 'Repeat for the Other Eye ',
      description:
          'Uncover the covered eye and repeat the test for the other eye.',
      imagePath: AppAssets.va5,
      index: 4,
    ),
    VisualAcutyTestAssetModel(
      title: 'Interpreting Results',
      description:
          "Results will show as 'Normal,' 'Mild Vision Loss,' 'Moderate Vision Loss,' or 'Severe Vision Loss.' Take note of each eye's result.",
      imagePath: AppAssets.va6,
      index: 5,
    ),
    VisualAcutyTestAssetModel(
      title: 'Cover your left eye',
      description: 'Cover your left eye and test your right eye',
      imagePath: AppAssets.va7,
      index: 6,
    ),
  ];

  int _currentPageIndex = 0;
  bool? _lastIsLeftEye;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final eyeTestController = Get.isRegistered<EyeTestController>()
        ? Get.find<EyeTestController>()
        : Get.put(EyeTestController(), permanent: true);

    try {
      // Make sure the same instance is kept alive across route changes.
      Get.put<EyeTestController>(eyeTestController, permanent: true);
    } catch (_) {
      // ignore
    }

    Future<bool> handleBack() async {
      try {
        if (Get.isRegistered<EyeTestController>()) {
          Get.delete<EyeTestController>(force: true);
        }
      } catch (_) {
        // ignore
      }
      Get.offAll(() => const EyeTestListScreen());
      return false;
    }

    return WillPopScope(
      onWillPop: handleBack,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.0,
          leading: IconButton(
            onPressed: () {
              handleBack();
            },
            icon: const Icon(Icons.arrow_back, color: AppColors.black),
          ),
          title: const Text('Visual Acuity Instructions'),
          centerTitle: false,
        ),
        backgroundColor: AppColors.appBackground,
        body: Obx(() {
          final isLeft = eyeTestController.isLeftEye.value;
          if (_lastIsLeftEye != null && _lastIsLeftEye != isLeft) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              setState(() {
                _currentPageIndex = 0;
              });
              if (_pageController.hasClients) {
                _pageController.jumpToPage(0);
              }
            });
          }
          _lastIsLeftEye = isLeft;

          final items = isLeft ? _leftInstructions : _rightInstructions;

          return SizedBox(
            height: SizeConfig.screenHeight,
            width: SizeConfig.screenWidth,
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: items.length,
                    onPageChanged: (value) {
                      setState(() {
                        _currentPageIndex = value;
                      });
                    },
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          Flexible(
                            flex: 1,
                            child: SizedBox(
                              height: double.maxFinite,
                              width: double.maxFinite,
                              child: Image.asset(
                                items[index].imagePath,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Flexible(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              child: Column(
                                children: [
                                  const SizedBox(height: 20),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          items[index].title,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 22,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          items[index].description,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 15,
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      scrollDirection: Axis.horizontal,
                                      itemCount: items.length,
                                      itemBuilder: (context, i) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            right: 6,
                                          ),
                                          child: Align(
                                            child: Container(
                                              height: 10,
                                              width: 10,
                                              decoration: BoxDecoration(
                                                color: i == _currentPageIndex
                                                    ? Colors.green
                                                    : Colors.green.withOpacity(
                                                        .4,
                                                      ),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: CustomButton(
                    title: 'Start Test',
                    callBackFunction: () {
                      Get.off(
                        () => const VisualAcuityTestScreen(currentPage: 0),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
