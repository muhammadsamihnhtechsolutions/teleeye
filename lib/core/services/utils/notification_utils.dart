import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:eye_buddy/core/services/utils/keys/shared_pref_keys.dart';
import 'package:eye_buddy/core/services/utils/string_to_map.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AwesomeNotificationController {
  /// Use this method to detect when a new notification or a schedule is created
  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(
    ReceivedNotification receivedNotification,
  ) async {
    // Optional: log or track
  }

  /// Use this method to detect every time that a new notification is displayed
  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(
    ReceivedNotification receivedNotification,
  ) async {
    // Optional: log or track
  }

  /// Use this method to detect if the user dismissed a notification
  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    // Optional: log or track
  }

  /// Use this method to detect when the user taps on a notification or action button
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    // Handle tap on notification
    final payload = receivedAction.payload ?? {};

    try {
      final meta = payload['meta']?.toString() ?? '';
      String notificationCriteria = '';

      if (meta.isNotEmpty) {
        final firebasePayload = await stringToMapAsync(meta);
        notificationCriteria = firebasePayload['criteria']?.toString() ?? '';
      }

      notificationCriteria = notificationCriteria.isNotEmpty
          ? notificationCriteria
          : (payload['criteria']?.toString() ?? '');

      if (notificationCriteria == 'c') {
        notificationCriteria = 'prescription';
      }

      if (notificationCriteria == 'prescription') {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(criteria, 'prescription');
      }
    } catch (_) {
      // ignore
    }
  }
}
