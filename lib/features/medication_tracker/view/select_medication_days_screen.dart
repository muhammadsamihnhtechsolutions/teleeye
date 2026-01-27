import 'package:eye_buddy/core/services/utils/config/app_colors.dart';
import 'package:eye_buddy/features/global_widgets/custom_button.dart';
import 'package:eye_buddy/features/global_widgets/inter_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SelectMedicationDaysScreen extends StatefulWidget {
  const SelectMedicationDaysScreen({super.key, required this.initialDays});

  final List<String> initialDays;

  @override
  State<SelectMedicationDaysScreen> createState() =>
      _SelectMedicationDaysScreenState();
}

class _SelectMedicationDaysScreenState
    extends State<SelectMedicationDaysScreen> {
  late final RxList<String> _selected;

  static const _allDays = <String>[
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];

  @override
  void initState() {
    super.initState();
    _selected = widget.initialDays.toList().obs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const InterText(title: 'Select Days'),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: CustomButton(
          title: 'Done',
          callBackFunction: () {
            Get.back(result: _selected.toList());
          },
        ),
      ),
      body: Obx(() {
        final selectedSnapshot = _selected.toList();
        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: _allDays.length,
          itemBuilder: (context, index) {
            final day = _allDays[index];
            final isChecked = selectedSnapshot.contains(day);
            return ListTile(
              tileColor: Colors.white,
              title: InterText(title: day),
              trailing: Checkbox(
                value: isChecked,
                activeColor: AppColors.primaryColor,
                onChanged: (v) {
                  if (v == true) {
                    if (!_selected.contains(day)) _selected.add(day);
                  } else {
                    _selected.remove(day);
                  }
                },
              ),
              onTap: () {
                if (isChecked) {
                  _selected.remove(day);
                } else {
                  _selected.add(day);
                }
              },
            );
          },
        );
      }),
    );
  }
}
