import 'package:eye_buddy/core/services/api/model/doctor_list_response_model.dart';
import 'package:eye_buddy/core/services/api/model/patient_list_model.dart';
import 'package:eye_buddy/core/services/api/service/api_constants.dart';
import 'package:eye_buddy/core/services/utils/assets/app_assets.dart';
import 'package:eye_buddy/core/services/utils/config/app_colors.dart';
import 'package:eye_buddy/core/services/utils/size_config.dart';
import 'package:eye_buddy/features/global_widgets/common_app_bar.dart';
import 'package:eye_buddy/features/global_widgets/common_network_image_widget.dart';
import 'package:eye_buddy/features/global_widgets/common_size_box.dart';
import 'package:eye_buddy/features/global_widgets/inter_text.dart';
import 'package:eye_buddy/features/patient_select/controller/patient_select_controller.dart';
import 'package:eye_buddy/l10n/app_localizations.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class PatientSelectScreen extends StatelessWidget {
  const PatientSelectScreen({super.key, required this.doctor});

  final Doctor doctor;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final l10n = AppLocalizations.of(context)!;

    return GetBuilder<PatientSelectController>(
      init: PatientSelectController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.appBackground,
          appBar: CommonAppBar(
            title: l10n.profile,
            elevation: 0,
            icon: Icons.arrow_back,
            finishScreen: true,
            isTitleCenter: false,
            context: context,
          ),
          body: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: getProportionateScreenWidth(20),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: getProportionateScreenHeight(24)),
                  _DoctorShortDetails(doctor: doctor),
                  CommonSizeBox(height: getProportionateScreenHeight(10)),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: InterText(
                      title: l10n.selectPatient,
                      textColor: AppColors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  CommonSizeBox(height: getProportionateScreenHeight(12)),
                  Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (controller.patients.isEmpty) {
                      return InterText(
                        title: controller.errorMessage.value.isNotEmpty
                            ? controller.errorMessage.value
                            : l10n.no_patient_found,
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.patients.length,
                      itemBuilder: (context, index) {
                        final patient = controller.patients[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: GestureDetector(
                            onTap: () =>
                                controller.onPatientSelected(patient, doctor),
                            child: _PatientShortDetails(patient: patient),
                          ),
                        );
                      },
                    );
                  }),
                  CommonSizeBox(height: getProportionateScreenHeight(6)),
                  InterText(
                    title: l10n.or,
                    textColor: AppColors.color888E9D,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  CommonSizeBox(height: getProportionateScreenHeight(16)),
                  GestureDetector(
                    onTap: () => controller.onCreateNewPatient(),
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
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: getProportionateScreenWidth(22),
                                width: getProportionateScreenWidth(22),
                                child: SvgPicture.asset(
                                  AppAssets.createPatient,
                                ),
                              ),
                              CommonSizeBox(
                                width: getProportionateScreenWidth(16),
                              ),
                              InterText(
                                title: l10n.createPatientProfile,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                textColor: AppColors.color888E9D,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: kToolbarHeight * 2),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DoctorShortDetails extends StatelessWidget {
  const _DoctorShortDetails({required this.doctor});

  final Doctor doctor;

  @override
  Widget build(BuildContext context) {
    final specialties = doctor.specialty
        .map((e) => e.title)
        .whereType<String>()
        .toList()
        .join(', ');
    final hospitals = doctor.hospital
        .map((e) => e.name)
        .whereType<String>()
        .toList()
        .join(', ');

    return Container(
      width: SizeConfig.screenWidth,
      margin: EdgeInsets.only(bottom: getProportionateScreenWidth(10)),
      color: Colors.transparent,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: getProportionateScreenHeight(100),
            width: getProportionateScreenHeight(100),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: CommonNetworkImageWidget(imageLink: (doctor.photo ?? '')),
            ),
          ),
          CommonSizeBox(width: getProportionateScreenWidth(12)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: SizeConfig.screenWidth / 2,
                child: InterText(
                  title: doctor.name ?? '',
                  textColor: AppColors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
              if (specialties.isNotEmpty) ...[
                SizedBox(
                  width: SizeConfig.screenWidth / 2,
                  child: InterText(
                    title: specialties,
                    fontSize: 12,
                    textColor: AppColors.color888E9D,
                  ),
                ),
                SizedBox(height: getProportionateScreenHeight(5)),
              ],
              if (hospitals.isNotEmpty) ...[
                SizedBox(
                  width: SizeConfig.screenWidth / 2,
                  child: InterText(
                    title: hospitals,
                    fontSize: 12,
                    textColor: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: getProportionateScreenHeight(6)),
              ],
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                  const SizedBox(width: 4),
                  InterText(
                    title:
                        '${doctor.averageRating ?? 0} (${doctor.ratingCount ?? 0})',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PatientShortDetails extends StatelessWidget {
  const _PatientShortDetails({required this.patient});

  final MyPatient patient;

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
            height: getProportionateScreenWidth(50),
            width: getProportionateScreenWidth(50),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: patient.photo != null && patient.photo!.isNotEmpty
                  ? CommonNetworkImageWidget(
                      imageLink:
                          '${ApiConstants.imageBaseUrl}${patient.photo!}',
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
          CommonSizeBox(width: getProportionateScreenWidth(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InterText(
                  title: patient.name ?? 'Unknown',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                CommonSizeBox(height: getProportionateScreenHeight(4)),
                if (patient.relation != null && patient.relation!.isNotEmpty)
                  InterText(
                    title: patient.relation!,
                    fontSize: 12,
                    textColor: AppColors.color888E9D,
                  ),
                if (patient.dateOfBirth != null)
                  InterText(
                    title: 'DOB: ${patient.dateOfBirth}',
                    fontSize: 12,
                    textColor: AppColors.color888E9D,
                  ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: AppColors.color888E9D,
          ),
        ],
      ),
    );
  }
}
