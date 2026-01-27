import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dotted_border/dotted_border.dart';

import '../../../core/services/api/model/doctor_list_response_model.dart';
import '../../../core/services/api/model/patient_list_model.dart';
import '../../../core/services/api/service/api_constants.dart';
import '../../../core/services/utils/config/app_colors.dart';
import '../../../core/services/utils/assets/app_assets.dart';
import '../../../core/services/utils/input_formatters/max_int_text_input_formatter.dart';
import '../../../core/services/utils/size_config.dart';
import '../../../features/global_widgets/common_network_image_widget.dart';
import '../../../features/global_widgets/custom_button.dart';
import '../../../features/global_widgets/custom_text_field.dart';
import '../../../features/global_widgets/inter_text.dart';
import '../../../features/global_widgets/toast.dart';
import '../../../features/bootom_navbar_screen/views/bottom_navbar_screen.dart';
import '../../../l10n/app_localizations.dart';
import '../controller/reason_for_visit_controller.dart';

class ReasonForVisitScreen extends StatelessWidget {
  const ReasonForVisitScreen({
    super.key,
    required this.patientData,
    required this.selectedDoctor,
  });

  final MyPatient patientData;
  final Doctor selectedDoctor;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ReasonForVisitController>(
      init: ReasonForVisitController(),
      builder: (controller) {
        return _ReasonForVisitView(
          controller: controller,
          patientData: patientData,
          selectedDoctor: selectedDoctor,
        );
      },
    );
  }
}

class _ReasonForVisitView extends StatefulWidget {
  const _ReasonForVisitView({
    required this.controller,
    required this.patientData,
    required this.selectedDoctor,
  });

  final ReasonForVisitController controller;
  final MyPatient patientData;
  final Doctor selectedDoctor;

  @override
  State<_ReasonForVisitView> createState() => _ReasonForVisitViewState();
}

class _ReasonForVisitViewState extends State<_ReasonForVisitView> {
  late TextEditingController ageController;
  late TextEditingController weightController;
  late TextEditingController reasonController;
  late TextEditingController descriptionController;

  String _lastHandledError = '';
  bool _isProceedLocked = false;

  @override
  void initState() {
    super.initState();
    ageController = TextEditingController();
    weightController = TextEditingController();
    reasonController = TextEditingController();
    descriptionController = TextEditingController();

    // Initialize with patient data
    ageController.text = widget.patientData.dateOfBirth == null
        ? ""
        : _getYearsOld(widget.patientData.dateOfBirth!);
    weightController.text = widget.patientData.weight == null
        ? ""
        : widget.patientData.weight!;
  }

