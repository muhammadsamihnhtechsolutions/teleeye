// import 'package:eye_buddy/app/utils/config/app_colors.dart';
import 'package:eye_buddy/core/services/utils/config/app_colors.dart';
import 'package:eye_buddy/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

// import '../../../l10n/app_localizations.dart';
// import '../shemmer/card_skelton_screen.dart';

class CustomLoader extends StatefulWidget {
  const CustomLoader({super.key});

  @override
  _CustomLoader createState() => _CustomLoader();
}

class _CustomLoader extends State<CustomLoader> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // return NewsCardSkelton();
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
          ),
          width: MediaQuery.of(context).size.width * .6,
          child: SizedBox(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(AppColors.primaryColor),
                  ),
                ),
                SizedBox(width: 16),
                Text(
                  l10n.loading,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomLoadingScreen extends StatelessWidget {
  const CustomLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // return NewsCardSkelton();
    return Container(
      height: double.maxFinite,
      width: double.maxFinite,
      color: Colors.white,
      child: const CustomLoader(),
    );
  }
}
