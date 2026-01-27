import 'package:eye_buddy/core/services/utils/config/app_colors.dart';
import 'package:eye_buddy/core/services/utils/size_config.dart';
import 'package:eye_buddy/features/global_widgets/custom_button.dart';
import 'package:eye_buddy/features/global_widgets/common_app_bar.dart';
import 'package:eye_buddy/features/global_widgets/common_size_box.dart';
import 'package:eye_buddy/features/global_widgets/inter_text.dart';
import 'package:eye_buddy/features/more/controller/more_controller.dart';
import 'package:eye_buddy/features/more/view/upload_clinical_result_screen.dart';
import 'package:eye_buddy/features/more/widgets/clinical_result_list_item.dart';
import 'package:eye_buddy/features/global_widgets/no_data_found_widget.dart';
import 'package:eye_buddy/features/more/view/card_skelton_screen.dart';
import 'package:eye_buddy/core/services/api/model/app_test_result_response_model.dart';
import 'package:eye_buddy/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TestResultsScreen extends StatefulWidget {
  const TestResultsScreen({super.key});

  @override
  State<TestResultsScreen> createState() => _TestResultsScreenState();
}

class _TestResultsScreenState extends State<TestResultsScreen> {
  late final PageController _pageController;
  final RxInt _selectedIndex = 0.obs;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    final MoreController controller = Get.isRegistered<MoreController>()
        ? Get.find<MoreController>()
        : Get.put(MoreController());
    controller.fetchClinicalResults();
    controller.fetchAppTestResults();
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
    final MoreController controller = Get.find<MoreController>();

    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: CommonAppBar(
        title: localLanguage.test_results,
        elevation: 0,
        icon: Icons.arrow_back,
        finishScreen: true,
        isTitleCenter: false,
        context: context,
      ),
      body: Column(
        children: [
          _TestResultTabBar(
            selectedIndex: _selectedIndex,
            onTap: (index) {
              _selectedIndex.value = index;
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
              );
            },
            appTestTitle: localLanguage.app_test,
            clinicalTitle: localLanguage.clinical_results,
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) => _selectedIndex.value = index,
              children: [
                _AppTestResultsView(
                  controller: controller,
                  emptyTitle: localLanguage.you_dont_have_any_app_test_results,
                ),
                _ClinicalResultsView(
                  controller: controller,
                  addButtonTitle: localLanguage.add_new_test_result,
                  emptyTitle: localLanguage.you_dont_have_any_clinical_results,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TestResultTabBar extends StatelessWidget {
  const _TestResultTabBar({
    required this.selectedIndex,
    required this.onTap,
    required this.appTestTitle,
    required this.clinicalTitle,
  });

  final RxInt selectedIndex;
  final ValueChanged<int> onTap;
  final String appTestTitle;
  final String clinicalTitle;

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
            _TestResultTabChip(
              title: appTestTitle,
              isActive: selectedIndex.value == 0,
              onTap: () => onTap(0),
            ),
            _TestResultTabChip(
              title: clinicalTitle,
              isActive: selectedIndex.value == 1,
              onTap: () => onTap(1),
            ),
          ],
        );
      }),
    );
  }
}