  @override
  void dispose() {
    ageController.dispose();
    weightController.dispose();
    reasonController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  String _getYearsOld(String dateOfBirth) {
    try {
      final birthDate = DateTime.parse(dateOfBirth);
      final now = DateTime.now();
      int age = now.year - birthDate.year;
      if (now.month < birthDate.month ||
          (now.month == birthDate.month && now.day < birthDate.day)) {
        age--;
      }
      return age.toString();
    } catch (e) {
      return '';
    }
  }

  Future<String> _getCountryID() async {
    // This should return the country ID based on location
    // For now, returning Bangladesh as default
    return "Bangladesh";
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final l10n = AppLocalizations.of(context)!;

    return Obx(() {
      final isBusy = widget.controller.isLoading.value || _isProceedLocked;

      return Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                color: Colors.black,
                onPressed: () {
                  widget.controller.clearState();
                  Get.back();
                },
              ),
              title: InterText(title: l10n.reason_for_visit),
            ),
            bottomNavigationBar: Padding(
              padding: EdgeInsets.only(
                left: getProportionateScreenWidth(20),
                right: getProportionateScreenWidth(20),
                bottom: getProportionateScreenWidth(20),
              ),
              child: Stack(
                children: [
                  CustomButton(
                    title: l10n.proceedNext,
                    callBackFunction: () {
                      if (isBusy) return;
                      _onProceedNext();
                    },
                  ),
                  if (isBusy)
                    Positioned.fill(
                      child: AbsorbPointer(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            body: Stack(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 16),
                              _PatientTile(patientData: widget.patientData),
                              const SizedBox(height: 16),
                              _AgeWeightFields(
                                ageController: ageController,
                                weightController: weightController,
                              ),
                              const SizedBox(height: 16),
                              InterText(
                                title: l10n.appointment_reason_optional,
                                fontSize: 11,
                              ),
                              const SizedBox(height: 10),
                              CustomTextFormField(
                                textEditingController: reasonController,
                              ),
                              const SizedBox(height: 16),
                              _EyePhotoSection(controller: widget.controller),
                              const SizedBox(height: 16),
                              InterText(
                                title: l10n.describe_the_problem,
                                fontSize: 11,
                              ),
                              const SizedBox(height: 10),
                              CustomTextFormField(
                                textEditingController: descriptionController,
                                hint: l10n.describe_problem_hint,
                                maxLines: 5,
                              ),
                              const SizedBox(height: 16),
                              InterText(
                                title: l10n
                                    .attach_reports_previous_prescriptions_optional,
                                fontSize: 11,
                              ),
                              const SizedBox(height: 10),
                              _AttachReportsButton(
                                controller: widget.controller,
                                patientId: widget.patientData.id ?? '',
                              ),
                              const SizedBox(height: 12),
                            ],
                          ),
                        ),
                        _PrescriptionFilesList(controller: widget.controller),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
                Obx(() {
                  final message = widget.controller.errorMessage.value.trim();
                  if (message.isEmpty) {
                    _lastHandledError = '';
                    return const SizedBox.shrink();
                  }

                  if (_lastHandledError == message) {
                    return const SizedBox.shrink();
                  }

                  _lastHandledError = message;

                  WidgetsBinding.instance.addPostFrameCallback((_) async {
                    if (!mounted) return;

                    final isOffline = message.toLowerCase().contains('offline');
                    if (!isOffline) {
                      showToast(message: message, context: context);
                      widget.controller.errorMessage.value = '';
                      return;
                    }

                    await Get.dialog(
                      AlertDialog(
                        title: Text(l10n.offline),
                        content: Text(l10n.doctor_is_offline_try_again_later),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                      barrierDismissible: true,
                    );

                    widget.controller.errorMessage.value = '';
                    widget.controller.clearState();
                    if (!mounted) return;
                    Get.offAll(() => const BottomNavBarScreen());
                  });

                  return const SizedBox.shrink();
                }),
              ],
            ),
          ),
          if (isBusy)
            Positioned.fill(
              child: AbsorbPointer(
                child: Container(
                  color: Colors.black26,
                  child: const Center(child: CircularProgressIndicator()),
                ),
              ),
            ),
        ],
      );
    });
  }

  void _onProceedNext() async {
    if (_isProceedLocked) return;
    setState(() => _isProceedLocked = true);

    final l10n = AppLocalizations.of(context)!;
    if (ageController.text.isEmpty) {
      showToast(message: l10n.please_enter_age_try_again, context: context);
      if (mounted) setState(() => _isProceedLocked = false);
      return;
    }
    final ageValue = int.tryParse(ageController.text.trim());
    if (ageValue == null || ageValue > 999) {
      showToast(
        message: 'Age must be 999 or less',
        context: context,
      );
      if (mounted) setState(() => _isProceedLocked = false);
      return;
    }
    if (weightController.text.isEmpty) {
      showToast(message: l10n.please_enter_weight_try_again, context: context);
      if (mounted) setState(() => _isProceedLocked = false);
      return;
    }
    final weightValue = int.tryParse(weightController.text.trim());
    if (weightValue == null || weightValue > 999) {
      showToast(
        message: AppLocalizations.of(context)!.weight_max_999,
        context: context,
      );
      if (mounted) setState(() => _isProceedLocked = false);
      return;
    }
    if (descriptionController.text.isEmpty) {
      showToast(
        message: l10n.please_enter_problem_description_try_again,
        context: context,
      );
      if (mounted) setState(() => _isProceedLocked = false);
      return;
    }
    if (widget.controller.eyePhotoList.isEmpty) {
      showToast(
        message: 'Please attach at least one eye photo to proceed',
        context: context,
      );
      if (mounted) setState(() => _isProceedLocked = false);
      return;
    }

    try {
      await widget.controller.saveAppointment({
        "appointmentType": "regular",
        "patient": widget.patientData.id,
        "doctor": widget.selectedDoctor.id,
        "age": ageController.text,
        "weight": weightController.text,
        "reason": reasonController.text,
        "description": descriptionController.text,
        "locationGenre": await _getCountryID() == "Bangladesh"
            ? "local"
            : "foreigner",
        "patientData": widget.patientData,
        "selectedDoctor": widget.selectedDoctor,
      });
    } finally {
      if (mounted) setState(() => _isProceedLocked = false);
    }
  }
}

