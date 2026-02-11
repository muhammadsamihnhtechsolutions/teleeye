// import 'dart:async';
// import 'dart:developer' as developer;
// import 'dart:io';
// import 'package:agora_rtc_engine/agora_rtc_engine.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:lottie/lottie.dart';
// import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
// import 'package:audioplayers/audioplayers.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter/foundation.dart';
// import '../view/agora_call_room_screen.dart';
// import 'agora_singleton.dart';
// import '../../../core/services/utils/handlers/agora_call_socket_handler.dart';
// import '../../../core/services/utils/assets/app_assets.dart';
// import '../../../core/services/utils/config/app_colors.dart';
// import '../../../core/services/utils/size_config.dart';
// import '../../../core/services/api/repo/api_repo.dart';
// import '../../../core/services/utils/keys/shared_pref_keys.dart';
// import '../../appointments/controller/appointment_controller.dart';
// import '../../global_widgets/inter_text.dart';
// import '../../global_widgets/common_network_image_widget.dart';
// import '../../login/controller/profile_controller.dart';

// void log(String message, {Object? error, StackTrace? stackTrace}) {
//   if (!kDebugMode) return;
//   developer.log(message, error: error, stackTrace: stackTrace);
// }

// class CallController extends GetxController {
//   static CallController get to => Get.find();

//   final RxString appointmentId = ''.obs;
//   final RxString doctorName = ''.obs;
//   final RxString doctorPhoto = ''.obs;
//   final RxBool isIncomingVisible = false.obs;

//   // ---------------------------
//   // In-call (Agora) state
//   // ---------------------------
//   static const String _flowTag = 'CALLFLOW';
//   int _flowSeq = 0;

//   void _flow(String step, {Object? data}) {
//     if (!kDebugMode) return;
//     _flowSeq++;
//     developer.log(
//       '$_flowTag[${_flowSeq.toString().padLeft(3, '0')}] $step${data == null ? '' : ' | $data'}',
//     );
//   }

//   AgoraSingleton get _agoraSingleton => Get.find<AgoraSingleton>();

//   final RxBool isInCall = false.obs;
//   final RxBool isConnecting = false.obs;
//   final RxBool isCallUiVisible = false.obs;
//   final RxBool isLocalMicActive = true.obs;
//   final RxBool isLocalCameraActive = true.obs;
//   final RxBool isRemoteAudioActive = true.obs;
//   final RxBool isRemoteVideoActive = false.obs;
//   final RxBool isSpeakerOn = true.obs;
//   final RxBool isRemoteSpeaking = false.obs;
//   final RxString currentAppointmentId = ''.obs;
//   final RxString currentCallKitId = ''.obs;
//   final RxInt remoteUserId = 0.obs;
//   final RxInt localUid = 0.obs;

//   final RxString appId = ''.obs;
//   final RxString patientToken = ''.obs;
//   final RxString channelId = ''.obs;

//   final RxString callStatus = 'idle'.obs; // idle, connecting, in_call, ended
//   final RxString errorMessage = ''.obs;

//   final RxBool isDoctor = false.obs;

//   int _lastJoinAttemptMs = 0;
//   static const int _syntheticEndWindowMs = 20000;
//   int _suppressEndUntilMs = 0;
//   Timer? _remoteSpeakingDebounce;
//   Timer? _connectionLossTimer;
//   String _lastConnectionState = '';
//   bool _isEnding = false;
//   final ApiRepo _apiRepo = ApiRepo();

//   Timer? _autoDeclineTimer;
//   static const int _autoDeclineSeconds = 30;

//   Timer? _remoteWatchdogTimer;
//   static const int _remoteWatchdogSeconds = 30;

//   Timer? _joinSignalTimer;
//   int _joinSignalAttempts = 0;
//   static const int _maxJoinSignalAttempts = 4;

//   StreamSubscription? _callKitSub;

//   AudioPlayer _ringtonePlayer = AudioPlayer();
//   bool _isRingtonePlaying = false;

//   Future<void> _configureRingtonePlayer() async {
//     try {
//       await _ringtonePlayer.setAudioContext(
//         AudioContext(
//           android: AudioContextAndroid(
//             usageType: AndroidUsageType.notificationRingtone,
//             contentType: AndroidContentType.sonification,
//             audioFocus: AndroidAudioFocus.gainTransientMayDuck,
//           ),
//         ),
//       );
//     } catch (_) {
//       // ignore
//     }
//   }

//   Future<void> _startRingtone() async {
//     if (_isRingtonePlaying) return;
//     try {
//       await _ringtonePlayer.setReleaseMode(ReleaseMode.loop);
//       await _ringtonePlayer.play(
//         AssetSource('ringtone/ringtone.mp3'),
//         volume: 1.0,
//       );
//       _isRingtonePlaying = true;
//     } catch (e) {
//       _isRingtonePlaying = false;
//       log('CALLCONTROLLER: Failed to start ringtone: $e');
//     }
//   }

//   Future<void> _stopRingtone() async {
//     _isRingtonePlaying = false;
//     try {
//       try {
//         await _ringtonePlayer.setVolume(0);
//       } catch (_) {
//         // ignore
//       }
//       try {
//         await _ringtonePlayer.pause();
//       } catch (_) {
//         // ignore
//       }
//       await _ringtonePlayer.stop();
//     } catch (_) {
//       // ignore
//     }

//     // Some Android devices keep a MediaPlayer session alive even after stop.
//     // Releasing the player ensures the ringtone audio is fully terminated.
//     try {
//       await _ringtonePlayer.release();
//     } catch (_) {
//       // ignore
//     }
//   }

//   Future<void> stopRingtone() async {
//     _cancelAutoDeclineTimer();
//     _cancelRemoteWatchdogTimer();
//     await _stopRingtone();

//     // Reset the player instance so future calls can ring again cleanly.
//     try {
//       await _ringtonePlayer.dispose();
//     } catch (_) {
//       // ignore
//     }
//     _ringtonePlayer = AudioPlayer();
//     _configureRingtonePlayer();
//   }

//   Future<void> _safeEndCallKitSessions({String? callId}) async {
//     try {
//       // End any active CallKit calls first. On some devices, the CallKit
//       // internal UUID differs from our appointmentId, so endCall(appointmentId)
//       // won't stop the system ringtone.
//       try {
//         final active = await FlutterCallkitIncoming.activeCalls();
//         if (active is List) {
//           for (final c in active) {
//             if (c is Map) {
//               final id =
//                   (c['id']?.toString() ??
//                           c['callUUID']?.toString() ??
//                           c['uuid']?.toString() ??
//                           '')
//                       .trim();
//               if (_looksLikeUuid(id)) {
//                 try {
//                   await FlutterCallkitIncoming.endCall(id);
//                 } catch (_) {
//                   // ignore
//                 }
//               }
//             }
//           }
//         }
//       } catch (_) {
//         // ignore
//       }

