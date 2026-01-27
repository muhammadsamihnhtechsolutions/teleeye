import 'package:eye_buddy/core/services/api/model/doctor_list_response_model.dart';
import 'package:eye_buddy/core/services/utils/config/app_colors.dart';
import 'package:eye_buddy/core/services/utils/extensions.dart';
import 'package:eye_buddy/core/services/utils/functions.dart';
import 'package:eye_buddy/core/services/utils/global_variables.dart';
import 'package:eye_buddy/core/services/utils/size_config.dart';
import 'package:eye_buddy/features/doctor_list/controller/doctor_profile_controller.dart';
import 'package:eye_buddy/features/doctor_list/widgets/get_doctor_statistics_tile.dart';
import 'package:eye_buddy/features/doctor_list/widgets/get_doctor_profile_bottom_bar.dart';
import 'package:eye_buddy/features/doctor_list/widgets/get_doctor_profile_filter.dart';
import 'package:eye_buddy/features/doctor_list/widgets/get_doctors_profile_widget.dart';
import 'package:eye_buddy/features/global_widgets/inter_text.dart';
import 'package:eye_buddy/features/global_widgets/common_network_image_widget.dart';
import 'package:eye_buddy/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class DoctorProfileScreen extends StatelessWidget {
  const DoctorProfileScreen({super.key, required this.doctor});

  final Doctor doctor;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final l10n = AppLocalizations.of(context)!;

    final controller = Get.put(
      DoctorProfileController(doctor: doctor, isFromFavoriteList: false),
    );

    return Obx(() {
      final currentDoctor = controller.selectedDoctor.value ?? doctor;

      return Scaffold(
        backgroundColor: AppColors.appBackground,
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: Colors.black,
            onPressed: () => Get.back(),
          ),
          title: InterText(title: l10n.profile),
          actions: [
            Align(
              child: Container(
                height: 25,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: AppColors.primaryColor,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                alignment: Alignment.center,
                child: InterText(
                  title: capitalizeFirstWord(
                    (currentDoctor.availabilityStatus ?? '').toString(),
                  ),
                  fontSize: 14,
                  textColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 20),
          ],
        ),
        bottomNavigationBar: GetDoctorProfileBottomBar(
          doctorProfile: currentDoctor,
        ),
        body: SizedBox(
          width: SizeConfig.screenWidth,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    GetDoctorsProfile(
                      isFromFavoriteList: false,
                      doctor: currentDoctor,
                    ),
                    SizedBox(height: getProportionateScreenHeight(24)),
                    GetDoctorsStatisticsTile(doctor: currentDoctor),
                    SizedBox(height: getProportionateScreenHeight(24)),
                    const DoctorProfileFilter(),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
              Flexible(
                child: PageView.builder(
                  controller: controller.pageController,
                  itemCount: 3,
                  onPageChanged: controller.onPageChanged,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _DoctorProfileInfoTab(doctor: currentDoctor);
                    } else if (index == 1) {
                      return _DoctorProfileExperienceTab(doctor: currentDoctor);
                    }
                    return const _DoctorProfileFeedbackTab();
                  },
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _DoctorProfileInfoTab extends StatelessWidget {
  const _DoctorProfileInfoTab({required this.doctor});

  final Doctor doctor;

  static const double _cardRadius = 14;

  @override
  Widget build(BuildContext context) {
    final about = (doctor.about ?? '').trim();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 20),
      children: [
        Row(
          children: [
            Expanded(
              child: _ProfileInfoCard(
                title: 'Consultation Fee',
                subtitle: '(Incl 5% VAT)',
                icon: Icons.payments_outlined,
                valueBuilder: FutureBuilder(
                  future: getDoctorConsultationFee(doctor: doctor),
                  initialData: '',
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      );
                    }
                    return InterText(
                      title: '$getCurrencySymbol ${snapshot.data ?? '--'}',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ProfileInfoCard(
                title: 'Follow-up Fee',
                subtitle: '(Incl 5% VAT)',
                icon: Icons.currency_exchange,
                valueBuilder: FutureBuilder(
                  future: getDoctorFollowUpFeeUsd(doctor: doctor),
                  initialData: '',
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      );
                    }
                    return InterText(
                      title: '$getCurrencySymbol ${snapshot.data ?? '--'}',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(_cardRadius),
            border: Border.all(color: AppColors.colorE6F2EE),
          ),
          child: Row(
            children: [
              Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  color: AppColors.colorE6F2EE,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.access_time_rounded,
                  color: AppColors.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const InterText(
                      title: 'Average consultation time',
                      fontSize: 12,
                      textColor: AppColors.color888E9D,
                    ),
                    const SizedBox(height: 4),
                    InterText(
                      title: '${doctor.averageConsultancyTime ?? 0} min',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const _SectionHeader(
          title: 'About doctor',
          icon: Icons.info_outline_rounded,
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(_cardRadius),
            border: Border.all(color: AppColors.colorE6F2EE),
          ),
          child: about.isEmpty
              ? const _EmptyStateInline(
                  icon: Icons.description_outlined,
                  message: 'No bio added yet.',
                )
              : InterText(
                  title: about,
                  fontSize: 14,
                  textColor: AppColors.color0D2238,
                ),
        ),
      ],
    );
  }
}

class _ProfileInfoCard extends StatelessWidget {
  const _ProfileInfoCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.valueBuilder,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget valueBuilder;

  static const double _cardRadius = 14;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_cardRadius),
        border: Border.all(color: AppColors.colorE6F2EE),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 32,
                width: 32,
                decoration: BoxDecoration(
                  color: AppColors.colorE6F2EE,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primaryColor, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: InterText(
                  title: title,
                  fontSize: 12,
                  textColor: AppColors.color888E9D,
                  maxLines: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          valueBuilder,
          const SizedBox(height: 2),
          InterText(
            title: subtitle,
            fontSize: 11,
            textColor: AppColors.color888E9D,
          ),
        ],
      ),
    );
  }
}

class _DoctorProfileExperienceTab extends StatelessWidget {
  const _DoctorProfileExperienceTab({required this.doctor});

  final Doctor doctor;

  static const double _cardRadius = 14;

  String _fmtMonthYear(DateTime? d) {
    if (d == null) return '';
    try {
      return DateFormat('MMM yyyy').format(d.toLocal());
    } catch (_) {
      return '';
    }
  }

  Widget _infoRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 28,
          width: 28,
          decoration: BoxDecoration(
            color: AppColors.colorE6F2EE,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InterText(
                title: label,
                fontSize: 11,
                textColor: AppColors.color888E9D,
              ),
              const SizedBox(height: 2),
              InterText(
                title: value,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                textColor: AppColors.color0D2238,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final experiences = doctor.experiences ?? const [];

    if (experiences.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: _EmptyStateFull(
          icon: Icons.work_outline_rounded,
          title: 'No experience added',
          message: 'This doctor hasn’t added experience details yet.',
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 20),
      itemCount: experiences.length,
      itemBuilder: (context, index) {
        final exp = experiences[index];
        final designation = (exp.designation ?? '').trim();
        final hospital = (exp.hospitalName ?? '').trim();
        final department = (exp.department ?? '').trim();
        final start = _fmtMonthYear(exp.startDate);
        final end = exp.currentlyWorkingHere == true
            ? 'Present'
            : _fmtMonthYear(exp.endDate);
        final range =
            [start, end].where((e) => e.trim().isNotEmpty).join(' - ');
        final statusLabel =
            exp.currentlyWorkingHere == true ? 'Currently working' : 'Past';

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(_cardRadius),
              border: Border.all(color: AppColors.colorE6F2EE),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 10,
                  margin: const EdgeInsets.only(top: 4),
                  child: Column(
                    children: [
                      Container(
                        height: 10,
                        width: 10,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 2,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.colorE6F2EE,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InterText(
                        title: designation.isNotEmpty ? designation : '—',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        textColor: AppColors.color0D2238,
                      ),
                      if (hospital.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        _infoRow(
                          icon: Icons.local_hospital_outlined,
                          iconColor: AppColors.primaryColor,
                          label: 'Hospital',
                          value: hospital,
                        ),
                      ],
                      if (department.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        _infoRow(
                          icon: Icons.account_tree_outlined,
                          iconColor: AppColors.primaryColor,
                          label: 'Department',
                          value: department,
                        ),
                      ],
                      if (range.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        _infoRow(
                          icon: Icons.calendar_month_outlined,
                          iconColor: AppColors.color888E9D,
                          label: 'Period',
                          value: range,
                        ),
                      ],
                      const SizedBox(height: 10),
                      _infoRow(
                        icon: Icons.work_outline_rounded,
                        iconColor: AppColors.color888E9D,
                        label: 'Type',
                        value: statusLabel,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DoctorProfileFeedbackTab extends StatelessWidget {
  const _DoctorProfileFeedbackTab();

  static const double _cardRadius = 14;

  Widget _buildStars(double rating) {
    final int fullStars = rating.floor().clamp(0, 5);
    final bool hasHalf = (rating - fullStars) >= 0.5 && fullStars < 5;
    final int emptyStars = 5 - fullStars - (hasHalf ? 1 : 0);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < fullStars; i++)
          const Icon(Icons.star, size: 14, color: Colors.amber),
        if (hasHalf) const Icon(Icons.star_half, size: 14, color: Colors.amber),
        for (int i = 0; i < emptyStars; i++)
          const Icon(Icons.star_border, size: 14, color: Colors.amber),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DoctorProfileController>();

    return Obx(() {
      if (controller.isFeedbackLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primaryColor),
        );
      }

      if (controller.feedbackErrorMessage.value.isNotEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InterText(
                  title: controller.feedbackErrorMessage.value,
                  fontSize: 14,
                  textColor: AppColors.color888E9D,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => controller.loadDoctorFeedback(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      }

      final feedback = controller.feedbackModel.value;
      final docs = feedback?.data?.docs ?? const [];
      final avg = feedback?.averageRating ?? 0.0;
      final total = feedback?.totalRatings ?? docs.length;

      if (docs.isEmpty) {
        return const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: _EmptyStateFull(
            icon: Icons.chat_bubble_outline_rounded,
            title: 'No feedback yet',
            message: 'Be the first to leave a review after your appointment.',
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => controller.loadDoctorFeedback(),
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 20),
          itemCount: docs.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(_cardRadius),
                    border: Border.all(color: AppColors.colorE6F2EE),
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 44,
                        width: 44,
                        decoration: BoxDecoration(
                          color: AppColors.colorCCE7D9,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.star_rounded,
                          color: AppColors.primaryColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InterText(
                              title: avg.toStringAsFixed(1),
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              textColor: AppColors.color0D2238,
                            ),
                            const SizedBox(height: 2),
                            InterText(
                              title: '$total reviews',
                              fontSize: 12,
                              textColor: AppColors.color888E9D,
                            ),
                          ],
                        ),
                      ),
                      _buildStars(avg),
                    ],
                  ),
                ),
              );
            }

            final doc = docs[index - 1];
            final rating = doc.rating ?? 0.0;
            final patientName = (doc.patient?.name ?? 'Patient').trim();
            final review = (doc.review ?? '').trim();
            final photoPath = (doc.patient?.photo ?? '').trim();
            final createdAt = doc.createdAt?.toIso8601String();
            final dateLabel = createdAt == null ? '' : formatDateDDMMMMYYYY(createdAt);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(_cardRadius),
                  border: Border.all(color: AppColors.colorE6F2EE),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 40,
                      width: 40,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(40),
                        child: CommonNetworkImageWidget(imageLink: photoPath),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: InterText(
                                  title: patientName.isNotEmpty
                                      ? patientName
                                      : 'Patient',
                                  fontWeight: FontWeight.w700,
                                  maxLines: 1,
                                  textColor: AppColors.color0D2238,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.colorE6F2EE,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      size: 14,
                                      color: AppColors.primaryColor,
                                    ),
                                    const SizedBox(width: 4),
                                    InterText(
                                      title: rating.toStringAsFixed(1),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      textColor: AppColors.color0D2238,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              _buildStars(rating),
                              if (dateLabel.isNotEmpty) ...[
                                const SizedBox(width: 10),
                                Flexible(
                                  child: InterText(
                                    title: dateLabel,
                                    fontSize: 12,
                                    textColor: AppColors.color888E9D,
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (review.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            InterText(
                              title: review,
                              fontSize: 14,
                              textColor: AppColors.color0D2238,
                            ),
                          ] else ...[
                            const SizedBox(height: 10),
                            const _EmptyStateInline(
                              icon: Icons.notes_outlined,
                              message: 'No written review.',
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primaryColor),
        const SizedBox(width: 8),
        InterText(
          title: title,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          textColor: AppColors.color008541,
        ),
      ],
    );
  }
}

class _EmptyStateInline extends StatelessWidget {
  const _EmptyStateInline({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.color888E9D),
        const SizedBox(width: 8),
        Expanded(
          child: InterText(
            title: message,
            fontSize: 13,
            textColor: AppColors.color888E9D,
          ),
        ),
      ],
    );
  }
}

class _EmptyStateFull extends StatelessWidget {
  const _EmptyStateFull({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(top: SizeConfig.screenHeight / 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 64,
              width: 64,
              decoration: BoxDecoration(
                color: AppColors.colorE6F2EE,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(icon, size: 30, color: AppColors.primaryColor),
            ),
            const SizedBox(height: 12),
            InterText(
              title: title,
              fontSize: 15,
              fontWeight: FontWeight.w800,
              textColor: AppColors.color0D2238,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            InterText(
              title: message,
              fontSize: 13,
              textColor: AppColors.color888E9D,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
