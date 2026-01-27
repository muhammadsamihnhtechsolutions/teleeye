import 'package:eye_buddy/core/services/utils/assets/app_assets.dart';
import 'package:eye_buddy/core/services/utils/config/app_colors.dart';
import 'package:eye_buddy/core/services/utils/size_config.dart';
import 'package:eye_buddy/features/global_widgets/common_size_box.dart';
import 'package:eye_buddy/features/global_widgets/inter_text.dart';
import 'package:eye_buddy/features/login/controller/profile_controller.dart';
import 'package:eye_buddy/features/login/view/login_screen.dart';
import 'package:eye_buddy/features/more/controller/more_controller.dart';
import 'package:eye_buddy/features/more/view/all_prescriptions_screen.dart';
import 'package:eye_buddy/features/more/view/change_language_screen.dart';
import 'package:eye_buddy/features/more/view/change_mobile_number_screen.dart';
import 'package:eye_buddy/features/more/view/dummy_privacy_policy_screen.dart';
import 'package:eye_buddy/features/more/view/dummy_terms_and_conditions_screen.dart';
import 'package:eye_buddy/features/more/view/emergency_call_screen.dart';
import 'package:eye_buddy/features/more/view/favourite_doctors_screen.dart';
import 'package:eye_buddy/features/more/view/live_support_screen.dart';
import 'package:eye_buddy/features/more/view/promos_screen.dart';
import 'package:eye_buddy/features/more/view/test_results_screen.dart';
import 'package:eye_buddy/features/more/view/transactions_history_screen.dart';
import 'package:eye_buddy/features/more/widgets/more_header_section.dart';
import 'package:eye_buddy/features/more/widgets/more_option_item.dart';
import 'package:eye_buddy/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eye_buddy/core/services/api/data/api_data.dart';
import 'package:eye_buddy/core/services/utils/keys/shared_pref_keys.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  late final MoreController moreController;
  late final ProfileController profileController;

  @override
  void initState() {
    super.initState();
    moreController = Get.isRegistered<MoreController>()
        ? Get.find<MoreController>()
        : Get.put(MoreController());
    profileController = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      profileController.getProfileData();
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final localLanguage = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(0),
        child: AppBar(backgroundColor: AppColors.colorCCE7D9),
      ),
      backgroundColor: AppColors.appBackground,
      body: SizedBox(
        width: SizeConfig.screenWidth,
        child: MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: ListView(
            children: [
              const MoreHeaderSection(),
              CommonSizeBox(height: getProportionateScreenWidth(10)),
              Container(
                color: AppColors.white,
                padding: EdgeInsets.only(
                  top: getProportionateScreenWidth(10),
                  bottom: getProportionateScreenWidth(10),
                  left: getProportionateScreenWidth(20),
                  right: getProportionateScreenWidth(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InterText(
                      title: localLanguage.my_records.toUpperCase(),
                      fontSize: 16,
                      textColor: AppColors.color888E9D,
                    ),
                    MoreOptionItem(
                      iconName: AppAssets.allPrescriptions,
                      title: localLanguage.all_prescriptions,
                      callBackFunction: () {
                        Get.to(() => const AllPrescriptionsScreen());
                      },
                    ),
                    MoreOptionItem(
                      iconName: AppAssets.testResults,
                      title: localLanguage.test_results,
                      callBackFunction: () {
                        Get.to(() => const TestResultsScreen());
                      },
                    ),
                  ],
                ),
              ),
              CommonSizeBox(height: getProportionateScreenWidth(10)),
              Container(
                color: AppColors.white,
                padding: EdgeInsets.only(
                  top: getProportionateScreenWidth(10),
                  bottom: getProportionateScreenWidth(10),
                  left: getProportionateScreenWidth(20),
                  right: getProportionateScreenWidth(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InterText(
                      title: localLanguage.general.toUpperCase(),
                      fontSize: 16,
                      textColor: AppColors.color888E9D,
                    ),
                    MoreOptionItem(
                      iconName: AppAssets.favouriteDoctors,
                      title: localLanguage.favourite_doctors,
                      callBackFunction: () {
                        Get.to(() => const FavouriteDoctorsScreen());
                      },
                    ),
                    MoreOptionItem(
                      iconName: AppAssets.transactionsHistory,
                      title: localLanguage.transactions_history,
                      callBackFunction: () {
                        Get.to(() => const TransactionsHistoryScreen());
                      },
                    ),
                    MoreOptionItem(
                      iconName: AppAssets.promos,
                      title: localLanguage.promos,
                      callBackFunction: () {
                        Get.to(() => const PromosScreen());
                      },
                    ),
                  ],
                ),
              ),
              CommonSizeBox(height: getProportionateScreenWidth(10)),
              Container(
                color: AppColors.white,
                padding: EdgeInsets.only(
                  top: getProportionateScreenWidth(10),
                  bottom: getProportionateScreenWidth(10),
                  left: getProportionateScreenWidth(20),
                  right: getProportionateScreenWidth(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InterText(
                      title: localLanguage.settings.toUpperCase(),
                      fontSize: 16,
                      textColor: AppColors.color888E9D,
                    ),
                    MoreOptionItem(
                      iconName: AppAssets.changeMobileNumber,
                      title: localLanguage.change_mobile_number,
                      callBackFunction: () {
                        Get.to(() => const ChangeMobileNumberScreen());
                      },
                    ),
                    MoreOptionItem(
                      iconName: AppAssets.language,
                      title: localLanguage.language,
                      callBackFunction: () {
                        Get.to(() => const ChangeLanguageScreen());
                      },
                    ),
                  ],
                ),
              ),
              CommonSizeBox(height: getProportionateScreenWidth(10)),
              Container(
                color: AppColors.white,
                padding: EdgeInsets.only(
                  top: getProportionateScreenWidth(10),
                  bottom: getProportionateScreenWidth(10),
                  left: getProportionateScreenWidth(20),
                  right: getProportionateScreenWidth(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      child: InterText(
                        title: localLanguage.legal.toUpperCase(),
                        fontSize: 16,
                        textColor: AppColors.color888E9D,
                      ),
                    ),
                    MoreOptionItem(
                      iconName: AppAssets.termsAndConditions,
                      title: localLanguage.termsAndConditions,
                      callBackFunction: () {
                        Get.to(() => const DummyTermsAndConditionsScreen());
                      },
                    ),
                    MoreOptionItem(
                      iconName: AppAssets.privacyAndPolicy,
                      title: localLanguage.privacyPolicy,
                      callBackFunction: () {
                        Get.to(() => const DummyPrivacyPolicyScreen());
                      },
                    ),
                    
                  ],
                ),
              ),
              CommonSizeBox(height: getProportionateScreenWidth(10)),
              Container(
                color: AppColors.white,
                padding: EdgeInsets.only(
                  top: getProportionateScreenWidth(10),
                  bottom: getProportionateScreenWidth(10),
                  left: getProportionateScreenWidth(20),
                  right: getProportionateScreenWidth(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      child: InterText(
                        title: localLanguage.help.toUpperCase(),
                        fontSize: 16,
                        textColor: AppColors.color888E9D,
                      ),
                    ),
                    MoreOptionItem(
                      iconName: AppAssets.emergencyCall,
                      title: localLanguage.emergency_call,
                      callBackFunction: () {
                        Get.to(() => const EmergencyCallScreen());
                      },
                    ),
                    MoreOptionItem(
                      iconName: AppAssets.liveSupport,
                      title: localLanguage.live_support,
                      callBackFunction: () {
                        Get.to(() => const LiveSupportScreen());
                      },
                    ),
                  ],
                ),
              ),
              CommonSizeBox(height: getProportionateScreenWidth(10)),
              GestureDetector(
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await removeToken();
                  await prefs.remove('getProfileData');
                  await prefs.setBool(isCallAccepted, false);
                  Get.offAll(() => LoginScreen(showBackButton: false));
                },
                child: Container(
                  color: AppColors.white,
                  height: kToolbarHeight,
                  padding: EdgeInsets.only(
                    left: getProportionateScreenWidth(20),
                    right: getProportionateScreenWidth(20),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        child: const Icon(Icons.logout, size: 18),
                      ),
                      CommonSizeBox(width: 8),
                      SizedBox(
                        child: InterText(
                          title: localLanguage.log_out,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              CommonSizeBox(height: getProportionateScreenWidth(20)),
            ],
          ),
        ),
      ),
    );
  }
}