//       final id = (callId ?? '').trim();
//       if (_looksLikeUuid(id)) {
//         try {
//           await FlutterCallkitIncoming.endCall(id);
//         } catch (_) {
//           // ignore
//         }
//       }
//       try {
//         await FlutterCallkitIncoming.endAllCalls();
//       } catch (_) {
//         // ignore
//       }
//     } catch (_) {
//       // ignore
//     }
//   }

//   String _sanitizeDoctorPhoto(String? raw) {
//     final v = (raw ?? '').trim();
//     if (v.isEmpty) return '';
//     final lower = v.toLowerCase();
//     if (lower == 'undefined') return '';
//     if (lower.endsWith('.undefined')) {
//       return v.substring(0, v.length - '.undefined'.length);
//     }
//     return v;
//   }

//   bool _looksLikeUuid(String id) {
//     final s = id.trim();
//     if (s.length != 36) return false;
//     for (var i = 0; i < s.length; i++) {
//       final code = s.codeUnitAt(i);
//       if (i == 8 || i == 13 || i == 18 || i == 23) {
//         if (code != 45) return false;
//         continue;
//       }
//       final isDigit = code >= 48 && code <= 57;
//       final isLower = code >= 97 && code <= 102;
//       final isUpper = code >= 65 && code <= 70;
//       if (!isDigit && !isLower && !isUpper) return false;
//     }
//     return true;
//   }

//   void _cancelAutoDeclineTimer() {
//     _autoDeclineTimer?.cancel();
//     _autoDeclineTimer = null;
//   }

//   void _cancelRemoteWatchdogTimer() {
//     _remoteWatchdogTimer?.cancel();
//     _remoteWatchdogTimer = null;
//   }

//   void _cancelJoinSignalTimer() {
//     _joinSignalTimer?.cancel();
//     _joinSignalTimer = null;
//     _joinSignalAttempts = 0;
//   }

//   void _startJoinSignalRetry() {
//     if (isDoctor.value) return;
//     _cancelJoinSignalTimer();
//     _joinSignalTimer = Timer.periodic(const Duration(seconds: 2), (t) {
//       if (remoteUserId.value != 0) {
//         _cancelJoinSignalTimer();
//         return;
//       }
//       if (currentAppointmentId.value.isEmpty || localUid.value == 0) return;
//       _joinSignalAttempts++;
//       try {
//         AgoraCallSocketHandler().emitJoinCall(
//           appointmentId: currentAppointmentId.value,
//           patientAgoraId: localUid.value,
//         );
//       } catch (_) {
//         // ignore
//       }
//       if (_joinSignalAttempts >= _maxJoinSignalAttempts) {
//         _cancelJoinSignalTimer();
//       }
//     });
//   }

//   void _cancelConnectionLossTimer() {
//     _connectionLossTimer?.cancel();
//     _connectionLossTimer = null;
//   }

//   void _startRemoteWatchdogTimer({required String forAppointmentId}) {
//     _cancelRemoteWatchdogTimer();
//     _remoteWatchdogTimer = Timer(Duration(seconds: _remoteWatchdogSeconds), () {
//       if (!isIncomingVisible.value) return;
//       if (appointmentId.value != forAppointmentId) return;
//       log(
//         'CALLCONTROLLER: Remote watchdog fired after ${_remoteWatchdogSeconds}s. Dismissing stuck ringing. appointmentId=$forAppointmentId',
//       );
//       _dismissIncomingCall(reason: 'remote_watchdog');
//     });
//   }

//   void _startAutoDeclineTimer({required String forAppointmentId}) {
//     _cancelAutoDeclineTimer();
//     _autoDeclineTimer = Timer(Duration(seconds: _autoDeclineSeconds), () {
//       if (!isIncomingVisible.value) return;
//       if (appointmentId.value != forAppointmentId) return;
//       log(
//         'CALLCONTROLLER: Auto-declining incoming call after ${_autoDeclineSeconds}s. appointmentId=$forAppointmentId',
//       );
//       declineIncomingCall();
//     });
//   }

//   Future<void> markIncomingAccepted() async {
//     _cancelAutoDeclineTimer();
//     _cancelRemoteWatchdogTimer();
//     _cancelJoinSignalTimer();
//     // Defensive: if CallKit/system UI was shown earlier for this appointment,
//     // ensure we end those sessions so the device ringtone stops.
//     await _safeEndCallKitSessions(callId: currentCallKitId.value);
//     await stopRingtone();
//     isIncomingVisible.value = false;
//   }

//   Future<void> declineIncomingCall() async {
//     _cancelAutoDeclineTimer();
//     _cancelRemoteWatchdogTimer();
//     _cancelJoinSignalTimer();

//     // In case any CallKit/system ringtone is active, end it immediately.
//     await _safeEndCallKitSessions(callId: currentCallKitId.value);

//     await _stopRingtone();
//     try {
//       await rejectCall();
//     } catch (_) {
//       // ignore
//     }
//     _dismissIncomingCall(reason: 'local_reject');
//   }

//   Future<void> _dismissIncomingCall({required String reason}) async {
//     log('CALLCONTROLLER: Dismissing incoming call. reason=$reason');
//     _cancelAutoDeclineTimer();
//     _cancelRemoteWatchdogTimer();
//     _cancelJoinSignalTimer();
//     await stopRingtone();
//     isIncomingVisible.value = false;
//     final activeAppointmentId = appointmentId.value;
//     final activeCallKitId = currentCallKitId.value;
//     appointmentId.value = '';
//     currentCallKitId.value = '';
//     doctorName.value = '';
//     doctorPhoto.value = '';

//     await _safeEndCallKitSessions(callId: activeCallKitId);

//     // Clear persisted incoming-call payload (used by background/banner flows).
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setBool(pendingIncomingCallOpen, false);
//       await prefs.remove(SharedPrefKeys.incomingCallName);
//       await prefs.remove(SharedPrefKeys.incomingCallAppointmentId);
//       await prefs.remove(SharedPrefKeys.incomingCallImage);
//       await prefs.remove(SharedPrefKeys.incomingCallCallKitId);
//     } catch (_) {
//       // ignore
//     }

//     // Stop listening to call events for this appointment
//     try {
//       AgoraCallSocketHandler().disposeSocket(disconnect: true);
//     } catch (_) {
//       // ignore
//     }

//     try {
//       AgoraCallSocketHandler().preconnect();
//     } catch (_) {
//       // ignore
//     }

//     // Close any incoming-call UI (dialog/banner or screen)
//     try {
//       if (Get.isDialogOpen ?? false) {
//         Get.back();
//       } else if ((Get.key.currentState?.canPop() ?? false) &&
//           (Get.currentRoute.contains('IncomingCallScreen') ||
//               Get.currentRoute.contains('IncomingCall'))) {
//         Get.back();
//       }
//     } catch (_) {
//       // ignore
//     }
//   }

