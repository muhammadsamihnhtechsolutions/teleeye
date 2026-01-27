import 'package:eye_buddy/core/services/api/model/appointment_doctor_model.dart';
import 'package:eye_buddy/core/services/api/model/doctor_list_response_model.dart';
import 'package:eye_buddy/core/services/api/repo/api_repo.dart';
import 'package:eye_buddy/core/services/utils/config/app_colors.dart';
import 'package:eye_buddy/core/services/utils/functions.dart';
import 'package:eye_buddy/core/services/utils/global_variables.dart';
import 'package:eye_buddy/core/services/utils/size_config.dart';
import 'package:eye_buddy/features/appointments/controller/appointment_controller.dart';
import 'package:eye_buddy/features/appointments/controller/appointment_filter_controller.dart';
import 'package:eye_buddy/features/doctor_list/view/doctor_profile_screen.dart';
import 'package:eye_buddy/features/global_widgets/common_network_image_widget.dart';
import 'package:eye_buddy/features/global_widgets/inter_text.dart';
import 'package:eye_buddy/features/global_widgets/toast.dart';
import 'package:eye_buddy/features/more/view/live_support_screen.dart';
import 'package:eye_buddy/features/rating/view/rating_screen.dart';
import 'package:eye_buddy/features/waiting_for_doctor/view/waiting_for_doctor_screen.dart';
import 'package:eye_buddy/l10n/app_localizations.dart';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class AppointmentTileWidget extends StatelessWidget {
  const AppointmentTileWidget({
    super.key,
    required this.appointmentType,
    required this.appointmentData,
  });

  final AppointmentFilterType appointmentType;
  final AppointmentData appointmentData;

  String _formatDate(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      final formatter = DateFormat('dd MMMM yyyy hh:mm a');
      return formatter.format(dateTime);
    } catch (_) {
      return dateTimeString;
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final l10n = AppLocalizations.of(context)!;
    final doctor = appointmentData.doctor;
    final appointmentController = Get.isRegistered<AppointmentController>()
        ? Get.find<AppointmentController>()
        : Get.put(AppointmentController());

    Future<void> _onTap() async {
      if (appointmentType == AppointmentFilterType.upcoming && doctor != null) {
        // Persist patient Agora token for this appointment so
        // CallController can load it when starting the call.
        final token = appointmentData.patientAgoraToken?.toString() ?? '';
        final channelId = appointmentData.channelId?.toString() ?? '';
        final appointmentId = appointmentData.id?.toString() ?? '';

        log('APPOINTMENT TILE: patientAgoraToken → "$token"');
        log('APPOINTMENT TILE: channelId → "$channelId"');
        log('APPOINTMENT TILE: appointmentId → "$appointmentId"');

        if (token.isNotEmpty) {
          try {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('patient_agora_token', token);
            if (appointmentId.isNotEmpty) {
              await prefs.setString(
                'patient_agora_token_$appointmentId',
                token,
              );
            }

            // Use channelId if available, otherwise use appointmentId as fallback
            final finalChannelId = channelId.isNotEmpty
                ? channelId
                : appointmentId;
            if (finalChannelId.isNotEmpty) {
              await prefs.setString('agora_channel_id', finalChannelId);
              if (appointmentId.isNotEmpty) {
                await prefs.setString(
                  'agora_channel_id_$appointmentId',
                  finalChannelId,
                );
              }
              log('APPOINTMENT TILE: Saved channel ID → "$finalChannelId"');
            }
            log(
              'APPOINTMENT TILE: Saved patient_agora_token to SharedPreferences',
            );
          } catch (e) {
            log('APPOINTMENT TILE ERROR: Failed to save token - $e');
          }
        } else {
          log(
            'APPOINTMENT TILE WARNING: patientAgoraToken is empty for this appointment',
          );
        }

        // Map core AppointmentDoctor to Doctor model expected by WaitingForDoctorScreen
        final selectedDoctor = Doctor(
          name: doctor.name,
          photo: doctor.photo,
          phone: doctor.phone,
        );

        Get.to(
          () => const WaitingForDoctorScreen(),
          arguments: {
            'selectedDoctor': selectedDoctor,
            'patientData': null,
            'appointmentId': appointmentData.id,
            'queueStatus': appointmentData.queueStatus,
          },
        );
      }
    }

    Future<void> _onPrimaryActionTap() async {
      if (appointmentType == AppointmentFilterType.upcoming) {
        await _onTap();
        return;
      }

      final docId = appointmentData.doctor?.id?.toString() ?? '';
      if (docId.isEmpty) {
        showToast(
          message: '404 - Appointment doctor profile not found!',
          context: context,
        );
        return;
      }

      final fetchedDoctor = await appointmentController.getDoctorById(
        appointmentId: (appointmentData.id ?? '').toString(),
        docId: docId,
      );
      if (fetchedDoctor == null) {
        showToast(
          message: '404 - Appointment doctor profile not found!',
          context: context,
        );
        return;
      }

      Get.to(() => DoctorProfileScreen(doctor: fetchedDoctor));
    }

    final dateText = (appointmentData.date ?? '').isNotEmpty
        ? _formatDate(appointmentData.date!.toString())
        : '';
    final amount = (appointmentData.totalAmount ?? 0).toString();
    final appointmentIdText =
        getShortAppointmentId(
          appointmentId: appointmentData.id,
          wantedLength: 5,
        ) ??
        'NO_ID';
    final durationMin = ((appointmentData.callDurationInSec ?? 0) / 60).ceil();

    return Padding(
      padding: EdgeInsets.only(bottom: getProportionateScreenHeight(10)),
      child: Container(
        width: double.maxFinite,
        height: getProportionateScreenWidth(170),
        color: Colors.white,
        child: Column(
          children: [
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InterText(
                        title: dateText,
                        textColor: AppColors.color888E9D,
                        fontSize: 14,
                      ),
                      Row(
                        children: [
                          InterText(
                            title: '$amount $getCurrencySymbol',
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_forward_ios_sharp, size: 10),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: getProportionateScreenHeight(15)),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: getProportionateScreenHeight(40),
                        width: getProportionateScreenHeight(40),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(40),
                          child: CommonNetworkImageWidget(
                            imageLink: (doctor?.photo ?? ''),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              alignment: Alignment.centerLeft,
                              height: 30,
                              child: InterText(
                                title: doctor?.name ?? '',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: getProportionateScreenHeight(4)),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Flexible(
                                  child: SizedBox(
                                    width: double.maxFinite,
                                    child: GestureDetector(
                                      onTap: () async {
                                        final id = (appointmentData.id ?? '')
                                            .toString()
                                            .trim();
                                        if (id.isEmpty) return;
                                        await Clipboard.setData(
                                          ClipboardData(text: id),
                                        );
                                        showToast(
                                          message:
                                              '${l10n.copied_to_clipboard} $id',
                                          context: context,
                                        );
                                      },
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          InterText(
                                            title: l10n.appointment_id,
                                            fontSize: 12,
                                            textColor: AppColors.color888E9D,
                                          ),
                                          SizedBox(height: 4),
                                          InterText(
                                            title: appointmentIdText
                                                .toUpperCase(),
                                            fontSize: 12,
                                            textColor: Colors.black,
                                            maxLines: 1,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Flexible(
                                  child: SizedBox(
                                    width: double.maxFinite,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        InterText(
                                          title: l10n.duration,
                                          fontSize: 12,
                                          textColor: AppColors.color888E9D,
                                        ),
                                        const SizedBox(height: 4),
                                        InterText(
                                          title: '$durationMin min',
                                          fontSize: 12,
                                          textColor: Colors.black,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                ],
              ),
            ),
            Container(
              height: 1,
              width: double.maxFinite,
              color: AppColors.colorEDEDED,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(() {
                      final isBtnLoading =
                          appointmentController
                              .isAppointmentButtonLoading
                              .value &&
                          appointmentController.appointmentIdLoading.value ==
                              (appointmentData.id ?? '');
                      if (isBtnLoading) {
                        return const SizedBox(
                          width: 100,
                          child: CupertinoActivityIndicator(
                            color: AppColors.primaryColor,
                          ),
                        );
                      }

                      return GestureDetector(
                        onTap: () async {
                          // Keep same behavior as BLoC: show loader for the primary action only
                          // (Book again / Go to appointment)
                          final apptId = (appointmentData.id ?? '').toString();
                          appointmentController
                                  .isAppointmentButtonLoading
                                  .value =
                              true;
                          appointmentController.appointmentIdLoading.value =
                              apptId;
                          try {
                            await _onPrimaryActionTap();
                          } finally {
                            appointmentController
                                    .isAppointmentButtonLoading
                                    .value =
                                false;
                            appointmentController.appointmentIdLoading.value =
                                '';
                          }
                        },
                        child: Container(
                          color: Colors.transparent,
                          child: InterText(
                            title:
                                (appointmentType ==
                                    AppointmentFilterType.upcoming
                                ? l10n.go_to_appointment.toUpperCase()
                                : l10n.book_again.toUpperCase()),
                            textColor: AppColors.primaryColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }),
                    if (appointmentType == AppointmentFilterType.past)
                      _StaticRatingRow(
                        rating: appointmentData.rating?.rating ?? 0.0,
                        hasRating: appointmentData.hasRating ?? false,
                        onTapRateNow: () async {
                          final apptId = (appointmentData.id ?? '').toString();
                          if (apptId.isEmpty) return;

                          final ok = await Get.to<bool>(
                            () => RatingScreen(appointmentId: apptId),
                          );
                          if (ok == true) {
                            await appointmentController.getAppointments(
                              loadFromStorage: false,
                            );
                          }
                        },
                      ),
                    if (appointmentType == AppointmentFilterType.upcoming)
                      GestureDetector(
                        onTap: () {
                          Get.to(() => const LiveSupportScreen());
                        },
                        child: const InterText(
                          title: 'HELP',
                          textColor: AppColors.primaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StaticRatingRow extends StatelessWidget {
  const _StaticRatingRow({
    required this.rating,
    required this.hasRating,
    required this.onTapRateNow,
  });

  final double rating;
  final bool hasRating;
  final VoidCallback onTapRateNow;

  @override
  Widget build(BuildContext context) {
    if (!hasRating) {
      final l10n = AppLocalizations.of(context)!;
      return GestureDetector(
        onTap: onTapRateNow,
        child: InterText(
          title: l10n.rate_now.toUpperCase(),
          textColor: AppColors.primaryColor,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    return RatingBarIndicator(
      rating: rating,
      itemSize: 20,
      itemPadding: const EdgeInsets.symmetric(horizontal: 4),
      itemBuilder: (context, _) =>
          const Icon(Icons.star_rate_rounded, color: Colors.amber),
    );
  }
}
