//import 'package:eye_buddy/app/views/global_widgets/common_size_box.dart';
import 'package:eye_buddy/features/global_widgets/common_size_box.dart';
//import 'package:eye_buddy/app/views/global_widgets/inter_text.dart';
import 'package:eye_buddy/features/global_widgets/inter_text.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'package:eye_buddy/core/services/utils/assets/app_assets.dart';

class NoDataFoundWidget extends StatelessWidget {
  String? title;
  NoDataFoundWidget({super.key, this.title = "No data found"});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 100,
            child: Align(child: LottieBuilder.asset(AppAssets.searchEmpty)),
          ),
          CommonSizeBox(height: 20),
          InterText(title: "${title}", textColor: Colors.grey, fontSize: 12),
        ],
      ),
    );
  }
}
