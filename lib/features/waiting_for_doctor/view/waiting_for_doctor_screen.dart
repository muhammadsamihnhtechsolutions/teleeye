import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/controler/app_state_controller.dart';
import '../../../core/services/api/model/appointment_doctor_model.dart';
import '../../../core/services/api/repo/api_repo.dart';
import '../../../core/services/api/model/doctor_list_response_model.dart';
import '../../../core/services/api/model/patient_list_model.dart';
import '../../../core/services/utils/assets/app_assets.dart';
import '../../../core/services/utils/config/app_colors.dart';
import '../../../core/services/utils/size_config.dart';
import '../../../core/services/widgets/support_bottom_nav_bar.dart';
import '../../../features/global_widgets/common_network_image_widget.dart';
import '../../../features/global_widgets/inter_text.dart';
import '../../../features/login/controller/profile_controller.dart';

import '../../../l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../features/bootom_navbar_screen/views/bottom_navbar_screen.dart';

class WaitingForDoctorScreen extends StatefulWidget {
  const WaitingForDoctorScreen({super.key});

  @override
  State<WaitingForDoctorScreen> createState() => _WaitingForDoctorScreenState();
}

class _WaitingForDoctorScreenState extends State<WaitingForDoctorScreen> {
  final ApiRepo _apiRepo = ApiRepo();

  Timer? _pollTimer;
  String _appointmentId = '';
  MyPatient? _patientData;
  Doctor? _selectedDoctor;
  QueueStatus? _queueStatus;

  Map<String, dynamic> _readArgsMap() {
    final args = Get.arguments;
    if (args is Map) {
      return args.map((k, v) => MapEntry(k.toString(), v));
    }
    return <String, dynamic>{};
  }

  MyPatient? _parsePatient(dynamic raw) {
    if (raw is MyPatient) return raw;
    if (raw is Map) {
      return MyPatient.fromMap(raw.map((k, v) => MapEntry(k.toString(), v)));
    }
    return null;
  }

  Doctor? _parseDoctor(dynamic raw) {
    if (raw is Doctor) return raw;
    if (raw is Map) {
      return Doctor.fromJson(raw.map((k, v) => MapEntry(k.toString(), v)));
    }
    return null;
  }

  QueueStatus? _parseQueueStatus(dynamic raw) {
    if (raw is QueueStatus) return raw;
    if (raw is Map) {
      return QueueStatus.fromJson(raw.map((k, v) => MapEntry(k.toString(), v)));
    }
    return null;
  }