class _TestResultTabChip extends StatelessWidget {
  const _TestResultTabChip({
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

class _AppTestItem extends StatelessWidget {
  const _AppTestItem({
    required this.title,
    required this.leftEye,
    required this.rightEye,
  });

  final String title;
  final List<String> leftEye;
  final List<String> rightEye;

  @override
  Widget build(BuildContext context) {
    final localLanguage = AppLocalizations.of(context)!;

    return Container(
      margin: EdgeInsets.only(bottom: getProportionateScreenWidth(10)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: AppColors.white,
        border: Border.all(color: AppColors.colorEFEFEF),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: getProportionateScreenWidth(18),
              top: getProportionateScreenWidth(10),
              bottom: getProportionateScreenWidth(10),
            ),
            child: InterText(
              title: title,
              textColor: AppColors.black,
              fontSize: 14,
            ),
          ),
          Container(
            width: double.maxFinite,
            height: 1,
            color: AppColors.colorEFEFEF,
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    getProportionateScreenWidth(18),
                    getProportionateScreenWidth(7),
                    0,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InterText(
                        title: localLanguage.left_eye,
                        textColor: AppColors.color888E9D,
                        fontSize: 12,
                      ),
                      CommonSizeBox(height: getProportionateScreenWidth(10)),
                      MediaQuery.removePadding(
                        context: context,
                        removeBottom: true,
                        child: ListView.builder(
                          itemCount: leftEye.length,
                          shrinkWrap: true,
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            return Container(
                              margin: EdgeInsets.only(
                                bottom: getProportionateScreenWidth(10),
                              ),
                              child: InterText(
                                title: leftEye[index],
                                textColor: AppColors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: 1,
                height: getProportionateScreenWidth(80),
                color: AppColors.colorEFEFEF,
              ),
              Flexible(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    getProportionateScreenWidth(18),
                    getProportionateScreenWidth(7),
                    0,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InterText(
                        title: localLanguage.right_eye,
                        textColor: AppColors.color888E9D,
                        fontSize: 12,
                      ),
                      CommonSizeBox(height: getProportionateScreenWidth(10)),
                      MediaQuery.removePadding(
                        context: context,
                        removeBottom: true,
                        child: ListView.builder(
                          itemCount: rightEye.length,
                          shrinkWrap: true,
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            return Container(
                              margin: EdgeInsets.only(
                                bottom: getProportionateScreenWidth(10),
                              ),
                              child: InterText(
                                title: rightEye[index],
                                textColor: AppColors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _AppTestResultsView extends StatelessWidget {
  const _AppTestResultsView({
    required this.controller,
    required this.emptyTitle,
  });

  final MoreController controller;
  final String emptyTitle;

  bool _isMeaningfulValue(String value) {
    final v = value.trim();
    if (v.isEmpty) return false;
    if (v == '0/0') return false;
    if (v == '0/23') return false;
    return true;
  }

  List<String> _osOnly(EyeSide? side) {
    final os = (side?.os ?? '').trim();
    if (!_isMeaningfulValue(os)) return const <String>[];
    return <String>['OS   $os'];
  }

  List<String> _odOnly(EyeSide? side) {
    final od = (side?.od ?? '').trim();
    if (!_isMeaningfulValue(od)) return const <String>[];
    return <String>['OD   $od'];
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final localLanguage = AppLocalizations.of(context)!;

    return Obx(() {
      final bool loading = controller.isLoadingAppTestResults.value;
      final resp = controller.appTestResultResponse.value;
      final data = resp?.appTestData;

      final hasAnyData =
          data?.visualAcuity != null ||
          data?.nearVision != null ||
          data?.colorVision != null ||
          data?.amdVision != null;

      return Scaffold(
        backgroundColor: AppColors.appBackground,
        body: Stack(
          children: [
            RefreshIndicator(
              onRefresh: controller.fetchAppTestResults,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: getProportionateScreenWidth(20),
                ).copyWith(top: getProportionateScreenWidth(20)),
                child: (!hasAnyData)
                    ? SizedBox(
                        height: MediaQuery.sizeOf(context).height * 0.7,
                        child: Center(
                          child: NoDataFoundWidget(title: emptyTitle),
                        ),
                      )
                    : Column(
                        children: [
                          if (data?.visualAcuity != null)
                            _AppTestItem(
                              title: localLanguage.visual_acuity,
                              leftEye: _osOnly(data?.visualAcuity?.left),
                              rightEye: _odOnly(data?.visualAcuity?.right),
                            ),
                          if (data?.nearVision != null)
                            _AppTestItem(
                              title: localLanguage.near_vision,
                              leftEye: _osOnly(data?.nearVision?.left),
                              rightEye: _odOnly(data?.nearVision?.right),
                            ),
                          if (data?.colorVision != null)
                            _AppTestItem(
                              title: localLanguage.color_vision,
                              leftEye: [
                                if ((data?.colorVision?.left ?? '')
                                    .trim()
                                    .isNotEmpty)
                                  (data?.colorVision?.left ?? '').trim(),
                              ],
                              rightEye: [
                                if ((data?.colorVision?.right ?? '')
                                    .trim()
                                    .isNotEmpty)
                                  (data?.colorVision?.right ?? '').trim(),
                              ],
                            ),
                          if (data?.amdVision != null)
                            _AppTestItem(
                              title: localLanguage.amd,
                              leftEye: [
                                if ((data?.amdVision?.left ?? '')
                                    .trim()
                                    .isNotEmpty)
                                  (data?.amdVision?.left ?? '').trim(),
                              ],
                              rightEye: [
                                if ((data?.amdVision?.right ?? '')
                                    .trim()
                                    .isNotEmpty)
                                  (data?.amdVision?.right ?? '').trim(),
                              ],
                            ),
                          CommonSizeBox(
                            height: getProportionateScreenWidth(24),
                          ),
                        ],
                      ),
              ),
            ),
            if (loading) const Positioned.fill(child: NewsCardSkelton()),
          ],
        ),
      );
    });
  }
}

class _ClinicalResultsView extends StatelessWidget {
  const _ClinicalResultsView({
    required this.controller,
    required this.addButtonTitle,
    required this.emptyTitle,
  });

  final MoreController controller;
  final String addButtonTitle;
  final String emptyTitle;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Obx(() {
      return Scaffold(
        backgroundColor: AppColors.appBackground,
        bottomNavigationBar: Padding(
          padding: EdgeInsets.only(
            left: getProportionateScreenWidth(20),
            right: getProportionateScreenWidth(20),
            bottom: getProportionateScreenWidth(20),
          ),
          child: CustomButton(
            title: addButtonTitle,
            callBackFunction: () {
              Get.to(() => const UploadClinicalResultScreen());
            },
          ),
        ),
        body: Stack(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: getProportionateScreenWidth(20),
              ),
              child: SizedBox(
                child: controller.clinicalResultDocs.isNotEmpty
                    ? GridView.builder(
                        itemCount: controller.clinicalResultDocs.length,
                        padding: const EdgeInsets.only(bottom: 50, top: 20),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: getProportionateScreenWidth(10),
                          mainAxisSpacing: getProportionateScreenWidth(10),
                        ),
                        physics: const BouncingScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return ClinicalResultListItem(
                            testResult: controller.clinicalResultDocs[index],
                          );
                        },
                      )
                    : SizedBox(
                        height: MediaQuery.sizeOf(context).height,
                        child: NoDataFoundWidget(title: emptyTitle),
                      ),
              ),
            ),
            if (controller.isLoadingClinicalResults.value)
              const Positioned.fill(child: NewsCardSkelton()),
          ],
        ),
      );
    });
  }
}
