import 'package:eye_buddy/core/services/utils/config/app_colors.dart';
import 'package:eye_buddy/core/services/utils/size_config.dart';
import 'package:eye_buddy/features/global_widgets/common_app_bar.dart';
import 'package:eye_buddy/features/global_widgets/common_size_box.dart';
import 'package:eye_buddy/features/global_widgets/custom_button.dart';
import 'package:eye_buddy/features/global_widgets/custom_text_field.dart';
import 'package:eye_buddy/features/global_widgets/inter_text.dart';
import 'package:eye_buddy/features/global_widgets/no_data_found_widget.dart';
import 'package:eye_buddy/features/global_widgets/toast.dart';
import 'package:eye_buddy/features/more/controller/more_controller.dart';
import 'package:eye_buddy/features/more/view/card_skelton_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';

class PromosScreen extends StatefulWidget {
  const PromosScreen({super.key, this.appointmentId});

  final String? appointmentId;

  @override
  State<PromosScreen> createState() => _PromosScreenState();
}

class _PromosScreenState extends State<PromosScreen> {
  final TextEditingController promoCodeController = TextEditingController(
    text: '',
  );

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<MoreController>()) {
      Get.put(MoreController());
    }
    Get.find<MoreController>().fetchPromos();
  }

  @override
  void dispose() {
    promoCodeController.dispose();
    super.dispose();
  }

  String _formatValidTill(String? isoString) {
    if (isoString == null || isoString.isEmpty) return '';
    try {
      return DateFormat('dd MMM, yyyy').format(DateTime.parse(isoString));
    } catch (_) {
      return '';
    }
  }

  Future<void> _applyPromoByCode(BuildContext context, String code) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = Get.find<MoreController>();
    final appointmentId = (widget.appointmentId ?? '').trim();
    if (appointmentId.isEmpty) {
      showToast(message: l10n.invalid_appointment_context, context: context);
      return;
    }

    final resp = await controller.applyPromoToAppointment(
      code: code,
      appointmentId: appointmentId,
    );
    if (resp == null) {
      showToast(message: l10n.invalid_promo, context: context);
      return;
    }

    if (resp.status == 'success') {
      showToast(message: l10n.promo_applied, context: context);
    } else {
      showToast(message: l10n.invalid_promo, context: context);
    }
  }

  void _showAddPromoBottomSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      barrierColor: Colors.black.withOpacity(.3),
      backgroundColor: Colors.white,
      elevation: 10,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      builder: (BuildContext ctx) {
        final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;
        return SafeArea(
          child: AnimatedPadding(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            padding: EdgeInsets.only(
              left: 22,
              right: 22,
              top: 22,
              bottom: bottomInset + 12,
            ),
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                InterText(
                  title: l10n.add_promo_code,
                  fontWeight: FontWeight.bold,
                ),
                SizedBox(height: getProportionateScreenHeight(12)),
                CustomTextFormField(
                  textEditingController: promoCodeController,
                  hint: l10n.promo_code,
                ),
                SizedBox(height: getProportionateScreenHeight(20)),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        title: l10n.cancel,
                        backGroundColor: AppColors.color888E9D,
                        callBackFunction: () {
                          Navigator.pop(ctx);
                        },
                      ),
                    ),
                    CommonSizeBox(width: getProportionateScreenWidth(15)),
                    Expanded(
                      child: CustomButton(
                        title: l10n.add,
                        callBackFunction: () async {
                          final code = promoCodeController.text.trim();
                          await _applyPromoByCode(context, code);
                          Navigator.pop(ctx);
                          if (Navigator.of(context).canPop()) {
                            Navigator.pop(context);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: getProportionateScreenHeight(12)),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final MoreController controller = Get.find<MoreController>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: CommonAppBar(
        title: l10n.promos,
        elevation: 0,
        icon: Icons.arrow_back,
        finishScreen: true,
        isTitleCenter: false,
        context: context,
      ),
      bottomNavigationBar: Obx(() {
        return controller.isLoadingPromos.value
            ? const SizedBox.shrink()
            : Padding(
                padding: EdgeInsets.only(
                  left: getProportionateScreenWidth(20),
                  right: getProportionateScreenWidth(20),
                  bottom: getProportionateScreenWidth(20),
                ),
                child: CustomButton(
                  title: l10n.add_promo_code,
                  callBackFunction: () {
                    _showAddPromoBottomSheet(context);
                  },
                ),
              );
      }),
      body: Obx(() {
        return RefreshIndicator(
          onRefresh: controller.fetchPromos,
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height,
            child: controller.isLoadingPromos.value
                ? Container(color: Colors.white, child: const NewsCardSkelton())
                : controller.apiPromos.isEmpty
                ? NoDataFoundWidget(title: l10n.you_dont_have_any_promo)
                : ListView.builder(
                    itemCount: controller.apiPromos.length,
                    cacheExtent: 10,
                    padding: EdgeInsets.only(
                      bottom: getProportionateScreenHeight(50),
                      top: getProportionateScreenHeight(10),
                    ),
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (listViewContext, index) {
                      final promo = controller.apiPromos[index];
                      final code = (promo.code ?? '').toString();
                      return GestureDetector(
                        onTap: () async {
                          if ((widget.appointmentId ?? '').isEmpty) return;
                          await _applyPromoByCode(context, code);
                          if (mounted && Navigator.of(context).canPop()) {
                            Navigator.pop(context);
                          }
                        },
                        child: Container(
                          width: SizeConfig.screenWidth,
                          color: AppColors.white,
                          padding: EdgeInsets.fromLTRB(
                            getProportionateScreenWidth(20),
                            getProportionateScreenHeight(13),
                            getProportionateScreenWidth(20),
                            getProportionateScreenHeight(13),
                          ),
                          margin: EdgeInsets.only(
                            bottom: getProportionateScreenHeight(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    child: InterText(
                                      title: code,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      textColor: AppColors.color008541,
                                    ),
                                  ),
                                  CommonSizeBox(
                                    height: getProportionateScreenHeight(14),
                                  ),
                                  RichText(
                                    text: TextSpan(
                                      text: '* ${l10n.minimum_amount} ',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.color888E9D,
                                      ),
                                      children: <TextSpan>[
                                        TextSpan(
                                          text:
                                              '${promo.minimumPurchase ?? 0} Tk.',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.color001B0D,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  CommonSizeBox(
                                    height: getProportionateScreenHeight(6),
                                  ),
                                  RichText(
                                    text: TextSpan(
                                      text: '* ${l10n.valid_till} ',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.color888E9D,
                                      ),
                                      children: <TextSpan>[
                                        TextSpan(
                                          text: _formatValidTill(
                                            promo.validTill,
                                          ),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.color001B0D,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    child: InterText(
                                      title:
                                          '${promo.discount ?? 0}% ${l10n.off}',
                                      textColor: AppColors.color008541,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  CommonSizeBox(
                                    height: getProportionateScreenHeight(4),
                                  ),
                                  SizedBox(
                                    child: InterText(
                                      title:
                                          '${l10n.up_to} ${promo.maximumDiscount ?? 0} Tk.',
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        );
      }),
    );
  }
}
