import 'package:eye_buddy/core/services/utils/config/app_colors.dart';
import 'package:eye_buddy/core/services/api/model/prescription_list_response_model.dart';
import 'package:eye_buddy/core/services/api/model/patient_list_model.dart';
import 'package:eye_buddy/core/services/utils/size_config.dart';
import 'package:eye_buddy/features/global_widgets/common_app_bar.dart';
import 'package:eye_buddy/features/global_widgets/custom_button.dart';
import 'package:eye_buddy/features/global_widgets/inter_text.dart';
import 'package:eye_buddy/features/global_widgets/no_data_found_widget.dart';
import 'package:eye_buddy/features/more/controller/more_controller.dart';
import 'package:eye_buddy/features/more/view/add_prescription_screen.dart';
import 'package:eye_buddy/features/more/view/card_skelton_screen.dart';
import 'package:eye_buddy/features/more/widgets/prescription_list_item.dart';
import 'package:eye_buddy/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AllPrescriptionsScreen extends StatefulWidget {
  const AllPrescriptionsScreen({super.key});

  @override
  State<AllPrescriptionsScreen> createState() => _AllPrescriptionsScreenState();
}

class _AllPrescriptionsScreenState extends State<AllPrescriptionsScreen> {
  late MoreController controller;
  bool _didInitLoad = false;
  late final PageController _pageController = PageController();
  final RxInt _selectedIndex = 0.obs;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<MoreController>()
        ? Get.find<MoreController>()
        : Get.put(MoreController());

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || _didInitLoad) return;
      _didInitLoad = true;

      if (controller.isLoadingPatients.value == false) {
        await controller.fetchPatients();
      }

      if (!mounted) return;
      if (controller.selectedPatient.value == null &&
          controller.patients.isNotEmpty) {
        controller.setSelectedPatient(controller.patients.first);
      }

      if (controller.apiPrescriptions.isEmpty &&
          controller.isLoadingPrescriptions.value == false) {
        await controller.fetchPrescriptions(remoteOnly: true);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final localLanguage = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: CommonAppBar(
        title: localLanguage.all_prescriptions,
        elevation: 0,
        icon: Icons.arrow_back,
        finishScreen: true,
        isTitleCenter: false,
        context: context,
      ),
      bottomNavigationBar: Obx(() {
        final showAdd = _selectedIndex.value == 1;
        if (!showAdd) return const SizedBox.shrink();
        return Padding(
          padding: EdgeInsets.only(
            left: getProportionateScreenWidth(20),
            right: getProportionateScreenWidth(20),
            bottom: getProportionateScreenWidth(20),
          ),
          child: CustomButton(
            title: localLanguage.add_new_prescription,
            callBackFunction: () {
              Get.to(() => const AddPrescriptionScreen());
            },
          ),
        );
      }),
      body: Obx(() {
        final isLoadingPatients = controller.isLoadingPatients.value;
        final patients = controller.patients;
        final isLoadingPrescriptions = controller.isLoadingPrescriptions.value;
        final prescriptions = controller.apiPrescriptions;

        final doctorPrescriptions = prescriptions.where((p) {
          final titleLower = (p.title ?? '').trim().toLowerCase();
          final hasMeds = (p.medicines ?? const []).isNotEmpty;
          return hasMeds || titleLower == 'rx';
        }).toList();

        final myPrescriptions = prescriptions.where((p) {
          final titleLower = (p.title ?? '').trim().toLowerCase();
          final hasMeds = (p.medicines ?? const []).isNotEmpty;
          return !(hasMeds || titleLower == 'rx');
        }).toList();

        return RefreshIndicator(
          onRefresh: () async {
            await controller.fetchPatients();
            await controller.fetchPrescriptions(remoteOnly: true);
          },
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(
                  left: getProportionateScreenWidth(20),
                  right: getProportionateScreenWidth(20),
                  top: getProportionateScreenWidth(12),
                ),
                child: _PatientPickerCard(
                  controller: controller,
                  localLanguage: localLanguage,
                  isLoading: isLoadingPatients,
                  patients: patients,
                ),
              ),
              SizedBox(height: getProportionateScreenHeight(12)),
              _PrescriptionTabBar(
                selectedIndex: _selectedIndex,
                onTap: (index) {
                  _selectedIndex.value = index;
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                  );
                },
              ),
              SizedBox(height: getProportionateScreenHeight(12)),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) => _selectedIndex.value = index,
                  children: [
                    _PrescriptionGrid(
                      isLoading: isLoadingPrescriptions,
                      prescriptions: doctorPrescriptions,
                      emptyTitle: localLanguage.you_dont_have_any_prescription,
                      showAddToMedicine: true,
                    ),
                    _PrescriptionGrid(
                      isLoading: isLoadingPrescriptions,
                      prescriptions: myPrescriptions,
                      emptyTitle: localLanguage.you_dont_have_any_prescription,
                      showAddToMedicine: false,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _PrescriptionTabBar extends StatelessWidget {
  const _PrescriptionTabBar({
    required this.selectedIndex,
    required this.onTap,
  });

  final RxInt selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Container(
      height: getProportionateScreenHeight(45),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.color80C2A0),
      ),
      padding: const EdgeInsets.all(5),
      margin: EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(20)),
      child: Obx(() {
        return Row(
          children: [
            _PrescriptionTabChip(
              title: 'Doctor Prescriptions',
              isActive: selectedIndex.value == 0,
              onTap: () => onTap(0),
            ),
            _PrescriptionTabChip(
              title: 'My Prescriptions',
              isActive: selectedIndex.value == 1,
              onTap: () => onTap(1),
            ),
          ],
        );
      }),
    );
  }
}

