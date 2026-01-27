import 'package:eye_buddy/core/services/utils/config/app_colors.dart';
import 'package:eye_buddy/core/services/utils/size_config.dart';
import 'package:eye_buddy/features/global_widgets/common_app_bar.dart';
import 'package:eye_buddy/features/global_widgets/custom_button.dart';
import 'package:eye_buddy/features/global_widgets/custom_text_field.dart';
import 'package:eye_buddy/features/global_widgets/inter_text.dart';
import 'package:eye_buddy/features/global_widgets/toast.dart';
import 'package:eye_buddy/features/more/controller/edit_prescription_controller.dart';
import 'package:eye_buddy/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditPrescriptionScreen extends StatefulWidget {
  const EditPrescriptionScreen({
    super.key,
    required this.screenName,
    required this.prescriptionId,
    required this.title,
    this.isFromTestResultScreen = false,
    this.isFromPrescriptionScreen = false,
  });

  final String screenName;
  final bool isFromTestResultScreen;
  final bool isFromPrescriptionScreen;
  final String prescriptionId;
  final String title;

  @override
  State<EditPrescriptionScreen> createState() => _EditPrescriptionScreenState();
}

class _EditPrescriptionScreenState extends State<EditPrescriptionScreen> {
  late final TextEditingController titleController;
  late final EditPrescriptionController controller;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.title);
    controller = Get.put(EditPrescriptionController());
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
        title: widget.screenName,
        elevation: 0,
        icon: Icons.arrow_back,
        finishScreen: true,
        isTitleCenter: false,
        context: context,
      ),
      bottomNavigationBar: Obx(
        () {
          final isLoading = controller.isLoading.value;
          return Padding(
            padding: EdgeInsets.only(
              left: getProportionateScreenWidth(20),
              right: getProportionateScreenWidth(20),
              bottom: getProportionateScreenWidth(20),
            ),
            child: isLoading
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
                        InterText(
                          title: localLanguage.loading,
                          textColor: AppColors.primaryColor,
                        ),
                      ],
                    ),
                  )
                : CustomButton(
                    title: localLanguage.save,
                    callBackFunction: () async {
                      if (titleController.text.trim().isEmpty) {
                        showToast(
                          message: 'Please give title',
                          context: context,
                          backgroundColor: AppColors.colorF14F4A,
                        );
                        return;
                      }

                      final id = widget.prescriptionId;
                      final title = titleController.text.trim();

                      (bool success, String message) result;

                      if (widget.isFromTestResultScreen) {
                        result = await controller.updateClinicalPrescription(
                          id: id,
                          title: title,
                        );
                      } else {
                        result = await controller.updatePatientPrescription(
                          id: id,
                          title: title,
                        );
                      }

                      final success = result.$1;
                      final message = result.$2.isNotEmpty
                          ? result.$2
                          : (success
                              ? 'Prescription updated successfully'
                              : 'Something went wrong');

                      showToast(
                        message: message,
                        context: context,
                      );

                      if (success) {
                        titleController.text = '';
                        Get.back();
                      }
                    },
                  ),
          );
        },
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: getProportionateScreenHeight(8)),
            InterText(
              title: widget.isFromTestResultScreen
                  ? localLanguage.title
                  : localLanguage.prescription_title,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              textColor: AppColors.color001B0D,
            ),
            SizedBox(height: getProportionateScreenHeight(8)),
            CustomTextFormField(
              textEditingController: titleController,
              hint: localLanguage.title,
              sufffixOnTapFunction: () {},
              suffixSvgPath: '',
              textInputType: TextInputType.text,
            ),
          ],
        ),
      ),
    );
  }
}