//   Future<void> dismissIncomingCallFromRemote({
//     String reason = 'remote_end',
//   }) async {
//     await _dismissIncomingCall(reason: reason);
//   }

//   void showIncomingCall({
//     required String appointmentId,
//     String? callKitId,
//     required String doctorName,
//     required String? doctorPhoto,
//   }) {
//     if (Platform.isIOS) return;
//     // If a call is already being shown for the same appointment, do nothing
//     if (isIncomingVisible.value && this.appointmentId.value == appointmentId) {
//       return;
//     }

//     this.appointmentId.value = appointmentId;
//     final trimmedCallKitId = (callKitId ?? '').trim();
//     currentCallKitId.value =
//         _looksLikeUuid(trimmedCallKitId) ? trimmedCallKitId : '';
//     this.doctorName.value = doctorName;
//     this.doctorPhoto.value = _sanitizeDoctorPhoto(doctorPhoto);
//     log('CALLCONTROLLER: incoming call photo=${this.doctorPhoto.value}');
//     isIncomingVisible.value = true;

//     _startRingtone();

//     // Defensive: clear any stale CallKit sessions before showing a new incoming call.
//     _safeEndCallKitSessions(callId: currentCallKitId.value);

//     _startAutoDeclineTimer(forAppointmentId: appointmentId);
//     _startRemoteWatchdogTimer(forAppointmentId: appointmentId);

//     // Keep in-call state in sync with the current appointment
//     currentAppointmentId.value = appointmentId;
//     isDoctor.value = false;

//     // Listen for doctor cancel/end so patient UI dismisses immediately
//     try {
//       AgoraCallSocketHandler().initSocket(
//         appointmentId: appointmentId,
//         onJoinedEvent: () {
//           // doctor is in room; stop watchdog so we don't dismiss a valid ring
//           _cancelRemoteWatchdogTimer();
//         },
//         onRejectedEvent: () async {
//           _cancelRemoteWatchdogTimer();
//           await _dismissIncomingCall(reason: 'remote_reject');
//         },
//         onEndedEvent: () async {
//           _cancelRemoteWatchdogTimer();
//           await _dismissIncomingCall(reason: 'remote_end');
//         },
//       );
//     } catch (e) {
//       log('CALLCONTROLLER: Failed to init socket for incoming call: $e');
//     }

//     // Navigate to incoming call screen
//     Get.to(() => IncomingCallScreen());
//   }

//   @override
//   void onInit() {
//     super.onInit();
//     _configureRingtonePlayer();
//     _flow('A: controller.onInit');
//     _setupEventCallbacks();
//     _syncWithSingleton();
//     try {
//       _callKitSub = FlutterCallkitIncoming.onEvent.listen((event) async {
//         try {
//           if (event == null) return;
//           final eventName = (event.event.toString());
//           log('CALLCONTROLLER: CallKit event=$eventName body=${event.body}');

//           // When doctor ends/cancels, CallKit may emit ended/timeout.
//           // Ensure we dismiss incoming UI + stop ringing.
//           if (eventName.contains('actionCallEnded') ||
//               eventName.contains('actionCallTimeout')) {
//             // If the call is already accepted / in-call UI is visible, never let
//             // CallKit "ended" tear down the in-app call screen. We rely on Agora/socket
//             // events for actual call end.
//             try {
//               final prefs = await SharedPreferences.getInstance();
//               final accepted = prefs.getBool(isCallAccepted) ?? false;
//               if (accepted || isCallUiVisible.value || isInCall.value) {
//                 return;
//               }
//             } catch (_) {
//               // ignore
//             }

//             final shouldIgnore =
//                 await _shouldIgnoreSyntheticEnd(body: event.body);
//             if (shouldIgnore) return;

//             if (isIncomingVisible.value) {
//               _dismissIncomingCall(reason: 'callkit_end');
//             }
//           }

//           if (eventName.contains('actionCallDecline')) {
//             if (isIncomingVisible.value) {
//               _dismissIncomingCall(reason: 'callkit_decline');
//             }
//           }
//         } catch (_) {
//           // ignore
//         }
//       });
//     } catch (e) {
//       log('CALLCONTROLLER: Failed to attach CallKit listener: $e');
//     }
//   }

//   @override
//   void onClose() {
//     try {
//       _callKitSub?.cancel();
//     } catch (_) {
//       // ignore
//     }
//     _remoteSpeakingDebounce?.cancel();
//     _cleanup();
//     _stopRingtone();
//     try {
//       _ringtonePlayer.release();
//     } catch (_) {
//       // ignore
//     }
//     try {
//       _ringtonePlayer.dispose();
//     } catch (_) {
//       // ignore
//     }
//     _cancelAutoDeclineTimer();
//     _cancelRemoteWatchdogTimer();
//     _cancelJoinSignalTimer();
//     super.onClose();
//   }

//   /// Handle call acceptance - called when user accepts incoming call
//   Future<void> joinCall({required int patientAgoraId}) async {
//     try {
//       log(
//         'CALLCONTROLLER: Joining call with patient Agora ID: $patientAgoraId',
//       );
//       _lastJoinAttemptMs = DateTime.now().millisecondsSinceEpoch;

//       // Track local UID and move call into connecting/active state
//       localUid.value = patientAgoraId;
//       isInCall.value = true;
//       isConnecting.value = false;
//       callStatus.value = 'in_call';
//     } catch (e) {
//       log('CALLCONTROLLER ERROR: Failed to join call - $e');
//     }
//   }

//   /// Handle call rejection - called when user rejects incoming call
//   Future<void> rejectCall() async {
//     try {
//       log(
//         'CALLCONTROLLER: Rejecting call for appointment: ${appointmentId.value}',
//       );

//       if (currentAppointmentId.value.isNotEmpty) {
//         try {
//           AgoraCallSocketHandler().emitRejectCall(
//             appointmentId: currentAppointmentId.value,
//           );
//         } catch (_) {
//           // ignore
//         }
//       }

//       isConnecting.value = false;
//       isInCall.value = false;
//       callStatus.value = 'ended';

//       await _cleanupAfterCall(reason: 'local_reject');
//     } catch (e) {
//       log('CALLCONTROLLER ERROR: Failed to reject call - $e');
//     }
//   }

//   String _autoAttachFlagKey(String appointmentId) {
//     return 'auto_eye_test_sent_$appointmentId';
//   }

//   Future<String> _resolvePatientId() async {
//     try {
//       final profileCtrl = Get.isRegistered<ProfileController>()
//           ? Get.find<ProfileController>()
//           : Get.put(ProfileController());
//       if (profileCtrl.profileData.value.profile == null) {
//         await profileCtrl.getProfileData();
//       }
//       return (profileCtrl.profileData.value.profile?.sId ?? '').trim();
//     } catch (_) {
//       return '';
//     }
//   }

