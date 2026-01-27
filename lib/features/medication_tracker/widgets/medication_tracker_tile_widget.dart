import 'package:eye_buddy/core/services/api/model/medication_tracker_model.dart';
import 'package:eye_buddy/core/services/utils/config/app_colors.dart';
import 'package:eye_buddy/core/services/utils/dimentions.dart';
import 'package:eye_buddy/features/global_widgets/inter_text.dart';
import 'package:eye_buddy/features/medication_tracker/view/medication_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class MedicationTrackerTileWidget extends StatelessWidget {
  const MedicationTrackerTileWidget({super.key, required this.medication});

  final Medication medication;

  String _getDayList() {
    String days = '';
    if (medication.sun == true) days = _append(days, 'Sun');
    if (medication.mon == true) days = _append(days, 'Mon');
    if (medication.tue == true) days = _append(days, 'Tue');
    if (medication.wed == true) days = _append(days, 'Wed');
    if (medication.thu == true) days = _append(days, 'Thu');
    if (medication.fri == true) days = _append(days, 'Fri');
    if (medication.sat == true) days = _append(days, 'Sat');
    return days;
  }

  String _append(String base, String value) {
    if (base.isEmpty) return value;
    return '$base, $value';
  }

  String _getNextTime(List<String> times) {
    final currentTime = DateTime.now();

    final allowedDays = _getDayList();
    final dayMapping = {
      'Sun': DateTime.sunday,
      'Mon': DateTime.monday,
      'Tue': DateTime.tuesday,
      'Wed': DateTime.wednesday,
      'Thu': DateTime.thursday,
      'Fri': DateTime.friday,
      'Sat': DateTime.saturday,
    };

    final allowedWeekdays = allowedDays
        .split(', ')
        .map((d) => dayMapping[d])
        .whereType<int>()
        .toList();

    for (int dayOffset = 0; dayOffset < 7; dayOffset++) {
      final currentDay = currentTime.add(Duration(days: dayOffset));
      if (!allowedWeekdays.contains(currentDay.weekday)) continue;

      for (final timeString in times) {
        final time = DateFormat.Hm().parse(timeString);
        final nextTime = DateTime(
          currentDay.year,
          currentDay.month,
          currentDay.day,
          time.hour,
          time.minute,
        );

        if (nextTime.isAfter(currentTime)) {
          final formattedNextTime = DateFormat.jm().format(nextTime);
          if (dayOffset == 0) return 'Today - $formattedNextTime';
          if (dayOffset == 1) return 'Tomorrow - $formattedNextTime';
          final dayOfWeek = DateFormat.EEEE().format(nextTime);
          return '$dayOfWeek - $formattedNextTime';
        }
      }
    }

    return 'No upcoming medication times found.';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () {
          Get.to(() => MedicationDetailsScreen(medication: medication));
        },
        child: Material(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          shadowColor: AppColors.black.withOpacity(.25),
          child: Container(
            padding: const EdgeInsets.all(15),
            height: 120,
            width: getWidth(context: context),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.white,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InterText(
                        title: medication.title ?? '',
                        maxLines: 1,
                        fontWeight: FontWeight.bold,
                      ),
                      const SizedBox(height: 5),
                      InterText(
                        title: medication.description ?? '',
                        maxLines: 2,
                        fontSize: 12,
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          InterText(
                            title: _getNextTime(medication.time),
                            textColor: AppColors.primaryColor,
                            fontSize: 12,
                          ),
                          const SizedBox(width: 8),
                          _getDayList().isEmpty
                              ? const SizedBox.shrink()
                              : Container(
                                  height: 10,
                                  width: 1,
                                  color: AppColors.primaryColor,
                                ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: InterText(
                              maxLines: 1,
                              title: _getDayList(),
                              textColor: AppColors.primaryColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
