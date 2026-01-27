import 'package:eye_buddy/core/services/api/model/medication_tracker_model.dart';
import 'package:eye_buddy/core/services/utils/config/app_colors.dart';
import 'package:eye_buddy/core/services/utils/dimentions.dart';
import 'package:eye_buddy/core/services/utils/size_config.dart';
import 'package:eye_buddy/features/global_widgets/custom_loader.dart';
import 'package:eye_buddy/features/global_widgets/custom_text_field.dart';
import 'package:eye_buddy/features/global_widgets/filled_button.dart';
import 'package:eye_buddy/features/global_widgets/inter_text.dart';
import 'package:eye_buddy/features/global_widgets/toast.dart';
import 'package:eye_buddy/l10n/app_localizations.dart';
import 'package:eye_buddy/features/medication_tracker/controller/medication_tracker_controller.dart';
import 'package:eye_buddy/features/medication_tracker/view/select_medication_days_screen.dart';
import 'package:eye_buddy/features/medication_tracker/widgets/medication_day_list_widget.dart';
import 'package:eye_buddy/features/medication_tracker/widgets/medication_time_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AddOrEditMedicationScreen extends StatefulWidget {
  const AddOrEditMedicationScreen({
    super.key,
    this.isEdit = false,
    this.medication,
  });

  final bool isEdit;
  final Medication? medication;

  @override
  State<AddOrEditMedicationScreen> createState() =>
      _AddOrEditMedicationScreenState();
}

class _AddOrEditMedicationScreenState extends State<AddOrEditMedicationScreen> {
  late final MedicationTrackerController _controller;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final RxList<String> _timeList = <String>[].obs;
  final RxList<String> _dayList = <String>[].obs;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<MedicationTrackerController>();

