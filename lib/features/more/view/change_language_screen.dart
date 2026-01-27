import 'package:eye_buddy/core/services/utils/config/app_colors.dart';
import 'package:eye_buddy/core/services/utils/size_config.dart';
import 'package:eye_buddy/features/global_widgets/common_app_bar.dart';
import 'package:eye_buddy/features/global_widgets/inter_text.dart';
import 'package:eye_buddy/features/more/controller/more_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../l10n/app_localizations.dart';

class ChangeLanguageScreen extends StatefulWidget {
  const ChangeLanguageScreen({super.key});

  @override
  State<ChangeLanguageScreen> createState() => _ChangeLanguageScreenState();
}

class _ChangeLanguageScreenState extends State<ChangeLanguageScreen> {
  Locale? _initialLocale;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initialLocale ??= Localizations.localeOf(context);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final MoreController controller = Get.find<MoreController>();

    return Localizations.override(
      context: context,
      locale: _initialLocale,
      child: Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context)!;
          return Scaffold(
            backgroundColor: AppColors.appBackground,
            appBar: CommonAppBar(
              title: l10n.language,
              elevation: 0,
              icon: Icons.arrow_back,
              finishScreen: true,
              isTitleCenter: false,
              context: context,
            ),
            body: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.color888E9D.withOpacity(0.25),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InterText(
                          title: l10n.language,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        const SizedBox(height: 6),
                        InterText(
                          title: l10n.change_language,
                          fontSize: 12,
                          textColor: AppColors.color888E9D,
                        ),
                        const SizedBox(height: 14),
                        Obx(
                          () => Column(
                            children: [
                              _LanguageTile(
                                title: l10n.english_language,
                                subtitle: l10n.english_language_subtitle,
                                value: 'en',
                                groupValue: controller.selectedLocaleCode.value,
                                onChanged: (value) {
                                  controller.setLocale(value);
                                },
                              ),
                              const SizedBox(height: 10),
                              _LanguageTile(
                                title: l10n.bangla_language,
                                subtitle: l10n.bangla_language_subtitle,
                                value: 'bn',
                                groupValue: controller.selectedLocaleCode.value,
                                onChanged: (value) {
                                  controller.setLocale(value);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final String value;
  final String groupValue;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final selected = groupValue == value;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? AppColors.primaryColor
                : AppColors.color888E9D.withOpacity(0.25),
          ),
          color: selected
              ? AppColors.primaryColor.withOpacity(0.08)
              : Colors.white,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InterText(
                    title: title,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  const SizedBox(height: 2),
                  InterText(
                    title: subtitle,
                    fontSize: 12,
                    textColor: AppColors.color888E9D,
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: groupValue,
              activeColor: AppColors.primaryColor,
              onChanged: (val) {
                if (val != null) onChanged(val);
              },
            ),
          ],
        ),
      ),
    );
  }
}
