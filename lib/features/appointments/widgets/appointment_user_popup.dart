import 'package:eye_buddy/features/global_widgets/common_network_image_widget.dart';
import 'package:eye_buddy/features/global_widgets/inter_text.dart';
import 'package:eye_buddy/core/services/utils/size_config.dart';
import 'package:flutter/material.dart';

class AppointmentUserPopUpWidget extends StatelessWidget {
  const AppointmentUserPopUpWidget({
    super.key,
    required this.userName,
    required this.image,
  });

  final String userName;
  final String image;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: getProportionateScreenHeight(35),
      width: getProportionateScreenWidth(200),
      child: Row(
        children: [
          SizedBox(
            height: getProportionateScreenHeight(35),
            width: getProportionateScreenHeight(35),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(35),
              child: CommonNetworkImageWidget(imageLink: image),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: InterText(title: userName, fontSize: 14, maxLines: 1),
          ),
        ],
      ),
    );
  }
}