class _PatientTile extends StatelessWidget {
  const _PatientTile({required this.patientData});

  final MyPatient patientData;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.color888E9D.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          SizedBox(
            height: 50,
            width: 50,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: patientData.photo != null && patientData.photo!.isNotEmpty
                  ? CommonNetworkImageWidget(
                      imageLink:
                          '${ApiConstants.imageBaseUrl}${patientData.photo!}',
                    )
                  : Container(
                      color: AppColors.color888E9D.withOpacity(0.2),
                      child: const Icon(
                        Icons.person,
                        color: AppColors.color888E9D,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InterText(
                  title: patientData.name ?? 'Unknown',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                if (patientData.relation != null &&
                    patientData.relation!.isNotEmpty)
                  InterText(
                    title: patientData.relation!,
                    fontSize: 12,
                    textColor: AppColors.color888E9D,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AgeWeightFields extends StatelessWidget {
  const _AgeWeightFields({
    required this.ageController,
    required this.weightController,
  });

  final TextEditingController ageController;
  final TextEditingController weightController;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InterText(title: 'Age', fontSize: 11),
              const SizedBox(height: 10),
              CustomTextFormField(
                textEditingController: ageController,
                textInputType: TextInputType.number,
                containsSuffix: true,
                sufffixOnTapFunction: () {},
                suffixSvgPath: AppAssets.years,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                  const MaxIntTextInputFormatter(max: 999),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InterText(title: 'Weight', fontSize: 11),
              const SizedBox(height: 10),
              CustomTextFormField(
                textEditingController: weightController,
                textInputType: TextInputType.number,
                containsSuffix: true,
                sufffixOnTapFunction: () {},
                suffixSvgPath: AppAssets.kgSmall,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                  const MaxIntTextInputFormatter(max: 999),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EyePhotoSection extends StatelessWidget {
  const _EyePhotoSection({required this.controller});

  final ReasonForVisitController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() {
          final hasPhotos = controller.eyePhotoList.isNotEmpty;
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InterText(
                title: 'Attach your eye photo *',
                fontSize: 11,
                textColor:
                    hasPhotos ? Colors.black : AppColors.colorF14F4A,
              ),
              GestureDetector(
                onTap: _showExampleImages,
                child: InterText(
                  title: 'See example',
                  fontSize: 11,
                  textColor: const Color.fromARGB(25, 209, 193, 193),
                ),
              ),
            ],
          );
        }),
        const SizedBox(height: 4),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              const SizedBox(width: 20),
              _EyePhotoList(controller: controller),
              _AddEyePhotoButton(onTap: () => controller.selectImage(context)),
              const SizedBox(width: 20),
            ],
          ),
        ),
      ],
    );
  }

  void _showExampleImages() {
    Get.dialog(
      Dialog(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Gap(4),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InterText(
                      title: "Example Images",
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close, color: AppColors.black),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Column(
                children: [
                  SizedBox(
                    width: double.maxFinite,
                    child: Image.asset(AppAssets.eye_example_one),
                  ),
                  SizedBox(
                    width: double.maxFinite,
                    child: Image.asset(AppAssets.eye_example_two),
                  ),
                  SizedBox(
                    width: double.maxFinite,
                    child: Image.asset(AppAssets.eye_example_three),
                  ),
                ],
              ),
              CustomButton(title: 'Close', callBackFunction: () => Get.back()),
            ],
          ),
        ),
      ),
    );
  }
}

class _EyePhotoList extends StatelessWidget {
  const _EyePhotoList({required this.controller});

