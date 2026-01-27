import 'package:eye_buddy/core/services/api/model/test_result_response_model.dart'
    as tr;
import 'package:eye_buddy/core/services/api/service/api_constants.dart';
import 'package:eye_buddy/core/services/utils/assets/app_assets.dart';
import 'package:eye_buddy/core/services/utils/config/app_colors.dart';
import 'package:eye_buddy/core/services/utils/functions.dart';
import 'package:eye_buddy/core/services/utils/size_config.dart';
import 'package:eye_buddy/features/global_widgets/common_network_image_widget.dart';
import 'package:eye_buddy/features/global_widgets/common_size_box.dart';
import 'package:eye_buddy/features/global_widgets/inter_text.dart';
import 'package:eye_buddy/features/more/controller/more_controller.dart';
import 'package:eye_buddy/features/more/widgets/clinical_result_option_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class ClinicalResultListItem extends StatelessWidget {
  const ClinicalResultListItem({super.key, required this.testResult});

  final tr.TestResult testResult;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AppColors.colorEDEDED,
      ),
      padding: EdgeInsets.all(getProportionateScreenWidth(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              SizedBox(
                height: getProportionateScreenWidth(
                  getProportionateScreenWidth(80),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CommonNetworkImageWidget(
                    imageLink:
                        '${ApiConstants.imageBaseUrl}${testResult.attachment ?? ''}',
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () {
                    try {
                      final controller = Get.find<MoreController>();
                      controller.sharePrescription(
                        file: testResult.attachment,
                        title: testResult.title,
                      );
                    } catch (_) {
                      // ignore
                    }
                  },
                  child: SvgPicture.asset(
                    AppAssets.share,
                    height: getProportionateScreenWidth(14),
                    width: getProportionateScreenWidth(14),
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      isScrollControlled: false,
                      context: context,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15.0),
                          topRight: Radius.circular(15.0),
                        ),
                      ),
                      builder: (BuildContext bc) {
                        return SizedBox(
                          height: getProportionateScreenHeight(150),
                          child: ClinicalResultOptionBottomSheet(
                            testResult: testResult,
                          ),
                        );
                      },
                    );
                  },
                  child: SvgPicture.asset(
                    AppAssets.option,
                    height: getProportionateScreenWidth(14),
                    width: getProportionateScreenWidth(14),
                  ),
                ),
              ),
            ],
          ),
          CommonSizeBox(height: getProportionateScreenHeight(7)),
          InterText(
            title: formatDate((testResult.createdAt ?? '').toString()),
            fontSize: 12,
            textColor: AppColors.black,
            maxLines: 1,
          ),
          CommonSizeBox(height: getProportionateScreenWidth(5)),
          InterText(
            title: (testResult.title ?? '').toString(),
            fontSize: 14,
            textColor: AppColors.black,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}
