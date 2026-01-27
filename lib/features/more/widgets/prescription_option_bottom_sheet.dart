import 'package:eye_buddy/core/services/api/model/prescription_list_response_model.dart';
import 'package:eye_buddy/core/services/utils/config/app_colors.dart';
import 'package:eye_buddy/core/services/utils/size_config.dart';
import 'package:eye_buddy/features/global_widgets/common_size_box.dart';
import 'package:eye_buddy/features/global_widgets/inter_text.dart';
import 'package:eye_buddy/features/more/controller/more_controller.dart';
import 'package:eye_buddy/features/more/view/edit_prescription_screen.dart';
import 'package:eye_buddy/features/medication_tracker/controller/medication_tracker_controller.dart';
import 'package:eye_buddy/features/medication_tracker/view/add_or_edit_medication_screen.dart';
import 'package:eye_buddy/core/services/api/model/medication_tracker_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PrescriptionOptionBottomSheet extends StatelessWidget {
  const PrescriptionOptionBottomSheet({
    super.key,
    required this.prescription,
    this.showAddToMedicine = true,
  });

  final Prescription prescription;
  final bool showAddToMedicine;

  List<(String name, String instructions)> _apiMedicineItems() {
    final medicines = prescription.medicines ?? const [];
    return medicines
        .map((m) => ((m.name ?? '').trim(), (m.instructions ?? '').trim()))
        .where((it) => it.$1.isNotEmpty || it.$2.isNotEmpty)
        .toList();
  }

  Future<void> _showNoMedicineDialog(BuildContext ctx) async {
    await showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('No medicine prescribed'),
        content: const Text("Doctor didn't prescribe you any medicine."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _showMedicineSelectionDialog({
    required BuildContext ctx,
    required List<(String name, String instructions)> medicines,
  }) async {
    final selectedIndices = <int>{};

    await showDialog(
      context: ctx,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Select Medicines'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Choose the medicines you want to add to My Medicine.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.color888E9D,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(medicines.length, (index) {
                    final medicine = medicines[index];
                    final isSelected = selectedIndices.contains(index);
                    return InkWell(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            selectedIndices.remove(index);
                          } else {
                            selectedIndices.add(index);
                          }
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.colorE6F2EE
                              : AppColors.colorFBFBFB,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primaryColor
                                : AppColors.colorEDEDED,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Checkbox(
                              value: isSelected,
                              activeColor: AppColors.primaryColor,
                              onChanged: (value) {
                                setState(() {
                                  if (value == true) {
                                    selectedIndices.add(index);
                                  } else {
                                    selectedIndices.remove(index);
                                  }
                                });
                              },
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SelectableText(
                                    medicine.$1.isNotEmpty
                                        ? medicine.$1
                                        : 'Medicine ${index + 1}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (medicine.$2.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    SelectableText(
                                      medicine.$2,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.color777777,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          actions: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryColor,
                side: const BorderSide(color: AppColors.primaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  if (selectedIndices.length == medicines.length) {
                    selectedIndices.clear();
                  } else {
                    selectedIndices.addAll(
                      List.generate(medicines.length, (i) => i),
                    );
                  }
                });
              },
              child: Text(
                selectedIndices.length == medicines.length
                    ? 'Deselect All'
                    : 'Select All',
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: selectedIndices.isEmpty
                  ? null
                  : () {
                      Navigator.of(context).pop();
                      _addSelectedMedicines(medicines, selectedIndices);
                    },
              child: const Text('Add Selected'),
            ),
          ],
        ),
      ),
    );
  }

  void _addSelectedMedicines(
    List<(String name, String instructions)> medicines,
    Set<int> selectedIndices,
  ) async {
    if (selectedIndices.isEmpty) return;

    final sortedIndices = selectedIndices.toList()..sort();

    // Navigate to each selected medicine sequentially
    for (final index in sortedIndices) {
      if (index >= 0 && index < medicines.length) {
        final medicine = medicines[index];

        // Navigate to add medication screen
        await Get.to(
          () => AddOrEditMedicationScreen(
            isEdit: false,
            medication: Medication(
              title: medicine.$1.isNotEmpty ? medicine.$1 : 'Medicine',
              description: medicine.$2,
              time: const [],
            ),
          ),
        );

        // Small delay between navigations to ensure smooth transitions
        if (index != sortedIndices.last) {
          await Future.delayed(const Duration(milliseconds: 300));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final moreController = Get.find<MoreController>();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AppColors.white,
      ),
      padding: EdgeInsets.all(getProportionateScreenWidth(20)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CommonSizeBox(height: getProportionateScreenHeight(7)),
          if (showAddToMedicine) ...[
            InkWell(
              onTap: () async {
                final rootContext = Get.overlayContext ?? Get.context;
                Get.back();

                if (!Get.isRegistered<MedicationTrackerController>()) {
                  Get.put(MedicationTrackerController());
                }

                Future<void> openDialogWithPrefill({
                  required String name,
                  required String desc,
                }) async {
                  final ctx = rootContext;
                  if (ctx == null) return;
                  final nameController = TextEditingController(text: name);
                  final descController = TextEditingController(text: desc);

                  await showDialog(
                    context: ctx,
                    builder: (_) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      title: const Text('Add to My Medicine'),
                      content: Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(ctx).viewInsets.bottom,
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: nameController,
                                decoration: const InputDecoration(
                                  labelText: 'Medicine name',
                                  filled: true,
                                  fillColor: AppColors.colorFBFBFB,
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: AppColors.colorEDEDED,
                                    ),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: descController,
                                maxLines: 3,
                                decoration: const InputDecoration(
                                  labelText: 'Doctor instructions',
                                  filled: true,
                                  fillColor: AppColors.colorFBFBFB,
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: AppColors.colorEDEDED,
                                    ),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      actions: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.primaryColor,
                                    side: const BorderSide(
                                      color: AppColors.primaryColor,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                  onPressed: () {
                                    Get.back();
                                  },
                                  child: const Text('Cancel'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                  onPressed: () {
                                    final nameValue = nameController.text
                                        .trim();
                                    final descValue = descController.text
                                        .trim();
                                    Get.back();

                                    Get.to(
                                      () => AddOrEditMedicationScreen(
                                        isEdit: false,
                                        medication: Medication(
                                          title: nameValue.isEmpty
                                              ? 'Medicine'
                                              : nameValue,
                                          description: descValue,
                                          time: const [],
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Continue',
                                    style: TextStyle(color: AppColors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final ctx = rootContext;
                if (ctx == null) return;

                final items = _apiMedicineItems();
                if (items.isEmpty) {
                  await _showNoMedicineDialog(ctx);
                  return;
                }

                if (items.length == 1) {
                  final one = items.first;
                  await openDialogWithPrefill(name: one.$1, desc: one.$2);
                  return;
                }

                await _showMedicineSelectionDialog(ctx: ctx, medicines: items);
              },
              child: InterText(
                title: 'Add to My Medicine',
                fontSize: 14,
                textColor: AppColors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
            CommonSizeBox(height: getProportionateScreenWidth(5)),
            Container(
              height: 1,
              width: double.infinity,
              color: AppColors.colorEDEDED,
              margin: EdgeInsets.symmetric(vertical: 20),
            ),
          ],
          InkWell(
            onTap: () {
              Get.back();
              Get.to(
                () => EditPrescriptionScreen(
                  screenName: 'Edit Prescription',
                  isFromPrescriptionScreen: true,
                  prescriptionId: prescription.sId ?? '',
                  title: prescription.title ?? '',
                ),
              );
            },
            child: InterText(
              title: 'Edit',
              fontSize: 14,
              textColor: AppColors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
          CommonSizeBox(height: getProportionateScreenWidth(5)),
          Container(
            height: 1,
            width: double.infinity,
            color: AppColors.colorEDEDED,
            margin: EdgeInsets.symmetric(vertical: 20),
          ),
          InkWell(
            onTap: () async {
              final id = prescription.sId;
              if (id != null && id.isNotEmpty) {
                await moreController.deletePrescription(id);
              }
              Get.back();
            },
            child: InterText(
              title: 'Delete',
              fontSize: 14,
              textColor: AppColors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
