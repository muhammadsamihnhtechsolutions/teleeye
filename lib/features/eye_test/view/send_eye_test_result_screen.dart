import 'package:eye_buddy/core/services/api/model/doctor_list_response_model.dart';
import 'package:eye_buddy/core/services/api/model/patient_list_model.dart';
import 'package:eye_buddy/core/services/utils/config/app_colors.dart';
import 'package:eye_buddy/core/services/utils/size_config.dart';
import 'package:eye_buddy/features/doctor_list/controller/doctor_list_controller.dart';
import 'package:eye_buddy/core/services/api/repo/api_repo.dart';
import 'package:eye_buddy/features/eye_test/controller/eye_test_controller.dart';
import 'package:eye_buddy/features/login/controller/profile_controller.dart';
import 'package:eye_buddy/features/bootom_navbar_screen/views/bottom_navbar_screen.dart';
import 'package:eye_buddy/features/global_widgets/common_app_bar.dart';
import 'package:eye_buddy/features/global_widgets/custom_button.dart';
import 'package:eye_buddy/features/global_widgets/inter_text.dart';
import 'package:eye_buddy/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class SendEyeTestResultScreen extends StatefulWidget {
  const SendEyeTestResultScreen({super.key});

  @override
  State<SendEyeTestResultScreen> createState() =>
      _SendEyeTestResultScreenState();
}

class _SendEyeTestResultScreenState extends State<SendEyeTestResultScreen> {
  late final DoctorListController _doctorController;
  late final EyeTestController _eyeTestController;
  final ApiRepo _apiRepo = ApiRepo();
  final Rx<Doctor?> selectedDoctor = Rx<Doctor?>(null);
  final Rx<MyPatient?> selectedPatient = Rx<MyPatient?>(null);
  final patients = <MyPatient>[].obs;
  final RxBool _isLoadingPatients = false.obs;
  final TextEditingController _messageController = TextEditingController();
  final RxBool _isSending = false.obs;

  @override
  void initState() {
    super.initState();
    _doctorController = Get.isRegistered<DoctorListController>()
        ? Get.find<DoctorListController>()
        : Get.put(DoctorListController());
    _eyeTestController = Get.isRegistered<EyeTestController>()
        ? Get.find<EyeTestController>()
        : Get.put(EyeTestController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final l10n = AppLocalizations.of(Get.context!);
      _messageController.text =
          l10n?.please_review_my_recent_eye_test_results ??
          'Please review my recent eye test results.';
    });