  Widget _buildBookingStatus(AppLocalizations l10n, bool isLoading) {
    if (isLoading) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 15),
          InterText(
            title: l10n.loading,
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(AppAssets.checkbox),
        const SizedBox(height: 15),
        InterText(
          title: l10n.congrats,
          textAlign: TextAlign.center,
        ),
        InterText(
          title: l10n.appointment_booked_successfully,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Future<void> _refreshQueueStatus() async {
    final safeAppointmentId = _appointmentId.trim();
    if (safeAppointmentId.isEmpty) return;

    try {
      // Resolve patientId from argument first, then fall back to profile.
      var patientId = (_patientData?.id ?? '').toString().trim();

      if (patientId.isEmpty) {
        final profileCtrl = Get.isRegistered<ProfileController>()
            ? Get.find<ProfileController>()
            : Get.put(ProfileController());
        if (profileCtrl.profileData.value.profile == null) {
          await profileCtrl.getProfileData();
        }
        patientId = (profileCtrl.profileData.value.profile?.sId ?? '')
            .toString()
            .trim();
      }

      if (patientId.isEmpty) return;

      final resp = await _apiRepo.getAppointments('upcoming', patientId);
      final parsed = GetAppointmentApiResponse.fromJson(
        resp as Map<String, dynamic>,
      );

      final docs =
          parsed.appointmentList?.appointmentData ?? <AppointmentData>[];
      final match = docs.firstWhereOrNull(
        (a) => (a.id ?? '').toString() == safeAppointmentId,
      );
      final latestQueue = match?.queueStatus;
      if (latestQueue == null) return;

      if (!mounted) return;
      setState(() {
        _queueStatus = latestQueue;
      });
    } catch (_) {
      // ignore
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _refreshQueueStatus(),
    );
  }

  Future<bool> _handleBack() async {
    Get.offAll(() => const BottomNavBarScreen());
    return false;
  }

  @override
  void initState() {
    super.initState();
    final args = _readArgsMap();
    _appointmentId = (args['appointmentId'] ?? '').toString();
    _patientData = _parsePatient(args['patientData']);
    _selectedDoctor = _parseDoctor(args['selectedDoctor']);
    _queueStatus = _parseQueueStatus(args['queueStatus']);
    _startPolling();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshQueueStatus();
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final l10n = AppLocalizations.of(context)!;
    final QueueStatus? queueStatus = _queueStatus;
    final appStateController = Get.isRegistered<AppStateController>()
        ? Get.find<AppStateController>()
        : null;

    final size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: _handleBack,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: Colors.black,
            onPressed: () {
              _handleBack();
            },
          ),
          title: InterText(title: l10n.waiting_for_doctor),
        ),
        body: SizedBox(
          height: size.height,
          width: size.width,
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        WaitingForDoctorDoctorTile(
                          selectedDoctor:
                              _selectedDoctor ??
                              Doctor(
                                name: l10n.unknown_doctor,
                                id: '',
                                photo: '',
                                experienceInYear: 0,
                                averageRating: 0,
                                specialty: const [],
                              ),
                          patientData: _patientData,
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: size.width,
                          child: appStateController == null
                              ? _buildBookingStatus(l10n, false)
                              : Obx(() {
                                  final isLoading = appStateController
                                      .isPaymentVerificationInProgress
                                      .value;
                                  return _buildBookingStatus(
                                    l10n,
                                    isLoading,
                                  );
                                }),
                        ),
                        const SizedBox(height: 30),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: _selectedDoctor?.name ?? '',
                                style: interTextStyle.copyWith(
                                  fontSize: 14,
                                  color: AppColors.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: l10n.will_call_you_soon,
                                style: interTextStyle.copyWith(
                                  fontSize: 14,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        InterText(
                          title:
                              l10n.dont_turn_off_your_internet_doctor_will_call,
                          fontSize: 14,
                          textColor: AppColors.color888E9D,
                        ),
                        const SizedBox(height: 20),
                        Container(
                          height: 1,
                          width: size.width,
                          color: AppColors.color888E9D.withOpacity(.2),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                InterText(
                                  title: l10n.estimated_wait_time,
                                  textColor: AppColors.color888E9D,
                                  fontSize: 14,
                                ),
                                const SizedBox(height: 8),
                                InterText(
                                  title:
                                      '${queueStatus?.waitingTimeInMin ?? 0} ${l10n.mins}',
                                ),
                              ],
                            ),
                            const SizedBox(width: 20),
                            Column(
                              children: [
                                InterText(
                                  title: l10n.patients_before_you,
                                  textColor: AppColors.color888E9D,
                                  fontSize: 14,
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: AppColors.primaryColor,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 14,
                                  ),
                                  alignment: Alignment.center,
                                  child: InterText(
                                    title:
                                        '${queueStatus?.totalQueueCount ?? 0}',
                                    textColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        GestureDetector(
                          onTap: () {
                            _handleBack();
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.primaryColor),
                              color: Colors.white,
                            ),
                            alignment: Alignment.center,
                            child: InterText(
                              title: 'Go to Home',
                              textColor: AppColors.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: kToolbarHeight),
                      ],
                    ),
                  ),
                ),
              ),
              const SupportBottomNavBar(),
            ],
          ),
        ),
      ),
    );
  }
}

class WaitingForDoctorDoctorTile extends StatelessWidget {
  const WaitingForDoctorDoctorTile({
    super.key,
    required this.patientData,
    required this.selectedDoctor,
  });

  final MyPatient? patientData;
  final Doctor selectedDoctor;

  @override
  Widget build(BuildContext context) {
    final specialties = selectedDoctor.specialty
        .map((e) => e.title)
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
      child: Row(
        children: [
          SizedBox(
            height: getProportionateScreenHeight(60),
            width: getProportionateScreenHeight(60),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(60),
              child: CommonNetworkImageWidget(
                imageLink: (selectedDoctor.photo ?? ''),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InterText(
                  title: selectedDoctor.name ?? '',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                const SizedBox(height: 6),
                InterText(
                  title: specialties,
                  fontSize: 10,
                  textColor: AppColors.color888E9D,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              color: AppColors.colorCCE7D9,
            ),
            alignment: Alignment.center,
            child: InterText(
              title: AppLocalizations.of(context)!.paid,
              fontSize: 10,
              textColor: AppColors.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