//   String _resolveDoctorIdFromAppointments(String appointmentId) {
//     try {
//       if (!Get.isRegistered<AppointmentController>()) return '';
//       final apptCtrl = Get.find<AppointmentController>();

//       final lists = [
//         apptCtrl.upcomingAppointments.value?.appointmentList?.appointmentData,
//         apptCtrl.followupAppointments.value?.appointmentList?.appointmentData,
//         apptCtrl.pastAppointments.value?.appointmentList?.appointmentData,
//       ];

//       for (final list in lists) {
//         final items = list ?? const [];
//         for (final appt in items) {
//           final id = (appt.id ?? '').trim();
//           if (id == appointmentId.trim()) {
//             return (appt.doctor?.id ?? '').trim();
//           }
//         }
//       }

//       return '';
//     } catch (_) {
//       return '';
//     }
//   }

//   Future<void> _autoSendEyeTestResultsToDoctor({
//     required String appointmentId,
//   }) async {
//     // Patient-side only.
//     if (isDoctor.value) return;
//     final apptId = appointmentId.trim();
//     if (apptId.isEmpty) return;

//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final alreadySent = prefs.getBool(_autoAttachFlagKey(apptId)) ?? false;
//       if (alreadySent) return;

//       // Ensure we have cached appointments so we can resolve doctorId.
//       final AppointmentController apptCtrl =
//           Get.isRegistered<AppointmentController>()
//               ? Get.find<AppointmentController>()
//               : Get.put(AppointmentController());
//       try {
//         await apptCtrl.getAppointments();
//       } catch (_) {
//         // ignore
//       }

//       final doctorId = _resolveDoctorIdFromAppointments(apptId);
//       if (doctorId.isEmpty) return;

//       final patientId = await _resolvePatientId();
//       if (patientId.isEmpty) return;

//       // Latest app test results from API
//       final appTests = await _apiRepo.getAppTestResult();

//       // Latest clinical report metadata (best-effort)
//       Map<String, dynamic>? latestClinical;
//       try {
//         final clinicalResp = await _apiRepo.getClinicalTestResultData();
//         final docs = clinicalResp.data?.docs ?? const [];
//         if (docs.isNotEmpty) {
//           final doc = docs.first;
//           latestClinical = {
//             'title': (doc.title ?? '').toString(),
//             'attachment': (doc.attachment ?? '').toString(),
//             'createdAt': (doc.createdAt ?? '').toString(),
//           };
//         }
//       } catch (_) {
//         // ignore
//       }

//       final results = {
//         'appointmentId': apptId,
//         'appTest': appTests.appTestData?.toJson(),
//         if (latestClinical != null) 'latestClinical': latestClinical,
//       };

//       final resp = await _apiRepo.sendEyeTestResultsToDoctor(
//         doctorId: doctorId,
//         patientId: patientId,
//         message: 'Please review my recent eye test results.',
//         results: results,
//       );

//       final ok = (resp.status ?? '').toLowerCase() == 'success';
//       if (ok) {
//         await prefs.setBool(_autoAttachFlagKey(apptId), true);
//       }
//     } catch (e, s) {
//       log(
//         'CALLFLOW: autoSendEyeTestResultsToDoctor error: $e',
//         stackTrace: s,
//       );
//     }
//   }

//   Future<void> _cleanupAfterCall({required String reason}) async {
//     try {
//       await AgoraCallSocketHandler().disposeSocket();
//     } catch (_) {
//       // ignore
//     }

//     try {
//       AgoraCallSocketHandler().preconnect();
//     } catch (_) {
//       // ignore
//     }

//     try {
//       await _agoraSingleton.leaveChannel(reason: reason);
//     } catch (_) {
//       // ignore
//     }

//     // Clear accepted-call flag so the app doesn't keep reopening the call screen.
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setBool(isCallAccepted, false);
//       await prefs.setBool(pendingIncomingCallOpen, false);
//     } catch (_) {
//       // ignore
//     }

//     _cleanup();
//   }

//   Future<void> cleanupAfterCall({String reason = 'view_dispose'}) async {
//     await _cleanupAfterCall(reason: reason);
//   }

//   void _setupEventCallbacks() {
//     _flow('B: setupEventCallbacks');

//     _agoraSingleton.onJoinChannelSuccess = (connection, elapsed) {
//       try {
//         _flow(
//           'H: onJoinChannelSuccess',
//           data: {
//             'uid': connection.localUid ?? 0,
//             'channel': connection.channelId,
//             'elapsed': elapsed,
//           },
//         );
//         handleJoinChannelSuccess(connection.localUid ?? 0);
//       } catch (e, st) {
//         _flow('H: onJoinChannelSuccess ERROR', data: '$e\n$st');
//       }
//     };

//     _agoraSingleton.onUserJoined = (connection, remoteUid, elapsed) {
//       try {
//         _flow(
//           'I: onUserJoined',
//           data: {
//             'remoteUid': remoteUid,
//             'channel': connection.channelId,
//             'elapsed': elapsed,
//           },
//         );
//         handleUserJoined(remoteUid);
//       } catch (e, st) {
//         _flow('I: onUserJoined ERROR', data: '$e\n$st');
//       }
//     };

//     _agoraSingleton.onUserOffline = (connection, remoteUid, reason) {
//       try {
//         _flow(
//           'J: onUserOffline',
//           data: {
//             'remoteUid': remoteUid,
//             'channel': connection.channelId,
//             'reason': reason.toString(),
//           },
//         );
//         handleUserOffline(remoteUid);
//       } catch (e, st) {
//         _flow('J: onUserOffline ERROR', data: '$e\n$st');
//       }
//     };

//     _agoraSingleton.onConnectionStateChanged = (connection, state, reason) {
//       try {
//         _flow(
//           'Y: onConnectionStateChanged',
//           data: {
//             'state': state.toString(),
//             'reason': reason.toString(),
//             'channel': connection.channelId,
//           },
//         );

//         _lastConnectionState = state.toString();

//         // Avoid immediately ending the call on transient disconnects.
//         // On some Android devices, a brief disconnect/reconnect can happen
//         // during audio route changes or while resuming from notifications.
//         final isBad =
//             state == ConnectionStateType.connectionStateFailed ||
//             state == ConnectionStateType.connectionStateDisconnected;
//         final isGood =
//             state == ConnectionStateType.connectionStateConnected ||
//             state == ConnectionStateType.connectionStateReconnecting ||
//             state == ConnectionStateType.connectionStateConnecting;

//         if (isGood) {
//           _cancelConnectionLossTimer();
//           return;
//         }

//         if (!isDoctor.value && isBad) {
//           final hasJoinedChannel = localUid.value != 0;
//           final shouldWatch =
//               isInCall.value || (isConnecting.value && hasJoinedChannel);
//           if (!shouldWatch) return;

//           // Mark as reconnecting (UI won't auto-pop).
//           if (callStatus.value != 'reconnecting') {
//             callStatus.value = 'reconnecting';
//           }

