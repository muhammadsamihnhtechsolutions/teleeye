import 'package:eye_buddy/core/services/api/service/api_constants.dart';
import 'package:eye_buddy/core/services/utils/size_config.dart';
import 'package:eye_buddy/features/global_widgets/common_network_image_widget.dart';
import 'package:eye_buddy/features/global_widgets/common_size_box.dart';
import 'package:eye_buddy/features/global_widgets/language_chip.dart';
import 'package:eye_buddy/features/login/controller/profile_controller.dart';
import 'package:eye_buddy/core/services/utils/assets/app_assets.dart';
import 'package:eye_buddy/features/notifications/view/notifications_screen.dart';
import 'package:eye_buddy/features/more/view/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final profileController = Get.find<ProfileController>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Obx(() {
            final profilePhoto =
                profileController.profileData.value.profile?.photo;
            return GestureDetector(
              onTap: () {
                Get.to(() => const ProfileScreen());
              },
              child: SizedBox(
                height: getProportionateScreenHeight(48),
                width: getProportionateScreenHeight(48),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(48),
                  child: CommonNetworkImageWidget(
                    imageLink: profilePhoto != null
                        ? '${ApiConstants.imageBaseUrl}$profilePhoto'
                        : '',
                  ),
                ),
              ),
            );
          }),
          const Spacer(),
          LanguageChip(),
          CommonSizeBox(width: getProportionateScreenWidth(20)),
          GestureDetector(
            onTap: () {
              // TODO: Navigate to notifications screen when available
              // NavigatorServices().to(
              //   context: context,
              //   widget: NotificationsScreen(),
              // );
              Get.to(() => const NotificationsScreen());
            },
            child: SvgPicture.asset(
              AppAssets.bell,
              height: getProportionateScreenWidth(20),
              width: getProportionateScreenWidth(20),
            ),
          ),
        ],
      ),
    );
  }
}