    _fetchPatients();
  }

  Future<void> _fetchPatients() async {
    _isLoadingPatients.value = true;
    try {
      final resp = await _apiRepo.getMyPatientList();
      if (resp.status == 'success' && resp.data != null) {
        patients.assignAll(resp.data!);
        if (selectedPatient.value == null && patients.isNotEmpty) {
          selectedPatient.value = patients.first;
        }
      } else {
        patients.clear();
      }
    } catch (_) {
      patients.clear();
    } finally {
      _isLoadingPatients.value = false;
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    SizeConfig().init(context);

    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: CommonAppBar(
        title: l10n.send_results_to_doctor,
        elevation: 0,
        icon: Icons.arrow_back,
        finishScreen: true,
        isTitleCenter: false,
        context: context,
      ),
      body: Obx(() {
        if (_doctorController.isLoading.value || _isLoadingPatients.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (_doctorController.doctors.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 72,
                    width: 72,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.person_off_outlined,
                      color: AppColors.primaryColor,
                      size: 34,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const InterText(
                    title: 'No doctors available',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const InterText(
                    title:
                        'Please try again later or go back to home to explore other options.',
                    fontSize: 12,
                    textColor: AppColors.color888E9D,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),
                  CustomButton(
                    title: 'Go to Home',
                    callBackFunction: () {
                      Get.offAll(() => const BottomNavBarScreen());
                    },
                  ),
                ],
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const InterText(
                        title: 'Select patient',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      const SizedBox(height: 12),
                      patients.isEmpty
                          ? const InterText(
                              title: 'No patients available',
                              fontSize: 14,
                              textColor: AppColors.color888E9D,
                            )
                          : DropdownButtonFormField<MyPatient>(
                              value: selectedPatient.value,
                              hint: const InterText(title: 'Choose patient...'),
                              items: patients.map((patient) {
                                return DropdownMenuItem(
                                  value: patient,
                                  child: SizedBox(
                                    width: SizeConfig.screenWidth * 0.7,
                                    child: Text(
                                      patient.name ?? '',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                selectedPatient.value = value;
                              },
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                            ),
                      const SizedBox(height: 20),
                      const InterText(
                        title: 'Select a doctor',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<Doctor>(
                        value: selectedDoctor.value,
                        hint: const InterText(title: 'Choose doctor...'),
                        items: _doctorController.doctors.map((doctor) {
                          return DropdownMenuItem(
                            value: doctor,
                            child: SizedBox(
                              width: SizeConfig.screenWidth * 0.7,
                              child: Text(
                                doctor.name ?? '',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          selectedDoctor.value = value;
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppColors.primaryColor,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const InterText(
                        title: 'Message (optional)',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _messageController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Add a note for the doctor...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppColors.primaryColor,
                            ),
                          ),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
              Obx(() {
                final canSend = selectedDoctor.value != null;
                final isBusy = _isSending.value;
                return CustomButton(
                  title: isBusy ? l10n.sending : l10n.send_results,
                  callBackFunction: (canSend && !isBusy)
                      ? () => _sendResults()
                      : () {},
                );
              }),
              const SizedBox(height: 12),
            ],
          ),
        );
      }),
    );
  }

  void _sendResults() async {
    if (_isSending.value) return;
    final doctor = selectedDoctor.value;
    if (doctor == null) return;

    final selectedPatientId = (selectedPatient.value?.id ?? '').trim();

    // Fallback patient ID from ProfileController
    final profilePatientId = Get.isRegistered<ProfileController>()
        ? (Get.find<ProfileController>().profileData.value.profile?.sId ?? '')
        : '';

    final patientId = selectedPatientId.isNotEmpty
        ? selectedPatientId
        : profilePatientId;

    final l10n = AppLocalizations.of(Get.context!)!;

    if (patientId.isEmpty) {
      Get.snackbar(l10n.error, l10n.patient_profile_not_found);
      return;
    }

    if ((doctor.id ?? '').isEmpty) {
      Get.snackbar(l10n.error, l10n.doctor_not_found);
      return;
    }

    final msg = _messageController.text.trim().isNotEmpty
        ? _messageController.text.trim()
        : l10n.please_review_my_recent_eye_test_results;

    final results = _eyeTestController.buildResultsPayloadForSend();
    if (results == null) {
      Get.snackbar(
        l10n.error,
        'Please complete at least one eye test before sending results.',
      );
      return;
    }

    _isSending.value = true;
    try {
      final resp = await _apiRepo.sendEyeTestResultsToDoctor(
        doctorId: doctor.id!,
        patientId: patientId,
        message: msg,
        results: results,
      );

      if (resp.status == 'success') {
        Get.snackbar(
          l10n.sent,
          resp.message ??
              l10n.your_results_have_been_sent_to(
                doctor.name ?? l10n.the_doctor,
              ),
        );
        Get.offAll(() => const BottomNavBarScreen());
      } else {
        Get.snackbar(
          l10n.error,
          resp.message ?? l10n.failed_to_send_results_please_try_again,
        );
      }
    } catch (e) {
      final l10n = AppLocalizations.of(Get.context!)!;
      Get.snackbar(l10n.error, l10n.failed_to_send_results_please_try_again);
    } finally {
      _isSending.value = false;
    }
  }
}