//           _connectionLossTimer ??= Timer(const Duration(seconds: 8), () {
//             try {
//               final stillBad = (_lastConnectionState.toLowerCase().contains('failed') ||
//                   _lastConnectionState.toLowerCase().contains('disconnected'));
//               if (stillBad && (isInCall.value || isConnecting.value)) {
//                 _endCallInternal(reason: 'connection_lost', emitSocket: false);
//               }
//             } catch (_) {
//               // ignore
//             } finally {
//               _cancelConnectionLossTimer();
//             }
//           });
//         }
//       } catch (e, st) {
//         _flow('Y: onConnectionStateChanged ERROR', data: '$e\n$st');
//       }
//     };

//     _agoraSingleton.onRemoteVideoStateChanged =
//         (
//           RtcConnection connection,
//           int remoteUid,
//           RemoteVideoState state,
//           RemoteVideoStateReason reason,
//           int elapsed,
//         ) {
//           try {
//             _flow(
//               'K: onRemoteVideoStateChanged',
//               data: {
//                 'remoteUid': remoteUid,
//                 'channel': connection.channelId,
//                 'state': state.toString(),
//                 'reason': reason.toString(),
//                 'elapsed': elapsed,
//               },
//             );
//             handleRemoteVideoStateChanged(remoteUid, state, reason);
//           } catch (e, st) {
//             _flow('K: onRemoteVideoStateChanged ERROR', data: '$e\n$st');
//           }
//         };

//     _agoraSingleton.onError = (err, msg) {
//       try {
//         _flow('Z: onError', data: {'err': err.toString(), 'msg': msg});
//         handleError('$err: $msg');
//       } catch (e, st) {
//         _flow('Z: onError ERROR', data: '$e\n$st');
//       }
//     };

//     _agoraSingleton.onAudioVolumeIndication =
//         (connection, speakers, total, vad) {
//           try {
//             final remoteUid = remoteUserId.value;
//             if (remoteUid == 0) return;

//             bool speakingNow = false;
//             for (final s in speakers) {
//               if (s.uid == remoteUid) {
//                 final vad = s.vad ?? 0;
//                 final volume = s.volume ?? 0;
//                 if (vad == 1 || volume > 10) {
//                   speakingNow = true;
//                   break;
//                 }
//               }
//             }

//             if (speakingNow) {
//               if (!isRemoteSpeaking.value) {
//                 isRemoteSpeaking.value = true;
//               }
//               _remoteSpeakingDebounce?.cancel();
//               _remoteSpeakingDebounce = Timer(
//                 const Duration(milliseconds: 600),
//                 () => isRemoteSpeaking.value = false,
//               );
//             }
//           } catch (_) {
//             // ignore
//           }
//         };
//   }

//   Future<bool> _shouldIgnoreSyntheticEnd({Map<dynamic, dynamic>? body}) async {
//     try {
//       final now = DateTime.now().millisecondsSinceEpoch;
//       if (now - _lastJoinAttemptMs < _syntheticEndWindowMs) return true;
//       if (_suppressEndUntilMs > 0 && now < _suppressEndUntilMs) return true;

//       final prefs = await SharedPreferences.getInstance();
//       final lastAcceptMs = prefs.getInt('callkit_last_accept_ms') ?? 0;
//       if (lastAcceptMs > 0 && (now - lastAcceptMs) < _syntheticEndWindowMs) {
//         return true;
//       }

//       // If the ended event references the same appointment we just accepted, ignore.
//       final endedId = (body is Map && body['extra'] is Map
//               ? (body['extra']?['appointmentId'] ?? '')
//               : '')
//           .toString()
//           .trim();
//       final currentId = currentAppointmentId.value.trim();
//       if (endedId.isNotEmpty &&
//           currentId.isNotEmpty &&
//           endedId == currentId &&
//           (now - _lastJoinAttemptMs) < (_syntheticEndWindowMs * 2)) {
//         return true;
//       }
//     } catch (_) {
//       // ignore
//     }
//     return false;
//   }

//   void _syncWithSingleton() {
//     ever(_agoraSingleton.isInCall, (bool value) => isInCall.value = value);
//     ever(
//       _agoraSingleton.isConnecting,
//       (bool value) => isConnecting.value = value,
//     );
//     ever(
//       _agoraSingleton.remoteUserId,
//       (int value) => remoteUserId.value = value,
//     );
//   }

//   Future<void> startCall({
//     required String appointmentId,
//     String? token,
//     String? appId,
//     bool asDoctor = false,
//     bool enableVideo = true,
//     bool forceRestart = false,
//     bool forceHydrate = false,
//   }) async {
//     try {
//       log('CONTROLLER: Starting call for appointment: $appointmentId');
//       _flow('C: startCall.enter', data: {'appointmentId': appointmentId});

//       if (!forceRestart &&
//           currentAppointmentId.value == appointmentId &&
//           (isConnecting.value || isInCall.value)) {
//         log(
//           'CONTROLLER: startCall ignored (already connecting/in-call for same appointment)',
//         );
//         return;
//       }

//       if (forceRestart) {
//         try {
//           await _agoraSingleton.leaveChannel(reason: 'force_rejoin');
//         } catch (_) {
//           // ignore
//         }
//         isConnecting.value = false;
//         isInCall.value = false;
//         callStatus.value = 'connecting';
//       }

//       isConnecting.value = true;
//       callStatus.value = 'connecting';
//       currentAppointmentId.value = appointmentId;
//       errorMessage.value = '';
//       isDoctor.value = asDoctor;
//       // Suppress remote/end handling until join completes or remote joins.
//       final nowMs = DateTime.now().millisecondsSinceEpoch;
//       _suppressEndUntilMs = nowMs + _syntheticEndWindowMs;
//       _flow('D: state.connecting');

//       if (!asDoctor) {
//         unawaited(_autoSendEyeTestResultsToDoctor(appointmentId: appointmentId));
//       }

//       try {
//         final prefs = await SharedPreferences.getInstance();

//         final tokenKey =
//             asDoctor
//                 ? 'doctor_agora_token_$appointmentId'
//                 : 'patient_agora_token_$appointmentId';
//         final defaultTokenKey =
//             asDoctor ? 'doctor_agora_token' : 'patient_agora_token';

//         final storedToken = prefs.getString(tokenKey) ?? '';
//         final storedChannelId =
//             (prefs.getString('agora_channel_id_$appointmentId') ?? '')
//                 .toString()
//                 .trim();
//         final defaultToken = prefs.getString(defaultTokenKey) ?? '';
//         final defaultChannelId =
//             (prefs.getString('agora_channel_id') ?? '').toString().trim();
//         bool shouldHydrate = forceHydrate;
//         _flow(
//           'E: loadToken',
//           data: {
//             'asDoctor': asDoctor,
//             'tokenKey': tokenKey,
//             'tokenLen': storedToken.length,
//           },
//         );

