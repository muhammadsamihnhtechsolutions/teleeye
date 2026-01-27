import 'package:eye_buddy/core/services/utils/config/app_colors.dart';
import 'package:eye_buddy/features/global_widgets/inter_text.dart';
import 'package:flutter/material.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  CommonAppBar({
    this.height = kToolbarHeight,
    required this.elevation,
    required this.title,
    required this.context,
    required this.finishScreen,
    required this.isTitleCenter,
    required this.icon,
    this.onBack,
    super.key,
  });
  String title;
  final double height;
  final double elevation;
  final bool finishScreen;
  final bool isTitleCenter;
  final IconData icon;
  BuildContext context;
  final VoidCallback? onBack;

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return _appbar();
  }

  Widget _appbar() {
    return AppBar(
      centerTitle: isTitleCenter,
      title: InterText(title: title),
      elevation: elevation,
      backgroundColor: AppColors.white,
      leading: IconButton(
        onPressed: () {
          if (onBack != null) {
            onBack!.call();
            return;
          }
          if (finishScreen) {
            Navigator.pop(context);
          }
        },
        icon: const Icon(Icons.arrow_back, color: AppColors.black, size: 20),
      ),
    );
  }
}
