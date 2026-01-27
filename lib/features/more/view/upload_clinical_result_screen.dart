import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:eye_buddy/core/services/utils/assets/app_assets.dart';
import 'package:eye_buddy/core/services/utils/config/app_colors.dart';
import 'package:eye_buddy/core/services/utils/size_config.dart';
import 'package:eye_buddy/features/global_widgets/common_app_bar.dart';
import 'package:eye_buddy/features/global_widgets/common_size_box.dart';
import 'package:eye_buddy/features/global_widgets/custom_button.dart';
import 'package:eye_buddy/features/global_widgets/custom_text_field.dart';
import 'package:eye_buddy/features/global_widgets/inter_text.dart';
import 'package:eye_buddy/features/global_widgets/toast.dart';
import 'package:eye_buddy/features/more/controller/more_controller.dart';
import 'package:eye_buddy/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class UploadClinicalResultScreen extends StatefulWidget {
  const UploadClinicalResultScreen({super.key});

  @override
  State<UploadClinicalResultScreen> createState() =>
      _UploadClinicalResultScreenState();
}

class _UploadClinicalResultScreenState
    extends State<UploadClinicalResultScreen> {
  final TextEditingController titleController = TextEditingController();

  late final MoreController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<MoreController>();
    if (_controller.patients.isEmpty) {
      _controller.fetchPatients();
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: CommonAppBar(
        title: l10n.add_new_test_result,
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
          child: _controller.isUploadingClinicalResult.value
              ? SizedBox(
                  height: kToolbarHeight * 1.5,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      SizedBox(
                        height: 14,
                        width: 14,
                        child: CircularProgressIndicator(
                          color: AppColors.primaryColor,
                          strokeWidth: 1.5,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Loading...',
                        style: TextStyle(color: AppColors.primaryColor),
                      ),
                    ],
                  ),
                )
              : CustomButton(
                  title: l10n.save,
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
                        l10n.please_give_title,
                        backgroundColor: AppColors.colorF14F4A,
                      );
                      return;
                    }
                    if (_controller.selectedClinicalFile.value == null) {
                      safeToast(
                        l10n.please_select_a_prescription,
                        backgroundColor: AppColors.colorF14F4A,
                      );
                      return;
                    }
                    if (_controller.selectedPatient.value == null) {
                      safeToast(
                        l10n.please_select_your_patient,
                        backgroundColor: AppColors.colorF14F4A,
                      );
                      return;
                    }

                    final success = await _controller.uploadClinicalResult(
                      titleController.text.trim(),
                      patientId: _controller.selectedPatient.value?.id,
                    );
                    if (!mounted) return;
                    if (success) {
                      Get.back();
                      safeToast('Success');
                    } else {
                      safeToast(
                        'Something went wrong',
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
                title: l10n.title,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                textColor: AppColors.color001B0D,
              ),
              CommonSizeBox(height: getProportionateScreenHeight(8)),
              CustomTextFormField(
                textEditingController: titleController,
                hint: l10n.title,
              ),
              CommonSizeBox(height: getProportionateScreenHeight(18)),
              InterText(
                title: l10n.clinical_results,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                textColor: AppColors.color001B0D,
              ),
              CommonSizeBox(height: getProportionateScreenHeight(8)),
              Obx(() {
                final XFile? file = _controller.selectedClinicalFile.value;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (file != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        height: getProportionateScreenHeight(150),
                        width: getProportionateScreenHeight(150),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(File(file.path), fit: BoxFit.fill),
                        ),
                      ),
                    InkWell(
                      onTap: () async {
                        await _controller.pickClinicalFile();
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
                                      const InterText(
                                        title:
                                            'Upload reports and previous prescriptions',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        textColor: AppColors.black,
                                      ),
                                      CommonSizeBox(
                                        height: getProportionateScreenHeight(5),
                                      ),
                                      const InterText(
                                        title: 'Format will be JPG, PNG',
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
    final l10n = AppLocalizations.of(context)!;

    return Obx(() {
      final items = controller.patients;
      final selected = controller.selectedPatient.value;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.colorEFEFEF),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton(
            isExpanded: true,
            value: selected,
            hint: InterText(
              title: l10n.select_your_patient,
              textColor: AppColors.color888E9D,
            ),
            items: items
                .map(
                  (p) => DropdownMenuItem(
                    value: p,
                    child: InterText(title: p.name ?? ''),
                  ),
                )
                .toList(),
            onChanged: (val) => controller.setSelectedPatient(val),
          ),
        ),
      );
    });
  }
}
