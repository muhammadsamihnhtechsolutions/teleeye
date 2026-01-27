import 'package:eye_buddy/core/services/utils/config/app_colors.dart';
//import 'package:eye_buddy/core/features/global_widgets/inter_text.dart';
import 'package:eye_buddy/features/global_widgets/inter_text.dart';
import 'package:eye_buddy/features/more/view/dummy_privacy_policy_screen.dart';
import 'package:eye_buddy/features/more/view/dummy_terms_and_conditions_screen.dart';
import 'package:eye_buddy/l10n/app_localizations.dart';
//import 'package:eye_buddy/l10n/app_localizations.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginTermsAndConditionsWidget extends StatefulWidget {
  const LoginTermsAndConditionsWidget({super.key});

  @override
  State<LoginTermsAndConditionsWidget> createState() =>
      _LoginTermsAndConditionsWidgetState();
}

class _LoginTermsAndConditionsWidgetState
    extends State<LoginTermsAndConditionsWidget> {
  late final TapGestureRecognizer _termsConditionRecognizer;
  late final TapGestureRecognizer _privacyPolicyRecognizer;

  @override
  void initState() {
    super.initState();
    _termsConditionRecognizer = TapGestureRecognizer()
      ..onTap = _openTermsAndConditions;
    _privacyPolicyRecognizer = TapGestureRecognizer()
      ..onTap = _openPrivacyPolicy;
  }

  void _openTermsAndConditions() {
    Get.to(() => const DummyTermsAndConditionsScreen());
  }

  void _openPrivacyPolicy() {
    Get.to(() => const DummyPrivacyPolicyScreen());
  }

  @override
  void dispose() {
    _termsConditionRecognizer.dispose();
    _privacyPolicyRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return RichText(
      text: TextSpan(
        style: interTextStyle.copyWith(
          color: AppColors.color888E9D,
          fontSize: 12,
        ),
        children: [
          TextSpan(text: l10n.byTappingContinueYouAgreeTo),
          TextSpan(
            text: l10n.termsAndConditions,
            style: interTextStyle.copyWith(
              color: AppColors.color008541,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            recognizer: _termsConditionRecognizer,
          ),
          TextSpan(text: l10n.and),
          TextSpan(
            recognizer: _privacyPolicyRecognizer,
            text: l10n.privacyPolicy,
            style: interTextStyle.copyWith(
              color: AppColors.color008541,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(text: l10n.ofBangladeshEyeHospital),
        ],
      ),
    );
  }
}
