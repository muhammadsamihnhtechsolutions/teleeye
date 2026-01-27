import 'package:eye_buddy/core/services/utils/config/app_colors.dart';
import 'package:eye_buddy/core/services/utils/functions.dart';
import 'package:eye_buddy/core/services/utils/size_config.dart';
import 'package:eye_buddy/core/services/utils/assets/app_assets.dart';
import 'package:eye_buddy/core/services/utils/global_variables.dart';
import 'package:eye_buddy/features/global_widgets/common_app_bar.dart';
import 'package:eye_buddy/features/global_widgets/common_size_box.dart';
import 'package:eye_buddy/features/global_widgets/inter_text.dart';
import 'package:eye_buddy/features/global_widgets/no_data_found_widget.dart';
import 'package:eye_buddy/features/more/controller/more_controller.dart';
import 'package:eye_buddy/features/more/view/card_skelton_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../l10n/app_localizations.dart';

class TransactionsHistoryScreen extends StatefulWidget {
  const TransactionsHistoryScreen({super.key});

  @override
  State<TransactionsHistoryScreen> createState() =>
      _TransactionsHistoryScreenState();
}

class _TransactionsHistoryScreenState extends State<TransactionsHistoryScreen> {
  @override
  void initState() {
    super.initState();
    // Match BLoC: fetch on screen open (every time the screen is created)
    final controller = Get.find<MoreController>();
    controller.fetchTransactionsHistory();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final MoreController controller = Get.find<MoreController>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: CommonAppBar(
        title: l10n.transactions_history,
        elevation: 0,
        icon: Icons.arrow_back,
        finishScreen: true,
        isTitleCenter: false,
        context: context,
      ),
      body: Obx(() {
        if (controller.isLoadingTransactions.value) {
          return const NewsCardSkelton();
        }

        final items = controller.transactionAppointments;
        if (items.isEmpty) {
          return NoDataFoundWidget(
            title: l10n.you_dont_have_any_transactions_history,
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchTransactionsHistory(),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: getProportionateScreenWidth(20),
            ),
            child: ListView.builder(
              itemCount: items.length,
              padding: const EdgeInsets.only(bottom: 50, top: 17),
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                final appointment = items[index];
                final doctorName = appointment.doctor?.name ?? '';
                final amount =
                    appointment.grandTotal?.toString() ??
                    appointment.totalAmount?.toString() ??
                    '';
                final dateText = (appointment.date ?? '').toString();

                return Container(
                  margin: EdgeInsets.only(
                    bottom: getProportionateScreenWidth(23),
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: getProportionateScreenHeight(40),
                        width: getProportionateScreenHeight(40),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: AppColors.colorE6F2EE,
                        ),
                        child: SvgPicture.asset(
                          AppAssets.transactions,
                          height: getProportionateScreenWidth(21),
                          width: getProportionateScreenWidth(21),
                        ),
                      ),
                      CommonSizeBox(width: getProportionateScreenWidth(14)),
                      SizedBox(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                text: 'Paid to ',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.black,
                                ),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: doctorName,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: getProportionateScreenHeight(10)),
                            InterText(
                              title: formatDate(dateText),
                              fontSize: 9,
                              textColor: AppColors.color888E9D,
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      InterText(
                        title: '$getCurrencySymbol $amount',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ],
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