class _PrescriptionTabChip extends StatelessWidget {
  const _PrescriptionTabChip({
    required this.title,
    required this.isActive,
    required this.onTap,
  });

  final String title;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: isActive ? AppColors.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          alignment: Alignment.center,
          child: InterText(
            title: title,
            textColor: isActive ? Colors.white : Colors.black,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _PrescriptionGrid extends StatelessWidget {
  const _PrescriptionGrid({
    required this.isLoading,
    required this.prescriptions,
    required this.emptyTitle,
    required this.showAddToMedicine,
  });

  final bool isLoading;
  final List<Prescription> prescriptions;
  final String emptyTitle;
  final bool showAddToMedicine;

  @override
  Widget build(BuildContext context) {
    if (isLoading && prescriptions.isEmpty) {
      return const NewsCardSkelton();
    }
    if (prescriptions.isEmpty) {
      return NoDataFoundWidget(title: emptyTitle);
    }
    return Padding(
      padding: EdgeInsets.only(
        left: getProportionateScreenWidth(20),
        right: getProportionateScreenWidth(20),
        bottom: getProportionateScreenHeight(40),
      ),
      child: GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: getProportionateScreenWidth(12),
          mainAxisSpacing: getProportionateScreenWidth(12),
          childAspectRatio: .78,
        ),
        itemCount: prescriptions.length,
        itemBuilder: (context, index) {
          final prescription = prescriptions[index];
          return PrescriptionListItem(
            prescription: prescription,
            showAddToMedicine: showAddToMedicine,
            showUploaderLabel: false,
          );
        },
      ),
    );
  }
}

class _PatientPickerCard extends StatelessWidget {
  const _PatientPickerCard({
    required this.controller,
    required this.localLanguage,
    required this.isLoading,
    required this.patients,
  });

  final MoreController controller;
  final AppLocalizations localLanguage;
  final bool isLoading;
  final List<MyPatient> patients;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = controller.selectedPatient.value;

      Widget content;
      if (isLoading && patients.isEmpty) {
        content = const SizedBox(
          height: 44,
          child: Center(
            child: SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      } else if (patients.isEmpty) {
        content = SizedBox(
          height: 44,
          child: Center(
            child: InterText(
              title: localLanguage.please_select_your_patient,
              fontSize: 12,
              textColor: AppColors.color888E9D,
            ),
          ),
        );
      } else {
        content = DropdownButtonHideUnderline(
          child: DropdownButton<MyPatient>(
            isExpanded: true,
            icon: const Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.primaryColor,
              size: 28,
            ),
            value: selected == null
                ? null
                : patients.firstWhereOrNull(
                    (p) => (p.id ?? '') == (selected.id ?? ''),
                  ),
            hint: InterText(
              title: localLanguage.selectPatient,
              fontSize: 13,
              textColor: AppColors.black,
            ),
            items: patients
                .map(
                  (p) => DropdownMenuItem<MyPatient>(
                    value: p,
                    child: InterText(
                      title: (p.name ?? '').trim().isEmpty
                          ? localLanguage.selectPatient
                          : (p.name ?? ''),
                      fontSize: 13,
                      textColor: AppColors.black,
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) async {
              if (value == null) return;
              controller.setSelectedPatient(value);
              await controller.fetchPrescriptions(remoteOnly: true);
            },
          ),
        );
      }

      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: getProportionateScreenWidth(12),
          vertical: getProportionateScreenWidth(8),
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.colorEFEFEF),
        ),
        child: content,
      );
    });
  }
}
