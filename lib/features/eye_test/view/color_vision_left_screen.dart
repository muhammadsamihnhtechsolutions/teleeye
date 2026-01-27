import 'package:eye_buddy/core/services/utils/config/app_colors.dart';
import 'package:eye_buddy/core/services/utils/size_config.dart';
import 'package:eye_buddy/features/eye_test/controller/eye_test_controller.dart';
import 'package:eye_buddy/features/eye_test/view/color_vision_right_instruction_screen.dart';
import 'package:eye_buddy/features/global_widgets/common_app_bar.dart';
import 'package:eye_buddy/features/global_widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ColorVisionLeftScreen extends StatefulWidget {
  const ColorVisionLeftScreen({super.key});

  @override
  State<ColorVisionLeftScreen> createState() => _ColorVisionLeftScreenState();
}

class _ColorVisionLeftScreenState extends State<ColorVisionLeftScreen> {
  final _text = TextEditingController();
  bool _validate = false;
  int _tap = 0;

  static const List<String> _answers = ['12', '29', '15', '97', '16', '0'];

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  String _currentImagePath() {
    final index = (_tap + 1).clamp(1, 6);
    return 'assets/images/color_blind/vision$index.png';
  }

  void _onConfirm(EyeTestController controller) {
    setState(() {
      _validate = _text.text.trim().isEmpty;
      if (_validate) return;

      final answerIndex = _tap.clamp(0, 5);
      if (_text.text.trim() == _answers[answerIndex]) {
        controller.incrementColorVisionLeft();
      }

      _tap++;
      _text.clear();

      if (_tap >= 6) {
        Get.to(() => const ColorVisionRightInstructionScreen());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final controller = Get.isRegistered<EyeTestController>()
        ? Get.find<EyeTestController>()
        : Get.put(EyeTestController());

    return Scaffold(
      appBar: CommonAppBar(
        title: 'Color Blind',
        elevation: 0,
        icon: Icons.arrow_back,
        finishScreen: true,
        isTitleCenter: false,
        context: context,
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: SizedBox(
                    height: 220,
                    width: 334,
                    child: Image.asset(_currentImagePath()),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(30.0),
                  child: Text(
                    'If you don\'t see any number, enter the letter \'0\'.',
                    style: TextStyle(
                      fontFamily: 'DemiBold',
                      color: Color(0xFF181D3D),
                      fontSize: 22,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Text(
                        'I see',
                        style: TextStyle(color: Colors.black, fontSize: 16),
                      ),
                    ),
                    SizedBox(
                      width: 130,
                      child: TextField(
                        keyboardType: TextInputType.number,
                        controller: _text,
                        decoration: InputDecoration(
                          labelText: 'Insert Number Here',
                          errorText: _validate ? 'Value Can\'t Be Empty' : null,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 50),
                  child: CustomButton(
                    title: 'Confirm',
                    callBackFunction: () => _onConfirm(controller),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Left Eye',
                  style: TextStyle(color: AppColors.color888E9D),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
