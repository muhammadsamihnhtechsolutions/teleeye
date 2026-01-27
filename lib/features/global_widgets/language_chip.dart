import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:eye_buddy/core/services/utils/config/app_colors.dart';
import 'package:eye_buddy/core/services/utils/keys/shared_pref_keys.dart';
import 'package:eye_buddy/features/global_widgets/inter_text.dart';
import 'package:eye_buddy/features/more/controller/more_controller.dart';

// Language enum
enum Language { bangla, english }

class _LanguageChipController extends GetxController {
  final selectedLocaleCode = 'en'.obs;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(languagePrefsKey);
      final code = (saved == 'bn' || saved == 'en')
          ? saved!
          : (Get.locale?.languageCode == 'bn' ? 'bn' : 'en');
      selectedLocaleCode.value = code;
    } catch (_) {
      selectedLocaleCode.value = Get.locale?.languageCode == 'bn' ? 'bn' : 'en';
    }
  }

  Future<void> setLocale(String code) async {
    final normalized = (code == 'bn') ? 'bn' : 'en';
    selectedLocaleCode.value = normalized;
    Get.updateLocale(Locale(normalized));
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(languagePrefsKey, normalized);
    } catch (_) {
      // ignore
    }
  }
}

// The LanguageChip widget using GetX
class LanguageChip extends StatelessWidget {
  LanguageChip({super.key});

  final _LanguageChipController controller =
      Get.isRegistered<_LanguageChipController>()
      ? Get.find<_LanguageChipController>()
      : Get.put(_LanguageChipController(), permanent: true);

  @override
  Widget build(BuildContext context) {
    final MoreController? moreController = Get.isRegistered<MoreController>()
        ? Get.find<MoreController>()
        : null;

    final RxString selectedCodeRx =
        moreController?.selectedLocaleCode ?? controller.selectedLocaleCode;

    void setLocale(String code) {
      if (moreController != null) {
        moreController.setLocale(code);
        return;
      }
      controller.setLocale(code);
    }

    return Align(
      child: Obx(
        () => Container(
          width: 70,
          height: 30,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(63),
            border: Border.all(color: AppColors.color008541),
          ),
          child: Row(
            children: [
              // Bangla button
              Flexible(
                child: GestureDetector(
                  onTap: () {
                    setLocale('bn');
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(63),
                        bottomLeft: Radius.circular(63),
                      ),
                      color: selectedCodeRx.value == 'en'
                          ? Colors.transparent
                          : AppColors.color008541,
                    ),
                    alignment: Alignment.center,
                    child: InterText(
                      title: 'বাং',
                      fontSize: 9,
                      textColor: selectedCodeRx.value == 'en'
                          ? Colors.black
                          : Colors.white,
                    ),
                  ),
                ),
              ),

              // English button
              Flexible(
                child: GestureDetector(
                  onTap: () {
                    setLocale('en');
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(63),
                        bottomRight: Radius.circular(63),
                      ),
                      color: selectedCodeRx.value == 'bn'
                          ? Colors.transparent
                          : AppColors.color008541,
                    ),
                    alignment: Alignment.center,
                    child: InterText(
                      title: 'ENG',
                      fontSize: 9,
                      textColor: selectedCodeRx.value == 'bn'
                          ? Colors.black
                          : Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
