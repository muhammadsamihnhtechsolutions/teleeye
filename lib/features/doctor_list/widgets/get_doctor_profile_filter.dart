import 'package:eye_buddy/core/services/utils/config/app_colors.dart';
import 'package:eye_buddy/features/doctor_list/controller/doctor_profile_controller.dart';
import 'package:eye_buddy/features/global_widgets/inter_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DoctorProfileFilter extends StatelessWidget {
  const DoctorProfileFilter({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DoctorProfileController>();

    return Container(
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.color80C2A0),
      ),
      padding: const EdgeInsets.all(5),
      child: Obx(
        () => Row(
          children: [
            DoctorProfileFilterChip(
              isActive:
                  controller.currentFilterType.value ==
                  DoctorProfileFilterType.info,
              title: 'Info',
              filterType: DoctorProfileFilterType.info,
            ),
            DoctorProfileFilterChip(
              isActive:
                  controller.currentFilterType.value ==
                  DoctorProfileFilterType.experience,
              title: 'Experience',
              filterType: DoctorProfileFilterType.experience,
            ),
            DoctorProfileFilterChip(
              isActive:
                  controller.currentFilterType.value ==
                  DoctorProfileFilterType.feedback,
              title: 'Feedback',
              filterType: DoctorProfileFilterType.feedback,
            ),
          ],
        ),
      ),
    );
  }
}

class DoctorProfileFilterChip extends StatelessWidget {
  const DoctorProfileFilterChip({
    required this.title,
    required this.isActive,
    required this.filterType,
    super.key,
  });

  final String title;
  final bool isActive;
  final DoctorProfileFilterType filterType;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DoctorProfileController>();

    return Flexible(
      child: GestureDetector(
        onTap: () {
          controller.updateFilterType(filterType);
        },
        child: Container(
          decoration: BoxDecoration(
            color: isActive ? AppColors.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          alignment: Alignment.center,
          child: InterText(
            title: title,
            textColor: isActive ? Colors.white : Colors.black.withOpacity(.7),
            fontSize: 14,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
