import 'package:eye_buddy/features/more/view/card_skelton_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/utils/config/app_colors.dart';
import '../../../core/services/utils/size_config.dart';
import '../../../core/services/utils/functions.dart';
import '../../../core/services/api/model/notification_response_model.dart';
import '../../global_widgets/inter_text.dart';
import '../../global_widgets/no_data_found_widget.dart';
import '../controller/notification_controller.dart';

import '../../../l10n/app_localizations.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotificationController());

    SizeConfig().init(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.black,
          onPressed: () => Navigator.pop(context),
        ),
        title: InterText(title: AppLocalizations.of(context)!.notifications),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Container(
            height: SizeConfig.screenHeight,
            width: SizeConfig.screenWidth,
            color: Colors.white,
            child: const NewsCardSkelton(),
          );
        }

        if (controller.notifications.isEmpty) {
          return NoDataFoundWidget(
            title: AppLocalizations.of(context)!.you_dont_have_any_notification,
          );
        }

        return Container(
          height: SizeConfig.screenHeight,
          width: SizeConfig.screenWidth,
          child: RefreshIndicator(
            onRefresh: controller.refreshNotifications,
            child: ListView.builder(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: controller.notifications.length,
              itemBuilder: (context, index) {
                final item = controller.notifications[index];
                if (_isEmptyItem(item)) {
                  return const SizedBox.shrink();
                }
                return _notificationItem(item);
              },
            ),
          ),
        );
      }),
    );
  }

  bool _isEmptyItem(NotificationModel notificationModel) {
    final desc = (notificationModel.metaData?.description ?? '').trim();
    final title = (notificationModel.title ?? '').trim();
    final body = (notificationModel.body ?? '').trim();
    return desc.isEmpty && title.isEmpty && body.isEmpty;
  }

  Widget _notificationItem(NotificationModel notificationModel) {
    final desc = (notificationModel.metaData?.description ?? '').trim();
    final title = (notificationModel.title ?? '').trim();
    final body = (notificationModel.body ?? '').trim();
    final displayText = desc.isNotEmpty
        ? desc
        : (title.isNotEmpty
            ? title
            : body);

    return Container(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: Row(
              children: [
                Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                    color: AppColors.colorCCE7D9,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: const Icon(
                    Icons.notifications_none_outlined,
                    color: AppColors.primaryColor,
                    size: 18,
                  ),
                ),
                SizedBox(width: getProportionateScreenHeight(10)),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          text: displayText,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.black,
                          ),
                          children: const <TextSpan>[],
                        ),
                      ),
                      SizedBox(height: getProportionateScreenHeight(10)),
                      InterText(
                        title: notificationModel.metaData?.date != null
                            ? '${formatDateDDMMMMYYYY(notificationModel.metaData!.date!)}'
                            : '',
                        fontSize: 9,
                        textColor: AppColors.color888E9D,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, color: AppColors.colorEDEDED),
        ],
      ),
    );
  }
}
