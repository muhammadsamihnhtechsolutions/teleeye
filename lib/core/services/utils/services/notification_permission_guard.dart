import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationPermissionGuard {
  static Future<NotificationSettings>? _inFlightRequest;

  static Future<NotificationSettings> requestPermission() {
    final inFlight = _inFlightRequest;
    if (inFlight != null) return inFlight;

    final future = FirebaseMessaging.instance
        .requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        )
        // Ensure we clear the guard even if the request fails.
        .whenComplete(() => _inFlightRequest = null);

    _inFlightRequest = future;
    return future;
  }
}
