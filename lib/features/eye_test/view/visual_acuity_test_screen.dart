import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:eye_buddy/core/services/utils/config/app_colors.dart';
import 'package:eye_buddy/core/services/utils/assets/app_assets.dart';
import 'package:eye_buddy/features/eye_test/model/visual_acuity_test_model.dart';
import 'package:eye_buddy/features/eye_test/controller/timer_controller.dart';
import 'package:eye_buddy/features/eye_test/view/visual_acuity_instructions_screen.dart';
import 'package:eye_buddy/features/eye_test/view/visual_acuity_select_answer_screen.dart';
import 'package:eye_buddy/features/global_widgets/inter_text.dart';

// Visual Acuity Test Screen
class VisualAcuityTestScreen extends StatefulWidget {
  final int currentPage;

  const VisualAcuityTestScreen({super.key, required this.currentPage});

  @override
  State<VisualAcuityTestScreen> createState() => _VisualAcuityTestScreenState();
}

class _VisualAcuityTestScreenState extends State<VisualAcuityTestScreen> {
  late final TimerController timerController;
  late final Worker _countdownWorker;
  bool _navigatedToAnswer = false;

  void _handleBack() {
    try {
      _navigatedToAnswer = true;
      timerController.resetStopwatch();
    } catch (_) {
      // ignore
    }
    try {
      if (Get.isRegistered<TimerController>()) {
        Get.delete<TimerController>();
      }
    } catch (_) {
      // ignore
    }
    Get.offAll(() => const VisualAcuityInstructionsScreen());
  }

  @override
  void initState() {
    super.initState();
    timerController = Get.put(TimerController());
    timerController.startStopwatch();

    _countdownWorker = ever<int>(timerController.countdown, (value) {
      if (value != 0) return;
      if (_navigatedToAnswer) return;
      _navigatedToAnswer = true;

      timerController.resetStopwatch();
      Get.off(
        () => VisualAcuitySelectAnswerScreen(currentPage: widget.currentPage),
      );
    });
  }

  @override
  void dispose() {
    _countdownWorker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(preferredSize: Size.zero, child: AppBar()),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 22),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            GetVisualAcuityTestScreenAppbar(
              currentPage: widget.currentPage,
              onBack: _handleBack,
            ),
            Expanded(
              child: Center(
                child: Align(
                  child: MillimeterBox(
                    mmVal: visualAcuityEyeTestList[widget.currentPage].sizeInMM,
                    numberOfturns: visualAcuityEyeTestList[widget.currentPage]
                        .numberOfturns,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GetVisualAcuityTestScreenAppbar extends StatelessWidget {
  final int currentPage;
  final VoidCallback onBack;

  const GetVisualAcuityTestScreenAppbar({
    super.key,
    required this.currentPage,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final TimerController timerController = Get.find<TimerController>();

    return SizedBox(
      height: kToolbarHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back, color: AppColors.black),
              ),
              InterText(
                title:
                    '${visualAcuityEyeTestList[currentPage].myRange}/${visualAcuityEyeTestList[currentPage].averageHumansRange}',
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ],
          ),
          Obx(() {
            return Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(width: 1, color: AppColors.primaryColor),
              ),
              alignment: Alignment.center,
              child: InterText(
                title: "${timerController.countdown.value}",
                fontWeight: FontWeight.bold,
              ),
            );
          }),
        ],
      ),
    );
  }
}

class MillimeterBox extends StatefulWidget {
  final double mmVal;
  final int numberOfturns;

  const MillimeterBox({
    super.key,
    required this.mmVal,
    required this.numberOfturns,
  });

  @override
  State<MillimeterBox> createState() => _MillimeterBoxState();
}

class _MillimeterBoxState extends State<MillimeterBox> {
  late double screenWidth;
  late double screenHeight;
  double boxSizeInPixels = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateScreenSize();
    });
  }

  void _updateScreenSize() {
    setState(() {
      screenWidth = MediaQuery.of(context).size.width;
      screenHeight = MediaQuery.of(context).size.height;

      // Assuming 1 inch = 25.4 millimeters
      final screenInches =
          screenWidth / MediaQuery.of(context).devicePixelRatio;
      final millimetersPerPixel = 25.4 / screenInches;
      boxSizeInPixels = millimetersPerPixel * 50;
    });
  }

  @override
  Widget build(BuildContext context) {
    double ppi = DeviceUtils.getDevicePPI(context);
    double letterHeightMm = 0.582;
    double letterHeightPx = DeviceUtils.mmToPixels(letterHeightMm, ppi);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: letterHeightPx + widget.mmVal,
          height: letterHeightPx + widget.mmVal,
          color: Colors.transparent,
          child: RotatedBox(
            quarterTurns: widget.numberOfturns,
            child: SvgPicture.asset(
              AppAssets.visualAcuityTestE,
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }
}
