import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/services/utils/config/app_colors.dart';
import '../../../core/services/utils/assets/app_assets.dart';
import '../../../core/services/utils/input_formatters/max_int_text_input_formatter.dart';
import '../../../core/services/utils/size_config.dart';
import '../../../features/global_widgets/inter_text.dart';
import '../../../l10n/app_localizations.dart';
import '../controller/create_patient_profile_controller.dart';

class CreatePatientProfileScreen extends StatelessWidget {
  const CreatePatientProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CreatePatientProfileController>(
      init: CreatePatientProfileController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.appBackground,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: const IconThemeData(color: AppColors.black),
            title: InterText(
              title: AppLocalizations.of(context)!.createPatientProfile,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              textColor: AppColors.black,
            ),
            centerTitle: false,
          ),
          body: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: getProportionateScreenWidth(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        _ProfileImageSection(controller: controller),
                        const SizedBox(height: 24),
                        _NameField(controller: controller),
                        const SizedBox(height: 16),
                        _DOBField(controller: controller),
                        const SizedBox(height: 16),
                        _WeightField(controller: controller),
                        const SizedBox(height: 16),
                        _GenderField(controller: controller),
                        const SizedBox(height: 16),
                        _RelationField(controller: controller),
                        const SizedBox(height: 40),
                        _SaveButton(controller: controller),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
                Obx(
                  () => controller.isLoading.value
                      ? Container(
                          color: Colors.black26,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ProfileImageSection extends StatelessWidget {
  const _ProfileImageSection({required this.controller});

  final CreatePatientProfileController controller;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () => controller.selectProfileImage(context),
        child: Obx(() {
          final hasImage = controller.selectedProfile.value != null;

          return Container(
            height: 120,
            width: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryColor, width: 2),
            ),
            child: hasImage
                ? ClipOval(
                    child: SizedBox.expand(
                      child: Image.file(
                        File(controller.selectedProfile.value!.path),
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                : Container(
                    // color: AppColors.colorEFEFEF,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt,
                            size: 25,
                            color: AppColors.color888E9D,
                          ),
                          const SizedBox(height: 8),
                          InterText(
                            title: AppLocalizations.of(context)!.add_photo,
                            fontSize: 12,
                            textColor: AppColors.color888E9D,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
          );
        }),
      ),
    );
  }
}

class _NameField extends StatelessWidget {
  const _NameField({required this.controller});

  final CreatePatientProfileController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InterText(
          title: AppLocalizations.of(context)!.patient_name,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          textColor: AppColors.black,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller.nameController,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.enter_patient_name,
            hintStyle: const TextStyle(color: AppColors.color888E9D),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.color888E9D),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.color888E9D),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primaryColor),
            ),
          ),
        ),
      ],
    );
  }
}

class _DOBField extends StatelessWidget {
  const _DOBField({required this.controller});

  final CreatePatientProfileController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InterText(
          title: AppLocalizations.of(context)!.date_of_birth,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          textColor: AppColors.black,
        ),
        const SizedBox(height: 8),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () async {
            FocusManager.instance.primaryFocus?.unfocus();

            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now().subtract(
                const Duration(days: 365 * 20),
              ),
              firstDate: DateTime.now().subtract(
                const Duration(days: 365 * 100),
              ),
              lastDate: DateTime.now(),
            );

            if (date != null) {
              controller.dobController.text = DateFormat(
                'MM/dd/yyyy',
              ).format(date);
            }
          },
          child: AbsorbPointer(
            child: TextField(
              controller: controller.dobController,
              readOnly: true,
              showCursor: false,
              enableInteractiveSelection: false,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.select_date_of_birth,
                hintStyle: const TextStyle(color: AppColors.color888E9D),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.color888E9D),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.color888E9D),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.primaryColor),
                ),
                suffixIcon: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: SvgPicture.asset(
                    AppAssets.calender,
                    height: 20,
                    width: 20,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _WeightField extends StatelessWidget {
  const _WeightField({required this.controller});

  final CreatePatientProfileController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InterText(
          title: AppLocalizations.of(context)!.weight,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          textColor: AppColors.black,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller.weightController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(3),
            const MaxIntTextInputFormatter(max: 999),
          ],
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.enter_weight,
            hintStyle: const TextStyle(color: AppColors.color888E9D),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.color888E9D),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.color888E9D),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primaryColor),
            ),
            suffixIcon: Padding(
              padding: const EdgeInsets.all(12),
              child: SvgPicture.asset(AppAssets.kgSmall, width: 20, height: 20),
            ),
          ),
        ),
      ],
    );
  }
}

class _GenderField extends StatelessWidget {
  const _GenderField({required this.controller});

  final CreatePatientProfileController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InterText(
          title: AppLocalizations.of(context)!.gender,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          textColor: AppColors.black,
        ),
        const SizedBox(height: 8),
        Obx(
          () => Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => controller.selectGender('Male'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: controller.genderValue.value == 'Male'
                          ? AppColors.primaryColor
                          : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: controller.genderValue.value == 'Male'
                            ? AppColors.primaryColor
                            : AppColors.color888E9D,
                      ),
                    ),
                    child: InterText(
                      title: AppLocalizations.of(context)!.male,
                      fontSize: 14,
                      textColor: controller.genderValue.value == 'Male'
                          ? Colors.white
                          : AppColors.color888E9D,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: GestureDetector(
                  onTap: () => controller.selectGender('Female'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: controller.genderValue.value == 'Female'
                          ? AppColors.primaryColor
                          : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: controller.genderValue.value == 'Female'
                            ? AppColors.primaryColor
                            : AppColors.color888E9D,
                      ),
                    ),
                    child: InterText(
                      title: AppLocalizations.of(context)!.female,
                      fontSize: 14,
                      textColor: controller.genderValue.value == 'Female'
                          ? Colors.white
                          : AppColors.color888E9D,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RelationField extends StatelessWidget {
  const _RelationField({required this.controller});

  final CreatePatientProfileController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InterText(
          title: AppLocalizations.of(context)!.relation_with_you_optional,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          textColor: AppColors.black,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller.relationWithYouController,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.relation_hint,
            hintStyle: const TextStyle(color: AppColors.color888E9D),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.color888E9D),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.color888E9D),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primaryColor),
            ),
          ),
        ),
      ],
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.controller});

  final CreatePatientProfileController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => ElevatedButton(
        onPressed: controller.isLoading.value ? null : controller.savePatient,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          minimumSize: Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: controller.isLoading.value
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : InterText(
                title: AppLocalizations.of(context)!.save_patient_profile,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                textColor: Colors.white,
              ),
      ),
    );
  }
}
