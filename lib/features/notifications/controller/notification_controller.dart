import 'package:get/get.dart';

import '../../../core/services/api/repo/api_repo.dart';
import '../../../core/services/api/model/notification_response_model.dart';

class NotificationController extends GetxController {
  final ApiRepo _apiRepo;

  NotificationController({ApiRepo? apiRepo}) : _apiRepo = apiRepo ?? ApiRepo();

  final RxBool isLoading = false.obs;
  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  NotificationResponseModel? response;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final res = await _apiRepo.getNotificationList(<String, String>{});

      if (res.status == 'success') {
        response = res;
        notifications.assignAll(
          res.notificationData?.notificationList ?? <NotificationModel>[],
        );
      } else {
        errorMessage.value = res.message ?? 'Something went wrong';
      }
    } catch (e) {
      errorMessage.value = 'Failed to load notifications';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshNotifications() async {
    await loadNotifications();
  }
}
