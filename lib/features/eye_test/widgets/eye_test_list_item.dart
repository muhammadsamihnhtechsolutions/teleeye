import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:eye_buddy/core/services/utils/config/app_colors.dart';
import 'package:eye_buddy/core/services/utils/size_config.dart';
import 'package:eye_buddy/features/global_widgets/common_size_box.dart';
import 'package:eye_buddy/features/global_widgets/inter_text.dart';

class EyeTestListItem extends StatelessWidget {
  final String title;
  final String iconName;
  final String shortDetails;
  final VoidCallback callBackFunction;

  const EyeTestListItem({
    required this.iconName,
    required this.title,
    required this.shortDetails,
    required this.callBackFunction,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        left: getProportionateScreenWidth(20),
        right: getProportionateScreenWidth(20),
        bottom: getProportionateScreenWidth(10),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: getProportionateScreenWidth(15),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AppColors.white,
      ),
      child: GestureDetector(
        onTap: callBackFunction,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: getProportionateScreenWidth(21),
            top: getProportionateScreenWidth(21),
          ),
          child: Row(
            children: [
              SvgPicture.asset(
                iconName,
                height: getProportionateScreenWidth(60),
                width: getProportionateScreenWidth(60),
              ),
              CommonSizeBox(width: getProportionateScreenWidth(16)),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InterText(
                      title: title,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    CommonSizeBox(height: getProportionateScreenWidth(8)),
                    InterText(
                      title: shortDetails,
                      fontSize: 12,
                      textColor: AppColors.color888E9D,
                      fontWeight: FontWeight.w400,
                    ),
                  ],
                ),
              ),
              CommonSizeBox(width: getProportionateScreenWidth(16)),
              Container(
                height: getProportionateScreenHeight(35),
                width: getProportionateScreenHeight(35),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: AppColors.colorE6F2EE,
                ),
                child: const Icon(
                  Icons.arrow_forward,
                  size: 20,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
