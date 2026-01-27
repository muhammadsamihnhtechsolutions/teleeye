import 'package:eye_buddy/core/services/api/model/doctor_list_response_model.dart';
import 'package:eye_buddy/core/services/utils/config/app_colors.dart';
import 'package:eye_buddy/core/services/utils/functions.dart';
import 'package:eye_buddy/core/services/utils/global_variables.dart';
import 'package:eye_buddy/core/services/utils/size_config.dart';
import 'package:eye_buddy/features/global_widgets/inter_text.dart';
import 'package:eye_buddy/features/patient_select/view/patient_select_screen.dart';
import 'package:eye_buddy/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GetDoctorProfileBottomBar extends StatelessWidget {
  const GetDoctorProfileBottomBar({super.key, required this.doctorProfile});

  final Doctor? doctorProfile;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      height: getProportionateScreenHeight(90),
      width: SizeConfig.screenWidth,
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InterText(title: l10n.consultationFee, fontSize: 14),
              FutureBuilder(
                builder: (ctx, snapshot) {
                  return InterText(
                    title: '$getCurrencySymbol ${snapshot.data ?? ''}',
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    textColor: AppColors.color008541,
                  );
                },
                initialData: "",
                future: getDoctorConsultationFee(doctor: doctorProfile!),
              ),
            ],
          ),
          GetDoctorsProfileButton(
            icon: Icons.videocam,
            isFilled: true,
            title: l10n.seeDoctorNow,
            height: 45,
            fontSize: 14,
            width: getProportionateScreenWidth(190),
            callBackFunction: () {
              if (doctorProfile!.availabilityStatus != "offline") {
                Get.to(() => PatientSelectScreen(doctor: doctorProfile!));
              } else {
                Get.snackbar(
                  'Offline',
                  l10n.doctor_is_offline_try_again_later,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class GetDoctorsProfileButton extends StatelessWidget {
  const GetDoctorsProfileButton({
    super.key,
    required this.icon,
    required this.isFilled,
    required this.title,
    required this.height,
    required this.fontSize,
    required this.width,
    required this.callBackFunction,
  });

  final IconData icon;
  final bool isFilled;
  final String title;
  final double height;
  final double fontSize;
  final double width;
  final VoidCallback callBackFunction;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: callBackFunction,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: isFilled ? AppColors.primaryColor : Colors.transparent,
          border: isFilled ? null : Border.all(color: AppColors.primaryColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isFilled ? Colors.white : AppColors.primaryColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            InterText(
              title: title,
              fontSize: fontSize,
              textColor: isFilled ? Colors.white : AppColors.primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}
