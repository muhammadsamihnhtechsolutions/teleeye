import 'package:eye_buddy/core/services/utils/config/app_colors.dart';
import 'package:eye_buddy/core/services/utils/size_config.dart';
import 'package:eye_buddy/features/global_widgets/common_app_bar.dart';
import 'package:eye_buddy/features/global_widgets/common_size_box.dart';
import 'package:eye_buddy/features/global_widgets/custom_button.dart';
import 'package:eye_buddy/features/global_widgets/custom_loader.dart';
import 'package:eye_buddy/features/global_widgets/custom_text_field.dart';
import 'package:eye_buddy/features/global_widgets/inter_text.dart';
import 'package:eye_buddy/features/global_widgets/toast.dart';
import 'package:eye_buddy/features/login/view/otp_screen.dart';
import 'package:eye_buddy/features/login/controller/profile_controller.dart';
import 'package:eye_buddy/core/services/api/repo/api_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../l10n/app_localizations.dart';

class ChangeMobileNumberScreen extends StatefulWidget {
  const ChangeMobileNumberScreen({super.key});

  @override
  State<ChangeMobileNumberScreen> createState() =>
      _ChangeMobileNumberScreenState();
}

class _ChangeMobileNumberScreenState extends State<ChangeMobileNumberScreen> {
  final TextEditingController currentMobileNumberController =
      TextEditingController();
  final TextEditingController newMobileNumberController =
      TextEditingController();
  final TextEditingController confirmMobileNumberController =
      TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _prefillCurrentNumber();
  }

  void _prefillCurrentNumber() {
    try {
      final profile = Get.find<ProfileController>().profileData.value.profile;
      if (profile?.phone != null) {
        currentMobileNumberController.text = profile!.phone!;
      }
    } catch (_) {
      // Profile data not ready; leave empty
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: CommonAppBar(
        title: l10n.change_mobile_number,
        elevation: 0,
        icon: Icons.arrow_back,
        finishScreen: true,
        isTitleCenter: false,
        context: context,
      ),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: getProportionateScreenWidth(20),
              vertical: getProportionateScreenWidth(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InterText(title: l10n.current_mobile_number, fontSize: 14),
                CommonSizeBox(height: getProportionateScreenHeight(8)),
                CustomTextFormField(
                  textEditingController: currentMobileNumberController,
                  isEnabled: false,
                  textInputType: TextInputType.phone,
                ),
                CommonSizeBox(height: getProportionateScreenHeight(16)),
                InterText(title: l10n.new_mobile_number, fontSize: 14),
                CommonSizeBox(height: getProportionateScreenHeight(8)),
                CustomTextFormField(
                  textEditingController: newMobileNumberController,
                  textInputType: TextInputType.phone,
                  maxLength: 11,
                  hint: l10n.enter_new_mobile_number,
                ),
                CommonSizeBox(height: getProportionateScreenHeight(16)),
                InterText(title: l10n.confirm_mobile_number, fontSize: 14),
                CommonSizeBox(height: getProportionateScreenHeight(8)),
                CustomTextFormField(
                  textEditingController: confirmMobileNumberController,
                  textInputType: TextInputType.phone,
                  maxLength: 11,
                  hint: l10n.confirm_new_mobile_number,
                ),
                CommonSizeBox(height: getProportionateScreenHeight(22)),
                CustomButton(
                  title: l10n.change_mobile_number,
                  callBackFunction: () {
                    _submit(context);
                  },
                ),
              ],
            ),
          ),
          if (_isLoading) const Positioned.fill(child: CustomLoadingScreen()),
        ],
      ),
    );
  }

  bool _isPhoneNoValid(String? phoneNo) {
    if (phoneNo == null) return false;
    final regExp = RegExp(r'(^(?:[+0]9)?[0-9]{10,12}$)');
    return regExp.hasMatch(phoneNo);
  }

  Future<void> _submit(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) return;

    if (newMobileNumberController.text.isEmpty ||
        currentMobileNumberController.text.isEmpty ||
        confirmMobileNumberController.text.isEmpty) {
      showToast(
        message: l10n.please_complete_the_form_and_try_again,
        context: context,
      );
      return;
    }
    if (newMobileNumberController.text != confirmMobileNumberController.text) {
      showToast(
        message: l10n.given_phone_numbers_are_not_the_same,
        context: context,
      );
      return;
    }

    final confirmPhone = confirmMobileNumberController.text.trim();
    if (!_isPhoneNoValid(confirmPhone)) {
      showToast(message: l10n.given_phone_numbers_not_valid, context: context);
      return;
    }

    String dialCode = '';
    try {
      final profile = Get.find<ProfileController>().profileData.value.profile;
      dialCode = (profile?.dialCode ?? '').trim();
    } catch (_) {
      dialCode = '';
    }

    final params = {
      'currentDialCode': dialCode,
      'dialCode': dialCode,
      'currentPhone': currentMobileNumberController.text.trim(),
      'phone': confirmPhone,
    };

    setState(() {
      _isLoading = true;
    });

    try {
      final apiRes = await ApiRepo().changePhoneNumber(params: params);

      showToast(
        message: (apiRes.message ?? '').isNotEmpty
            ? apiRes.message!
            : l10n.we_will_verify_the_new_mobile_number_shortly,
        context: context,
      );

      if ((apiRes.status ?? '').toLowerCase() == 'success') {
        final traceId = (apiRes.data?.traceId ?? '').trim();
        if (traceId.isEmpty) {
          showToast(message: l10n.missing_trace_id, context: context);
          return;
        }

        final phoneNumber = '$dialCode$confirmPhone';
        Get.off(
          () => OtpScreen(
            phoneNumber: phoneNumber,
            traceId: traceId,
            isForChangePhoneNumber: true,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
