import 'dart:developer';
import 'dart:convert';

import 'package:eye_buddy/core/services/api/model/medication_tracker_model.dart';
import 'package:eye_buddy/core/services/api/repo/api_repo.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MedicationTrackerController extends GetxController {
  final ApiRepo _apiRepo = ApiRepo();

  final isLoading = false.obs;
  final medications = <Medication>[].obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMedications();
  }

  List<Map<String, dynamic>> _decodeMedicationRawList(String? jsonData) {
    try {
      final decoded = jsonDecode(jsonData ?? '[]');
      if (decoded is! List) return <Map<String, dynamic>>[];
      return decoded
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    } catch (_) {
      return <Map<String, dynamic>>[];
    }
  }

  int _getDayOfWeek(String day) {
    switch (day.toLowerCase()) {
      case 'mon':
        return DateTime.monday;
      case 'tue':
        return DateTime.tuesday;
      case 'wed':
        return DateTime.wednesday;
      case 'thu':
        return DateTime.thursday;
      case 'fri':
        return DateTime.friday;
      case 'sat':
        return DateTime.saturday;
      case 'sun':
        return DateTime.sunday;
      default:
        return DateTime.monday;
    }
  }

  DateTime? _nextOccurrence({required String day, required String time}) {
    try {
      final parts = time.split(':');
      if (parts.length < 2) return null;
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final now = DateTime.now();
      final targetWeekday = _getDayOfWeek(day);

      var scheduled = DateTime(now.year, now.month, now.day, hour, minute);
      while (scheduled.weekday != targetWeekday || scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }
      return scheduled;
    } catch (_) {
      return null;
    }
  }

  Future<void> _ensureAwesomeNotificationsPermission() async {
    try {
      final allowed = await AwesomeNotifications().isNotificationAllowed();
      if (!allowed) {
        await AwesomeNotifications().requestPermissionToSendNotifications();
      }
    } catch (_) {
      // ignore
    }
  }

  Future<void> _scheduleMedicationNotificationFromRaw(
    Map<String, dynamic> raw,
  ) async {
    final id = raw['_id']?.toString() ?? '';
    if (id.isEmpty) return;

    final status = raw['status']?.toString().toLowerCase() ?? '';
    if (status == 'inactive') return;

    final day = raw['day']?.toString() ?? '';
    final time = raw['time']?.toString() ?? '';
    if (day.isEmpty || time.isEmpty) return;

    final scheduled = _nextOccurrence(day: day, time: time);
    if (scheduled == null) return;

    final title = (raw['title']?.toString() ?? 'Medication').trim();
    final notificationId = id.hashCode;

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: notificationId,
        channelKey: 'basic_channel',
        title: title,
        body: 'It is time to take your medication.',
        payload: {
          'type': 'medication',
          'medicationId': id,
          'title': title,
          'day': day,
          'time': time,
        },
      ),
      schedule: NotificationCalendar(
        year: scheduled.year,
        month: scheduled.month,
        day: scheduled.day,
        hour: scheduled.hour,
        minute: scheduled.minute,
        second: 0,
        millisecond: 0,
        repeats: false,
      ),
    );
  }

  Future<void> _cancelMedicationNotificationByRawId(String rawId) async {
    if (rawId.trim().isEmpty) return;
    try {
      await AwesomeNotifications().cancel(rawId.hashCode);
    } catch (_) {
      // ignore
    }
  }

  Future<void> _rescheduleNotificationsForTitle(String title) async {
    if (title.trim().isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = prefs.getString('getMedicationListJson');
      final rawList = _decodeMedicationRawList(jsonData);

      final matching = rawList
          .where((e) => (e['title']?.toString() ?? '') == title)
          .toList();

      await _ensureAwesomeNotificationsPermission();
      for (final e in matching) {
        final id = e['_id']?.toString() ?? '';
        await _cancelMedicationNotificationByRawId(id);
        await _scheduleMedicationNotificationFromRaw(e);
      }
    } catch (_) {
      // ignore
    }
  }

  Future<void> fetchMedications() async {
    isLoading.value = true;
    errorMessage.value = '';

    List<Map<String, dynamic>> oldRawList = const [];
    try {
      final prefs = await SharedPreferences.getInstance();
      oldRawList = _decodeMedicationRawList(
        prefs.getString('getMedicationListJson'),
      );
    } catch (_) {
      oldRawList = const [];
    }

    try {
      final resp = await _apiRepo.getMedications();
      if (resp.status == 'success') {
        medications.assignAll(resp.data?.docs ?? const []);

        try {
          final prefs = await SharedPreferences.getInstance();
          final newRawList = _decodeMedicationRawList(
            prefs.getString('getMedicationListJson'),
          );
          final oldIds = oldRawList
              .map((e) => e['_id']?.toString() ?? '')
              .where((id) => id.isNotEmpty)
              .toSet();
          final newItems = newRawList
              .where((e) => !oldIds.contains(e['_id']?.toString() ?? ''))
              .toList();

          if (newItems.isNotEmpty) {
            await _ensureAwesomeNotificationsPermission();
            for (final raw in newItems) {
              await _scheduleMedicationNotificationFromRaw(raw);
            }
          }
        } catch (e, s) {
          log('fetchMedications scheduling error: $e', stackTrace: s);
        }
      } else {
        medications.clear();
        errorMessage.value = resp.message;
      }
    } catch (e, s) {
      log('fetchMedications error: $e', stackTrace: s);
      medications.clear();
      errorMessage.value = 'Failed to load medications';
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createMedication(Medication medication) async {
    if (isLoading.value) return false;
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final resp = await _apiRepo.addMedication(medication: medication);
      if (resp.status == 'success') {
        await fetchMedications();
        return true;
      }
      errorMessage.value = resp.message;
      return false;
    } catch (e, s) {
      log('createMedication error: $e', stackTrace: s);
      errorMessage.value = 'Failed to create medication';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateMedication(Medication medication) async {
    if (isLoading.value) return false;
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final resp = await _apiRepo.updateMedication(medication: medication);
      if (resp.status == 'success') {
        await fetchMedications();
        await _rescheduleNotificationsForTitle(medication.title ?? '');
        return true;
      }
      errorMessage.value = resp.message;
      return false;
    } catch (e, s) {
      log('updateMedication error: $e', stackTrace: s);
      errorMessage.value = 'Failed to update medication';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteMedicationGroupByTitle(String title) async {
    // BLoC deletes all items matching title (because backend stores per day+time).
    if (title.trim().isEmpty) return false;

    final prefs = await SharedPreferences.getInstance();
    final jsonData = prefs.getString('getMedicationListJson');
    final List<dynamic> rawList = jsonDecode(jsonData ?? '[]') as List<dynamic>;

    final ids = rawList
        .whereType<Map<String, dynamic>>()
        .where((e) => (e['title']?.toString() ?? '') == title)
        .map((e) => e['_id']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();

    if (ids.isEmpty) return false;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      for (final id in ids) {
        await _cancelMedicationNotificationByRawId(id);
      }
      for (final id in ids) {
        await _apiRepo.deleteMedication(id: id);
      }
      await fetchMedications();
      return true;
    } catch (e, s) {
      log('deleteMedicationGroupByTitle error: $e', stackTrace: s);
      errorMessage.value = 'Failed to delete medication';
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
