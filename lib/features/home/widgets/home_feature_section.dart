import 'package:eye_buddy/core/services/utils/assets/app_assets.dart';
import 'package:eye_buddy/core/services/utils/config/app_colors.dart';
import 'package:eye_buddy/core/services/utils/size_config.dart';
import 'package:eye_buddy/features/eye_test/view/eye_test_list_screen.dart';
import 'package:eye_buddy/features/home/widgets/home_banner_ad.dart';
import 'package:eye_buddy/features/global_widgets/common_size_box.dart';
import 'package:eye_buddy/features/global_widgets/inter_text.dart';
import 'package:eye_buddy/features/doctor_list/view/doctor_list_screen.dart';
import 'package:eye_buddy/features/medication_tracker/view/medication_tracker_screen.dart';
import 'package:eye_buddy/features/more/view/all_prescriptions_screen.dart';
import 'package:eye_buddy/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

class HomeFeatureSection extends StatelessWidget {
  const HomeFeatureSection({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.only(
        top: 10,
        left: getProportionateScreenWidth(20),
        right: getProportionateScreenWidth(20),
        bottom: getProportionateScreenWidth(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.quick_access,
            style: TextStyle(
              color: Color(0xFF001B0D),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          Gap(10),
          Row(
            children: [
              Expanded(
                child: homeFeaturedSectionItem(
                  context: context,
                  imageAssets: AppAssets.doctor,
                  title: l10n.video_consultation,
                  titleDetails: l10n.doctors_are_online,
                  isOnline: true,
                  onPressed: () {
                    Get.to(() => const DoctorListScreen());
                  },
                ),
              ),
              CommonSizeBox(width: 16),
              Expanded(
                child: homeFeaturedSectionItem(
                  context: context,
                  imageAssets: AppAssets.eyeTest,
                  title: l10n.eye_test,
                  onPressed: () {
                    Get.to(() => const EyeTestListScreen());
                  },
                  titleDetails: l10n.check_your_vision_now,
                ),
              ),
            ],
          ),
          CommonSizeBox(height: 10),
          Row(
            children: [
              Expanded(
                child: homeFeaturedSectionItem(
                  context: context,
                  imageAssets: AppAssets.eye_test_home,
                  onPressed: () {
                    Get.to(() => const MedicationTrackerScreen());
                  },
                  title: l10n.medication_tracker,
                  titleDetails:
                      "${l10n.never_miss_a_dose}\n${l10n.set_reminders}",
                ),
              ),
              CommonSizeBox(width: 16),
              Expanded(
                child: homeFeaturedSectionItem(
                  context: context,
                  imageAssets: AppAssets.all_prescriptions_home,
                  onPressed: () {
                    Get.to(() => const AllPrescriptionsScreen());
                  },
                  title: l10n.all_prescriptions,
                  titleDetails: l10n.your_prescriptions_all_in_one_place,
                ),
              ),
            ],
          ),
          CommonSizeBox(height: 24),
          // const HomeBannerAd(),
        ],
      ),
    );
  }

  Widget homeFeaturedSectionItem({
    required onPressed,
    required BuildContext context,
    required String imageAssets,
    required String title,
    required String titleDetails,
    bool isOnline = false,
  }) {
    return InkWell(
      onTap: () {
        onPressed();
      },
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          color: Colors.white,
          border: Border.all(color: AppColors.colorEDEDED, width: 2),
        ),
        child: Column(
          children: [
            Flexible(
              flex: 1,
              child: Container(
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.all(10),
                padding:
                    imageAssets == AppAssets.eyeTest ||
                        imageAssets == AppAssets.doctor
                    ? EdgeInsets.only(top: 10)
                    : EdgeInsets.all(15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  color: AppColors.primaryColor,
                ),
                alignment: imageAssets == AppAssets.eyeTest
                    ? Alignment.centerRight
                    : Alignment.center,
                child: Image.asset(imageAssets, fit: BoxFit.fitHeight),
              ),
            ),
            Flexible(
              flex: 1,
              child: Container(
                padding: EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    InterText(
                      title: title,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      textColor: AppColors.black,
                      textAlign: TextAlign.center,
                    ),
                    CommonSizeBox(height: getProportionateScreenWidth(6)),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Visibility(
                          visible: isOnline,
                          child: Container(
                            width: 10,
                            height: 10,
                            margin: EdgeInsets.only(right: 3, top: 3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                        Flexible(
                          child: InterText(
                            title: titleDetails,
                            fontSize: 10.5,
                            textAlign: TextAlign.center,
                            maxLines: 3,
                            textColor: AppColors.black.withOpacity(.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
