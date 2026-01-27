import 'package:eye_buddy/core/services/utils/config/app_colors.dart';
import 'package:eye_buddy/core/services/utils/size_config.dart';
import 'package:eye_buddy/core/services/utils/assets/app_assets.dart';
import 'package:eye_buddy/features/global_widgets/common_app_bar.dart';
import 'package:eye_buddy/features/global_widgets/common_size_box.dart';
import 'package:eye_buddy/features/global_widgets/inter_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../l10n/app_localizations.dart';

class DummyTermsAndConditionsScreen extends StatelessWidget {
  const DummyTermsAndConditionsScreen({super.key});

  static const double _cardRadius = 14;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: CommonAppBar(
        title: l10n.terms_conditions_title,
        elevation: 0,
        icon: Icons.arrow_back,
        finishScreen: true,
        isTitleCenter: false,
        context: context,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: getProportionateScreenWidth(20),
          vertical: getProportionateScreenWidth(16),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              CommonSizeBox(height: getProportionateScreenHeight(20)),
              _buildSection(
                l10n.terms_conditions_intro_title,
                l10n.terms_conditions_intro_body,
                icon: Icons.description_outlined,
              ),
              CommonSizeBox(height: getProportionateScreenHeight(20)),
              _buildSection(
                l10n.terms_conditions_section_1_title,
                l10n.terms_conditions_section_1_body,
                icon: Icons.menu_book_outlined,
              ),
              CommonSizeBox(height: getProportionateScreenHeight(20)),
              _buildSection(
                l10n.terms_conditions_section_2_title,
                l10n.terms_conditions_section_2_body,
                icon: Icons.verified_outlined,
              ),
              CommonSizeBox(height: getProportionateScreenHeight(20)),
              _buildSection(
                l10n.terms_conditions_section_3_title,
                l10n.terms_conditions_section_3_body,
                icon: Icons.medical_services_outlined,
              ),
              CommonSizeBox(height: getProportionateScreenHeight(20)),
              _buildSection(
                l10n.terms_conditions_section_4_title,
                l10n.terms_conditions_section_4_body,
                icon: Icons.payments_outlined,
              ),
              CommonSizeBox(height: getProportionateScreenHeight(20)),
              _buildSection(
                l10n.terms_conditions_section_5_title,
                l10n.terms_conditions_section_5_body,
                icon: Icons.local_hospital_outlined,
              ),
              CommonSizeBox(height: getProportionateScreenHeight(20)),
              _buildSection(
                l10n.terms_conditions_section_6_title,
                l10n.terms_conditions_section_6_body,
                icon: Icons.rule_outlined,
              ),
              CommonSizeBox(height: getProportionateScreenHeight(20)),
              _buildSection(
                l10n.terms_conditions_section_7_title,
                l10n.terms_conditions_section_7_body,
                icon: Icons.privacy_tip_outlined,
              ),
              CommonSizeBox(height: getProportionateScreenHeight(20)),
              _buildSection(
                l10n.terms_conditions_section_8_title,
                l10n.terms_conditions_section_8_body,
                icon: Icons.warning_amber_outlined,
              ),
              CommonSizeBox(height: getProportionateScreenHeight(20)),
              _buildSection(
                l10n.terms_conditions_section_9_title,
                l10n.terms_conditions_section_9_body,
                icon: Icons.block_outlined,
              ),
              CommonSizeBox(height: getProportionateScreenHeight(20)),
              _buildSection(
                l10n.terms_conditions_section_10_title,
                l10n.terms_conditions_section_10_body,
                icon: Icons.update_outlined,
              ),
              CommonSizeBox(height: getProportionateScreenHeight(20)),
              _buildSection(
                l10n.terms_conditions_section_11_title,
                l10n.terms_conditions_section_11_body,
                icon: Icons.gavel_outlined,
              ),
              CommonSizeBox(height: getProportionateScreenHeight(20)),
              _buildSection(
                l10n.terms_conditions_section_12_title,
                l10n.terms_conditions_section_12_body,
                icon: Icons.contact_phone_outlined,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: getProportionateScreenWidth(16),
        vertical: getProportionateScreenHeight(16),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.white,
            AppColors.appBackground,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(_cardRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.color888E9D.withOpacity(0.14),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.appBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SvgPicture.asset(
                  AppAssets.termsAndConditions,
                  color: AppColors.primaryColor,
                ),
              ),
              CommonSizeBox(width: getProportionateScreenWidth(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InterText(
                      title: l10n.terms_conditions_title,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      textColor: AppColors.primaryColor,
                    ),
                    CommonSizeBox(height: getProportionateScreenHeight(6)),
                    InterText(
                      title: l10n.terms_conditions_subtitle,
                      fontSize: 14,
                      textColor: AppColors.color888E9D,
                    ),
                  ],
                ),
              ),
            ],
          ),
          CommonSizeBox(height: getProportionateScreenHeight(12)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: AppColors.primaryColor,
                ),
                CommonSizeBox(width: getProportionateScreenWidth(6)),
                InterText(
                  title: l10n.terms_conditions_effective_date,
                  fontSize: 12,
                  textColor: AppColors.primaryColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    String title,
    String content, {
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(_cardRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.color888E9D.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.45),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(_cardRadius),
                  bottomLeft: Radius.circular(_cardRadius),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: getProportionateScreenWidth(16),
                  vertical: getProportionateScreenHeight(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppColors.appBackground,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            icon,
                            size: 16,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        CommonSizeBox(width: getProportionateScreenWidth(10)),
                        Expanded(
                          child: InterText(
                            title: title,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    CommonSizeBox(height: getProportionateScreenHeight(8)),
                    InterText(
                      title: content,
                      fontSize: 14,
                      textColor: AppColors.color888E9D,
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
