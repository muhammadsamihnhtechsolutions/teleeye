import 'package:eye_buddy/core/services/api/model/doctor_list_response_model.dart';
import 'package:eye_buddy/core/services/utils/config/app_colors.dart';
import 'package:eye_buddy/core/services/utils/dimentions.dart';
import 'package:eye_buddy/core/services/utils/size_config.dart';
import 'package:eye_buddy/features/global_widgets/inter_text.dart';
import 'package:flutter/material.dart';

class GetDoctorsStatisticsTile extends StatelessWidget {
  const GetDoctorsStatisticsTile({super.key, required this.doctor});

  final Doctor? doctor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.white,
      ),
      height: getProportionateScreenHeight(70),
      width: getWidth(context: context),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InterText(
                title: 'Total Ratings',
                fontSize: 12,
                textColor: AppColors.color888E9D,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  InterText(
                    title: (doctor?.averageRating ?? 0).toString(),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ],
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InterText(
                title: 'Experience in',
                fontSize: 12,
                textColor: AppColors.color888E9D,
              ),
              const SizedBox(height: 4),
              InterText(
                title: (doctor?.experienceInYear ?? 0).toString(),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ],
          ),
          GestureDetector(
            onTap: () async {
              // Clipboard functionality can be added here
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InterText(
                  title: 'BMDC No.',
                  fontSize: 12,
                  textColor: AppColors.color888E9D,
                ),
                const SizedBox(height: 4),
                InterText(
                  title: (doctor?.bmdcCode?.length ?? 0) > 6
                      ? '${doctor?.bmdcCode?.substring(0, 6)}...'
                      : doctor?.bmdcCode ?? 'N/A',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
