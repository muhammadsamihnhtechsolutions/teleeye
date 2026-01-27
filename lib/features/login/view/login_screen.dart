import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eye_buddy/core/services/utils/config/app_colors.dart';
import 'package:eye_buddy/core/services/utils/size_config.dart';
import 'package:eye_buddy/core/services/utils/services/navigator_services.dart';
import 'package:eye_buddy/features/global_widgets/filled_button.dart';
import 'package:eye_buddy/features/global_widgets/inter_text.dart';
import 'package:eye_buddy/features/global_widgets/language_chip.dart';
import 'package:eye_buddy/features/global_widgets/toast.dart';
import 'package:eye_buddy/features/global_widgets/custom_loader.dart';
import 'package:eye_buddy/features/login/controller/login_controller.dart';
import 'package:eye_buddy/features/login/view/otp_screen.dart';
import 'package:eye_buddy/features/login/view/widgets/login_phone_form.dart';
import 'package:eye_buddy/features/login/view/widgets/login_terms_and_condition_widget.dart';
import 'package:eye_buddy/l10n/app_localizations.dart';
import 'package:validate_phone_number/validation.dart';

class LoginScreen extends StatefulWidget {
  final bool showBackButton;
  const LoginScreen({super.key, required this.showBackButton});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController countryCodeController = TextEditingController();
  final TextEditingController countryIsoCodeController =
      TextEditingController();
  final LoginController loginController = Get.put(LoginController());

  final RxBool _isPhoneValid = false.obs;

  void _revalidatePhone() {
    final nationalNumber = phoneNumberController.text.trim();
    final isoCode = countryIsoCodeController.text.trim();
    final bool valid =
        nationalNumber.isNotEmpty &&
        isoCode.isNotEmpty &&
        Validator.validatePhoneNumber(nationalNumber, isoCode);
    _isPhoneValid.value = valid;
  }

  @override
  void initState() {
    super.initState();
    phoneNumberController.addListener(_revalidatePhone);
  }

  @override
  void dispose() {
    phoneNumberController.removeListener(_revalidatePhone);
    phoneNumberController.dispose();
    countryCodeController.dispose();
    countryIsoCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    SizeConfig().init(context);

    return Scaffold(
      appBar: AppBar(
        leading: widget.showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        actions: [LanguageChip(), const SizedBox(width: 20)],
      ),
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: InterText(
                        title: l10n.welcome,
                        fontWeight: FontWeight.bold,
                        fontSize: 58,
                        textColor: AppColors.color008541,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: getProportionateScreenHeight(6)),
                    InterText(
                      title: l10n.enterYourMobileNumber,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    SizedBox(height: getProportionateScreenHeight(15)),
                    LoginPhoneTextField(
                      phoneNumberController: phoneNumberController,
                      countryCodeController: countryCodeController,
                      countryIsoCodeController: countryIsoCodeController,
                      onPhoneChanged: (_) {
                        _revalidatePhone();
                      },
                      onCountryChanged: () {
                        _revalidatePhone();
                      },
                    ),
                    SizedBox(height: getProportionateScreenHeight(15)),

                    Obx(() {
                      final canContinue =
                          _isPhoneValid.value &&
                          !loginController.isLoading.value;
                      return GetFilledButton(
                        title: l10n.continueNext,
                        isEnabled: canContinue,
                        callBackFunction: () async {
                          if (!_isPhoneValid.value) return;

                          await loginController.loginUser(
                            phone: phoneNumberController.text,
                            dialCode: countryCodeController.text,
                            context: context,
                          );

                          final loginData = loginController.loginData.value;
                          if (loginData != null) {
                            final fullPhoneNumber =
                                countryCodeController.text +
                                phoneNumberController.text;
                            final traceId = loginData.traceId;

                            if (traceId == null || traceId.isEmpty) {
                              showToast(
                                message: "TraceId missing",
                                context: context,
                              );
                              return;
                            }

                            NavigatorServices().to(
                              context: context,
                              widget: OtpScreen(
                                phoneNumber: fullPhoneNumber,
                                traceId: traceId,
                              ),
                            );

                            loginController.resetState();
                          }
                        },
                      );
                    }),

                    SizedBox(height: getProportionateScreenHeight(15)),
                    LoginTermsAndConditionsWidget(),
                  ],
                ),
              ),
            ),
          ),

          // LOADER — wrap only loader in Obx
          Obx(() {
            return loginController.isLoading.value
                ? const CustomLoadingScreen()
                : const SizedBox.shrink();
          }),
        ],
      ),
    );
  }
}
