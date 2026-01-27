import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/services/api/model/doctor_list_response_model.dart';
import '../../../core/services/api/model/patient_list_model.dart';
import '../../../core/services/api/model/appointment_doctor_model.dart';
import '../../../core/services/utils/config/app_colors.dart';
import '../../../core/services/utils/keys/shared_pref_keys.dart';
import '../../../core/services/utils/size_config.dart';
import '../../../core/services/utils/assets/app_assets.dart';
import '../../../core/services/utils/global_variables.dart';
import '../../../features/global_widgets/common_network_image_widget.dart';
import '../../../features/global_widgets/custom_button.dart';
import '../../../features/global_widgets/inter_text.dart';
import '../../more/view/card_skelton_screen.dart';
import '../../../l10n/app_localizations.dart';
import '../../more/view/promos_screen.dart';
import '../controller/reason_for_visit_controller.dart';

class AppointmentOverviewScreen extends StatelessWidget {
  const AppointmentOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final l10n = AppLocalizations.of(context)!;

    final args = Get.arguments as Map<String, dynamic>?;
    final MyPatient? patientData = args?['patientData'] as MyPatient?;
    final Doctor? selectedDoctor = args?['selectedDoctor'] as Doctor?;
    final Appointment? appointment = args?['appointment'] as Appointment?;

    // If required navigation arguments are missing, show a simple
    // error UI instead of throwing a type cast exception.
    if (patientData == null || selectedDoctor == null) {
      return Scaffold(body: Center(child: Text(l10n.invalid_appointment_data)));
    }

    final controller = Get.find<ReasonForVisitController>();

    // Make sure promo application can update the same appointment instance
    // used by the UI (BLoC keeps the appointment in its cubit state).
    if (controller.selectedAppointment.value == null && appointment != null) {
      controller.selectedAppointment.value = appointment;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.black,
          onPressed: () => Get.back(),
        ),
        title: InterText(title: l10n.overview),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          left: getProportionateScreenWidth(20),
          right: getProportionateScreenWidth(20),
          bottom: getProportionateScreenWidth(20),
        ),
        child: Obx(() {
          final isLoading = controller.isLoading.value;
          return CustomButton(
            title: l10n.proceedNext,
            callBackFunction: () async {
              if (isLoading) return;
              final selectedAppointmentId =
                  controller.selectedAppointment.value?.id ??
                  appointment?.id ??
                  '';

              final prefs = await SharedPreferences.getInstance();
              await prefs.setString(agoraChannelId, selectedAppointmentId);
              await prefs.setString(agoraDocName, selectedDoctor.name ?? '');
              await prefs.setString(agoraDocPhoto, selectedDoctor.photo ?? '');

              await controller.initiatePayment({
                'appointment': selectedAppointmentId,
                'paymentGateway': 'sslcommerz',
                'patientData': patientData,
                'selectedDoctor': selectedDoctor,
              });
            },
          );
        }),
      ),
      body: Stack(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    _DoctorTile(doctor: selectedDoctor),
                    const SizedBox(height: 10),
                    _PatientTile(patient: patientData),
                    const SizedBox(height: 10),
                    Obx(() {
                      final model =
                          controller.selectedAppointment.value ?? appointment;
                      return _PaymentDetailsTile(appointment: model);
                    }),
                    const SizedBox(height: 10),
                    _PromoTile(
                      appointmentId:
                          (controller.selectedAppointment.value?.id ??
                                  appointment?.id ??
                                  '')
                              .toString(),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
          Obx(
            () => controller.isLoading.value
                ? const NewsCardSkelton()
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _PromoTile extends StatelessWidget {
  const _PromoTile({required this.appointmentId});

  final String appointmentId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: () {
        // Open Promos screen similar to BLoC flow
        Get.to(() => PromosScreen(appointmentId: appointmentId));
      },
      child: Container(
        width: SizeConfig.screenWidth,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.colorEFEFEF),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SvgPicture.asset(AppAssets.promos),
                const SizedBox(width: 8),
                InterText(title: l10n.do_you_have_any_promo_code, fontSize: 12),
              ],
            ),
            const Icon(
              Icons.keyboard_arrow_right_outlined,
              color: AppColors.color888E9D,
            ),
          ],
        ),
      ),
    );
  }
}

class _DoctorTile extends StatelessWidget {
  const _DoctorTile({required this.doctor});

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
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.colorEFEFEF),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InterText(
            title: AppLocalizations.of(context)!.doctor_info,
            fontSize: 12,
            textColor: AppColors.color888E9D,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              SizedBox(
                height: getProportionateScreenHeight(60),
                width: getProportionateScreenHeight(60),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(60),
                  child: CommonNetworkImageWidget(
                    imageLink: (doctor.photo ?? ''),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InterText(
                      title: doctor.name ?? '',
                      fontWeight: FontWeight.bold,
                      maxLines: 2,
                      fontSize: 16,
                    ),
                    const SizedBox(height: 6),
                    if (specialties.isNotEmpty)
                      InterText(
                        title: specialties,
                        fontSize: 12,
                        textColor: AppColors.color888E9D,
                      ),
                    const SizedBox(height: 3),
                    if (hospitals.isNotEmpty)
                      InterText(title: hospitals, fontSize: 12),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PatientTile extends StatelessWidget {
  const _PatientTile({required this.patient});

  final MyPatient patient;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: SizeConfig.screenWidth,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.colorEFEFEF),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const InterText(
            title: 'Patient info',
            fontSize: 12,
            textColor: AppColors.color888E9D,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              SizedBox(
                height: getProportionateScreenHeight(60),
                width: getProportionateScreenHeight(60),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(60),
                  child: CommonNetworkImageWidget(
                    imageLink: (patient.photo ?? ''),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InterText(
                      title: patient.name ?? '',
                      fontWeight: FontWeight.bold,
                      maxLines: 2,
                      fontSize: 16,
                    ),
                    const SizedBox(height: 6),
                    if ((patient.relation ?? '').isNotEmpty)
                      InterText(
                        title: patient.relation ?? '',
                        fontSize: 12,
                        textColor: AppColors.color888E9D,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaymentDetailsTile extends StatelessWidget {
  const _PaymentDetailsTile({required this.appointment});

  final Appointment? appointment;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: SizeConfig.screenWidth,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.colorEFEFEF),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 17),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const InterText(
                  title: 'Payment Details',
                  fontSize: 12,
                  textColor: AppColors.color888E9D,
                ),
                const SizedBox(height: 5),
                _PaymentDetailsDataRow(
                  title: 'Consultation fee',
                  amount:
                      '$getCurrencySymbol ${(appointment?.totalAmount ?? 0)}',
                ),
                const SizedBox(height: 5),
                _PaymentDetailsDataRow(
                  title: 'Vat (5%)',
                  amount: '$getCurrencySymbol ${(appointment?.vat ?? 0)}',
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              return Flex(
                direction: Axis.horizontal,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  (constraints.constrainWidth() / 10).floor(),
                  (index) => const SizedBox(
                    width: 6,
                    height: 1,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: AppColors.colorEFEFEF),
                    ),
                  ),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 17),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                _PaymentDetailsDataRow(
                  title: 'Total',
                  amount:
                      '$getCurrencySymbol ${(appointment?.grandTotal ?? 0)}',
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentDetailsDataRow extends StatelessWidget {
  const _PaymentDetailsDataRow({required this.title, required this.amount});

  final String title;
  final String amount;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InterText(title: title, fontSize: 14),
        InterText(title: amount, fontSize: 14),
      ],
    );
  }
}