//         if (storedToken.isNotEmpty) {
//           patientToken.value = storedToken;
//           if (storedChannelId.isNotEmpty) {
//             channelId.value = storedChannelId;
//             _agoraSingleton.channelId.value = storedChannelId;
//           } else {
//             shouldHydrate = true;
//           }
//           _flow(
//             'E: loadToken.done',
//             data: {
//               'tokenLen': storedToken.length,
//               'channelId': channelId.value,
//             },
//           );
//         } else {
//           if (defaultToken.isNotEmpty) {
//             patientToken.value = defaultToken;
//             if (defaultChannelId.isNotEmpty) {
//               channelId.value = defaultChannelId;
//               _agoraSingleton.channelId.value = defaultChannelId;
//             }
//             shouldHydrate = true;
//             _flow(
//               'E: loadDefaultToken.done',
//               data: {
//                 'tokenLen': defaultToken.length,
//                 'channelId': channelId.value,
//               },
//             );
//           } else {
//             _handleCallError(
//               'No Agora token found. Please refresh appointment / try again.',
//             );
//             return;
//           }
//         }

//         // Best-effort hydrate from API when appointment-specific creds are missing.
//         if (shouldHydrate) {
//           try {
//             final hydrated =
//                 await _agoraSingleton.hydrateCallCredentials(appointmentId);
//             final hydratedToken =
//                 (hydrated['patientToken'] ?? '').toString().trim();
//             final hydratedChannel =
//                 (hydrated['channelId'] ?? '').toString().trim();
//             if (hydratedToken.isNotEmpty) {
//               patientToken.value = hydratedToken;
//             }
//             if (hydratedChannel.isNotEmpty) {
//               channelId.value = hydratedChannel;
//               _agoraSingleton.channelId.value = hydratedChannel;
//             }
//             // Persist for future resumes.
//             if (hydratedToken.isNotEmpty) {
//               await prefs.setString(
//                 'patient_agora_token_$appointmentId',
//                 hydratedToken,
//               );
//               await prefs.setString('patient_agora_token', hydratedToken);
//             }
//             if (hydratedChannel.isNotEmpty) {
//               await prefs.setString(
//                 'agora_channel_id_$appointmentId',
//                 hydratedChannel,
//               );
//               await prefs.setString('agora_channel_id', hydratedChannel);
//             }
//           } catch (_) {
//             // ignore and fall through to validation below
//           }
//         }
//       } catch (e) {
//         _handleCallError('Failed to load Agora credentials: $e');
//         return;
//       }

//       if (channelId.value.isEmpty) {
//         channelId.value = appointmentId;
//         _agoraSingleton.channelId.value = appointmentId;
//       }

//       // Best-effort hydrate from API if anything is still missing (common in
//       // banner/lock-screen accepts where payload lacks tokens).
//       if (patientToken.value.isEmpty) {
//         try {
//           final hydrated =
//               await _agoraSingleton.hydrateCallCredentials(appointmentId);
//           final hydratedToken = (hydrated['patientToken'] ?? '').toString().trim();
//           final hydratedChannel = (hydrated['channelId'] ?? '').toString().trim();
//           if (hydratedToken.isNotEmpty) {
//             patientToken.value = hydratedToken;
//           }
//           if (hydratedChannel.isNotEmpty) {
//             channelId.value = hydratedChannel;
//             _agoraSingleton.channelId.value = hydratedChannel;
//           }
//           // Persist for future resumes.
//           final prefs = await SharedPreferences.getInstance();
//           if (hydratedToken.isNotEmpty) {
//             await prefs.setString(
//               'patient_agora_token_$appointmentId',
//               hydratedToken,
//             );
//             await prefs.setString('patient_agora_token', hydratedToken);
//           }
//           if (hydratedChannel.isNotEmpty) {
//             await prefs.setString('agora_channel_id_$appointmentId', hydratedChannel);
//             await prefs.setString('agora_channel_id', hydratedChannel);
//           }
//         } catch (_) {
//           // ignore and fall through to validation below
//         }
//       }

//       if (patientToken.value.isEmpty) {
//         _handleCallError('Agora token is empty. Cannot join call.');
//         return;
//       }
//       if (channelId.value.isEmpty) {
//         _handleCallError('Agora channel is empty. Cannot join call.');
//         return;
//       }

//       // Important for lock-screen/terminated-app accept flows:
//       // Ensure socket is initialized BEFORE joining Agora so that when the
//       // onJoinChannelSuccess callback emits `joinedCall`, the socket is already
//       // connected/joined to the appointment room (otherwise the event can be dropped
//       // and doctor never receives the "patient joined" signal).
//       _flow('G: socket.init.begin');
//       await _initializeSocket(appointmentId);
//       _flow('G: socket.init.done');

//       _flow('F: joinChannel.begin', data: {'channelId': channelId.value});
//       await _agoraSingleton.joinChannel(
//         token: patientToken.value,
//         channelId: channelId.value,
//         uid: 0,
//         isDoctor: asDoctor,
//         enableVideo: enableVideo,
//       );
//       _flow('F: joinChannel.called');
//     } catch (e) {
//       _flow('C: startCall.ERROR', data: e);
//       _handleCallError('Failed to start call: $e');
//     }
//   }

//   Future<void> _initializeSocket(String appointmentId) async {
//     try {
//       _flow('G1: socket.initSocket.call', data: {'appointmentId': appointmentId});
//       await AgoraCallSocketHandler().initSocket(
//         appointmentId: appointmentId,
//         onJoinedEvent: () {},
//         onRejectedEvent: () {
//           _endCallInternal(reason: 'remote_reject', emitSocket: false);
//         },
//         onEndedEvent: () {
//           _endCallInternal(reason: 'remote_end', emitSocket: false);
//         },
//       );
//       _flow('G2: socket.initSocket.done');
//     } catch (e) {
//       _handleCallError('Failed to connect: $e');
//     }
//   }

//   Future<void> endCall() async {
//     try {
//       await _endCallInternal(reason: 'local_end', emitSocket: true);
//     } catch (e) {
//       log('CALLCONTROLLER ERROR: Failed to end call - $e');
//     }
//   }

//   Future<void> _endCallInternal({
//     required String reason,
//     required bool emitSocket,
//   }) async {
//     final now = DateTime.now().millisecondsSinceEpoch;
//     final isLocal = reason.startsWith('local_');
//     final stillJoining = _suppressEndUntilMs > 0 && now < _suppressEndUntilMs;
//     if (!isLocal && stillJoining) {
//       // Ignore remote/end during join window to keep UI alive after accept.
//       return;
//     }
//     if (_isEnding) return;
//     _isEnding = true;

//     try {
//       try {
//         await stopRingtone();
//       } catch (_) {
//         // ignore
//       }

