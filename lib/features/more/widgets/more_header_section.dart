import 'package:eye_buddy/core/services/api/service/api_constants.dart';
import 'package:eye_buddy/core/services/utils/assets/app_assets.dart';
import 'package:eye_buddy/core/services/utils/config/app_colors.dart';
import 'package:eye_buddy/core/services/utils/size_config.dart';
import 'package:eye_buddy/features/global_widgets/common_network_image_widget.dart';
import 'package:eye_buddy/features/global_widgets/common_size_box.dart';
import 'package:eye_buddy/features/global_widgets/inter_text.dart';
import 'package:eye_buddy/features/login/controller/profile_controller.dart';
import 'package:eye_buddy/features/more/view/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MoreHeaderSection extends StatelessWidget {
  const MoreHeaderSection({super.key});

  String _resolvePhotoUrl(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return '';
    final isAbsolute = Uri.tryParse(v)?.isAbsolute ?? false;
    if (isAbsolute) return v;
    return '${ApiConstants.imageBaseUrl}$v';
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final profileController = Get.find<ProfileController>();

    return GestureDetector(
      onTap: () {
        Get.to(() => const ProfileScreen());
      },
      child: Column(
        children: [
          Container(
            color: AppColors.colorCCE7D9,
            padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 22),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Obx(() {
                  final profile = profileController.profileData.value.profile;
                  if (profile == null) {
                    return const SizedBox.shrink();
                  }
                  return SizedBox(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(
                            getProportionateScreenHeight(60),
                          ),
                          child: profile.photo == '' || profile.photo == null
                              ? Container(
                                  height: getProportionateScreenHeight(64),
                                  width: getProportionateScreenHeight(64),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(110),
                                    border: Border.all(
                                      width: 2,
                                      color: AppColors.primaryColor,
                                    ),
                                    image: DecorationImage(
                                      image: AssetImage(
                                        AppAssets.beh_app_icon_with_bg,
                                      ),
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                )
                              : Container(
                                  height: getProportionateScreenHeight(64),
                                  width: getProportionateScreenHeight(64),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(60),
                                  ),
                                  child: CommonNetworkImageWidget(
                                    imageLink: _resolvePhotoUrl(profile.photo),
                                  ),
                                ),
                        ),
                        CommonSizeBox(width: getProportionateScreenWidth(10)),
                        SizedBox(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                child: InterText(
                                  title: profile.name ?? "",
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              CommonSizeBox(
                                height: getProportionateScreenWidth(2),
                              ),
                              InterText(
                                title: profile.phone ?? "",
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                textColor: AppColors.color888E9D,
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        const SizedBox(
                          child: Icon(
                            Icons.arrow_forward_ios,
                            color: AppColors.color008541,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          Container(
            width: SizeConfig.screenWidth,
            height: 1,
            color: AppColors.primaryColor,
          ),
        ],
      ),
    );
  }
}
