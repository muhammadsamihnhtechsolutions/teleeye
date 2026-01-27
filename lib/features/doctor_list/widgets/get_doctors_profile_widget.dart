import 'package:eye_buddy/core/services/api/model/doctor_list_response_model.dart';
import 'package:eye_buddy/core/services/api/service/api_constants.dart';
import 'package:eye_buddy/core/services/utils/config/app_colors.dart';
import 'package:eye_buddy/core/services/utils/size_config.dart';
import 'package:eye_buddy/features/doctor_list/controller/doctor_profile_controller.dart';
import 'package:eye_buddy/features/global_widgets/common_network_image_widget.dart';
import 'package:eye_buddy/features/global_widgets/inter_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

class GetDoctorsProfile extends StatelessWidget {
  const GetDoctorsProfile({
    super.key,
    required this.isFromFavoriteList,
    required this.doctor,
  });

  final bool isFromFavoriteList;
  final Doctor? doctor;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DoctorProfileController>();
    return Row(
      children: [
        SizedBox(
          height: getProportionateScreenHeight(100),
          width: getProportionateScreenHeight(100),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: CommonNetworkImageWidget(imageLink: (doctor?.photo ?? '')),
          ),
        ),
        SizedBox(width: getProportionateScreenWidth(16)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InterText(
                title: doctor?.name ?? 'Doctor',
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InterText(
                    title:
                        doctor?.specialty
                            .map((e) => e.title)
                            .toList()
                            .join(", ") ??
                        '',
                    fontSize: 12,
                    textColor: AppColors.color888E9D,
                  ),
                  const SizedBox(height: 2),
                  InterText(
                    title:
                        doctor?.hospital
                            .map((e) => e.name)
                            .toList()
                            .join(", ") ??
                        '',
                    fontSize: 12,
                  ),
                  const SizedBox(height: 12),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (controller.isFavoriteLoading.value) return;
                        controller.toggleFavorite();
                      },
                      child: Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: AppColors.color008541,
                        ),
                        alignment: Alignment.center,
                        child: Obx(() {
                          if (controller.isFavoriteLoading.value) {
                            return const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(
                                  AppColors.white,
                                ),
                              ),
                            );
                          }

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                doctor?.isFavorite ?? false
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: Colors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: InterText(
                                    fontSize: 14,
                                    textColor: AppColors.white,
                                    title: doctor?.isFavorite ?? false
                                        ? "Remove from favorites"
                                        : 'Add to favourites',
                                    maxLines: 1,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    onPressed: () {
                      final d = controller.selectedDoctor.value ?? doctor;
                      if (d == null) return;

                      final specialty = (d.specialty)
                          .map((e) => e.title)
                          .whereType<String>()
                          .where((e) => e.trim().isNotEmpty)
                          .toList()
                          .join(', ');
                      final hospital = (d.hospital)
                          .map((e) => e.name)
                          .whereType<String>()
                          .where((e) => e.trim().isNotEmpty)
                          .toList()
                          .join(', ');
                      final photoUrl = (d.photo ?? '').trim().isEmpty
                          ? ''
                          : '${ApiConstants.imageBaseUrl}${d.photo}';

                      final lines = <String>[
                        (d.name ?? '').trim().isEmpty
                            ? 'Doctor'
                            : (d.name ?? '').trim(),
                        if (specialty.isNotEmpty) specialty,
                        if (hospital.isNotEmpty) hospital,
                        if (photoUrl.isNotEmpty) photoUrl,
                      ];

                      final box = context.findRenderObject() as RenderBox?;
                      if (box == null) {
                        Share.share(lines.join('\n'));
                        return;
                      }

                      Share.share(
                        lines.join('\n'),
                        sharePositionOrigin:
                            box.localToGlobal(Offset.zero) & box.size,
                      );
                    },
                    icon: const Icon(
                      Icons.share_outlined,
                      color: AppColors.primaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
