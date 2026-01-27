import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
//import '../../utils/assets/app_assets.dart';
import 'package:eye_buddy/core/services/utils/assets/app_assets.dart';
//import '../../utils/size_config.dart';
import 'package:eye_buddy/core/services/utils/size_config.dart';
import 'inter_text.dart';

class NoInterConnectionWidget extends StatelessWidget {
  const NoInterConnectionWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var width = SizeConfig.screenWidth;
    var height = SizeConfig.screenHeight;

    return Scaffold(
      body: SizedBox(
        height: height,
        width: width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: height / 3,
              width: width / 2,
              child: SvgPicture.asset(
                AppAssets.noConnectionSvg,
                fit: BoxFit.contain,
              ),
            ),
            InterText(
              title: 'No Internet Connection',
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            SizedBox(height: 4),
            InterText(
              title: 'Please Check Your Internet',
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ],
        ),
      ),
    );
  }
}
