import 'package:eye_buddy/core/services/utils/config/app_colors.dart';
import 'package:eye_buddy/core/services/utils/dimentions.dart';
import 'package:eye_buddy/features/global_widgets/filled_button.dart';
import 'package:eye_buddy/features/global_widgets/inter_text.dart';
import 'package:eye_buddy/features/medication_tracker/widgets/medication_time_and_day_chip.dart';
import 'package:flutter/material.dart';

class MedicationDayListWidget extends StatelessWidget {
  const MedicationDayListWidget({
    super.key,
    required this.dayList,
    required this.addNewDayCallBackFunction,
    this.showAddDayButton = false,
  });

  final List<String> dayList;
  final bool showAddDayButton;
  final Function addNewDayCallBackFunction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: getWidth(context: context),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const InterText(
            title: 'Day',
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 10),
          Container(
            width: getWidth(context: context),
            height: 41,
            alignment: dayList.length == 6
                ? Alignment.center
                : Alignment.centerLeft,
            child: dayList.length == 7
                ? const InterText(
                    title: 'Every day',
                    textColor: AppColors.primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  )
                : dayList.isEmpty
                ? const InterText(
                    title: 'Add medication day schedule',
                    textColor: AppColors.color888E9D,
                    fontSize: 12,
                  )
                : ListView.builder(
                    itemCount: dayList.length,
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return MedicationTimeAndDayChip(text: dayList[index]);
                    },
                  ),
          ),
          if (showAddDayButton) ...[
            const SizedBox(height: 25),
            GetFilledButton(
              title: 'Custom',
              callBackFunction: () {
                addNewDayCallBackFunction();
              },
              titleColor: AppColors.primaryColor,
              buttonColor: AppColors.colorCCE7D9,
              buttonRadius: 5,
              buttonHeight: 40,
            ),
          ],
        ],
      ),
    );
  }
}
