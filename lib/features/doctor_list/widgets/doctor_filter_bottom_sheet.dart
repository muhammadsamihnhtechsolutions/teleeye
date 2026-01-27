import 'package:eye_buddy/core/services/utils/config/app_colors.dart';
import 'package:eye_buddy/features/doctor_list/controller/doctor_list_controller.dart';
import 'package:eye_buddy/features/global_widgets/custom_button.dart';
import 'package:eye_buddy/features/global_widgets/inter_text.dart';
import 'package:eye_buddy/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/api/model/doctor_list_response_model.dart';

class DoctorFilterBottomSheet extends StatelessWidget {
  const DoctorFilterBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = Get.find<DoctorListController>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              InterText(title: l10n.filter, fontWeight: FontWeight.bold),
              GestureDetector(
                onTap: () => Get.back(),
                child: const Icon(Icons.close, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 16),
          InterText(title: l10n.speciality, fontSize: 14),
          const SizedBox(height: 8),
          Obx(
            () => _SpecialtiesDropdown(
              specialties: controller.specialties,
              value: controller.selectedSpecialty.value,
              onChanged: controller.updateSelectedSpecialty,
            ),
          ),
          const SizedBox(height: 12),
          InterText(title: l10n.rating, fontSize: 14),
          const SizedBox(height: 8),
          Obx(
            () => Row(
              children: [
                _RatingChip(
                  title: l10n.up_to_4,
                  isActive: controller.currentRating.value == '4',
                  onTap: () => controller.updateCurrentRating('4'),
                ),
                const SizedBox(width: 8),
                _RatingChip(
                  title: l10n.up_to_4_5,
                  isActive: controller.currentRating.value == '4.5',
                  onTap: () => controller.updateCurrentRating('4.5'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          CustomButton(
            title: l10n.clear_filters,
            callBackFunction: () {
              controller.clearFilters();
              Get.back();
            },
            backGroundColor: Colors.white,
            textColor: Colors.black,
            showBorder: true,
          ),
          CustomButton(
            title: l10n.apply,
            callBackFunction: () {
              controller.applyFilters();
              Get.back();
            },
          ),
        ],
      ),
    );
  }
}

class _SpecialtiesDropdown extends StatelessWidget {
  const _SpecialtiesDropdown({
    required this.specialties,
    required this.value,
    required this.onChanged,
  });

  final List<Specialty> specialties;
  final Specialty? value;
  final ValueChanged<Specialty?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5.0),
        border: Border.all(color: Colors.grey),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 18.0, right: 18.0),
        child: Center(
          child: DropdownButtonHideUnderline(
            child: DropdownButton<Specialty>(
              isExpanded: true,
              alignment: Alignment.center,
              value: value,
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.primaryColor,
                size: 30,
              ),
              elevation: 16,
              style: TextStyle(fontSize: 13, color: Colors.grey[800]),
              onChanged: onChanged,
              hint: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  AppLocalizations.of(context)!.select_a_type,
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              items: specialties.map((e) {
                return DropdownMenuItem<Specialty>(
                  value: e,
                  child: Text(e.title ?? ''),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class _RatingChip extends StatelessWidget {
  const _RatingChip({
    required this.title,
    required this.isActive,
    required this.onTap,
  });

  final String title;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isActive ? AppColors.primaryColor : AppColors.appBackground,
          border: Border.all(color: AppColors.primaryColor.withOpacity(.2)),
        ),
        child: InterText(
          title: title,
          fontSize: 12,
          textColor: isActive ? AppColors.white : AppColors.black,
        ),
      ),
    );
  }
}
