import 'package:eye_buddy/core/services/api/service/api_constants.dart';
import 'package:eye_buddy/core/services/utils/config/app_colors.dart';
import 'package:eye_buddy/core/services/utils/size_config.dart';
import 'package:eye_buddy/features/global_widgets/common_app_bar.dart';
import 'package:eye_buddy/features/global_widgets/common_network_image_widget.dart';
import 'package:eye_buddy/features/global_widgets/common_size_box.dart';
import 'package:eye_buddy/features/global_widgets/custom_button.dart';
import 'package:eye_buddy/features/global_widgets/inter_text.dart';
import 'package:eye_buddy/features/bootom_navbar_screen/views/bottom_navbar_screen.dart';
import 'package:eye_buddy/features/login/controller/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../l10n/app_localizations.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  static const Color _green = AppColors.primaryColor;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileController controller;

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  Future<bool> _goHome() async {
    Get.offAll(() => const BottomNavBarScreen());
    return false;
  }

  String _resolvePhotoUrl(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return '';
    final isAbsolute = Uri.tryParse(v)?.isAbsolute ?? false;
    if (isAbsolute) return v;
    return '${ApiConstants.imageBaseUrl}$v';
  }

  @override
  void initState() {
    super.initState();
    controller = Get.find<ProfileController>();
    if (controller.profileData.value.profile == null) {
      controller.getProfileData();
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final l10n = AppLocalizations.of(context)!;
    return WillPopScope(
      onWillPop: _goHome,
      child: Scaffold(
        backgroundColor: AppColors.appBackground,
        appBar: CommonAppBar(
          title: l10n.my_profile,
          elevation: 0,
          icon: Icons.arrow_back,
          finishScreen: true,
          isTitleCenter: false,
          context: context,
          onBack: () {
            _goHome();
          },
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final profile = controller.profileData.value.profile;
          if (profile == null) {
            return Center(
              child: InterText(
                title: l10n.profile_data_not_available,
                fontSize: 16,
              ),
            );
          }

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: getProportionateScreenWidth(20),
              vertical: getProportionateScreenWidth(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: _cardDecoration(),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: ProfileScreen._green,
                            width: 2,
                          ),
                        ),
                        child: SizedBox(
                          height: getProportionateScreenHeight(72),
                          width: getProportionateScreenHeight(72),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(60),
                            child: CommonNetworkImageWidget(
                              imageLink: _resolvePhotoUrl(profile.photo),
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
                              title: (profile.name ?? '').isNotEmpty
                                  ? (profile.name ?? '')
                                  : '-',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.phone,
                                  size: 16,
                                  color: ProfileScreen._green,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: InterText(
                                    title: (profile.phone ?? '').isNotEmpty
                                        ? (profile.phone ?? '')
                                        : '-',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    textColor: AppColors.color888E9D,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                const _SectionTitle(title: 'Basic Info'),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: _cardDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ProfileInfoRow(
                        icon: Icons.person,
                        label: l10n.full_name,
                        value: profile.name ?? '',
                      ),
                      _ProfileInfoRow(
                        icon: Icons.phone_android,
                        label: l10n.phone,
                        value: profile.phone ?? '',
                      ),
                      _ProfileInfoRow(
                        icon: Icons.email_outlined,
                        label: l10n.email,
                        value: profile.email ?? '',
                      ),
                      _ProfileInfoRow(
                        icon: Icons.wc,
                        label: l10n.gender,
                        value: profile.gender ?? '',
                      ),
                      _ProfileInfoRow(
                        icon: Icons.monitor_weight_outlined,
                        label: l10n.weight,
                        value: profile.weight != null
                            ? '${profile.weight} KG'
                            : '',
                        removeBottomPadding: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 90),
              ],
            ),
          );
        }),
        bottomNavigationBar: Obx(() {
          final profile = controller.profileData.value.profile;
          if (controller.isLoading.value || profile == null) {
            return const SizedBox.shrink();
          }
          return SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.only(
                left: getProportionateScreenWidth(20),
                right: getProportionateScreenWidth(20),
                bottom: getProportionateScreenWidth(12),
              ),
              child: CustomButton(
                title: l10n.edit_profile,
                callBackFunction: () {
                  Get.to(() => EditProfileScreen(profile: profile));
                },
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  const _ProfileInfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.removeBottomPadding = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool removeBottomPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: removeBottomPadding ? 0 : 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: ProfileScreen._green),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          Expanded(
            child: Text(
              (value.isEmpty ? '-' : value),
              style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Container(
          width: 40,
          height: 3,
          decoration: BoxDecoration(
            color: ProfileScreen._green,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }
}
