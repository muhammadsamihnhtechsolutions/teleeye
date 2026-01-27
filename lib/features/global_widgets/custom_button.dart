import 'package:eye_buddy/core/services/utils/config/app_colors.dart';
import 'package:eye_buddy/core/services/utils/dimentions.dart';
// import 'package:eye_buddy/app/views/global_widgets/inter_text.dart';
import 'package:eye_buddy/core/services/utils/config/app_colors.dart';
import 'package:eye_buddy/core/services/utils/size_config.dart';
import 'package:eye_buddy/features/global_widgets/inter_text.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  CustomButton({
    super.key,
    required this.title,
    required this.callBackFunction,
    this.backGroundColor = AppColors.color008541,
    this.textColor = AppColors.white,
    this.showBorder = false,
  });

  String title;
  Function callBackFunction;
  Color backGroundColor;
  Color textColor;
  bool showBorder;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return GestureDetector(
      onTap: () {
        callBackFunction();
      },
      child: Container(
        // width: MediaQuery.of(context).size.width,
        height: getProportionateScreenHeight(55),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: showBorder ? Colors.white : backGroundColor,
          border: Border.all(width: 2, color: backGroundColor),
        ),

        alignment: Alignment.center,
        child: InterText(
          title: title,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          textColor: showBorder ? backGroundColor : textColor,
        ),
      ),
    );
  }
}