  final ReasonForVisitController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Row(
        children: List.generate(
          controller.eyePhotoList.length,
          (index) => Padding(
            padding: const EdgeInsets.only(right: 10),
            child: _EyeImageWidget(
              image: controller.eyePhotoList[index],
              onDelete: () => controller.deleteEyePhoto(position: index),
            ),
          ),
        ),
      );
    });
  }
}

class _EyeImageWidget extends StatelessWidget {
  const _EyeImageWidget({required this.image, required this.onDelete});

  final XFile image;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      width: 90,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primaryColor),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(image.path),
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          Positioned(
            top: 6,
            right: 6,
            child: GestureDetector(
              onTap: onDelete,
              child: Container(
                height: 25,
                width: 25,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(25)),
                  color: Colors.white,
                ),
                child: const Icon(Icons.delete, color: Colors.red, size: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddEyePhotoButton extends StatelessWidget {
  const _AddEyePhotoButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 90,
        width: 90,
        decoration: BoxDecoration(
          color: AppColors.colorEFEFEF,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.colorBBBBBB),
        ),
        child: Align(
          child: SizedBox(
            height: 45,
            width: 45,
            child: SvgPicture.asset(AppAssets.addMoreWithEye),
          ),
        ),
      ),
    );
  }
}

class _AttachReportsButton extends StatefulWidget {
  const _AttachReportsButton({
    required this.controller,
    required this.patientId,
  });

  final ReasonForVisitController controller;
  final String patientId;

  @override
  State<_AttachReportsButton> createState() => _AttachReportsButtonState();
}

class _AttachReportsButtonState extends State<_AttachReportsButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.bottomSheet(
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),
                  Center(
                    child: Container(
                      height: 4,
                      width: 44,
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Attach documents',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    leading: const Icon(Icons.history),
                    title: const Text('Attach last prescription'),
                    onTap: () async {
                      Get.back();
                      await widget.controller.selectLastPrescriptionFromLibrary(
                        patientId: widget.patientId,
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.description),
                    title: const Text('Choose from prescriptions'),
                    onTap: () async {
                      Get.back();
                      await widget.controller.selectPrescriptionFromLibrary(
                        patientId: widget.patientId,
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.upload_file),
                    title: const Text('Upload from device'),
                    onTap: () async {
                      Get.back();
                      await widget.controller.selectPrescriptionFile();
                    },
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          isScrollControlled: true,
        );
      },
      child: DottedBorder(
        borderType: BorderType.RRect,
        color: AppColors.color888E9D,
        radius: const Radius.circular(5),
        padding: const EdgeInsets.all(1),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(5)),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 22,
                  width: 22,
                  child: SvgPicture.asset(AppAssets.addMoreWithEye),
                ),
                const SizedBox(width: 16),
                const InterText(
                  title: 'Attach reports & prescriptions',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  textColor: AppColors.color888E9D,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PrescriptionFilesList extends StatelessWidget {
  const _PrescriptionFilesList({required this.controller});

  final ReasonForVisitController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.reportAndPrescriptionList.isEmpty) {
        return const SizedBox.shrink();
      }

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            const SizedBox(width: 20),
            ...List.generate(
              controller.reportAndPrescriptionList.length,
              (index) => Padding(
                padding: const EdgeInsets.only(right: 10),
                child: _PrescriptionFileWidget(
                  file: controller.reportAndPrescriptionList[index],
                  onDelete: () =>
                      controller.deletePatientPrescriptionFile(position: index),
                ),
              ),
            ),
            const SizedBox(width: 20),
          ],
        ),
      );
    });
  }
}

class _PrescriptionFileWidget extends StatelessWidget {
  const _PrescriptionFileWidget({required this.file, required this.onDelete});

  final File file;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isPdf = file.path.toLowerCase().endsWith('pdf');

    return Container(
      height: 90,
      width: 90,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primaryColor),
        color: Colors.black,
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: isPdf
                ? const Icon(Icons.description, color: Colors.white, size: 40)
                : Image.file(
                    file,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
          ),
          Positioned(
            top: 6,
            right: 6,
            child: GestureDetector(
              onTap: onDelete,
              child: Container(
                height: 25,
                width: 25,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(25)),
                  color: Colors.white,
                ),
                child: const Icon(Icons.delete, color: Colors.red, size: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