    final med = widget.medication;
    if (med != null) {
      _titleController.text = med.title ?? '';
      _descriptionController.text = med.description ?? '';
      _timeList.assignAll(med.time);
      _dayList.assignAll(_daysFromMedication(med));
    } else {
      _timeList.clear();
      _dayList.clear();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  List<String> _daysFromMedication(Medication m) {
    final days = <String>[];
    if (m.sun == true) days.add('Sunday');
    if (m.mon == true) days.add('Monday');
    if (m.tue == true) days.add('Tuesday');
    if (m.wed == true) days.add('Wednesday');
    if (m.thu == true) days.add('Thursday');
    if (m.fri == true) days.add('Friday');
    if (m.sat == true) days.add('Saturday');
    return days;
  }

  String _formatTimeOfDay(TimeOfDay timeOfDay) {
    final time = DateTime(0, 0, 0, timeOfDay.hour, timeOfDay.minute);
    return DateFormat.Hm().format(time);
  }

  Medication _buildMedication() {
    final med = widget.medication ?? Medication(time: const []);

    med.title = _titleController.text.trim();
    med.description = _descriptionController.text.trim();
    med.time = _timeList.toList();

    med.sun = _dayList.contains('Sunday');
    med.mon = _dayList.contains('Monday');
    med.tue = _dayList.contains('Tuesday');
    med.wed = _dayList.contains('Wednesday');
    med.thu = _dayList.contains('Thursday');
    med.fri = _dayList.contains('Friday');
    med.sat = _dayList.contains('Saturday');

    return med;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    SizeConfig().init(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: InterText(
          title: widget.isEdit ? 'Editing Medication' : 'Create Medication',
        ),
      ),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return Container(
            height: getHeight(context: context),
            width: getWidth(context: context),
            color: Colors.white,
            child: const CustomLoader(),
          );
        }

        return Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  const InterText(
                    title: 'Medication Title',
                    textColor: AppColors.color888E9D,
                    fontSize: 11,
                  ),
                  const SizedBox(height: 8),
                  CustomTextFormField(
                    hint: 'Enter Medication Title',
                    textEditingController: _titleController,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^[a-zA-Z0-9\s]*$'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const InterText(
                    title: 'Medication Description',
                    textColor: AppColors.color888E9D,
                    fontSize: 11,
                  ),
                  const SizedBox(height: 8),
                  CustomTextFormField(
                    hint: 'Enter Medication Description',
                    textEditingController: _descriptionController,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^[a-zA-Z0-9\s]*$'),
                      ),
                    ],
                    maxLines: 5,
                  ),
                  const SizedBox(height: 16),
                  Obx(() {
                    return MedicationTimeListWidget(
                      timeList: _timeList.toList(),
                      isEditOrUpdate: true,
                      onRemoveTime: (raw) {
                        _timeList.remove(raw);
                      },
                      onEditTime: (raw) async {
                        // Replace existing time with a newly picked value.
                        final old = raw;
                        final parts = old.split(':');
                        final initial = (parts.length >= 2)
                            ? TimeOfDay(
                                hour: int.tryParse(parts[0]) ?? 0,
                                minute: int.tryParse(parts[1]) ?? 0,
                              )
                            : TimeOfDay.now();

                        final picked = await showTimePicker(
                          context: context,
                          initialTime: initial,
                          builder: (pickerContext, child) {
                            if (child == null) return const SizedBox.shrink();
                            final base = Theme.of(pickerContext);
                            final mq = MediaQuery.of(pickerContext);
                            return MediaQuery(
                              data: mq.copyWith(textScaleFactor: 1.0),
                              child: Theme(
                                data: base.copyWith(
                                  timePickerTheme: TimePickerThemeData(
                                    dayPeriodColor:
                                        MaterialStateColor.resolveWith((
                                          states,
                                        ) {
                                          if (states.contains(
                                            MaterialState.selected,
                                          )) {
                                            return AppColors.primaryColor;
                                          }
                                          return AppColors.colorEDEDED;
                                        }),
                                    dayPeriodTextColor:
                                        MaterialStateColor.resolveWith((
                                          states,
                                        ) {
                                          if (states.contains(
                                            MaterialState.selected,
                                          )) {
                                            return Colors.white;
                                          }
                                          return AppColors.black;
                                        }),
                                    dayPeriodBorderSide: const BorderSide(
                                      color: AppColors.primaryColor,
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: child,
                              ),
                            );
                          },
                        );
                        if (picked == null) return;

                        final next = _formatTimeOfDay(picked);
                        if (next == old) return;

                        // Disallow duplicates.
                        if (_timeList.contains(next)) {
                          _timeList.remove(old);
                          return;
                        }

                        final idx = _timeList.indexOf(old);
                        if (idx >= 0) {
                          _timeList[idx] = next;
                        }
                      },
                      addNewTimeCallBackFunction: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                          builder: (pickerContext, child) {
                            if (child == null) return const SizedBox.shrink();
                            final base = Theme.of(pickerContext);
                            final mq = MediaQuery.of(pickerContext);
                            return MediaQuery(
                              data: mq.copyWith(textScaleFactor: 1.0),
                              child: Theme(
                                data: base.copyWith(
                                  timePickerTheme: TimePickerThemeData(
                                    dayPeriodColor:
                                        MaterialStateColor.resolveWith((
                                          states,
                                        ) {
                                          if (states.contains(
                                            MaterialState.selected,
                                          )) {
                                            return AppColors.primaryColor;
                                          }
                                          return AppColors.colorEDEDED;
                                        }),
                                    dayPeriodTextColor:
                                        MaterialStateColor.resolveWith((
                                          states,
                                        ) {
                                          if (states.contains(
                                            MaterialState.selected,
                                          )) {
                                            return Colors.white;
                                          }
                                          return AppColors.black;
                                        }),
                                    dayPeriodBorderSide: const BorderSide(
                                      color: AppColors.primaryColor,
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: child,
                              ),
                            );
                          },
                        );
                        if (time == null) return;
                        final t = _formatTimeOfDay(time);
                        if (!_timeList.contains(t)) {
                          _timeList.add(t);
                        }
                      },
                    );
                  }),
                  const SizedBox(height: 16),
                  Obx(() {
                    return MedicationDayListWidget(
                      dayList: _dayList.toList(),
                      showAddDayButton: true,
                      addNewDayCallBackFunction: () async {
                        final result = await Get.to<List<String>>(
                          () => SelectMedicationDaysScreen(
                            initialDays: _dayList.toList(),
                          ),
                        );
                        if (result != null) {
                          _dayList.assignAll(result);
                        }
                      },
                    );
                  }),
                  const SizedBox(height: kToolbarHeight * 2),
                ],
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: GetFilledButton(
                title: widget.isEdit
                    ? l10n.update_medication
                    : l10n.create_medication,
                callBackFunction: () async {
                  if (_titleController.text.trim().isEmpty) {
                    showToast(
                      message: l10n.please_enter_title,
                      context: context,
                    );
                    return;
                  }
                  if (_timeList.isEmpty) {
                    showToast(message: l10n.please_add_time, context: context);
                    return;
                  }
                  if (_dayList.isEmpty) {
                    showToast(message: l10n.please_add_day, context: context);
                    return;
                  }

                  final med = _buildMedication();
                  final ok = widget.isEdit
                      ? await _controller.updateMedication(med)
                      : await _controller.createMedication(med);

                  if (!mounted) return;

                  if (ok) {
                    showToast(
                      message: widget.isEdit
                          ? l10n.medication_updated_successfully
                          : l10n.medication_created_successfully,
                      context: context,
                    );
                    Get.back();
                  } else {
                    showToast(
                      message: _controller.errorMessage.value.isNotEmpty
                          ? _controller.errorMessage.value
                          : l10n.something_went_wrong,
                      context: context,
                    );
                  }
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}
