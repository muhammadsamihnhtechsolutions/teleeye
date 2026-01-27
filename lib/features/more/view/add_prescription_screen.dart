import 'package:eye_buddy/core/services/utils/config/app_colors.dart';
import 'package:eye_buddy/core/services/utils/assets/app_assets.dart';
import 'package:eye_buddy/core/services/utils/size_config.dart';
import 'package:eye_buddy/features/global_widgets/common_app_bar.dart';
import 'package:eye_buddy/features/global_widgets/common_size_box.dart';
import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:eye_buddy/features/global_widgets/custom_button.dart';
import 'package:eye_buddy/features/global_widgets/custom_text_field.dart';
import 'package:eye_buddy/features/global_widgets/inter_text.dart';
import 'package:eye_buddy/features/global_widgets/toast.dart';
import 'package:eye_buddy/features/more/controller/more_controller.dart';
import 'package:eye_buddy/core/services/api/service/api_constants.dart';
import 'package:eye_buddy/features/global_widgets/common_network_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:eye_buddy/l10n/app_localizations.dart';
import 'package:eye_buddy/core/services/api/model/patient_list_model.dart';

class AddPrescriptionScreen extends StatefulWidget {
  const AddPrescriptionScreen({super.key});

  @override
  State<AddPrescriptionScreen> createState() => _AddPrescriptionScreenState();
}

class _AddPrescriptionScreenState extends State<AddPrescriptionScreen> {
  final TextEditingController titleController = TextEditingController();