//       try {
//         final id = currentCallKitId.value.trim();
//         if (_looksLikeUuid(id)) {
//           FlutterCallkitIncoming.endCall(id).catchError((_) {});
//         }
//         FlutterCallkitIncoming.endAllCalls().catchError((_) {});
//       } catch (_) {
//         // ignore
//       }

//       if (emitSocket && currentAppointmentId.value.isNotEmpty) {
//         try {
//           AgoraCallSocketHandler().emitEndCall(
//             appointmentId: currentAppointmentId.value,
//           );
//         } catch (_) {
//           // ignore
//         }
//       }

//       isConnecting.value = false;
//       isInCall.value = false;
//       callStatus.value = 'ended';
//       remoteUserId.value = 0;
//       isRemoteVideoActive.value = false;
//       isRemoteAudioActive.value = false;

//       await _cleanupAfterCall(reason: reason);
//     } finally {
//       _isEnding = false;
//     }
//   }

//   Future<void> toggleMicrophone() async {
//     final bool nextEnabled = !isLocalMicActive.value;
//     isLocalMicActive.value = nextEnabled;
//     try {
//       await _agoraSingleton.engine.muteLocalAudioStream(!nextEnabled);
//     } catch (e) {
//       isLocalMicActive.value = !nextEnabled;
//       log('CALLCONTROLLER ERROR: Failed to toggle microphone - $e');
//     }
//   }

//   Future<void> toggleCamera() async {
//     final bool nextEnabled = !isLocalCameraActive.value;
//     isLocalCameraActive.value = nextEnabled;
//     try {
//       await _agoraSingleton.engine.muteLocalVideoStream(!nextEnabled);
//       await _agoraSingleton.engine.enableLocalVideo(nextEnabled);
//       if (nextEnabled) {
//         await _agoraSingleton.engine.startPreview();
//       }
//     } catch (e) {
//       isLocalCameraActive.value = !nextEnabled;
//       log('CALLCONTROLLER ERROR: Failed to toggle camera - $e');
//     }
//   }

//   Future<void> toggleSpeaker() async {
//     final bool nextEnabled = !isSpeakerOn.value;
//     isSpeakerOn.value = nextEnabled;
//     try {
//       await _agoraSingleton.engine.setEnableSpeakerphone(nextEnabled);
//     } catch (e) {
//       isSpeakerOn.value = !nextEnabled;
//       log('CALLCONTROLLER ERROR: Failed to toggle speaker - $e');
//     }
//   }

//   Future<void> toggleRemoteAudio() async {
//     final bool nextEnabled = !isRemoteAudioActive.value;
//     isRemoteAudioActive.value = nextEnabled;
//     try {
//       await _agoraSingleton.engine.muteAllRemoteAudioStreams(!nextEnabled);
//     } catch (e) {
//       isRemoteAudioActive.value = !nextEnabled;
//       log('CALLCONTROLLER ERROR: Failed to toggle remote audio - $e');
//     }
//   }

//   void _handleCallError(String error) {
//     errorMessage.value = error;
//     isConnecting.value = false;
//     isInCall.value = false;
//     callStatus.value = 'ended';
//   }

//   void _cleanup() {
//     isConnecting.value = false;
//     isInCall.value = false;
//     remoteUserId.value = 0;
//     isRemoteVideoActive.value = false;
//     isRemoteAudioActive.value = false;
//     errorMessage.value = '';
//     currentAppointmentId.value = '';
//     currentCallKitId.value = '';
//     _cancelConnectionLossTimer();
//     _cancelJoinSignalTimer();
//     _lastConnectionState = '';
//   }

//   void handleJoinChannelSuccess(int uid) {
//     localUid.value = uid;
//     isConnecting.value = false;
//     isInCall.value = true;
//     callStatus.value = 'connected';

//     try {
//       if (!isDoctor.value && currentAppointmentId.value.isNotEmpty && uid != 0) {
//         AgoraCallSocketHandler().emitJoinCall(
//           appointmentId: currentAppointmentId.value,
//           patientAgoraId: uid,
//         );
//         _startJoinSignalRetry();
//       }
//     } catch (_) {
//       // ignore
//     }
//   }

//   void handleUserJoined(int uid) {
//     remoteUserId.value = uid;
//     isRemoteAudioActive.value = true;
//     isRemoteVideoActive.value = true;
//     if (!isInCall.value) {
//       isInCall.value = true;
//       callStatus.value = 'in_call';
//     }
//     // Safe to clear suppression once remote joins.
//     _suppressEndUntilMs = 0;
//     _cancelJoinSignalTimer();
//   }

//   void handleUserOffline(int uid) {
//     if (remoteUserId.value == uid || remoteUserId.value == 0) {
//       remoteUserId.value = 0;
//     }
//     isRemoteAudioActive.value = false;
//     isRemoteVideoActive.value = false;

//     if (!isDoctor.value && (isInCall.value || isConnecting.value)) {
//       _endCallInternal(reason: 'agora_user_offline', emitSocket: false);
//     }
//   }

//   void handleRemoteVideoStateChanged(
//     int remoteUid,
//     RemoteVideoState state,
//     RemoteVideoStateReason reason,
//   ) {
//     if (remoteUserId.value == 0 && remoteUid != 0) {
//       remoteUserId.value = remoteUid;
//       isRemoteAudioActive.value = true;
//     }

//     if (remoteUserId.value == remoteUid) {
//       final stateString = state.toString();
//       if (stateString.contains('Playing') || stateString.contains('Decoding')) {
//         isRemoteVideoActive.value = true;
//       } else if (stateString.contains('Stopped') ||
//           stateString.contains('Frozen') ||
//           stateString.contains('Failed')) {
//         isRemoteVideoActive.value = false;
//       }
//     }
//   }

//   void handleError(String error) {
//     errorMessage.value = error;
//     final now = DateTime.now().millisecondsSinceEpoch;
//     if (!isDoctor.value && (isInCall.value || isConnecting.value)) {
//       if (_suppressEndUntilMs > 0 && now < _suppressEndUntilMs) {
//         log('CALLCONTROLLER: Suppressing error end during join window: $error');
//         return;
//       }
//       _endCallInternal(reason: 'agora_error', emitSocket: false);
//     } else {
//       isConnecting.value = false;
//       isInCall.value = false;
//       callStatus.value = 'error';
//     }
//   }
// }

// class IncomingCallScreen extends StatelessWidget {
//   IncomingCallScreen({super.key});

//   final CallController controller = CallController.to;

