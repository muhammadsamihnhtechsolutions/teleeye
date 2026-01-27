import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/api/model/doctor_list_response_model.dart';
import '../../../core/services/api/model/patient_list_model.dart';
import '../../../core/services/api/model/appointment_doctor_model.dart';
import '../../../core/services/utils/config/app_colors.dart';
import '../../../features/global_widgets/inter_text.dart';
import '../../../l10n/app_localizations.dart';

class PaymentInfoScreen extends StatelessWidget {
  const PaymentInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final args = Get.arguments as Map<String, dynamic>?;
    final String url = args?['url'] as String;
    final MyPatient patientData = args?['patientData'] as MyPatient;
    final Doctor selectedDoctor = args?['selectedDoctor'] as Doctor;
    final Appointment? appointment = args?['appointment'] as Appointment?;
    final String appointmentId = (appointment?.id ?? '').toString();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.black,
          onPressed: () => Get.back(),
        ),
        title: InterText(title: l10n.payment),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () async {
            Get.toNamed(
              '/payment-gateway',
              arguments: {
                'url': url,
                'appointmentId': appointmentId,
                'patientData': patientData,
                'selectedDoctor': selectedDoctor,
              },
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: InterText(
            title: l10n.pay_now,
            textColor: Colors.white,
            fontSize: 16,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DoctorSummary(doctor: selectedDoctor),
            const SizedBox(height: 16),
            _PatientSummary(patient: patientData),
            const SizedBox(height: 16),
            _PaymentDetails(appointment: appointment),
          ],
        ),
      ),
    );
  }
}

class _DoctorSummary extends StatelessWidget {
  const _DoctorSummary({required this.doctor});

  final Doctor doctor;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.colorEFEFEF),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InterText(
            title: l10n.doctor_info,
            fontSize: 12,
            textColor: AppColors.color888E9D,
          ),
          const SizedBox(height: 8),
          InterText(
            title: doctor.name ?? l10n.unknown_doctor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ],
      ),
    );
  }
}

class _PatientSummary extends StatelessWidget {
  const _PatientSummary({required this.patient});

  final MyPatient patient;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.colorEFEFEF),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InterText(
            title: l10n.patient_info,
            fontSize: 12,
            textColor: AppColors.color888E9D,
          ),
          const SizedBox(height: 8),
          InterText(
            title: patient.name ?? l10n.patient_info,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ],
      ),
    );
  }
}

class _PaymentDetails extends StatelessWidget {
  const _PaymentDetails({required this.appointment});

  final Appointment? appointment;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.colorEFEFEF),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InterText(
            title: l10n.payment_details,
            fontSize: 12,
            textColor: AppColors.color888E9D,
          ),
          const SizedBox(height: 8),
          _PaymentRow(
            title: l10n.consultation_fee,
            amount: appointment?.totalAmount?.toString() ?? '0',
          ),
          const SizedBox(height: 4),
          _PaymentRow(
            title: l10n.vat_five_percent,
            amount: appointment?.vat?.toString() ?? '0',
          ),
          const SizedBox(height: 8),
          _PaymentRow(
            title: l10n.total,
            amount: appointment?.grandTotal?.toString() ?? '0',
          ),
        ],
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({required this.title, required this.amount});

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
