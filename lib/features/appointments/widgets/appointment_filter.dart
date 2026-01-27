import 'package:eye_buddy/core/services/utils/config/app_colors.dart';
import 'package:eye_buddy/features/appointments/controller/appointment_filter_controller.dart';
import 'package:eye_buddy/features/global_widgets/inter_text.dart';
import 'package:eye_buddy/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppointmentsFilter extends StatelessWidget {
  const AppointmentsFilter({super.key});

  @override
  Widget build(BuildContext context) {
    final localLanguage = AppLocalizations.of(context)!;
    final filterController = Get.find<AppointmentFilterController>();

    return Container(
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.color80C2A0),
      ),
      padding: const EdgeInsets.all(5),
      child: Obx(() {
        return Row(
          children: [
            AppointmentsFilterChip(
              isActive:
                  filterController.appointmentType.value ==
                  AppointmentFilterType.past,
              title: localLanguage.past,
              appointmentType: AppointmentFilterType.past,
            ),
            AppointmentsFilterChip(
              isActive:
                  filterController.appointmentType.value ==
                  AppointmentFilterType.upcoming,
              appointmentType: AppointmentFilterType.upcoming,
              title: localLanguage.upcoming,
            ),
            AppointmentsFilterChip(
              isActive:
                  filterController.appointmentType.value ==
                  AppointmentFilterType.followup,
              title: localLanguage.followup,
              appointmentType: AppointmentFilterType.followup,
            ),
          ],
        );
      }),
    );
  }
}

class AppointmentsFilterChip extends StatelessWidget {
  AppointmentsFilterChip({
    required this.title,
    required this.isActive,
    required this.appointmentType,
    super.key,
  });

  final String title;
  final bool isActive;
  final AppointmentFilterType appointmentType;

  @override
  Widget build(BuildContext context) {
    final filterController = Get.find<AppointmentFilterController>();

    return Flexible(
      child: GestureDetector(
        onTap: () {
          filterController.changeAppointmentType(appointmentType);
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
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
