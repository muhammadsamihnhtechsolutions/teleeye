import 'package:eye_buddy/core/services/utils/assets/app_assets.dart';
import 'package:eye_buddy/core/services/utils/config/app_colors.dart';
import 'package:eye_buddy/core/services/utils/dimentions.dart';
import 'package:eye_buddy/core/services/utils/size_config.dart';
import 'package:eye_buddy/features/bootom_navbar_screen/contollers/bottom_navbar_controller.dart';
import 'package:eye_buddy/features/global_widgets/inter_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class BottomNavBarWidget extends StatelessWidget {
  const BottomNavBarWidget({super.key, required this.controller});

  final BottomNavBarController controller;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Container(
      height: kToolbarHeight * 1.5,
      width: getWidth(context: context),
      decoration: BoxDecoration(
        color: AppColors.colorFFFFFF,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(.1),
            blurRadius: 15,
            offset: const Offset(0, 0.75),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          BottomNavBarIconGetX(
            title: 'Home',
            iconPath: AppAssets.navbarHome,
            navbarPosition: 0,
            controller: controller,
          ),
          BottomNavBarIconGetX(
            title: 'Appointments',
            iconPath: AppAssets.navbarAppointments,
            navbarPosition: 1,
            controller: controller,
          ),
          BottomNavBarIconGetX(
            title: 'More',
            iconPath: AppAssets.navbarMore,
            navbarPosition: 2,
            controller: controller,
          ),
        ],
      ),
    );
  }
}

class BottomNavBarIconGetX extends StatelessWidget {
  BottomNavBarIconGetX({
    super.key,
    required this.title,
    required this.iconPath,
    required this.navbarPosition,
    required this.controller,
  });

  final String title;
  final String iconPath;
  final int navbarPosition;
  final BottomNavBarController controller;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Obx(() {
      bool isActive = controller.currentPageIndex.value == navbarPosition;
      return GestureDetector(
        onTap: () {
          controller.changePage(navbarPosition);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? AppColors.color008541 : Colors.transparent,
            borderRadius: BorderRadius.circular(130),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: getProportionateScreenHeight(15),
                width: getProportionateScreenHeight(15),
                child: SvgPicture.asset(
                  iconPath,
                  color: isActive ? Colors.white : AppColors.colorBBBBBB,
                ),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: InterText(
                  title: title,
                  textColor: isActive ? Colors.white : AppColors.colorBBBBBB,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
