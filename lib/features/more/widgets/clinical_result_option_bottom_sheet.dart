import 'package:eye_buddy/core/services/api/model/test_result_response_model.dart'
    as tr;
import 'package:eye_buddy/core/services/utils/config/app_colors.dart';
import 'package:eye_buddy/core/services/utils/size_config.dart';
import 'package:eye_buddy/features/global_widgets/common_size_box.dart';
import 'package:eye_buddy/features/global_widgets/inter_text.dart';
import 'package:eye_buddy/features/more/controller/more_controller.dart';
import 'package:eye_buddy/features/more/view/edit_prescription_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ClinicalResultOptionBottomSheet extends StatelessWidget {
  const ClinicalResultOptionBottomSheet({super.key, required this.testResult});

  final tr.TestResult testResult;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final controller = Get.find<MoreController>();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AppColors.white,
      ),
      padding: EdgeInsets.all(getProportionateScreenWidth(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CommonSizeBox(height: getProportionateScreenHeight(7)),
          GestureDetector(
            onTap: () {
              Get.back();
              Get.to(
                () => EditPrescriptionScreen(
                  screenName: 'Edit Prescription',
                  isFromTestResultScreen: true,
                  prescriptionId: testResult.id ?? '',
                  title: testResult.title ?? '',
                ),
              );
            },
            child: const InterText(
              title: 'Edit',
              fontSize: 14,
              textColor: AppColors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
          CommonSizeBox(height: getProportionateScreenWidth(5)),
          Container(
            height: 1,
            width: double.infinity,
            color: AppColors.colorEDEDED,
            margin: const EdgeInsets.symmetric(vertical: 20),
          ),
          GestureDetector(
            onTap: () async {
              Get.back();
              final id = testResult.id ?? '';
              if (id.isEmpty) return;
              await controller.deleteClinicalTestResult(id);
            },
            child: const InterText(
              title: 'Delete',
              fontSize: 14,
              textColor: AppColors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