  late final MoreController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<MoreController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _controller.fetchPatients();
    });
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final localLanguage = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: CommonAppBar(
        title: localLanguage.add_new_prescription,
        elevation: 0,
        icon: Icons.arrow_back,
        finishScreen: true,
        isTitleCenter: false,
        context: context,
      ),
      bottomNavigationBar: Obx(
        () => Padding(
          padding: EdgeInsets.only(
            left: getProportionateScreenWidth(20),
            right: getProportionateScreenWidth(20),
            bottom: getProportionateScreenWidth(20),
          ),
          child: _controller.isUploadingPrescription.value
              ? SizedBox(
                  height: kToolbarHeight * 1.5,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 14,
                        width: 14,
                        child: CircularProgressIndicator(
                          color: AppColors.primaryColor,
                          strokeWidth: 1.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${localLanguage.loading}...',
                        style: TextStyle(color: AppColors.primaryColor),
                      ),
                    ],
                  ),
                )
              : CustomButton(
                  title: localLanguage.save,
                  callBackFunction: () async {
                    void safeToast(
                      String message, {
                      Color backgroundColor = AppColors.primaryColor,
                    }) {
                      final ctx = Get.context;
                      if (ctx == null) return;
                      showToast(
                        message: message,
                        context: ctx,
                        backgroundColor: backgroundColor,
                      );
                    }

                    if (titleController.text.trim().isEmpty) {
                      safeToast(
                        localLanguage.please_give_title,
                        backgroundColor: AppColors.colorF14F4A,
                      );
                      return;
                    }
                    if (_controller.selectedPrescriptionFile.value == null) {
                      safeToast(
                        'Please select a prescription',
                        backgroundColor: AppColors.colorF14F4A,
                      );
                      return;
                    }

                    if (_controller.selectedPatient.value == null) {
                      safeToast(
                        localLanguage.please_select_your_patient,
                        backgroundColor: AppColors.colorF14F4A,
                      );
                      return;
                    }

                    final success = await _controller.uploadPrescription(
                      titleController.text.trim(),
                      patientId: _controller.selectedPatient.value?.id,
                    );
                    if (!mounted) return;
                    if (success) {
                      Get.back();
                      safeToast('Prescription uploaded');
                    } else {
                      safeToast(
                        'Upload failed, please try again.',
                        backgroundColor: AppColors.colorF14F4A,
                      );
                    }
                  },
                ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: getProportionateScreenWidth(20),
            vertical: getProportionateScreenWidth(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PatientDropdown(controller: _controller),
              CommonSizeBox(height: getProportionateScreenHeight(18)),
              InterText(
                title: localLanguage.prescription_title,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                textColor: AppColors.color001B0D,
              ),
              CommonSizeBox(height: getProportionateScreenHeight(8)),
              CustomTextFormField(
                textEditingController: titleController,
                hint: localLanguage.title,
              ),
              CommonSizeBox(height: getProportionateScreenHeight(18)),
              InterText(
                title: localLanguage.prescription,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                textColor: AppColors.color001B0D,
              ),
              CommonSizeBox(height: getProportionateScreenHeight(8)),
              Obx(() {
                final XFile? file = _controller.selectedPrescriptionFile.value;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (file != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        height: getProportionateScreenHeight(170),
                        width: double.infinity,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(File(file.path), fit: BoxFit.cover),
                        ),
                      ),
                    InkWell(
                      onTap: () async {
                        await _controller.pickPrescriptionFile();
                      },
                      child: DottedBorder(
                        borderType: BorderType.RRect,
                        color: AppColors.color888E9D,
                        radius: const Radius.circular(5),
                        padding: const EdgeInsets.all(1),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(5),
                          ),
                          child: Container(
                            width: SizeConfig.screenWidth,
                            padding: EdgeInsets.symmetric(
                              horizontal: getProportionateScreenHeight(18),
                              vertical: getProportionateScreenWidth(13),
                            ),
                            color: AppColors.white,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      InterText(
                                        title: localLanguage
                                            .upload_reports_and_previous_prescriptions,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        textColor: AppColors.black,
                                      ),
                                      CommonSizeBox(
                                        height: getProportionateScreenHeight(5),
                                      ),
                                      InterText(
                                        title: localLanguage
                                            .format_will_be_jpg_png_pdf,
                                        fontSize: 12,
                                        textColor: AppColors.color777777,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  height: getProportionateScreenWidth(45),
                                  width: getProportionateScreenWidth(45),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    color: AppColors.primaryColor,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: SvgPicture.asset(
                                      AppAssets.upload,
                                      colorFilter: const ColorFilter.mode(
                                        AppColors.white,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
              CommonSizeBox(height: getProportionateScreenHeight(12)),
            ],
          ),
        ),
      ),
    );
  }
}

class _PatientDropdown extends StatelessWidget {
  const _PatientDropdown({required this.controller});

  final MoreController controller;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final localLanguage = AppLocalizations.of(context)!;

    return Obx(() {
      final selected = controller.selectedPatient.value;
      final normalizedSelected = (selected == null)
          ? null
          : controller.patients.cast<MyPatient?>().firstWhere(
              (p) => p?.id != null && p!.id == selected.id,
              orElse: () => null,
            );

      final uniquePatientsById = <String, MyPatient>{};
      for (final p in controller.patients) {
        final id = p.id;
        if (id == null || id.isEmpty) continue;
        uniquePatientsById.putIfAbsent(id, () => p);
      }

      Widget content;
      if (controller.isLoadingPatients.value &&
          uniquePatientsById.values.isEmpty) {
        content = const SizedBox(
          height: 44,
          child: Center(
            child: SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      } else {
        content = DropdownButtonHideUnderline(
          child: DropdownButton<MyPatient>(
            isExpanded: true,
            alignment: Alignment.center,
            value: normalizedSelected,
            icon: const Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.primaryColor,
              size: 30,
            ),
            elevation: 16,
            style: TextStyle(fontSize: 13, color: Colors.grey[800]),
            onChanged: (MyPatient? newValue) {
              controller.setSelectedPatient(newValue);
            },
            hint: Container(
              alignment: Alignment.centerLeft,
              child: Text(
                localLanguage.select_your_patient,
                textAlign: TextAlign.start,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            items: uniquePatientsById.values.map((e) {
              final photo = (e.photo ?? '').trim();
              final imageLink = photo.isEmpty
                  ? ''
                  : (photo.startsWith('http')
                        ? photo
                        : '${ApiConstants.imageBaseUrl}$photo');

              return DropdownMenuItem<MyPatient>(
                value: e,
                child: Row(
                  children: [
                    SizedBox(
                      height: 26,
                      width: 26,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: CommonNetworkImageWidget(imageLink: imageLink),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        e.name ?? '',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      }

      return Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.colorEFEFEF),
        ),
        child: content,
      );
    });
  }
}
