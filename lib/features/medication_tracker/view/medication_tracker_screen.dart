import 'package:eye_buddy/core/services/utils/config/app_colors.dart';
import 'package:eye_buddy/core/services/utils/dimentions.dart';
import 'package:eye_buddy/core/services/utils/size_config.dart';
import 'package:eye_buddy/features/global_widgets/custom_loader.dart';
import 'package:eye_buddy/features/global_widgets/custom_button.dart';
import 'package:eye_buddy/features/global_widgets/inter_text.dart';
import 'package:eye_buddy/features/global_widgets/no_data_found_widget.dart';
import 'package:eye_buddy/features/medication_tracker/controller/medication_tracker_controller.dart';
import 'package:eye_buddy/features/medication_tracker/view/add_or_edit_medication_screen.dart';
import 'package:eye_buddy/features/medication_tracker/widgets/medication_tracker_tile_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eye_buddy/l10n/app_localizations.dart';

class MedicationTrackerScreen extends StatefulWidget {
  const MedicationTrackerScreen({super.key});

  @override
  State<MedicationTrackerScreen> createState() =>
      _MedicationTrackerScreenState();
}

class _MedicationTrackerScreenState extends State<MedicationTrackerScreen> {
  late final MedicationTrackerController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(MedicationTrackerController());
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: InterText(title: l10n.medication_tracker),
      ),
      bottomNavigationBar: Obx(() {
        if (controller.isLoading.value) return const SizedBox.shrink();
        return Padding(
          padding: EdgeInsets.only(
            left: getProportionateScreenWidth(20),
            right: getProportionateScreenWidth(20),
            bottom: getProportionateScreenWidth(20),
          ),
          child: CustomButton(
            title: 'Create New Medication',
            callBackFunction: () {
              Get.to(() => const AddOrEditMedicationScreen());
            },
          ),
        );
      }),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Container(
            height: getHeight(context: context),
            width: getWidth(context: context),
            color: Colors.white,
            child: const CustomLoader(),
          );
        }

        if (controller.medications.isEmpty) {
          return NoDataFoundWidget(
            title: "You don't have any medication tracking history",
          );
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          height: getHeight(context: context),
          width: getWidth(context: context),
          child: RefreshIndicator(
            onRefresh: controller.fetchMedications,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  ListView.builder(
                    itemCount: controller.medications.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final med = controller.medications[index];
                      return MedicationTrackerTileWidget(medication: med);
                    },
                  ),
                  const SizedBox(height: kTextTabBarHeight * 3),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