//   @override
//   // Widget build(BuildContext context) {
//   //   SizeConfig().init(context);
//   //   return PopScope(
//   //     canPop: false,
//   //     onPopInvokedWithResult: (didPop, result) {},
//   //     child: Scaffold(
//   //       backgroundColor: Colors.white,
//   //       body: Stack(
//   //         children: [
//   //           Column(
//   //             mainAxisAlignment: MainAxisAlignment.center,
//   //             crossAxisAlignment: CrossAxisAlignment.center,
//   //             // mainAxisAlignment: MainAxisAlignment.center,
//   //             children: [
//   //               Padding(
//   //                 padding: const EdgeInsets.all(16.0),
//   //                 child: Column(
//   //                   children: [
//   //                     InterText(
//   //                       title: 'Incoming call...',
//   //                       fontSize: 16,
//   //                       textColor: Colors.black,
//   //                     ),
//   //                     const SizedBox(height: 8),
//   //                     InterText(
//   //                       title: controller.doctorName.value.isNotEmpty
//   //                           ? controller.doctorName.value
//   //                           : 'BEH - DOCTOR',
//   //                       fontSize: 25,
//   //                       textColor: Colors.black,
//   //                       fontWeight: FontWeight.bold,
//   //                     ),
//   //                   ],
//   //                 ),
//   //               ),
//   //               const SizedBox(height: 25),
//   //               Container(
//   //                 decoration: BoxDecoration(
//   //                   border: Border.all(color: AppColors.primaryColor, width: 5),
//   //                   borderRadius: BorderRadius.circular(
//   //                     SizeConfig.screenWidth / 2,
//   //                   ),
//   //                 ),
//   //                 padding: const EdgeInsets.all(5),
//   //                 child: ClipRRect(
//   //                   borderRadius: BorderRadius.circular(
//   //                     SizeConfig.screenWidth / 2,
//   //                   ),
//   //                   child: Container(
//   //                     height: SizeConfig.screenWidth / 2,
//   //                     width: SizeConfig.screenWidth / 2,
//   //                     decoration: BoxDecoration(
//   //                       borderRadius: BorderRadius.circular(
//   //                         SizeConfig.screenWidth / 2,
//   //                       ),
//   //                     ),
//   //                     child: CommonNetworkImageWidget(
//   //                       imageLink: controller.doctorPhoto.value.isNotEmpty
//   //                           ? '${ApiConstants.imageBaseUrl}${controller.doctorPhoto.value}'
//   //                           : '',
//   //                     ),
//   //                   ),
//   //                 ),
//   //               ),
//   //               const SizedBox(height: 50),
//   //             ],
//   //           ),
//   //           Positioned(
//   //             left: 25,
//   //             bottom: 23,
//   //             child: InkWell(
//   //               onTap: () {
//   //                 log('IncomingCallScreen: declined by patient');
//   //                 // Notify Agora controller so it can emit rejectCall over socket
//   //                 try {
//   //                   CallController.to.rejectCall();
//   //                 } catch (_) {
//   //                   // Fallback: if controller is not available, just close screen
//   //                 }
//   //                 Get.back();
//   //               },
//   //               child: Image.asset(AppAssets.endCall, width: 100),
//   //             ),
//   //           ),
//   //           Positioned(
//   //             right: 0,
//   //             bottom: 0,
//   //             child: InkWell(
//   //               onTap: () {
//   //                 log('IncomingCallScreen: accepted by patient');
//   //                 // Navigate to call room screen with Agora integration
//   //                 Get.to(
//   //                   () => AgoraCallScreen(
//   //                     name: controller.doctorName.value,
//   //                     image: controller.doctorPhoto.value,
//   //                     appointmentId: controller.appointmentId.value,
//   //                   ),
//   //                 );
//   //               },
//   //               child: SizedBox(
//   //                 height: 140,
//   //                 child: Align(
//   //                   child: LottieBuilder.asset(AppAssets.acceptCall),
//   //                 ),
//   //               ),
//   //             ),
//   //           ),
//   //         ],
//   //       ),
//   //     ),
//   //   );
//   // }
//   @override
//   Widget build(BuildContext context) {
//     SizeConfig().init(context);

//     final double avatarSize = SizeConfig.screenWidth * 0.55;

//     return PopScope(
//       canPop: false,
//       onPopInvokedWithResult: (didPop, result) {},
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         body: SafeArea(
//           child: Stack(
//             children: [
//               /// CENTER CONTENT
//             //test
//               // Center(
//               //   child: Obx(() {
//               //     final name = controller.doctorName.value.trim();
//               //     final photo = controller.doctorPhoto.value.trim();

//               //     return Column(
//               //       mainAxisSize: MainAxisSize.min,
//               //       children: [
//               //         /// Incoming Text
//               //         const InterText(
//               //           //title: 'Incoming call...',
//               //           title:"forground call screen",
//               //           fontSize: 16,
//               //           textColor: Colors.black54,
//               //         ),
//               //         const SizedBox(height: 8),

//               //         /// Doctor Name
//               //         InterText(
//               //           title: name.isNotEmpty ? name : 'BEH - DOCTOR',
//               //           fontSize: 26,
//               //           textColor: Colors.black,
//               //           fontWeight: FontWeight.bold,
//               //           textAlign: TextAlign.center,
//               //         ),

//               //         const SizedBox(height: 30),

//               //         /// Avatar
//               //         Container(
//               //           padding: const EdgeInsets.all(6),
//               //           decoration: BoxDecoration(
//               //             shape: BoxShape.circle,
//               //             border: Border.all(
//               //               color: AppColors.primaryColor,
//               //               width: 5,
//               //             ),
//               //           ),
//               //           child: ClipOval(
//               //             child: SizedBox(
//               //               height: avatarSize,
//               //               width: avatarSize,
//               //               child: CommonNetworkImageWidget(
//               //                 imageLink: photo,
//               //                 memCacheWidth: 256,
//               //                 memCacheHeight: 256,
//               //               ),
//               //             ),
//               //           ),
//               //         ),
//               //       ],
//               //     );
//               //   }),
//               // ),

//             //test
//               /// DECLINE BUTTON
//               Positioned(
//                 left: 24,
//                 bottom: 30,
//                 child: InkWell(
//                   borderRadius: BorderRadius.circular(60),
//                   onTap: () async {
//                     log('IncomingCallScreen: declined by patient');
//                     await controller.declineIncomingCall();
//                   },
//                   child: Image.asset(AppAssets.endCall, width: 90),
//                 ),
//               ),

//               /// ACCEPT BUTTON
//               Positioned(
//                 right: 24,
//                 bottom: 20,
//                 child: InkWell(
//                   borderRadius: BorderRadius.circular(60),
//                   onTap: () async {
//                     log('IncomingCallScreen: accepted by patient');
//                     final apptId = controller.appointmentId.value;
//                     await controller.markIncomingAccepted();
//                     // Replace incoming screen so it can't keep any lingering UI/state.
//                     Get.off(
//                       () => AgoraCallScreen(
//                         name: controller.doctorName.value,
//                         image: controller.doctorPhoto.value,
//                         appointmentId: apptId,
//                       ),
//                     );
//                   },
//                   child: SizedBox(
//                     height: 120,
//                     width: 120,
//                     child: LottieBuilder.asset(
//                       AppAssets.acceptCall,
//                       fit: BoxFit.contain,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
