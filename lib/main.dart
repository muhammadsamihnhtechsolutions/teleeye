// import 'dart:async';
// import 'dart:developer' as developer;
// import 'dart:io';
// import 'dart:ui' as ui;
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:flutter/services.dart';
// import 'package:device_preview/device_preview.dart';
// import 'package:display_metrics/display_metrics.dart';
// import 'package:firebase_analytics/firebase_analytics.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:eye_buddy/firebase_options.dart'
//     if (dart.library.html) 'package:eye_buddy/firebase_options_web.dart';
// // App Controllers
// import 'package:eye_buddy/core/controler/app_state_controller.dart';
// // Views
// import 'package:eye_buddy/core/services/utils/services/calling_services.dart';
// import 'package:eye_buddy/core/services/utils/handlers/agora_call_socket_handler.dart';
// import 'package:eye_buddy/core/services/utils/notification_utils.dart';
// import 'package:eye_buddy/features/agora_call/controller/call_controller.dart';
// import 'package:eye_buddy/features/agora_call/controller/agora_singleton.dart';
// import 'package:eye_buddy/features/reason_for_visit/view/appointment_overview_screen.dart';
// import 'package:eye_buddy/features/payment_gateway/view/payment_gateway_screen.dart';
// import 'package:eye_buddy/features/waiting_for_doctor/view/waiting_for_doctor_screen.dart';
// import 'package:eye_buddy/features/splash/view/splash_screen.dart';
// import 'package:eye_buddy/features/login/controller/profile_controller.dart';
// import 'package:eye_buddy/features/more/controller/more_controller.dart';
// import 'package:eye_buddy/features/eye_test/controller/eye_test_controller.dart';
// // THEME
// import 'package:eye_buddy/core/services/utils/config/theme.dart';
// // LOCALIZATION
// import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:eye_buddy/l10n/app_localizations.dart';
// import 'package:eye_buddy/core/services/utils/keys/shared_pref_keys.dart';
// import 'package:eye_buddy/core/services/utils/keys/token_keys.dart';
// import 'package:eye_buddy/core/services/api/repo/api_repo.dart';
// import 'package:awesome_notifications/awesome_notifications.dart';
// import 'package:eye_buddy/core/services/utils/string_to_map.dart';
// import 'package:eye_buddy/features/agora_call/view/agora_call_room_screen.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'package:eye_buddy/core/services/utils/services/notification_permission_guard.dart';

// StreamSubscription? _callKitGlobalSub;

// void log(String message, {Object? error, StackTrace? stackTrace}) {
//   if (!kDebugMode) return;
//   developer.log(message, error: error, stackTrace: stackTrace);
// }

// void dPrint(Object? message) {
//   if (!kDebugMode) return;
//   // ignore: avoid_print
//   print(message);
// }

// void _handleCatch(String context, Object error, StackTrace stackTrace) {
//   log('ERROR[$context]: $error', error: error, stackTrace: stackTrace);
//   if (kDebugMode) {
//     Error.throwWithStackTrace(error, stackTrace);
//   }
// }

// Map<String, Object?> _redactFcmData(Map<String, dynamic> data) {
//   final out = <String, Object?>{};
//   for (final entry in data.entries) {
//     final k = entry.key.toString();
//     final lower = k.toLowerCase();
//     final v = entry.value;
//     if (lower.contains('token') ||
//         lower.contains('authorization') ||
//         lower.contains('password') ||
//         lower.contains('secret')) {
//       out[k] = '***';
//       continue;
//     }
//     final s = v?.toString() ?? '';
//     out[k] = s.length > 160 ? '${s.substring(0, 160)}…' : s;
//   }
//   return out;
// }

// void _logFcmForeground(String where, RemoteMessage message) {
//   try {
//     log(
//       'FCM[$where] id=${message.messageId} from=${message.from} sentTime=${message.sentTime} data=${_redactFcmData(message.data)}',
//     );
//   } catch (_) {
//     // ignore
//   }
// }

// Future<Map<String, String>> _hydrateCallCredentialsFromApi(
//   String appointmentId,
// ) async {
//   final result = <String, String>{};
//   try {
//     String patientId = '';
//     try {
//       final profileCtrl = Get.isRegistered<ProfileController>()
//           ? Get.find<ProfileController>()
//           : Get.put(ProfileController(), permanent: true);
//       if (profileCtrl.profileData.value.profile == null) {
//         await profileCtrl.getProfileData();
//       }
//       patientId = profileCtrl.profileData.value.profile?.sId ?? '';
//     } catch (_) {
//       // ignore
//     }

//     final api = ApiRepo();
//     final resp = await api.getAppointments('upcoming', patientId);
//     List<dynamic>? docs;
//     if (resp is Map<String, dynamic>) {
//       final data = resp['data'];
//       if (data is Map<String, dynamic> && data['docs'] is List) {
//         docs = data['docs'] as List;
//       }
//     }
//     if (docs != null) {
//       for (final doc in docs) {
//         if (doc is Map &&
//             (doc['_id'] ?? '').toString().trim() == appointmentId) {
//           final patientToken = (doc['patientAgoraToken'] ?? '')
//               .toString()
//               .trim();
//           final doctorToken = (doc['doctorAgoraToken'] ?? '').toString().trim();
//           final channelId =
//               (doc['agoraChannelId'] ?? doc['channelId'] ?? appointmentId)
//                   .toString()
//                   .trim();
//           if (patientToken.isNotEmpty) {
//             result['patientToken'] = patientToken;
//           }
//           if (doctorToken.isNotEmpty) {
//             result['doctorToken'] = doctorToken;
//           }
//           if (channelId.isNotEmpty) {
//             result['channelId'] = channelId;
//           }
//           break;
//         }
//       }
//     }
//   } catch (_) {
//     // ignore
//   }
//   return result;
// }

// bool _isTruthy(dynamic v) {
//   if (v == null) return false;
//   if (v is bool) return v;
//   final s = v.toString().trim().toLowerCase();
//   return s == 'true' || s == '1' || s == 'yes';
// }

// Map<String, dynamic>? _firstAcceptedCallFromActiveCalls(dynamic activeCalls) {
//   if (activeCalls is! List) return null;
//   for (final item in activeCalls) {
//     if (item is Map) {
//       final accepted =
//           _isTruthy(item['accepted']) || _isTruthy(item['isAccepted']);
//       if (accepted) {
//         return Map<String, dynamic>.from(item.map((k, v) => MapEntry('$k', v)));
//       }
//     }
//   }
//   return null;
// }

// Future<bool> _syncAcceptedCallFromActiveCalls({
//   SharedPreferences? prefs,
// }) async {
//   try {
//     final p = prefs ?? await SharedPreferences.getInstance();
//     final activeCalls = await FlutterCallkitIncoming.activeCalls();
//     final call = _firstAcceptedCallFromActiveCalls(activeCalls);
//     if (call == null) return false;

//     String appointmentId = '';
//     final extra = call['extra'];
//     if (extra is Map) {
//       appointmentId =
//           (extra['appointmentId'] ??
//                   extra['_id'] ??
//                   extra['appointment_id'] ??
//                   '')
//               .toString()
//               .trim();
//     }
//     if (appointmentId.isEmpty) {
//       final id = (call['id'] ?? call['uuid'] ?? call['callUUID'] ?? '')
//           .toString()
//           .trim();
//       if (_looksLikeMongoId(id)) appointmentId = id;
//     }
//     if (appointmentId.isEmpty) {
//       appointmentId =
//           (p.getString(SharedPrefKeys.incomingCallAppointmentId) ?? '').trim();
//     }
//     if (appointmentId.isEmpty) return false;

//     final name = (call['nameCaller'] ?? call['name'] ?? '').toString().trim();
//     final avatar = (call['avatar'] ?? call['photo'] ?? '').toString().trim();
//     final callKitId = (call['id'] ?? call['uuid'] ?? call['callUUID'] ?? '')
//         .toString()
//         .trim();

//     await p.setBool(isCallAccepted, true);
//     await p.setString(
//       agoraChannelId,
//       appointmentId,
//     ); // this key is used as appointmentId in app
//     if (name.isNotEmpty) await p.setString(agoraDocName, name);
//     if (avatar.isNotEmpty) await p.setString(agoraDocPhoto, avatar);

//     // Keep incoming-call prefs aligned (used by other flows/fallbacks).
//     await p.setString(SharedPrefKeys.incomingCallAppointmentId, appointmentId);
//     if (_looksLikeUuid(callKitId)) {
//       await p.setString(SharedPrefKeys.incomingCallCallKitId, callKitId);
//     }
//     if (name.isNotEmpty)
//       await p.setString(SharedPrefKeys.incomingCallName, name);
//     if (avatar.isNotEmpty)
//       await p.setString(SharedPrefKeys.incomingCallImage, avatar);
//     await p.setBool(pendingIncomingCallOpen, false);

//     return true;
//   } catch (_) {
//     return false;
//   }
// }

// Future<bool> _openCallRoomIfAccepted({bool retryIfNoContext = false}) async {
//   try {
//     final prefs = await SharedPreferences.getInstance();
//     final accepted = prefs.getBool(isCallAccepted) ?? false;
//     final appointmentId = (prefs.getString(agoraChannelId) ?? '').trim();
//     if (!accepted || appointmentId.isEmpty) return false;

//     // If the in-call UI is already visible, don't re-navigate.
//     try {
//       if (Get.isRegistered<CallController>()) {
//         final cc = CallController.to;
//         if (cc.isCallUiVisible.value) return true;
//       }
//     } catch (_) {
//       // ignore
//     }

//     // Hydrate tokens/channel if missing.
//     String channelToUse =
//         (prefs.getString('agora_channel_id_$appointmentId') ??
//                 prefs.getString('agora_channel_id') ??
//                 '')
//             .trim();
//     if (channelToUse.isEmpty) channelToUse = appointmentId;
//     String patientTokenToUse =
//         (prefs.getString('patient_agora_token_$appointmentId') ??
//                 prefs.getString('patient_agora_token') ??
//                 '')
//             .trim();
//     String doctorTokenToUse =
//         (prefs.getString('doctor_agora_token_$appointmentId') ??
//                 prefs.getString('doctor_agora_token') ??
//                 '')
//             .trim();

//     if (patientTokenToUse.isEmpty || doctorTokenToUse.isEmpty) {
//       final hydrated = await _hydrateCallCredentialsFromApi(appointmentId);
//       if (channelToUse.isEmpty) {
//         channelToUse = (hydrated['channelId'] ?? '').trim();
//       }
//       if (patientTokenToUse.isEmpty) {
//         patientTokenToUse = (hydrated['patientToken'] ?? '').trim();
//       }
//       if (doctorTokenToUse.isEmpty) {
//         doctorTokenToUse = (hydrated['doctorToken'] ?? '').trim();
//       }
//     }

//     if (channelToUse.isEmpty) channelToUse = appointmentId;
//     await prefs.setString('agora_channel_id', channelToUse);
//     await prefs.setString('agora_channel_id_$appointmentId', channelToUse);
//     if (patientTokenToUse.isNotEmpty) {
//       await prefs.setString('patient_agora_token', patientTokenToUse);
//       await prefs.setString(
//         'patient_agora_token_$appointmentId',
//         patientTokenToUse,
//       );
//     }
//     if (doctorTokenToUse.isNotEmpty) {
//       await prefs.setString('doctor_agora_token', doctorTokenToUse);
//       await prefs.setString(
//         'doctor_agora_token_$appointmentId',
//         doctorTokenToUse,
//       );
//     }

//     final name = (prefs.getString(agoraDocName) ?? '').trim();
//     final image = (prefs.getString(agoraDocPhoto) ?? '').trim();

//     void navigate() {
//       Get.offAll(
//         () => AgoraCallScreen(
//           name: name,
//           image: image.isNotEmpty ? image : null,
//           appointmentId: appointmentId,
//         ),
//       );
//     }

//     if (Get.key.currentContext != null) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         try {
//           navigate();
//         } catch (_) {}
//       });
//       return true;
//     }

//     if (!retryIfNoContext) return false;

//     int attempts = 0;
//     Timer.periodic(const Duration(milliseconds: 300), (t) {
//       attempts++;
//       if (Get.key.currentContext != null) {
//         t.cancel();
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           try {
//             navigate();
//           } catch (_) {}
//         });
//         return;
//       }
//       if (attempts >= 20) t.cancel();
//     });
//     return true;
//   } catch (_) {
//     // ignore
//   }
//   return false;
// }

// void _logFcmBackground(String where, RemoteMessage message) {
//   try {
//     dPrint(
//       'FCM[$where] id=${message.messageId} from=${message.from} sentTime=${message.sentTime} data=${_redactFcmData(message.data)}',
//     );
//   } catch (_) {
//     // ignore
//   }
// }

// Future<void> _persistIncomingCallPrefs({
//   required String appointmentId,
//   required String name,
//   required String? image,
//   String? callKitId,
//   String? patientToken,
//   String? doctorToken,
//   String? channelId,
// }) async {
//   final prefs = await SharedPreferences.getInstance();
//   await prefs.setString(
//     SharedPrefKeys.incomingCallAppointmentId,
//     appointmentId,
//   );
//   await prefs.setString(SharedPrefKeys.incomingCallName, name);
//   if (_looksLikeUuid((callKitId ?? '').trim())) {
//     await prefs.setString(
//       SharedPrefKeys.incomingCallCallKitId,
//       callKitId!.trim(),
//     );
//   } else {
//     await prefs.remove(SharedPrefKeys.incomingCallCallKitId);
//   }
//   if (image != null) {
//     await prefs.setString(SharedPrefKeys.incomingCallImage, image);
//   } else {
//     await prefs.remove(SharedPrefKeys.incomingCallImage);
//   }
//   await prefs.setBool(pendingIncomingCallOpen, true);

//   // Persist Agora credentials for fallback on accept.
//   if ((patientToken ?? '').trim().isNotEmpty) {
//     await prefs.setString('patient_agora_token', patientToken!.trim());
//     await prefs.setString(
//       'patient_agora_token_$appointmentId',
//       patientToken.trim(),
//     );
//   }
//   if ((doctorToken ?? '').trim().isNotEmpty) {
//     await prefs.setString('doctor_agora_token', doctorToken!.trim());
//     await prefs.setString(
//       'doctor_agora_token_$appointmentId',
//       doctorToken.trim(),
//     );
//   }
//   if ((channelId ?? '').trim().isNotEmpty) {
//     final ch = channelId!.trim();
//     await prefs.setString('agora_channel_id', ch);
//     await prefs.setString('agora_channel_id_$appointmentId', ch);
//   }
// }

// Future<bool> _tryOpenInAppIncomingCallFromPrefs() async {
//   try {
//     if (!Get.isRegistered<CallController>()) return false;
//     final ctx = Get.key.currentContext;
//     if (ctx == null) return false;

//     final prefs = await SharedPreferences.getInstance();
//     final pending = prefs.getBool(pendingIncomingCallOpen) ?? false;
//     if (!pending) return false;

//     final appointmentId =
//         (prefs.getString(SharedPrefKeys.incomingCallAppointmentId) ?? '')
//             .trim();
//     final name = (prefs.getString(SharedPrefKeys.incomingCallName) ?? '')
//         .trim();
//     final image = (prefs.getString(SharedPrefKeys.incomingCallImage) ?? '')
//         .trim();
//     final callKitId =
//         (prefs.getString(SharedPrefKeys.incomingCallCallKitId) ?? '').trim();
//     if (appointmentId.isEmpty) return false;

//     CallController.to.showIncomingCall(
//       appointmentId: appointmentId,
//       callKitId: callKitId,
//       doctorName: name.isNotEmpty ? name : 'BEH - DOCTOR',
//       doctorPhoto: image.isNotEmpty ? image : null,
//     );
//     await prefs.setBool(pendingIncomingCallOpen, false);
//     return true;
//   } catch (_) {
//     return false;
//   }
// }

// Future<void> _maybeOpenIncomingCallUiFromMessage(RemoteMessage message) async {
//   try {
//     final String metaRaw = (message.data['meta'] ?? '').toString();
//     Map<String, dynamic> firebasePayload = <String, dynamic>{};
//     if (metaRaw.trim().isNotEmpty) {
//       try {
//         firebasePayload = await stringToMapAsync(metaRaw);
//       } catch (_) {
//         firebasePayload = <String, dynamic>{};
//       }
//     }
//     if (firebasePayload.isEmpty) {
//       firebasePayload = message.data.map((k, v) => MapEntry(k, v));
//     }

//     final criteriaValue =
//         (firebasePayload['criteria'] ?? message.data['criteria']).toString();
//     final titleValue =
//         (firebasePayload['title'] ??
//                 message.notification?.title ??
//                 message.data['title'] ??
//                 '')
//             .toString();
//     final bool isCalling =
//         criteriaValue == 'appointment' &&
//         (titleValue.toLowerCase().contains('calling') ||
//             (firebasePayload['metaData'] is Map &&
//                 (firebasePayload['metaData'] as Map)['_id']
//                         ?.toString()
//                         .trim()
//                         .isNotEmpty ==
//                     true));
//     if (!isCalling) return;

//     final dynamic metaData = firebasePayload['metaData'];
//     if (metaData is! Map) return;

//     final appointmentId = (metaData['_id'] ?? '').toString().trim();
//     final doctorName = (metaData['doctor']?['name'] ?? '').toString().trim();
//     final doctorPhoto = metaData['doctor']?['photo']?.toString();
//     final patientToken =
//         (metaData['patientAgoraToken'] ??
//                 metaData['agoraToken'] ??
//                 metaData['token'] ??
//                 '')
//             .toString()
//             .trim();
//     final doctorToken = (metaData['doctorAgoraToken'] ?? '').toString().trim();
//     final channelId =
//         (metaData['channelId'] ?? metaData['agoraChannelId'] ?? appointmentId)
//             .toString()
//             .trim();
//     if (appointmentId.isEmpty) return;

//     // Ensure we can receive cancel/end events ASAP.
//     try {
//       AgoraCallSocketHandler().preconnect();
//     } catch (_) {
//       // ignore
//     }

//     await _persistIncomingCallPrefs(
//       appointmentId: appointmentId,
//       name: doctorName.isNotEmpty ? doctorName : 'BEH - DOCTOR',
//       image: doctorPhoto,
//       patientToken: patientToken,
//       doctorToken: doctorToken,
//       channelId: channelId,
//     );

//     // Best-effort open immediately if GetX is ready; otherwise the app lifecycle
//     // handler will pick it up after build/resume.
//     if (await _tryOpenInAppIncomingCallFromPrefs()) return;

//     int attempts = 0;
//     Timer.periodic(const Duration(milliseconds: 300), (t) async {
//       attempts++;
//       final ok = await _tryOpenInAppIncomingCallFromPrefs();
//       if (ok || attempts >= 20) {
//         t.cancel();
//       }
//     });
//   } catch (_) {
//     // ignore
//   }
// }

// Future<void> _handleCallKitAccept({required Map<String, dynamic>? body}) async {
//   final prefs = await SharedPreferences.getInstance();

//   // Mark accept time so we can ignore CallKit "ended" events triggered by our
//   // own endCall/endAllCalls (some devices emit actionCallEnded right after accept).
//   try {
//     await prefs.setInt(
//       'callkit_last_accept_ms',
//       DateTime.now().millisecondsSinceEpoch,
//     );
//   } catch (_) {
//     // ignore
//   }

//   final String appointmentIdFromExtra =
//       (body?['extra'] is Map ? (body?['extra']?['appointmentId'] ?? '') : '')
//           .toString()
//           .trim();
//   final String appointmentIdFromPrefs =
//       (prefs.getString(SharedPrefKeys.incomingCallAppointmentId) ?? '').trim();
//   final String idFromBody =
//       (body?['id']?.toString() ??
//               body?['callUUID']?.toString() ??
//               body?['uuid']?.toString() ??
//               '')
//           .trim();
//   final String appointmentIdFromBody = _looksLikeMongoId(idFromBody)
//       ? idFromBody
//       : '';

//   final String appointmentId = appointmentIdFromExtra.isNotEmpty
//       ? appointmentIdFromExtra
//       : (appointmentIdFromBody.isNotEmpty
//             ? appointmentIdFromBody
//             : appointmentIdFromPrefs);

//   if (appointmentId.isEmpty) return;

//   final String callKitId = _resolveCallKitIdFromCallKit(
//     prefs: prefs,
//     body: body,
//   );

//   final String name =
//       (body?['nameCaller']?.toString() ??
//               prefs.getString(SharedPrefKeys.incomingCallName) ??
//               '')
//           .trim();
//   final String image =
//       (body?['avatar']?.toString() ??
//               prefs.getString(SharedPrefKeys.incomingCallImage) ??
//               '')
//           .trim();

//   final patientTokenFromBody =
//       (body?['extra'] is Map ? body?['extra']?['patientAgoraToken'] : null)
//           ?.toString()
//           .trim();
//   final doctorTokenFromBody =
//       (body?['extra'] is Map ? body?['extra']?['doctorAgoraToken'] : null)
//           ?.toString()
//           .trim();
//   final channelIdFromBody =
//       (body?['extra'] is Map ? body?['extra']?['channelId'] : null)
//           ?.toString()
//           .trim();

//   try {
//     await prefs.setString('callkit_last_accept_appointment_id', appointmentId);
//     await prefs.setString('callkit_last_accept_callkit_id', callKitId);
//     if (callKitId.isNotEmpty) {
//       await prefs.setString(SharedPrefKeys.incomingCallCallKitId, callKitId);
//     } else {
//       await prefs.remove(SharedPrefKeys.incomingCallCallKitId);
//     }
//   } catch (_) {
//     // ignore
//   }

//   // Stop CallKit/system ringing immediately on accept.
//   try {
//     if (callKitId.isNotEmpty) {
//       await FlutterCallkitIncoming.endCall(callKitId);
//     }
//   } catch (_) {
//     // ignore
//   }
//   try {
//     await FlutterCallkitIncoming.endAllCalls();
//   } catch (_) {
//     // ignore
//   }

//   // Stop in-app ringing too (if visible).
//   try {
//     if (Get.isRegistered<CallController>()) {
//       await CallController.to.markIncomingAccepted();
//     }
//   } catch (_) {
//     // ignore
//   }

//   await prefs.setBool(isCallAccepted, true);
//   await prefs.setString(
//     agoraChannelId,
//     appointmentId,
//   ); // stored as appointmentId in app
//   if (name.isNotEmpty) await prefs.setString(agoraDocName, name);
//   if (image.isNotEmpty) await prefs.setString(agoraDocPhoto, image);
//   await prefs.setBool(pendingIncomingCallOpen, false);

//   // Persist any credentials we got in accept payload.
//   if ((patientTokenFromBody ?? '').trim().isNotEmpty) {
//     await prefs.setString('patient_agora_token', patientTokenFromBody!.trim());
//     await prefs.setString(
//       'patient_agora_token_$appointmentId',
//       patientTokenFromBody.trim(),
//     );
//   }
//   if ((doctorTokenFromBody ?? '').trim().isNotEmpty) {
//     await prefs.setString('doctor_agora_token', doctorTokenFromBody!.trim());
//     await prefs.setString(
//       'doctor_agora_token_$appointmentId',
//       doctorTokenFromBody.trim(),
//     );
//   }
//   if ((channelIdFromBody ?? '').trim().isNotEmpty) {
//     final ch = channelIdFromBody!.trim();
//     await prefs.setString('agora_channel_id', ch);
//     await prefs.setString('agora_channel_id_$appointmentId', ch);
//   }

//   // If any credentials are missing, hydrate from API (best-effort).
//   try {
//     final patientTok =
//         (prefs.getString('patient_agora_token_$appointmentId') ?? '').trim();
//     final doctorTok =
//         (prefs.getString('doctor_agora_token_$appointmentId') ?? '').trim();
//     final ch =
//         (prefs.getString('agora_channel_id_$appointmentId') ??
//                 prefs.getString('agora_channel_id') ??
//                 '')
//             .trim();
//     if (patientTok.isEmpty || doctorTok.isEmpty) {
//       final hydrated = await _hydrateCallCredentialsFromApi(appointmentId);
//       final hydratedChannel = (hydrated['channelId'] ?? '').trim();
//       final hydratedPatient = (hydrated['patientToken'] ?? '').trim();
//       final hydratedDoctor = (hydrated['doctorToken'] ?? '').trim();
//       if (hydratedPatient.isNotEmpty) {
//         await prefs.setString('patient_agora_token', hydratedPatient);
//         await prefs.setString(
//           'patient_agora_token_$appointmentId',
//           hydratedPatient,
//         );
//       }
//       if (hydratedDoctor.isNotEmpty) {
//         await prefs.setString('doctor_agora_token', hydratedDoctor);
//         await prefs.setString(
//           'doctor_agora_token_$appointmentId',
//           hydratedDoctor,
//         );
//       }
//       if (ch.isEmpty) {
//         final toSave = hydratedChannel.isNotEmpty
//             ? hydratedChannel
//             : appointmentId;
//         await prefs.setString('agora_channel_id', toSave);
//         await prefs.setString('agora_channel_id_$appointmentId', toSave);
//       }
//     }
//   } catch (_) {
//     // ignore
//   }

//   await _openCallRoomIfAccepted(retryIfNoContext: true);
// }

// bool _looksLikeMongoId(String id) {
//   final s = id.trim();
//   if (s.length != 24) return false;
//   for (final code in s.codeUnits) {
//     final isDigit = code >= 48 && code <= 57;
//     final isLowerHex = code >= 97 && code <= 102;
//     final isUpperHex = code >= 65 && code <= 70;
//     if (!isDigit && !isLowerHex && !isUpperHex) return false;
//   }
//   return true;
// }

// bool _looksLikeUuid(String id) {
//   final s = id.trim();
//   if (s.length != 36) return false;
//   for (var i = 0; i < s.length; i++) {
//     final code = s.codeUnitAt(i);
//     if (i == 8 || i == 13 || i == 18 || i == 23) {
//       if (code != 45) return false;
//       continue;
//     }
//     final isDigit = code >= 48 && code <= 57;
//     final isLower = code >= 97 && code <= 102;
//     final isUpper = code >= 65 && code <= 70;
//     if (!isDigit && !isLower && !isUpper) return false;
//   }
//   return true;
// }

// bool _looksLikeCallCancelOrEndTitle(String title) {
//   final t = title.toLowerCase();
//   return t.contains('cancel') ||
//       t.contains('canceled') ||
//       t.contains('cancelled') ||
//       t.contains('ended') ||
//       t.contains('end call') ||
//       t.contains('call end') ||
//       t.contains('declin') ||
//       t.contains('reject') ||
//       t.contains('missed call') ||
//       t.contains('no answer');
// }

// String _prettyAppointmentTypeLabel(String raw) {
//   final v = raw.trim();
//   if (v.isEmpty) return '';
//   final lower = v.toLowerCase();
//   if (lower == 'null' || lower == 'undefined') return '';

//   final normalized = v
//       .replaceAll('_', ' ')
//       .replaceAll('-', ' ')
//       .replaceAll(RegExp(r'\\s+'), ' ')
//       .trim();
//   if (normalized.isEmpty) return '';
//   return normalized
//       .split(' ')
//       .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
//       .join(' ');
// }

// String _resolveAppointmentTypeLabelFromMeta(dynamic metaData) {
//   if (metaData is! Map) return '';
//   final candidates = [
//     metaData['appointmentType'],
//     metaData['appointment_type'],
//     metaData['type'],
//     metaData['visitType'],
//     metaData['appointment'] is Map
//         ? (metaData['appointment'] as Map)['type']
//         : null,
//     metaData['appointment'] is Map
//         ? (metaData['appointment'] as Map)['appointmentType']
//         : null,
//   ];
//   for (final c in candidates) {
//     final label = _prettyAppointmentTypeLabel((c ?? '').toString());
//     if (label.isNotEmpty) return label;
//   }
//   return '';
// }

// Future<void> _endIncomingRingingFromPush({
//   required String appointmentId,
// }) async {
//   final prefs = await SharedPreferences.getInstance();
//   final accepted = prefs.getBool(isCallAccepted) ?? false;
//   final acceptedId = (prefs.getString(agoraChannelId) ?? '').trim();
//   if (accepted && acceptedId == appointmentId) {
//     // If call is already accepted/in-call, let in-call flow handle it.
//     return;
//   }

//   try {
//     final callKitId = _resolveCallKitIdFromCallKit(prefs: prefs, body: null);
//     if (callKitId.isNotEmpty) {
//       await FlutterCallkitIncoming.endCall(callKitId);
//     }
//   } catch (_) {
//     // ignore
//   }
//   try {
//     await FlutterCallkitIncoming.endAllCalls();
//   } catch (_) {
//     // ignore
//   }

//   // Best-effort: if app is running, dismiss in-app incoming UI too.
//   try {
//     if (Get.isRegistered<CallController>() &&
//         (CallController.to.isIncomingVisible.value)) {
//       await CallController.to.dismissIncomingCallFromRemote(
//         reason: 'push_cancel_end',
//       );
//     }
//   } catch (_) {
//     // ignore
//   }

//   try {
//     await prefs.setBool(isCallAccepted, false);
//     await prefs.setBool(pendingIncomingCallOpen, false);
//     await prefs.remove(SharedPrefKeys.incomingCallName);
//     await prefs.remove(SharedPrefKeys.incomingCallAppointmentId);
//     await prefs.remove(SharedPrefKeys.incomingCallImage);
//     await prefs.remove(SharedPrefKeys.incomingCallCallKitId);
//   } catch (_) {
//     // ignore
//   }
// }

// String _resolveAppointmentIdFromCallKit({
//   required SharedPreferences prefs,
//   required Map<String, dynamic>? body,
// }) {
//   final String fromExtra =
//       (body?['extra'] is Map ? (body?['extra']?['appointmentId'] ?? '') : '')
//           .toString()
//           .trim();
//   if (fromExtra.isNotEmpty) return fromExtra;

//   final String fromPrefs =
//       (prefs.getString(SharedPrefKeys.incomingCallAppointmentId) ?? '').trim();
//   if (fromPrefs.isNotEmpty) return fromPrefs;

//   final String fromBody =
//       (body?['id']?.toString() ??
//               body?['callUUID']?.toString() ??
//               body?['uuid']?.toString() ??
//               '')
//           .trim();
//   // Avoid using CallKit UUID as appointmentId.
//   if (_looksLikeMongoId(fromBody)) return fromBody;
//   return '';
// }

// String _resolveCallKitIdFromCallKit({
//   required SharedPreferences prefs,
//   required Map<String, dynamic>? body,
// }) {
//   final String fromExtra =
//       (body?['extra'] is Map ? (body?['extra']?['callKitId'] ?? '') : '')
//           .toString()
//           .trim();
//   if (_looksLikeUuid(fromExtra)) return fromExtra;

//   final String fromBody =
//       (body?['id']?.toString() ??
//               body?['callUUID']?.toString() ??
//               body?['uuid']?.toString() ??
//               '')
//           .trim();
//   if (_looksLikeUuid(fromBody)) return fromBody;

//   final String fromPrefs =
//       (prefs.getString(SharedPrefKeys.incomingCallCallKitId) ?? '').trim();
//   if (_looksLikeUuid(fromPrefs)) return fromPrefs;

//   return '';
// }

// Future<void> _handleCallKitDeclineOrEnd({
//   required String type,
//   required Map<String, dynamic>? body,
// }) async {
//   final prefs = await SharedPreferences.getInstance();

//   // Guard: some devices emit "ended/timeout" right after accept because we
//   // stop CallKit ringing. Never treat that as a real end.
//   try {
//     final lastAcceptMs = prefs.getInt('callkit_last_accept_ms') ?? 0;
//     final nowMs = DateTime.now().millisecondsSinceEpoch;
//     if (lastAcceptMs > 0 && (nowMs - lastAcceptMs) < 20000) {
//       // Still stop any lingering CallKit UI, but don't emit end/reject or clear app state.
//       final String callKitId = _resolveCallKitIdFromCallKit(
//         prefs: prefs,
//         body: body,
//       );
//       try {
//         if (callKitId.isNotEmpty) {
//           await FlutterCallkitIncoming.endCall(callKitId);
//         }
//       } catch (_) {}
//       try {
//         await FlutterCallkitIncoming.endAllCalls();
//       } catch (_) {}
//       return;
//     }
//   } catch (_) {
//     // ignore
//   }

//   final String appointmentId = _resolveAppointmentIdFromCallKit(
//     prefs: prefs,
//     body: body,
//   );

//   // CallKit uses its own UUID/id. End that specific call FIRST to stop system ringing.
//   final String callKitId = _resolveCallKitIdFromCallKit(
//     prefs: prefs,
//     body: body,
//   );

//   try {
//     if (callKitId.isNotEmpty) {
//       await FlutterCallkitIncoming.endCall(callKitId);
//     }
//   } catch (_) {
//     // ignore
//   }
//   try {
//     await FlutterCallkitIncoming.endAllCalls();
//   } catch (_) {
//     // ignore
//   }

//   // Ensure the calling service stops any remaining foreground service/notification.
//   try {
//     await CallService().dispose();
//   } catch (_) {
//     // ignore
//   }

//   // Stop any in-app ringtone as well.
//   try {
//     if (Get.isRegistered<CallController>()) {
//       await CallController.to.stopRingtone();
//     }
//   } catch (_) {
//     // ignore
//   }

//   if (appointmentId.isNotEmpty) {
//     try {
//       AgoraCallSocketHandler().preconnect();
//     } catch (_) {
//       // ignore
//     }
//     try {
//       if (type == 'reject') {
//         AgoraCallSocketHandler().emitRejectCall(appointmentId: appointmentId);
//       } else {
//         AgoraCallSocketHandler().emitEndCall(appointmentId: appointmentId);
//       }
//     } catch (_) {
//       // ignore
//     }
//   }

//   await prefs.setBool(isCallAccepted, false);
//   await prefs.setBool(pendingIncomingCallOpen, false);
//   await prefs.remove(SharedPrefKeys.incomingCallName);
//   await prefs.remove(SharedPrefKeys.incomingCallAppointmentId);
//   await prefs.remove(SharedPrefKeys.incomingCallImage);
//   await prefs.remove(SharedPrefKeys.incomingCallCallKitId);
//   await prefs.remove(SharedPrefKeys.incomingCallType);
// }

// void _attachCallKitGlobalListener() {
//   try {
//     _callKitGlobalSub?.cancel();
//   } catch (_) {
//     // ignore
//   }
//   try {
//     _callKitGlobalSub = FlutterCallkitIncoming.onEvent.listen((event) async {
//       try {
//         if (event == null) return;
//         final name = event.event.toString();
//         final body = event.body;
//         try {
//           log('MAIN CALLKIT: event=$name body=$body');
//         } catch (_) {
//           // ignore
//         }

//         final lower = name.toLowerCase();

//       dPrint('CALLKIT EVENT: $name');

//         if (lower.contains('actioncallaccept') ||
//             lower.contains('actionaccept') ||
//             lower.contains('callaccept')) {
//           // Mark accept time so synthetic "end" events are ignored across app & controller.
//           try {
//             final prefs = await SharedPreferences.getInstance();
//             await prefs.setInt(
//               'callkit_last_accept_ms',
//               DateTime.now().millisecondsSinceEpoch,
//             );
//             await prefs.setBool(isCallAccepted, true);
//           } catch (_) {}
//           await _handleCallKitAccept(body: body);
//           await _openCallRoomIfAccepted(retryIfNoContext: true);
//           return;
//         }

//         if (lower.contains('actioncalldecline') ||
//             lower.contains('actiondecline') ||
//             lower.contains('calldecline')) {
//           await _handleCallKitDeclineOrEnd(type: 'reject', body: body);
//           return;
//         }

//         if (lower.contains('actioncallended') ||
//             lower.contains('actioncalltimeout') ||
//             lower.contains('callended') ||
//             lower.contains('calltimeout')) {
//           // Some devices emit an "ended" event immediately after accept because
//           // we stop CallKit ringing by calling endCall/endAllCalls.
//           // Ignore that synthetic end event so we don't notify backend to end.
//           try {
//             final prefs = await SharedPreferences.getInstance();
//             final lastAcceptMs = prefs.getInt('callkit_last_accept_ms') ?? 0;
//             final lastAcceptId =
//                 (prefs.getString('callkit_last_accept_appointment_id') ?? '')
//                     .trim();
//             final lastAcceptCallKitId =
//                 (prefs.getString('callkit_last_accept_callkit_id') ?? '')
//                     .trim();
//             final nowMs = DateTime.now().millisecondsSinceEpoch;

//             final String endedIdFromExtra =
//                 (body is Map && body['extra'] is Map
//                         ? (body['extra']?['appointmentId'] ?? '')
//                         : '')
//                     .toString()
//                     .trim();
//             final String endedIdFromBody =
//                 (body is Map
//                         ? (body['id']?.toString() ??
//                               body['callUUID']?.toString() ??
//                               body['uuid']?.toString() ??
//                               '')
//                         : '')
//                     .toString()
//                     .trim();
//             final endedId = endedIdFromExtra.isNotEmpty
//                 ? endedIdFromExtra
//                 : (endedIdFromBody.isNotEmpty ? endedIdFromBody : lastAcceptId);

//             final isLikelySynthetic =
//                 lastAcceptMs > 0 && (nowMs - lastAcceptMs) < 20000;
//             if (isLikelySynthetic) {
//               // If we recently accepted, ignore any end within the window to
//               // keep the in-app call UI alive (even if IDs don't match).
//               if (lastAcceptId.isEmpty && lastAcceptCallKitId.isEmpty) {
//                 return;
//               }
//               if ((lastAcceptId.isNotEmpty && endedId == lastAcceptId) ||
//                   (lastAcceptCallKitId.isNotEmpty &&
//                       endedId == lastAcceptCallKitId)) {
//                 return;
//               }
//             }
//           } catch (_) {
//             // ignore
//           }
//           await _handleCallKitDeclineOrEnd(type: 'end', body: body);
//           return;
//         }
//       } catch (_) {
//         // ignore
//       }
//     });
//   } catch (_) {
//     // ignore
//   }
// }

// // --------------------------------------------------------------------------------------
// // PUSH NOTIFICATION ENTRY POINTS
// // --------------------------------------------------------------------------------------
// // We handle FCM notifications in both:
// // - Background isolate (app killed/background)
// // - Foreground (app open)
// //
// // A key requirement for call UX:
// // - On receiving *any* notification, preconnect the socket ASAP so that if the
// //   doctor cancels quickly, the patient app is already connected and can
// //   receive cancel/end events (reduces race conditions).

// @pragma('vm:entry-point')
// Future<void> _firebasePushNotificationOnBackgroundMessageHandler(
//   RemoteMessage message,
// ) async {
//   // Background isolate: ensure plugins are registered before using any plugin
//   // (CallKit, SharedPreferences, AwesomeNotifications, etc.).
//   try {
//     WidgetsFlutterBinding.ensureInitialized();
//   } catch (e, st) {
//     _handleCatch('bg.ensureInitialized', e, st);
//   }
//   try {
//     ui.DartPluginRegistrant.ensureInitialized();
//   } catch (e, st) {
//     _handleCatch('bg.pluginRegistrant', e, st);
//   }

//   // NOTE: in background isolate, `developer.log()` can be unreliable on some devices.
//   // Use `print()` so logs show up in logcat.
//   dPrint('FCM: background notification received (bg handler)');
//   _logFcmBackground('BG', message);
//   try {
//     await Firebase.initializeApp(
//       options: DefaultFirebaseOptions.currentPlatform,
//     );
//   } catch (e, st) {
//     dPrint('FCM: background Firebase.initializeApp failed: $e');
//     _handleCatch('bg.firebaseInit', e, st);
//   }

//   // Preconnect socket immediately (background isolate) so the connection is
//   // ready by the time the user opens the app / CallKit UI is shown.
//   try {
//     AgoraCallSocketHandler().preconnect();
//   } catch (e, st) {
//     _handleCatch('bg.preconnectSocket', e, st);
//   }

//   final String metaRaw = (message.data['meta'] ?? '').toString();
//   Map<String, dynamic> firebasePayload = <String, dynamic>{};
//   if (metaRaw.trim().isNotEmpty) {
//     try {
//       firebasePayload = stringToMap(metaRaw);
//     } catch (e, st) {
//       _handleCatch('bg.parseMeta', e, st);
//       firebasePayload = <String, dynamic>{};
//     }
//   }
//   if (firebasePayload.isEmpty) {
//     // Some backends send criteria/title directly in data instead of meta JSON.
//     firebasePayload = message.data.map((k, v) => MapEntry(k, v));
//   }
//   try {
//     dPrint(
//       'FCM: background criteria=${firebasePayload['criteria'] ?? message.data['criteria']} title=${firebasePayload['title'] ?? message.data['title'] ?? message.notification?.title}',
//     );
//   } catch (e, st) {
//     _handleCatch('bg.logCriteria', e, st);
//   }

//   final String bgTitle =
//       (firebasePayload['title'] ??
//               message.notification?.title ??
//               message.data['title'] ??
//               '')
//           .toString()
//           .trim();
//   final bool isAppointmentCriteria =
//       (firebasePayload['criteria'] ?? message.data['criteria']) ==
//       'appointment';

//   // Be resilient to title variations (some backends don't include "calling").
//   final dynamic bgMetaData = firebasePayload['metaData'];
//   final String bgTitleLower = bgTitle.toLowerCase();
//   final String metaType =
//       ((bgMetaData is Map ? bgMetaData['callType'] : null) ??
//               (bgMetaData is Map ? bgMetaData['type'] : null) ??
//               firebasePayload['callType'] ??
//               firebasePayload['type'] ??
//               '')
//           .toString()
//           .toLowerCase()
//           .trim();
//   final bool hasCallMeta =
//       bgMetaData is Map &&
//       (bgMetaData['_id']?.toString().trim().isNotEmpty ?? false) &&
//       ((bgMetaData['patientAgoraToken'] ??
//                   bgMetaData['agoraToken'] ??
//                   bgMetaData['token'] ??
//                   bgMetaData['channelId'] ??
//                   bgMetaData['agoraChannelId'])
//               ?.toString()
//               .trim()
//               .isNotEmpty ??
//           false);
//   final bool isCallTypeHint = metaType.contains('call');

//   final bool isIncomingCallBackground =
//       isAppointmentCriteria &&
//       (bgTitleLower.contains('calling') || isCallTypeHint || hasCallMeta);
//   if (isAppointmentCriteria && !isIncomingCallBackground) {
//     dPrint(
//       'FCM: background appointment notification not treated as call. title=$bgTitle metaType=$metaType hasMeta=${bgMetaData is Map}',
//     );
//   }
//   dPrint(
//     'FCM: background classification isIncomingCall=$isIncomingCallBackground isCancelOrEndPending=${_looksLikeCallCancelOrEndTitle(bgTitle)}',
//   );

//   // If doctor cancels/ends while CallKit is ringing, backend often sends a
//   // second push (title: "call ended/cancelled"). Handle that by ending CallKit
//   // immediately even if we cannot keep a socket alive in the bg isolate.
//   final bool isCancelOrEndBackground =
//       (firebasePayload['criteria'] ?? message.data['criteria']) ==
//           'appointment' &&
//       !isIncomingCallBackground &&
//       _looksLikeCallCancelOrEndTitle(bgTitle);

//   // In background isolate we show local notification for NON-call events.
//   // For incoming calls we prefer CallKit only (no normal notification).
//   if (!isIncomingCallBackground && !isCancelOrEndBackground) {
//     final computedTitle =
//         (firebasePayload['title'] ??
//                 message.notification?.title ??
//                 message.data['title'] ??
//                 '')
//             .toString()
//             .trim();
//     final computedBody =
//         (firebasePayload['body'] ??
//                 message.notification?.body ??
//                 message.data['body'] ??
//                 '')
//             .toString()
//             .trim();

//     // Skip empty notifications to avoid blank cards.
//     if (computedTitle.isNotEmpty || computedBody.isNotEmpty) {
//       dPrint(
//         'FCM: background showing notification banner title="$computedTitle" criteria=${firebasePayload['criteria'] ?? message.data['criteria']}',
//       );
//       // On Android, Firebase may already show system notification when
//       // message.notification is present. Avoid duplicate local notification.
//       final shouldShowLocal =
//           !(Platform.isAndroid && message.notification != null);
//       if (shouldShowLocal) {
//         await AwesomeNotifications().createNotification(
//           content: NotificationContent(
//             id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
//             channelKey: 'basic_channel',
//             title: computedTitle.isNotEmpty ? computedTitle : 'Eyebuddy',
//             body: computedBody,
//             payload: message.data.map((k, v) => MapEntry(k, '$v')),
//           ),
//         );
//       }
//     }
//   }

//   switch (firebasePayload['criteria']) {
//     case 'appointment':
//       if (isCancelOrEndBackground) {
//         try {
//           final dynamic metaData = firebasePayload['metaData'];
//           final appointmentId = (metaData is Map)
//               ? (metaData['_id'] ?? '').toString().trim()
//               : (firebasePayload['_id'] ?? message.data['_id'] ?? '')
//                     .toString()
//                     .trim();
//           if (appointmentId.isNotEmpty) {
//             await _endIncomingRingingFromPush(appointmentId: appointmentId);
//           } else {
//             // No appointmentId; still best-effort stop any ringing.
//             try {
//               await FlutterCallkitIncoming.endAllCalls();
//             } catch (e, st) {
//               _handleCatch('bg.endAllCalls', e, st);
//             }
//           }
//         } catch (e, st) {
//           _handleCatch('bg.cancelOrEnd', e, st);
//         }
//         return;
//       }
//       // Calling notification: open CallKit and start listening to socket events.
//       if (isIncomingCallBackground) {
//         dPrint(
//           'FCM: background triggering CallKit. title="$bgTitle" hasMeta=$hasCallMeta callType=$metaType',
//         );
//         final SharedPreferences prefs = await SharedPreferences.getInstance();
//         prefs.setString(criteria, 'appointment');
//         try {
//           dPrint(
//             "FCM: background metaData.doctor=${(firebasePayload['metaData'] is Map) ? (firebasePayload['metaData'] as Map)['doctor'] : null}",
//           );
//         } catch (e, st) {
//           _handleCatch('bg.logMeta', e, st);
//         }

//         try {
//           final dynamic metaData = firebasePayload['metaData'];
//           if (metaData is Map) {
//             // Persist Agora credentials (token/channel) so that when the user
//             // accepts from CallKit, CallController.startCall() can join.
//             try {
//               final appointmentId = (metaData['_id'] ?? '').toString().trim();

//               final patientToken =
//                   (metaData['patientAgoraToken'] ??
//                           metaData['agoraToken'] ??
//                           metaData['token'] ??
//                           '')
//                       .toString()
//                       .trim();

//               final doctorToken = (metaData['doctorAgoraToken'] ?? '')
//                   .toString()
//                   .trim();

//               final channelId =
//                   (metaData['channelId'] ??
//                           metaData['agoraChannelId'] ??
//                           appointmentId)
//                       .toString()
//                       .trim();

//               if (patientToken.isNotEmpty) {
//                 await prefs.setString('patient_agora_token', patientToken);
//                 if (appointmentId.isNotEmpty) {
//                   await prefs.setString(
//                     'patient_agora_token_$appointmentId',
//                     patientToken,
//                   );
//                 }
//               }

//               if (doctorToken.isNotEmpty) {
//                 await prefs.setString('doctor_agora_token', doctorToken);
//                 if (appointmentId.isNotEmpty) {
//                   await prefs.setString(
//                     'doctor_agora_token_$appointmentId',
//                     doctorToken,
//                   );
//                 }
//               }

//               final finalChannelId = channelId.isNotEmpty
//                   ? channelId
//                   : (appointmentId.isNotEmpty ? appointmentId : '');
//               if (finalChannelId.isNotEmpty) {
//                 await prefs.setString('agora_channel_id', finalChannelId);
//                 if (appointmentId.isNotEmpty) {
//                   await prefs.setString(
//                     'agora_channel_id_$appointmentId',
//                     finalChannelId,
//                   );
//                 }
//               }
//             } catch (e, st) {
//               _handleCatch('bg.persistTokens', e, st);
//             }

//             dPrint(
//               'FCM: background showing CallKit for appointmentId=${(metaData['_id'] ?? '').toString()}',
//             );
//             await CallService().showIncomingCall(
//               name: (metaData['doctor']?['name'] ?? '').toString(),
//               image: metaData['doctor']?['photo']?.toString(),
//               appointmentId: (metaData['_id'] ?? '').toString(),
//               appointmentType: _resolveAppointmentTypeLabelFromMeta(metaData),
//             );
//             return;
//           }
//         } catch (e, st) {
//           _handleCatch('bg.callPayload', e, st);
//         }

//         // Fallback: some backends don't include nested metaData map.
//         try {
//           final fallbackAppointmentId =
//               (firebasePayload['_id'] ?? message.data['_id'] ?? '')
//                   .toString()
//                   .trim();
//           final fallbackName =
//               (firebasePayload['doctorName'] ??
//                       message.data['doctorName'] ??
//                       message.notification?.title ??
//                       '')
//                   .toString();
//           if (fallbackAppointmentId.isNotEmpty) {
//             dPrint(
//               'FCM: background fallback showing CallKit appointmentId=$fallbackAppointmentId',
//             );
//             await CallService().showIncomingCall(
//               name: fallbackName,
//               image: null,
//               appointmentId: fallbackAppointmentId,
//               appointmentType: _resolveAppointmentTypeLabelFromMeta(
//                 firebasePayload['metaData'],
//               ),
//             );
//           } else {
//             dPrint('FCM: background call payload missing appointmentId');
//           }
//         } catch (e, st) {
//           dPrint('FCM: background fallback CallKit error: $e');
//           _handleCatch('bg.callFallback', e, st);
//         }
//       }
//       break;
//     case 'c':
//       final SharedPreferences prefs = await SharedPreferences.getInstance();
//       prefs.setString(criteria, 'prescription');
//       log('click noti main screen ${message.data.toString()}');
//       break;
//     default:
//       log('Received a push notification');
//   }
// }

// Future<void> _firebasePushNotificationOnForegroundMessageHandler(
//   RemoteMessage message,
// ) async {
//   // Foreground handler runs while app is open.
//   // We still show a local notification and also open in-app incoming call UI.
//   log('FCM: foreground notification received');
//   _logFcmForeground('FG', message);

//   // Preconnect socket immediately (foreground) for fastest possible call event
//   // handling (doctor end/cancel).
//   try {
//     AgoraCallSocketHandler().preconnect();
//   } catch (e, st) {
//     _handleCatch('fg.preconnectSocket', e, st);
//   }

//   final String metaRaw = (message.data['meta'] ?? '').toString();
//   final Map<String, dynamic> firebasePayload = metaRaw.isNotEmpty
//       ? await stringToMapAsync(metaRaw)
//       : <String, dynamic>{};
//   log('FCM: foreground criteria=${firebasePayload['criteria']}');

//   // If doctor cancels/ends while we are ringing, stop any ringing UI.
//   try {
//     final criteriaValue =
//         (firebasePayload['criteria'] ?? message.data['criteria']).toString();
//     final titleValue =
//         (firebasePayload['title'] ??
//                 message.notification?.title ??
//                 message.data['title'] ??
//                 '')
//             .toString();
//     if (criteriaValue == 'appointment' &&
//         _looksLikeCallCancelOrEndTitle(titleValue)) {
//       final dynamic metaData = firebasePayload['metaData'];
//       final appointmentId = (metaData is Map)
//           ? (metaData['_id'] ?? '').toString().trim()
//           : (firebasePayload['_id'] ?? message.data['_id'] ?? '')
//                 .toString()
//                 .trim();
//       if (appointmentId.isNotEmpty) {
//         await _endIncomingRingingFromPush(appointmentId: appointmentId);
//       } else {
//         await _endIncomingRingingFromPush(appointmentId: '');
//       }
//       return;
//     }
//   } catch (e, st) {
//     _handleCatch('fg.cancelOrEnd', e, st);
//   }

//   // Foreground UX requirement:
//   // - When app is open and it's an incoming call, we should NOT show a popup notification.
//   //   We show in-app incoming call UI instead.
//   final String title =
//       (firebasePayload['title'] ??
//               message.notification?.title ??
//               message.data['title'] ??
//               '')
//           .toString()
//           .trim();
//   final String body =
//       (firebasePayload['body'] ??
//               message.notification?.body ??
//               message.data['body'] ??
//               '')
//           .toString()
//           .trim();

//   // Skip empty notifications to avoid blank cards.
//   if (title.isEmpty && body.isEmpty) {
//     return;
//   }

//   final bool isIncomingCallForeground =
//       firebasePayload['criteria'] == 'appointment' &&
//       title.toLowerCase().contains('calling');
//   if (!isIncomingCallForeground) {
//     // Show local notification via AwesomeNotifications for non-call notifications.
//     await AwesomeNotifications().createNotification(
//       content: NotificationContent(
//         id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
//         channelKey: 'basic_channel',
//         title: title.isNotEmpty ? title : 'Eyebuddy',
//         body: body,
//         payload: message.data.map((k, v) => MapEntry(k, '$v')),
//       ),
//     );
//   }

//   switch (firebasePayload['criteria']) {
//     case 'appointment':
//       // Only handle "Calling" type appointment notifications here.
//       if (title.toLowerCase().contains('calling')) {
//         // Guard: if we already have an active call (or joining), ignore new call push.
//         try {
//           if (Get.isRegistered<AgoraSingleton>()) {
//             final agora = AgoraSingleton.to;
//             if (agora.isInCall.value || agora.isConnecting.value) {
//               log(
//                 'MAIN NOTIFICATION: Ignoring calling notification because call is already active/connecting',
//               );
//               return;
//             }
//           }
//         } catch (e, st) {
//           _handleCatch('fg.activeCallGuard', e, st);
//         }

//         final SharedPreferences prefs = await SharedPreferences.getInstance();
//         await prefs.setString(criteria, 'appointment');
//         log(
//           "Foreground Notification (global): ${firebasePayload['metaData']['doctor']}",
//         );

//         final appointmentId =
//             firebasePayload['metaData']['_id'] as String? ?? '';

//         // Guard: some devices may deliver the same FCM message twice in foreground.
//         // Avoid re-triggering incoming UI/ringtone for the same appointment.
//         try {
//           final lastForegroundCallAppointmentId =
//               prefs.getString('last_foreground_call_appointment_id') ?? '';
//           final lastForegroundCallAtMs =
//               prefs.getInt('last_foreground_call_at_ms') ?? 0;
//           final nowMs = DateTime.now().millisecondsSinceEpoch;
//           if (appointmentId.isNotEmpty &&
//               lastForegroundCallAppointmentId == appointmentId &&
//               (nowMs - lastForegroundCallAtMs) < 5000) {
//             log(
//               'MAIN NOTIFICATION: Duplicate foreground calling push ignored for appointmentId=$appointmentId',
//             );
//             return;
//           }
//           if (appointmentId.isNotEmpty) {
//             await prefs.setString(
//               'last_foreground_call_appointment_id',
//               appointmentId,
//             );
//             await prefs.setInt('last_foreground_call_at_ms', nowMs);
//           }
//         } catch (e, st) {
//           _handleCatch('fg.duplicateGuard', e, st);
//         }

//         // Avoid showing ringing UI for appointments that are already:
//         // - past
//         // - prescribed
//         // These are stored locally in SharedPreferences.
//         try {
//           final pastIds =
//               prefs.getStringList('past_appointment_ids') ?? const <String>[];

//           final prescribedIds =
//               prefs.getStringList('prescribed_appointment_ids') ??
//               const <String>[];

//           if (pastIds.contains(appointmentId)) {
//             log(
//               'MAIN NOTIFICATION: Ignoring calling notification because appointment is past: $appointmentId',
//             );
//             return;
//           }

//           if (prescribedIds.contains(appointmentId)) {
//             log(
//               'MAIN NOTIFICATION: Ignoring calling notification because appointment is prescribed: $appointmentId',
//             );
//             return;
//           }
//         } catch (e, st) {
//           log('MAIN NOTIFICATION: Failed to validate appointment status: $e');
//           _handleCatch('fg.appointmentStatus', e, st);
//         }

//         // Extract and save Agora credentials for the call.
//         // We persist tokens/channelId so the call screens can reliably pick
//         // them up later (even across app restarts).

//         // Notification payload differs across environments, so we try multiple
//         // possible keys.
//         final patientToken =
//             firebasePayload['metaData']['patientAgoraToken'] as String? ??
//             firebasePayload['metaData']['agoraToken'] as String? ??
//             firebasePayload['metaData']['token'] as String? ??
//             '';

//         final doctorToken =
//             firebasePayload['metaData']['doctorAgoraToken'] as String? ?? '';

//         final channelId =
//             firebasePayload['metaData']['channelId'] as String? ??
//             firebasePayload['metaData']['agoraChannelId'] as String? ??
//             appointmentId; // fallback to appointmentId

//         log('MAIN NOTIFICATION: appointmentId → "$appointmentId"');
//         log('MAIN NOTIFICATION: patientToken → "$patientToken"');
//         log('MAIN NOTIFICATION: doctorToken → "$doctorToken"');
//         log('MAIN NOTIFICATION: channelId → "$channelId"');

//         // Start call even without token (will use existing tokens from SharedPreferences).
//         // NOTE: for safety, we don't overwrite stored tokens with empty strings.
//         if (appointmentId.isNotEmpty) {
//           // Disable CallKit incoming UI in foreground to prevent ringtone MediaPlayer errors
//           // try {
//           //   final doctorName =
//           //       firebasePayload['metaData']['doctor']['name'] as String? ??
//           //       'BEH - DOCTOR';
//           //   final doctorPhoto =
//           //       firebasePayload['metaData']['doctor']['photo'] as String?;
//           //   await CallService().showIncomingCall(
//           //     name: doctorName,
//           //     image: doctorPhoto,
//           //     appointmentId: appointmentId,
//           //   );
//           // } catch (e) {
//           //   log(
//           //     'MAIN NOTIFICATION ERROR: Failed to show CallKit incoming call (foreground) - $e',
//           //   );
//           // }

//           try {
//             if (patientToken.isNotEmpty) {
//               await prefs.setString('patient_agora_token', patientToken);
//             } else {
//               log(
//                 'MAIN NOTIFICATION: patientToken is empty - will not overwrite stored token',
//               );
//             }

//             // Use channelId if available, otherwise use appointmentId as fallback.
//             final finalChannelId = channelId.isNotEmpty
//                 ? channelId
//                 : appointmentId;
//             if (finalChannelId.isNotEmpty) {
//               await prefs.setString('agora_channel_id', finalChannelId);
//               log('MAIN NOTIFICATION: Saved channel ID → "$finalChannelId"');
//             }

//             // Also save appointment-specific tokens so we can load them
//             // deterministically later.
//             if (patientToken.isNotEmpty) {
//               await prefs.setString(
//                 'patient_agora_token_$appointmentId',
//                 patientToken,
//               );
//             }

//             if (doctorToken.isNotEmpty) {
//               await prefs.setString('doctor_agora_token', doctorToken);
//               await prefs.setString(
//                 'doctor_agora_token_$appointmentId',
//                 doctorToken,
//               );
//             }
//             await prefs.setString(
//               'agora_channel_id_$appointmentId',
//               finalChannelId,
//             );

//             log(
//               'MAIN NOTIFICATION: Saved Agora credentials to SharedPreferences',
//             );
//           } catch (e, st) {
//             log('MAIN NOTIFICATION ERROR: Failed to save token - $e');
//             _handleCatch('fg.saveTokens', e, st);
//           }

//           // Open in-app incoming call screen.
//           // This is separate from CallKit (CallService) and is used for the
//           // in-app ringing UI.
//           try {
//             final doctorName =
//                 firebasePayload['metaData']['doctor']['name'] as String? ??
//                 'BEH - DOCTOR';
//             final doctorPhoto =
//                 firebasePayload['metaData']['doctor']['photo'] as String?;
//             CallController.to.showIncomingCall(
//               appointmentId: appointmentId,
//               doctorName: doctorName,
//               doctorPhoto: doctorPhoto,
//             );
//           } catch (e, st) {
//             log(
//               'MAIN NOTIFICATION ERROR: Failed to open incoming call UI - $e',
//             );
//             _handleCatch('fg.openIncomingUi', e, st);
//           }
//         }
//       }
//       break;
//     case 'c':
//       final SharedPreferences prefs = await SharedPreferences.getInstance();
//       await prefs.setString(criteria, 'prescription');
//       log(
//         'Foreground click noti main screen (global) ${message.data.toString()}',
//       );
//       break;
//     default:
//       log('Received a foreground push notification (global)');
//   }
// }

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   dPrint('[INIT] Starting main...');

//   // --------------------------------------------------------------------------------------
//   // APP STARTUP
//   // --------------------------------------------------------------------------------------
//   // 1) Initialize local notifications (AwesomeNotifications)
//   // 2) Initialize Firebase
//   // 3) Register FCM handlers
//   // 4) Fetch FCM token
//   // 5) Run the Flutter app

//   // AwesomeNotifications init
//   dPrint('[NOTIF] Initializing AwesomeNotifications...');
//   await AwesomeNotifications().initialize(null, [
//     NotificationChannel(
//       channelKey: 'basic_channel',
//       channelName: 'Basic notifications',
//       channelDescription: 'Notification channel for basic messages',
//       importance: NotificationImportance.High,
//       playSound: true,
//       enableVibration: true,
//       defaultColor: Color(0xFF9D50DD),
//       ledColor: Colors.white,
//     ),
//   ]);
//   dPrint('[NOTIF] AwesomeNotifications initialized.');

//   // Set listeners
//   AwesomeNotifications().setListeners(
//     onActionReceivedMethod:
//         AwesomeNotificationController.onActionReceivedMethod,
//     onNotificationCreatedMethod:
//         AwesomeNotificationController.onNotificationCreatedMethod,
//     onNotificationDisplayedMethod:
//         AwesomeNotificationController.onNotificationDisplayedMethod,
//     onDismissActionReceivedMethod:
//         AwesomeNotificationController.onDismissActionReceivedMethod,
//   );

//   if (kDebugMode) {
//     log('[FIREBASE] Initializing Firebase...');
//   }
//   try {
//     await Firebase.initializeApp(
//       options: DefaultFirebaseOptions.currentPlatform,
//     );
//     // Ensure Firebase Analytics is available (fixes "Analytics library is missing").
//     FirebaseAnalytics.instance;
//     try {
//       await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
//     } catch (_) {
//       // ignore
//     }
//     if (kDebugMode) {
//       log('[FIREBASE] Firebase initialized successfully');
//     }
//   } catch (e) {
//     log('[FIREBASE] Firebase initialization failed: $e');
//     rethrow;
//   }

//   // Google Mobile Ads (AdMob)
//   if (!kIsWeb &&
//       (defaultTargetPlatform == TargetPlatform.android ||
//           defaultTargetPlatform == TargetPlatform.iOS)) {
//     try {
//       await MobileAds.instance.initialize();
//     } catch (_) {
//       // ignore
//     }
//   }

//   // Initialize local notifications for permission handling
//   // final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//   //     FlutterLocalNotificationsPlugin();

//   // const AndroidInitializationSettings initializationSettingsAndroid =
//   //     AndroidInitializationSettings('@mipmap/ic_launcher');

//   // const InitializationSettings initializationSettings = InitializationSettings(
//   //   android: initializationSettingsAndroid,
//   // );

//   // await flutterLocalNotificationsPlugin.initialize(initializationSettings);
//   // print("Local notifications initialized");

//   // --------------------------------------------------------------------------------------
//   // FCM HANDLERS
//   // --------------------------------------------------------------------------------------
//   // Background handler (appointment calling, prescription etc.)
//   FirebaseMessaging.onBackgroundMessage(
//     _firebasePushNotificationOnBackgroundMessageHandler,
//   );
//   if (kDebugMode) {
//     log('[FCM] Background handler registered.');
//   }

//   _attachCallKitGlobalListener();

//   // Foreground handler
//   FirebaseMessaging.onMessage.listen(
//     _firebasePushNotificationOnForegroundMessageHandler,
//   );
//   if (kDebugMode) {
//     log('[FCM] Foreground handler registered.');
//   }

//   // User tapped notification while app is in background.
//   // Preconnect socket early so call events can be received ASAP.
//   FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//     _logFcmForeground('OPENED_APP', message);
//     try {
//       AgoraCallSocketHandler().preconnect();
//     } catch (_) {
//       // ignore
//     }
//     // If user tapped the banner, open the same in-app incoming call screen
//     // used in foreground (instead of showing CallKit again).
//     _maybeOpenIncomingCallUiFromMessage(message);
//     _openCallRoomIfAccepted(retryIfNoContext: true);
//   });

//   // App opened from terminated state by tapping notification.
//   FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
//     if (message != null) {
//       _logFcmForeground('INITIAL', message);
//       try {
//         AgoraCallSocketHandler().preconnect();
//       } catch (_) {
//         // ignore
//       }
//       // App opened from terminated by tapping banner: open in-app incoming UI.
//       _maybeOpenIncomingCallUiFromMessage(message);
//       _openCallRoomIfAccepted(retryIfNoContext: true);
//     }
//   });

//   // Check notification permissions at startup
//   final settings = await FirebaseMessaging.instance.getNotificationSettings();
//   dPrint("Notification permission status: ${settings.authorizationStatus}");

//   if (settings.authorizationStatus == AuthorizationStatus.denied) {
//     dPrint(
//       "Notification permissions are denied - user may need to enable in settings",
//     );
//   } else if (settings.authorizationStatus ==
//       AuthorizationStatus.notDetermined) {
//     dPrint("Notification permissions not determined - requesting now");
//     await FirebaseMessaging.instance.requestPermission(
//       alert: true,
//       announcement: false,
//       badge: true,
//       carPlay: false,
//       criticalAlert: false,
//       provisional: false,
//       sound: true,
//     );
//   } else {
//     dPrint("Notification permissions already granted");
//   }

//   // Initialize Firebase Messaging Token
//   dPrint('[TOKEN] Fetching FCM token...');
//   if (Platform.isIOS) {
//     dPrint('[TOKEN] Fetching FCM token for ios...');
//     final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
//     if (apnsToken == null || apnsToken.isEmpty) {
//       dPrint('[TOKEN] APNs token not ready yet');
//     } else {
//       apnsDeviceToken = apnsToken;
//       dPrint('[TOKEN] APNs token ready');
//       log('[TOKEN] APNs token: $apnsToken');
//     }
//   } else {
//     dPrint('[TOKEN] Fetching FCM token for android...');
//   }
//   try {
//     final fcmToken = await FirebaseMessaging.instance.getToken();
//     if (fcmToken != null && fcmToken.isNotEmpty) {
//       dPrint("[TOKEN] FCM TOKEN: $fcmToken");
//       log("[TOKEN] pushNoti token $fcmToken");
//       pushNotificationTokenKey = fcmToken;
//       userDeviceToken = fcmToken;
//       dPrint('[TOKEN] Token saved to pushNotificationTokenKey');
//       log('[TOKEN] Token saved to userDeviceToken => $userDeviceToken');
//     } else {
//       dPrint('[TOKEN] FCM token is null/empty');
//     }
//   } catch (e) {
//     dPrint('[TOKEN] Failed to fetch FCM token: $e');
//   }

//   // 🔑 FCM token (single source of truth)
//   // final String? fcmToken = await FirebaseMessaging.instance.getToken();

//   // if (fcmToken != null && fcmToken.isNotEmpty) {
//   //   pushNotificationTokenKey = fcmToken;
//   //   log('[TOKEN] FCM token: $fcmToken');
//   // } else {
//   //   log('[TOKEN] FCM token is null');
//   // }

//   // // 🍎 iOS: APNS token sirf debug / verification ke liye
//   // if (Platform.isIOS) {
//   //   final String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
//   //   log('[TOKEN] APNS token: $apnsToken');
//   // }

//   // // 🔁 Token refresh (VERY IMPORTANT for iOS)
//   FirebaseMessaging.instance.onTokenRefresh
//       .listen((newToken) {
//         pushNotificationTokenKey = newToken;
//         userDeviceToken = newToken;
//         log('[TOKEN] FCM token refreshed: $newToken');
//       })
//       .onError((err) {
//         // Error getting token.
//         log('[TOKEN] FCM token refreshed error: $err');
//       });
//   ;

//   // Request notification permissions (guarded against concurrent calls).
//   await NotificationPermissionGuard.requestPermission();

//   if (Platform.isIOS) {
//     try {
//       final voipToken = await FlutterCallkitIncoming.getDevicePushTokenVoIP();
//       if (voipToken != null && voipToken.toString().trim().isNotEmpty) {
//         voipDeviceToken = voipToken.toString().trim();
//       }
//       dPrint('[TOKEN] VoIP token: $voipToken');
//       log('[TOKEN] VoIP token: $voipToken');
//       if (voipDeviceToken.isEmpty) {
//         Future.delayed(const Duration(seconds: 4), () async {
//           try {
//             final retryToken =
//                 await FlutterCallkitIncoming.getDevicePushTokenVoIP();
//             if (retryToken != null && retryToken.toString().trim().isNotEmpty) {
//               voipDeviceToken = retryToken.toString().trim();
//               dPrint('[TOKEN] VoIP token retry: $retryToken');
//               log('[TOKEN] VoIP token retry: $retryToken');
//             }
//           } catch (e, st) {
//             _handleCatch('ios.voipTokenRetry', e, st);
//           }
//         });
//       }
//     } catch (e, st) {
//       _handleCatch('ios.voipToken', e, st);
//     }
//   }

//   if (Platform.isAndroid) {
//     await FirebaseMessaging.instance.setAutoInitEnabled(true);
//   }

//   await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
//     alert: true,
//     badge: true,
//     sound: true,
//   );

//   // ORIENTATION LOCK
//   await SystemChrome.setPreferredOrientations([
//     DeviceOrientation.portraitUp,
//     DeviceOrientation.portraitDown,
//   ]);

//   runApp(
//     DevicePreview(enabled: false, builder: (context) => const EyeBuddyApp()),
//   );
// }

// class EyeBuddyApp extends StatefulWidget {
//   const EyeBuddyApp({super.key});

//   @override
//   State<EyeBuddyApp> createState() => _EyeBuddyAppState();
// }

// class _BootstrapHome extends StatefulWidget {
//   const _BootstrapHome();

//   @override
//   State<_BootstrapHome> createState() => _BootstrapHomeState();
// }

// class _BootstrapHomeState extends State<_BootstrapHome> {
//   late final Future<Widget> _futureHome;

//   @override
//   void initState() {
//     super.initState();
//     _futureHome = _resolveHome();
//   }

//   Future<Widget> _resolveHome() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();

//       // If accept event was missed (some OEMs), sync accepted state from CallKit.
//       await _syncAcceptedCallFromActiveCalls(prefs: prefs);

//       final accepted = prefs.getBool(isCallAccepted) ?? false;
//       final callId = (prefs.getString(agoraChannelId) ?? '').trim();
//       if (accepted && callId.isNotEmpty) {
//         // Cold-start: ensure we have the Agora credentials before building the call screen.
//         try {
//           final patientTok =
//               (prefs.getString('patient_agora_token_$callId') ?? '').trim();
//           final doctorTok =
//               (prefs.getString('doctor_agora_token_$callId') ?? '').trim();
//           final channel =
//               (prefs.getString('agora_channel_id_$callId') ??
//                       prefs.getString('agora_channel_id') ??
//                       '')
//                   .trim();
//           if (patientTok.isEmpty || doctorTok.isEmpty) {
//             final hydrated = await _hydrateCallCredentialsFromApi(callId);
//             final hydratedChannel = (hydrated['channelId'] ?? '').trim();
//             final hydratedPatient = (hydrated['patientToken'] ?? '').trim();
//             final hydratedDoctor = (hydrated['doctorToken'] ?? '').trim();
//             if (hydratedPatient.isNotEmpty) {
//               await prefs.setString('patient_agora_token', hydratedPatient);
//               await prefs.setString(
//                 'patient_agora_token_$callId',
//                 hydratedPatient,
//               );
//             }
//             if (hydratedDoctor.isNotEmpty) {
//               await prefs.setString('doctor_agora_token', hydratedDoctor);
//               await prefs.setString(
//                 'doctor_agora_token_$callId',
//                 hydratedDoctor,
//               );
//             }
//             if (channel.isEmpty) {
//               final toSave = hydratedChannel.isNotEmpty
//                   ? hydratedChannel
//                   : callId;
//               await prefs.setString('agora_channel_id', toSave);
//               await prefs.setString('agora_channel_id_$callId', toSave);
//             }
//           } else if (channel.isEmpty) {
//             await prefs.setString('agora_channel_id', callId);
//             await prefs.setString('agora_channel_id_$callId', callId);
//           }
//         } catch (_) {
//           // ignore
//         }

//         final name = (prefs.getString(agoraDocName) ?? '').trim();
//         final image = (prefs.getString(agoraDocPhoto) ?? '').trim();
//         return AgoraCallScreen(
//           name: name,
//           image: image.isNotEmpty ? image : null,
//           appointmentId: callId,
//         );
//       }
//     } catch (_) {
//       // ignore
//     }
//     return const SplashScreen();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<Widget>(
//       future: _futureHome,
//       builder: (context, snapshot) {
//         final w = snapshot.data;
//         if (w != null) return w;
//         return const SizedBox.shrink();
//       },
//     );
//   }
// }

// class _EyeBuddyAppState extends State<EyeBuddyApp> with WidgetsBindingObserver {
//   final appStateController = Get.put(AppStateController());
//   String _lastHandledAcceptedCallId = '';

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     _restoreSavedLocale();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _ensureAndroidCallPermissions();
//       _ensureAndroidFullScreenIntentPermission();
//       _handlePendingIncomingOpenNavigation();
//       _handlePendingCallKitAcceptNavigation();
//     });
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     super.didChangeAppLifecycleState(state);
//     if (state == AppLifecycleState.resumed) {
//       _ensureAndroidCallPermissions();
//       _ensureAndroidFullScreenIntentPermission();
//       _handlePendingIncomingOpenNavigation();
//       _handlePendingCallKitAcceptNavigation();
//       _openCallRoomIfAccepted(retryIfNoContext: true);
//     }
//   }

//   Future<void> _ensureAndroidCallPermissions() async {
//     if (!Platform.isAndroid) return;

//     // Request POST_NOTIFICATIONS with a proper rationale + settings fallback.
//     // This is required for incoming call notifications/full-screen intent.
//     try {
//       await FlutterCallkitIncoming.requestNotificationPermission(<
//         String,
//         dynamic
//       >{
//         'title': 'Notifications required',
//         'rationaleMessagePermission':
//             'Enable notifications to receive incoming calls on the lock screen.',
//         'postNotificationMessageRequired':
//             'Please enable notifications in Settings to receive incoming calls.',
//       });
//     } catch (e) {
//       // Fallback: best-effort via permission_handler (some OEMs behave better).
//       try {
//         await Permission.notification.request();
//       } catch (_) {
//         // ignore
//       }
//       if (kDebugMode) {
//         log('[CALLKIT] Notification permission request failed: $e');
//       }
//     }
//   }

//   Future<void> _ensureAndroidFullScreenIntentPermission() async {
//     // Android 14+ requires a user-enabled "Use full screen intent" toggle per app.
//     // Without it, CallKit incoming UI may not appear over the lock screen.
//     if (!Platform.isAndroid) return;
//     try {
//       final can = await FlutterCallkitIncoming.canUseFullScreenIntent();
//       final canUse = (can is bool) ? can : true;
//       if (!canUse) {
//         if (kDebugMode) {
//           log(
//             '[CALLKIT] Full-screen intent not allowed; opening settings to enable it.',
//           );
//         }
//         await FlutterCallkitIncoming.requestFullIntentPermission();
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         log('[CALLKIT] Full-screen intent check failed: $e');
//       }
//     }
//   }

//   Future<void> _handlePendingIncomingOpenNavigation() async {
//     try {
//       await _tryOpenInAppIncomingCallFromPrefs();
//     } catch (_) {
//       // ignore
//     }
//   }

//   Future<void> _handlePendingCallKitAcceptNavigation() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();

//       // Some devices don't deliver the accept event to Flutter. Sync from CallKit.
//       await _syncAcceptedCallFromActiveCalls(prefs: prefs);

//       final accepted = prefs.getBool(isCallAccepted) ?? false;
//       if (!accepted) return;

//       final callId = (prefs.getString(agoraChannelId) ?? '').trim();
//       if (callId.isEmpty) return;

//       // Prevent duplicate navigations on multiple resume events.
//       if (_lastHandledAcceptedCallId == callId) {
//         try {
//           if (Get.isRegistered<CallController>() &&
//               CallController.to.isCallUiVisible.value) {
//             return;
//           }
//         } catch (_) {
//           // ignore
//         }
//       }
//       _lastHandledAcceptedCallId = callId;

//       // Attempt to open call room (with retry + hydration).
//       await _openCallRoomIfAccepted(retryIfNoContext: true);
//     } catch (_) {
//       // ignore
//     }
//   }

//   Future<void> _restoreSavedLocale() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final saved = (prefs.getString(languagePrefsKey) ?? '').trim();
//       final code = (saved == 'bn' || saved == 'en') ? saved : 'en';
//       if (Get.locale?.languageCode != code) {
//         Get.updateLocale(Locale(code));
//       }
//     } catch (_) {
//       // ignore
//     }
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return DisplayMetricsWidget(
//       child: GetMaterialApp(
//         initialBinding: BindingsBuilder(() {
//           // ----------------------------------------------------------------------------------
//           // GETX DEPENDENCY REGISTRATION
//           // ----------------------------------------------------------------------------------
//           // We register call-related controllers/services as permanent so they are
//           // not disposed between route changes (important for call lifecycle).
//           if (!Get.isRegistered<AgoraSingleton>()) {
//             Get.put(AgoraSingleton(), permanent: true);
//           }
//           if (!Get.isRegistered<CallController>()) {
//             Get.put(CallController(), permanent: true);
//           }
//           try {
//             // Keep socket warm at startup to reduce call cancel/end race.
//             AgoraCallSocketHandler().preconnect();
//           } catch (_) {
//             // ignore
//           }
//           if (!Get.isRegistered<ProfileController>()) {
//             Get.put(ProfileController(), permanent: true);
//           }
//           if (!Get.isRegistered<MoreController>()) {
//             Get.lazyPut(() => MoreController(), fenix: true);
//           }
//           if (!Get.isRegistered<EyeTestController>()) {
//             Get.lazyPut(() => EyeTestController(), fenix: true);
//           }
//         }),
//         builder: (context, child) {
//           final mq = MediaQuery.of(context);
//           final safeMq = mq.copyWith(
//             textScaler: TextScaler.linear(mq.textScaleFactor),
//           );
//           return MediaQuery(
//             data: safeMq,
//             child: GestureDetector(
//               behavior: HitTestBehavior.translucent,
//               onTap: () {
//                 FocusManager.instance.primaryFocus?.unfocus();
//               },
//               child: child ?? const SizedBox.shrink(),
//             ),
//           );
//         },
//         debugShowCheckedModeBanner: false,
//         theme: CustomTheme.lightTheme,

//         // <-- IMPORTANT (Fix Language Changing)
//         locale: Get.locale, // ⭐ current locale
//         fallbackLocale: const Locale('en'), // ⭐ fallback locale
//         // LOCALIZATION SETUP
//         localizationsDelegates: const [
//           AppLocalizations.delegate,
//           GlobalMaterialLocalizations.delegate,
//           GlobalWidgetsLocalizations.delegate,
//           GlobalCupertinoLocalizations.delegate,
//         ],
//         supportedLocales: AppLocalizations.supportedLocales,

//         getPages: [
//           GetPage(
//             name: '/appointment-overview',
//             page: () => const AppointmentOverviewScreen(),
//           ),
//           GetPage(
//             name: '/payment-gateway',
//             page: () => const PaymentGatewayScreen(),
//           ),
//           GetPage(
//             name: '/waiting-for-doctor',
//             page: () => const WaitingForDoctorScreen(),
//           ),
//         ],

//         home: const _BootstrapHome(),
//       ),
//     );
//   }
// // }

// import 'dart:developer' as developer;
// import 'dart:convert';

// import 'package:eye_buddy/features/reason_for_visit/view/appointment_overview_screen.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';

// import 'package:awesome_notifications/awesome_notifications.dart';

// import 'package:eye_buddy/firebase_options.dart'
//     if (dart.library.html) 'package:eye_buddy/firebase_options_web.dart';

// import 'package:eye_buddy/features/agora_call/view/PatientAgoraCallScreen.dart';
// import 'package:eye_buddy/core/services/utils/config/theme.dart';
// import 'package:eye_buddy/core/services/utils/keys/shared_pref_keys.dart';
// import 'package:eye_buddy/l10n/app_localizations.dart';

// import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:eye_buddy/features/splash/view/splash_screen.dart';

// import 'package:eye_buddy/features/payment_gateway/view/payment_gateway_screen.dart';
// import 'package:eye_buddy/features/waiting_for_doctor/view/waiting_for_doctor_screen.dart';

// void dLog(String msg) {
//   if (kDebugMode) developer.log(msg);
// }

// /// ------------------------------------------------------------
// /// 🔐 SAFE PAYLOAD CONVERTER (FIXED ISSUE)
// /// ------------------------------------------------------------
// Map<String, String> stringifyPayload(Map<String, dynamic> data) {
//   return data.map(
//     (key, value) => MapEntry(key, value?.toString() ?? ''),
//   );
// }

// /// ------------------------------------------------------------
// /// BACKGROUND / KILLED FCM
// /// ------------------------------------------------------------
// @pragma('vm:entry-point')
// Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );

//   final meta = message.data['meta'];
//   final isCall = meta != null && meta.toString().contains('Calling');
//   if (!isCall) return;

//   await AwesomeNotifications().createNotification(
//     content: NotificationContent(
//       id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
//       channelKey: 'call_channel',
//       title: 'Incoming Call',
//       body: 'Doctor is calling you',
//       category: NotificationCategory.Call,
//       wakeUpScreen: true,
//       fullScreenIntent: true,
//       payload: stringifyPayload(message.data), // ✅ FIX
//     ),
//   );
// }

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   await AwesomeNotifications().initialize(
//     null,
//     [
//       NotificationChannel(
//         channelKey: 'call_channel',
//         channelName: 'Incoming Calls',
//         channelDescription: 'Doctor calling notifications',
//         importance: NotificationImportance.Max,
//         playSound: true,
//         enableVibration: true,
//         locked: true,
//       ),
//     ],
//   );

//   await AwesomeNotifications().requestPermissionToSendNotifications();

//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );

//   FirebaseMessaging.onBackgroundMessage(
//     firebaseMessagingBackgroundHandler,
//   );

//   runApp(const EyeBuddyApp());
// }

// /// ------------------------------------------------------------
// /// APP
// /// ------------------------------------------------------------
// class EyeBuddyApp extends StatefulWidget {
//   const EyeBuddyApp({super.key});

//   @override
//   State<EyeBuddyApp> createState() => _EyeBuddyAppState();
// }

// class _EyeBuddyAppState extends State<EyeBuddyApp> {
//   @override
//   void initState() {
//     super.initState();
//     _restoreLocale();
//     _setupAwesomeListener();
//     _setupForegroundFCM();
//   }

//   /// ------------------------------------------------------------
//   /// NOTIFICATION TAP (BACKGROUND / KILLED)
//   /// ------------------------------------------------------------
//   void _setupAwesomeListener() {
//     AwesomeNotifications().setListeners(
//       onActionReceivedMethod: (action) async {
//         final payload = action.payload ?? {};

//         dLog('🟢 NOTIFICATION TAPPED');
//         dLog('📦 FULL PAYLOAD: $payload');

//         // 🔥 OPEN CALL FROM PAYLOAD
//         await _openCallFromPayload(stringifyPayload(payload));
//       },
//     );
//   }

//   /// ------------------------------------------------------------
//   /// FOREGROUND FCM
//   /// ------------------------------------------------------------
//   void _setupForegroundFCM() {
//     FirebaseMessaging.onMessage.listen((message) async {
//       final meta = message.data['meta'];
//       final isCall = meta != null && meta.toString().contains('Calling');
//       if (!isCall) return;

//       /// 🔥 AUTO OPEN CALL
//       _openCallFromPayload(stringifyPayload(message.data));

//       /// optional notification
//       await AwesomeNotifications().createNotification(
//         content: NotificationContent(
//           id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
//           channelKey: 'call_channel',
//           title: 'Incoming Call',
//           body: 'Doctor is calling you',
//           category: NotificationCategory.Call,
//           payload: stringifyPayload(message.data), // ✅ FIX
//         ),
//       );
//     });
//   }

//   /// ------------------------------------------------------------
//   /// COMMON CALL NAVIGATION
//   /// ------------------------------------------------------------
//   Future<void> _openCallFromPayload(Map<String, String> payload) async {
//     try {
//       String? channelId;
//       String? token;
//       String? doctorName;
//       String? doctorPhoto;

//       if (payload['meta'] != null && payload['meta']!.isNotEmpty) {
//         final meta = jsonDecode(payload['meta']!);
//         final metaData = meta['metaData'];

//         channelId = metaData['_id'];
//         token = metaData['patientAgoraToken'];

//         final doctor = metaData['doctor'];
//         doctorName = doctor?['name'];
//         doctorPhoto = doctor?['photo'];
//       }

//       final prefs = await SharedPreferences.getInstance();

//       channelId ??= prefs.getString('agora_channel_id');
//       token ??= prefs.getString('patient_agora_token');
//       doctorName ??= prefs.getString('doctor_name') ?? 'Doctor';
//       doctorPhoto ??= prefs.getString('doctor_photo') ?? '';

//       if (channelId == null || token == null) return;

//       Get.to(() => PatientCallScreen(
//             channelId: channelId!,
//             token: token!,
//             doctorName: doctorName!,
//             doctorPhoto: doctorPhoto!,
//           ));
//     } catch (e) {
//       dLog('❌ CALL OPEN ERROR: $e');
//     }
//   }

//   /// ------------------------------------------------------------
//   /// LOCALE
//   /// ------------------------------------------------------------
//   Future<void> _restoreLocale() async {
//     final prefs = await SharedPreferences.getInstance();
//     final saved = (prefs.getString(languagePrefsKey) ?? '').trim();
//     final code = (saved == 'bn' || saved == 'en') ? saved : 'en';
//     Get.updateLocale(Locale(code));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: CustomTheme.lightTheme,
//       locale: Get.locale,
//       fallbackLocale: const Locale('en'),
//       getPages: [
//         GetPage(
//           name: '/appointment-overview',
//           page: () => const AppointmentOverviewScreen(),
//         ),
//         GetPage(
//           name: '/payment-gateway',
//           page: () => const PaymentGatewayScreen(),
//         ),
//         GetPage(
//           name: '/waiting-for-doctor',
//           page: () => const WaitingForDoctorScreen(),
//         ),
//       ],
//       localizationsDelegates: const [
//         AppLocalizations.delegate,
//         GlobalMaterialLocalizations.delegate,
//         GlobalWidgetsLocalizations.delegate,
//         GlobalCupertinoLocalizations.delegate,
//       ],
//       supportedLocales: AppLocalizations.supportedLocales,
//       home: const SplashScreen(),
//     );
//   }
// }

// import 'dart:developer' as developer;
// import 'dart:convert';

// import 'package:eye_buddy/features/reason_for_visit/view/appointment_overview_screen.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';

// import 'package:awesome_notifications/awesome_notifications.dart';

// import 'package:eye_buddy/firebase_options.dart'
//     if (dart.library.html) 'package:eye_buddy/firebase_options_web.dart';

// import 'package:eye_buddy/features/agora_call/view/PatientAgoraCallScreen.dart';
// import 'package:eye_buddy/core/services/utils/config/theme.dart';
// import 'package:eye_buddy/core/services/utils/keys/shared_pref_keys.dart';
// import 'package:eye_buddy/l10n/app_localizations.dart';

// import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:eye_buddy/features/splash/view/splash_screen.dart';

// import 'package:eye_buddy/features/payment_gateway/view/payment_gateway_screen.dart';
// import 'package:eye_buddy/features/waiting_for_doctor/view/waiting_for_doctor_screen.dart';

// void dLog(String msg) {
//   if (kDebugMode) developer.log(msg);
// }

// /// ------------------------------------------------------------
// /// SAFE PAYLOAD
// /// ------------------------------------------------------------
// Map<String, String> stringifyPayload(Map<String, dynamic> data) {
//   return data.map((k, v) => MapEntry(k, v?.toString() ?? ''));
// }

// /// ------------------------------------------------------------
// /// BACKGROUND / KILLED FCM
// /// ------------------------------------------------------------
// @pragma('vm:entry-point')
// Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );

//   final meta = message.data['meta'];
//   if (meta == null || !meta.toString().contains('Calling')) return;

//   await AwesomeNotifications().createNotification(
//     content: NotificationContent(
//       id: 1001,
//       channelKey: 'call_channel',
//       title: 'Incoming Call',
//       body: 'Doctor is calling you',
//       category: NotificationCategory.Call,
//       wakeUpScreen: true,
//       fullScreenIntent: true,
//       locked: true,
//       payload: stringifyPayload(message.data),
//     ),
//     actionButtons: [
//       NotificationActionButton(
//         key: 'ACCEPT_CALL',
//         label: 'Accept',
//         color: Colors.green,
//       ),
//       NotificationActionButton(
//         key: 'DECLINE_CALL',
//         label: 'Decline',
//         color: Colors.red,
//         isDangerousOption: true,
//       ),
//     ],
//   );
// }

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   await AwesomeNotifications().initialize(
//     null,
//     [
//       NotificationChannel(
//         channelKey: 'call_channel',
//         channelName: 'Incoming Calls',
//         channelDescription: 'Doctor calling notifications',
//         importance: NotificationImportance.Max,
//         playSound: true,
//         enableVibration: true,
//         locked: true,
//       ),
//     ],
//   );

//   await AwesomeNotifications().requestPermissionToSendNotifications();

//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );

//   FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

//   runApp(const EyeBuddyApp());
// }

// /// ------------------------------------------------------------
// /// APP
// /// ------------------------------------------------------------
// class EyeBuddyApp extends StatefulWidget {
//   const EyeBuddyApp({super.key});

//   @override
//   State<EyeBuddyApp> createState() => _EyeBuddyAppState();
// }

// class _EyeBuddyAppState extends State<EyeBuddyApp> {
//   @override
//   void initState() {
//     super.initState();
//     _restoreLocale();
//     _setupAwesomeListener();
//     _setupForegroundFCM();
//   }

//   /// ------------------------------------------------------------
//   /// NOTIFICATION ACTION HANDLER
//   /// ------------------------------------------------------------
//   void _setupAwesomeListener() {
//     AwesomeNotifications().setListeners(
//       onActionReceivedMethod: (action) async {
//         final payload = action.payload ?? {};

//         if (action.buttonKeyPressed == 'DECLINE_CALL') {
//           AwesomeNotifications().cancel(action.id!);
//           return;
//         }

//         if (action.buttonKeyPressed == 'ACCEPT_CALL') {
//           await AwesomeNotifications().cancel(action.id!);
//           _openCallFromPayload(stringifyPayload(payload));
//         }
//       },
//     );
//   }

//   /// ------------------------------------------------------------
//   /// FOREGROUND CALL (AUTO OPEN)
//   /// ------------------------------------------------------------
//   void _setupForegroundFCM() {
//     FirebaseMessaging.onMessage.listen((message) async {
//       final meta = message.data['meta'];
//       if (meta == null || !meta.toString().contains('Calling')) return;

//       _openCallFromPayload(stringifyPayload(message.data));

//       await AwesomeNotifications().createNotification(
//         content: NotificationContent(
//           id: 1002,
//           channelKey: 'call_channel',
//           title: 'Incoming Call',
//           body: 'Doctor is calling you',
//           category: NotificationCategory.Call,
//           payload: stringifyPayload(message.data),
//         ),
//       );
//     });
//   }

//   /// ------------------------------------------------------------
//   /// OPEN CALL
//   /// ------------------------------------------------------------
//   Future<void> _openCallFromPayload(Map<String, String> payload) async {
//     try {
//       String? channelId;
//       String? token;
//       String? doctorName;
//       String? doctorPhoto;

//       if (payload['meta'] != null && payload['meta']!.isNotEmpty) {
//         final meta = jsonDecode(payload['meta']!);
//         final metaData = meta['metaData'];

//         channelId = metaData['_id'];
//         token = metaData['patientAgoraToken'];

//         final doctor = metaData['doctor'];
//         doctorName = doctor?['name'];
//         doctorPhoto = doctor?['photo'];
//       }

//       final prefs = await SharedPreferences.getInstance();
//       channelId ??= prefs.getString('agora_channel_id');
//       token ??= prefs.getString('patient_agora_token');
//       doctorName ??= prefs.getString('doctor_name') ?? 'Doctor';
//       doctorPhoto ??= prefs.getString('doctor_photo') ?? '';

//       if (channelId == null || token == null) return;

//       Get.to(() => PatientCallScreen(
//             channelId: channelId!,
//             token: token!,
//             doctorName: doctorName!,
//             doctorPhoto: doctorPhoto!,
//           ));
//     } catch (e) {
//       dLog('❌ CALL ERROR: $e');
//     }
//   }

//   /// ------------------------------------------------------------
//   /// LOCALE
//   /// ------------------------------------------------------------
//   Future<void> _restoreLocale() async {
//     final prefs = await SharedPreferences.getInstance();
//     final saved = prefs.getString(languagePrefsKey) ?? 'en';
//     Get.updateLocale(Locale(saved));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: CustomTheme.lightTheme,
//       locale: Get.locale,
//       fallbackLocale: const Locale('en'),
//       home: const SplashScreen(),
//       getPages: [
//         GetPage(
//           name: '/appointment-overview',
//           page: () => const AppointmentOverviewScreen(),
//         ),
//         GetPage(
//           name: '/payment-gateway',
//           page: () => const PaymentGatewayScreen(),
//         ),
//         GetPage(
//           name: '/waiting-for-doctor',
//           page: () => const WaitingForDoctorScreen(),
//         ),
//       ],
//       localizationsDelegates: const [
//         AppLocalizations.delegate,
//         GlobalMaterialLocalizations.delegate,
//         GlobalWidgetsLocalizations.delegate,
//         GlobalCupertinoLocalizations.delegate,
//       ],
//       supportedLocales: AppLocalizations.supportedLocales,
//     );
//   }
// }

// import 'dart:developer' as developer;
// import 'dart:convert';

// import 'package:eye_buddy/features/reason_for_visit/view/appointment_overview_screen.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';

// import 'package:awesome_notifications/awesome_notifications.dart';

// import 'package:eye_buddy/firebase_options.dart'
//     if (dart.library.html) 'package:eye_buddy/firebase_options_web.dart';

// import 'package:eye_buddy/features/agora_call/view/PatientAgoraCallScreen.dart';
// import 'package:eye_buddy/core/services/utils/config/theme.dart';
// import 'package:eye_buddy/core/services/utils/keys/shared_pref_keys.dart';
// import 'package:eye_buddy/l10n/app_localizations.dart';

// import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:eye_buddy/features/splash/view/splash_screen.dart';

// import 'package:eye_buddy/features/payment_gateway/view/payment_gateway_screen.dart';
// import 'package:eye_buddy/features/waiting_for_doctor/view/waiting_for_doctor_screen.dart';

// void dLog(String msg) {
//   if (kDebugMode) developer.log(msg);
// }

// /// ------------------------------------------------------------
// /// SAFE PAYLOAD
// /// ------------------------------------------------------------
// Map<String, String> stringifyPayload(Map<String, dynamic> data) {
//   return data.map((k, v) => MapEntry(k, v?.toString() ?? ''));
// }

// /// ------------------------------------------------------------
// /// BACKGROUND / KILLED FCM
// /// ------------------------------------------------------------
// @pragma('vm:entry-point')
// Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );

//   final meta = message.data['meta'];
//   if (meta == null || !meta.toString().contains('Calling')) return;

//   await AwesomeNotifications().createNotification(
//     content: NotificationContent(
//       id: 1001,
//       channelKey: 'call_channel',
//       title: 'Incoming Call',
//       body: 'Doctor is calling you',
//       category: NotificationCategory.Call,
//       wakeUpScreen: true,
//       fullScreenIntent: true,
//       locked: true,
//       payload: stringifyPayload(message.data),
//     ),
//    actionButtons: [
//   NotificationActionButton(
//     key: 'ACCEPT_CALL',
//     label: 'Accept',
//     color: Colors.green,
//     autoDismissible: true, // ✅ app khul sakti hai
//   ),
//   NotificationActionButton(
//     key: 'DECLINE_CALL',
//     label: 'Decline',
//     color: Colors.red,
//     isDangerousOption: true,
//     autoDismissible: true,
//     actionType: ActionType.SilentAction, // 🔥 MOST IMPORTANT
//   ),
// ],

//   );
// }

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   await AwesomeNotifications().initialize(
//     null,
//     [
//       NotificationChannel(
//         channelKey: 'call_channel',
//         channelName: 'Incoming Calls',
//         channelDescription: 'Doctor calling notifications',
//         importance: NotificationImportance.Max,
//         playSound: true,
//         enableVibration: true,
//         locked: true,
//       ),
//     ],
//   );

//   await AwesomeNotifications().requestPermissionToSendNotifications();

//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );

//   FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

//   runApp(const EyeBuddyApp());
// }

// /// ------------------------------------------------------------
// /// APP
// /// ------------------------------------------------------------
// class EyeBuddyApp extends StatefulWidget {
//   const EyeBuddyApp({super.key});

//   @override
//   State<EyeBuddyApp> createState() => _EyeBuddyAppState();
// }

// class _EyeBuddyAppState extends State<EyeBuddyApp> {
//   @override
//   void initState() {
//     super.initState();
//     _restoreLocale();
//     _setupAwesomeListener();
//     _setupForegroundFCM();
//     _setupTerminatedFCM();
//   }

// void _setupAwesomeListener() {
//   AwesomeNotifications().setListeners(
//     onActionReceivedMethod: (action) async {
//       final payload = action.payload ?? {};

//       // ❌ DECLINE → app open nahi hogi
//       if (action.buttonKeyPressed == 'DECLINE_CALL') {
//         await AwesomeNotifications().cancel(action.id!);

//         // 👉 yahan agar backend pe call cut ka API ho to call karo
//         // CallKit / Agora / API hit

//         return; // 🔥 VERY IMPORTANT
//       }

//       // ✅ ACCEPT → join call screen
//       if (action.buttonKeyPressed == 'ACCEPT_CALL') {
//         await AwesomeNotifications().cancel(action.id!);

//         _openCallFromPayload(
//           payload.map((k, v) => MapEntry(k, v.toString())),
//         );
//       }
//     },
//   );
// }

//   /// ------------------------------------------------------------
//   /// FOREGROUND CALL (AUTO OPEN)
//   /// ------------------------------------------------------------
//   void _setupForegroundFCM() {
//     FirebaseMessaging.onMessage.listen((message) async {
//       final meta = message.data['meta'];
//       if (meta == null || !meta.toString().contains('Calling')) return;

//       _openCallFromPayload(stringifyPayload(message.data));

//       await AwesomeNotifications().createNotification(
//         content: NotificationContent(
//           id: 1002,
//           channelKey: 'call_channel',
//           title: 'Incoming Call',
//           body: 'Doctor is calling you',
//           category: NotificationCategory.Call,
//           payload: stringifyPayload(message.data),
//         ),
//       );
//     });
//   }

//   /// ------------------------------------------------------------
//   /// TERMINATED FCM
//   /// ------------------------------------------------------------
//   void _setupTerminatedFCM() async {
//     RemoteMessage? initialMessage =
//         await FirebaseMessaging.instance.getInitialMessage();

//     if (initialMessage != null) {
//       final meta = initialMessage.data['meta'];
//       if (meta != null && meta.toString().contains('Calling')) {
//         _openCallFromPayload(stringifyPayload(initialMessage.data));
//       }
//     }
//   }

//   /// ------------------------------------------------------------
//   /// OPEN CALL
//   /// ------------------------------------------------------------
//   Future<void> _openCallFromPayload(Map<String, String> payload) async {
//     try {
//       String? channelId;
//       String? token;
//       String? doctorName;
//       String? doctorPhoto;

//       if (payload['meta'] != null && payload['meta']!.isNotEmpty) {
//         final meta = jsonDecode(payload['meta']!);
//         final metaData = meta['metaData'];

//         channelId = metaData['_id'];
//         token = metaData['patientAgoraToken'];

//         final doctor = metaData['doctor'];
//         doctorName = doctor?['name'];
//         doctorPhoto = doctor?['photo'];
//       }

//       final prefs = await SharedPreferences.getInstance();
//       channelId ??= prefs.getString('agora_channel_id');
//       token ??= prefs.getString('patient_agora_token');
//       doctorName ??= prefs.getString('doctor_name') ?? 'Doctor';
//       doctorPhoto ??= prefs.getString('doctor_photo') ?? '';

//     if (channelId == null || token == null) return;

// Get.to(() => PatientCallScreen(
//       channelId: channelId!,
//       token: token!,
//       doctorName: doctorName ?? 'Doctor',
//       doctorPhoto: doctorPhoto ?? '',
// ));
//     } catch (e) {
//       dLog('❌ CALL ERROR: $e');
//     }
//   }

//   /// ------------------------------------------------------------
//   /// LOCALE
//   /// ------------------------------------------------------------
//   Future<void> _restoreLocale() async {
//     final prefs = await SharedPreferences.getInstance();
//     final saved = prefs.getString(languagePrefsKey) ?? 'en';
//     Get.updateLocale(Locale(saved));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: CustomTheme.lightTheme,
//       locale: Get.locale,
//       fallbackLocale: const Locale('en'),
//       home: const SplashScreen(),
//       getPages: [
//         GetPage(
//           name: '/appointment-overview',
//           page: () => const AppointmentOverviewScreen(),
//         ),
//         GetPage(
//           name: '/payment-gateway',
//           page: () => const PaymentGatewayScreen(),
//         ),
//         GetPage(
//           name: '/waiting-for-doctor',
//           page: () => const WaitingForDoctorScreen(),
//         ),
//       ],
//       localizationsDelegates: const [
//         AppLocalizations.delegate,
//         GlobalMaterialLocalizations.delegate,
//         GlobalWidgetsLocalizations.delegate,
//         GlobalCupertinoLocalizations.delegate,
//       ],
//       supportedLocales: AppLocalizations.supportedLocales,
//     );
//   }
// }

// working main hey

//   import 'dart:developer' as developer;
// import 'dart:convert';

// import 'package:eye_buddy/features/reason_for_visit/view/appointment_overview_screen.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';

// import 'package:awesome_notifications/awesome_notifications.dart';

// import 'package:eye_buddy/firebase_options.dart'
//     if (dart.library.html) 'package:eye_buddy/firebase_options_web.dart';

// import 'package:eye_buddy/features/agora_call/view/PatientAgoraCallScreen.dart';
// import 'package:eye_buddy/core/services/utils/config/theme.dart';
// import 'package:eye_buddy/core/services/utils/keys/shared_pref_keys.dart';
// import 'package:eye_buddy/l10n/app_localizations.dart';

// import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:eye_buddy/features/splash/view/splash_screen.dart';

// import 'package:eye_buddy/features/payment_gateway/view/payment_gateway_screen.dart';
// import 'package:eye_buddy/features/waiting_for_doctor/view/waiting_for_doctor_screen.dart';

// void dLog(String msg) {
//   if (kDebugMode) developer.log(msg);
// }

// /// ------------------------------------------------------------
// /// SAFE PAYLOAD
// /// ------------------------------------------------------------
// Map<String, String> stringifyPayload(Map<String, dynamic> data) {
//   return data.map((k, v) => MapEntry(k, v?.toString() ?? ''));
// }

// /// ------------------------------------------------------------
// /// BACKGROUND / KILLED FCM
// /// ------------------------------------------------------------
// @pragma('vm:entry-point')
// Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );

//   final meta = message.data['meta'];
//   if (meta == null || !meta.toString().contains('Calling')) return;

//   await AwesomeNotifications().createNotification(
//     content: NotificationContent(
//       id: 1001,
//       channelKey: 'call_channel',
//       title: 'Incoming Call',
//       body: 'Doctor is calling you',
//       category: NotificationCategory.Call,
//       wakeUpScreen: true,
//       fullScreenIntent: true,
//       locked: true,
//       payload: stringifyPayload(message.data),
//     ),
//    actionButtons: [
//   NotificationActionButton(
//     key: 'ACCEPT_CALL',
//     label: 'Accept',
//     color: Colors.green,
//     autoDismissible: true, // ✅ app khul sakti hai
//   ),
//   NotificationActionButton(
//     key: 'DECLINE_CALL',
//     label: 'Decline',
//     color: Colors.red,
//     isDangerousOption: true,
//     autoDismissible: true,
//     actionType: ActionType.SilentAction, // 🔥 MOST IMPORTANT
//   ),
// ],

//   );
// }

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   await AwesomeNotifications().initialize(
//     null,
//     [
//       NotificationChannel(
//         channelKey: 'call_channel',
//         channelName: 'Incoming Calls',
//         channelDescription: 'Doctor calling notifications',
//         importance: NotificationImportance.Max,
//         playSound: true,
//         enableVibration: true,
//         locked: true,
//       ),
//     ],
//   );

//   await AwesomeNotifications().requestPermissionToSendNotifications();

//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );

//   FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

//   runApp(const EyeBuddyApp());
// }

// /// ------------------------------------------------------------
// /// APP
// /// ------------------------------------------------------------
// class EyeBuddyApp extends StatefulWidget {
//   const EyeBuddyApp({super.key});

//   @override
//   State<EyeBuddyApp> createState() => _EyeBuddyAppState();
// }

// class _EyeBuddyAppState extends State<EyeBuddyApp> {
//   @override
//   void initState() {
//     super.initState();
//     _restoreLocale();
//     _setupAwesomeListener();
//     _setupForegroundFCM();
//     _setupTerminatedFCM();
//   }

// void _setupAwesomeListener() {
//   AwesomeNotifications().setListeners(
//     onActionReceivedMethod: (action) async {
//       final payload = action.payload ?? {};

//       // ❌ DECLINE → app open nahi hogi
//       if (action.buttonKeyPressed == 'DECLINE_CALL') {
//         await AwesomeNotifications().cancel(action.id!);
//         return;
//       }

//       // ✅ ACCEPT → direct video join
//       if (action.buttonKeyPressed == 'ACCEPT_CALL') {
//         await AwesomeNotifications().cancel(action.id!);

//         _openCallFromPayload(
//           payload.map((k, v) => MapEntry(k, v.toString())),
//           autoAccept: true, // 🔥 DIRECT JOIN
//         );
//       }
//     },
//   );
// }

//   /// ------------------------------------------------------------
//   /// FOREGROUND CALL (AUTO OPEN)
//   /// ------------------------------------------------------------
//   void _setupForegroundFCM() {
//     FirebaseMessaging.onMessage.listen((message) async {
//       final meta = message.data['meta'];
//       if (meta == null || !meta.toString().contains('Calling')) return;

//       _openCallFromPayload(stringifyPayload(message.data));

//       await AwesomeNotifications().createNotification(
//         content: NotificationContent(
//           id: 1002,
//           channelKey: 'call_channel',
//           title: 'Incoming Call',
//           body: 'Doctor is calling you',
//           category: NotificationCategory.Call,
//           payload: stringifyPayload(message.data),
//         ),
//       );
//     });
//   }

//   /// ------------------------------------------------------------
//   /// TERMINATED FCM
//   /// ------------------------------------------------------------

//   void _setupTerminatedFCM() async {
//   RemoteMessage? initialMessage =
//       await FirebaseMessaging.instance.getInitialMessage();

//   if (initialMessage == null) return;

//   final data = initialMessage.data;
//   final meta = data['meta'] ?? '';

//   if (meta.toString().contains('Calling')) {
//     _openCallFromPayload(stringifyPayload(data));
//   }
// }

//  /// ------------------------------------------------------------
// /// OPEN CALL (UPDATED)
// /// ------------------------------------------------------------
// Future<void> _openCallFromPayload(
//   Map<String, String> payload, {
//   bool autoAccept = false,
// }) async {
//   try {
//     String? channelId;
//     String? token;
//     String? doctorName;
//     String? doctorPhoto;

//     if (payload['meta'] != null && payload['meta']!.isNotEmpty) {
//       final meta = jsonDecode(payload['meta']!);
//       final metaData = meta['metaData'];

//       channelId = metaData['_id'];
//       token = metaData['patientAgoraToken'];

//       final doctor = metaData['doctor'];
//       doctorName = doctor?['name'];
//       doctorPhoto = doctor?['photo'];
//     }

//     final prefs = await SharedPreferences.getInstance();
//     channelId ??= prefs.getString('agora_channel_id');
//     token ??= prefs.getString('patient_agora_token');
//     doctorName ??= prefs.getString('doctor_name') ?? 'Doctor';
//     doctorPhoto ??= prefs.getString('doctor_photo') ?? '';

//     if (channelId == null || token == null) return;

//     Get.to(() => PatientCallScreen(
//           channelId: channelId!,
//           token: token!,
//           doctorName: doctorName!,
//           doctorPhoto: doctorPhoto!,
//           autoAccept: autoAccept, // 🔥 IMPORTANT
//         ));
//   } catch (e) {
//     dLog('❌ CALL ERROR: $e');
//   }
// }

//   /// ------------------------------------------------------------
//   /// LOCALE
//   /// ------------------------------------------------------------
//   Future<void> _restoreLocale() async {
//     final prefs = await SharedPreferences.getInstance();
//     final saved = prefs.getString(languagePrefsKey) ?? 'en';
//     Get.updateLocale(Locale(saved));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: CustomTheme.lightTheme,
//       locale: Get.locale,
//       fallbackLocale: const Locale('en'),
//       home: const SplashScreen(),
//       getPages: [
//         GetPage(
//           name: '/appointment-overview',
//           page: () => const AppointmentOverviewScreen(),
//         ),
//         GetPage(
//           name: '/payment-gateway',
//           page: () => const PaymentGatewayScreen(),
//         ),
//         GetPage(
//           name: '/waiting-for-doctor',
//           page: () => const WaitingForDoctorScreen(),
//         ),
//       ],
//       localizationsDelegates: const [
//         AppLocalizations.delegate,
//         GlobalMaterialLocalizations.delegate,
//         GlobalWidgetsLocalizations.delegate,
//         GlobalCupertinoLocalizations.delegate,
//       ],
//       supportedLocales: AppLocalizations.supportedLocales,
//     );
//   }
// }

// onlyandoride

// ios setup ye sahi hey

// import 'dart:developer' as developer;
// import 'dart:convert';
// import 'dart:io';

// import 'package:eye_buddy/features/reason_for_visit/view/appointment_overview_screen.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_callkit_incoming/entities/call_event.dart';
// import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
// import 'package:get/get.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';

// import 'package:awesome_notifications/awesome_notifications.dart';

// import 'package:eye_buddy/firebase_options.dart'
//     if (dart.library.html) 'package:eye_buddy/firebase_options_web.dart';

// import 'package:eye_buddy/features/agora_call/view/PatientAgoraCallScreen.dart';
// import 'package:eye_buddy/core/services/utils/config/theme.dart';
// import 'package:eye_buddy/core/services/utils/keys/shared_pref_keys.dart';
// import 'package:eye_buddy/l10n/app_localizations.dart';

// import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:eye_buddy/features/splash/view/splash_screen.dart';

// import 'package:eye_buddy/features/payment_gateway/view/payment_gateway_screen.dart';
// import 'package:eye_buddy/features/waiting_for_doctor/view/waiting_for_doctor_screen.dart';

// import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';

// void dLog(String msg) {
//   if (kDebugMode) developer.log(msg);
// }

// /// ------------------------------------------------------------
// /// SAFE PAYLOAD
// /// ------------------------------------------------------------
// Map<String, String> stringifyPayload(Map<String, dynamic> data) {
//   return data.map((k, v) => MapEntry(k, v?.toString() ?? ''));
// }

// /// ------------------------------------------------------------
// /// BACKGROUND / KILLED FCM
// /// ------------------------------------------------------------
// @pragma('vm:entry-point')
// Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );

//   final meta = message.data['meta'];
//   if (meta == null || !meta.toString().contains('Calling')) return;

//   /// 🔴 ANDROID → AWESOME NOTIFICATION (UNCHANGED)
//   if (Platform.isAndroid) {
//     await AwesomeNotifications().createNotification(
//       content: NotificationContent(
//         id: 1001,
//         channelKey: 'call_channel',
//         title: 'Incoming Call',
//         body: 'Doctor is calling you',
//         category: NotificationCategory.Call,
//         wakeUpScreen: true,
//         fullScreenIntent: true,
//         locked: true,
//         payload: stringifyPayload(message.data),
//       ),
//       actionButtons: [
//         NotificationActionButton(
//           key: 'ACCEPT_CALL',
//           label: 'Accept',
//           color: Colors.green,
//           autoDismissible: true,
//         ),
//         NotificationActionButton(
//           key: 'DECLINE_CALL',
//           label: 'Decline',
//           color: Colors.red,
//           isDangerousOption: true,
//           autoDismissible: true,
//           actionType: ActionType.SilentAction,
//         ),
//       ],
//     );
//   }

//   /// 🍎 IOS → CALLKIT
//   if (Platform.isIOS) {
//     final metaJson = jsonDecode(message.data['meta']);
//     final metaData = metaJson['metaData'];

//     await FlutterCallkitIncoming.showCallkitIncoming(
//       CallKitParams(
//         id: metaData['_id'],
//         nameCaller: metaData['doctor']['name'],
//         handle: 'Doctor Call',
//         type: 0,
//         extra: stringifyPayload(message.data),
//       ),
//     );
//   }
// }

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   MobileAds.instance.initialize();

//   await AwesomeNotifications().initialize(
//     null,
//     [
//       NotificationChannel(
//         channelKey: 'call_channel',
//         channelName: 'Incoming Calls',
//         channelDescription: 'Doctor calling notifications',
//         importance: NotificationImportance.Max,
//         playSound: true,
//         enableVibration: true,
//         locked: true,
//       ),
//     ],
//   );

//   await AwesomeNotifications().requestPermissionToSendNotifications();

//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );

//   FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

//   runApp(const EyeBuddyApp());
// }

// /// ------------------------------------------------------------
// /// APP
// /// ------------------------------------------------------------
// class EyeBuddyApp extends StatefulWidget {
//   const EyeBuddyApp({super.key});

//   @override
//   State<EyeBuddyApp> createState() => _EyeBuddyAppState();
// }

// class _EyeBuddyAppState extends State<EyeBuddyApp> {
//   @override
//   void initState() {
//     super.initState();

//     _restoreLocale();
//     _setupAwesomeListener();      // ANDROID
//     _setupForegroundFCM();        // BOTH
//     _setupTerminatedFCM();        // BOTH
//     _handleKilledAwesomeAction(); // ANDROID
//     _setupIOSCallKitListener();   // 🍎 IOS ONLY

//     _ensureAndroidFullScreenIntentPermission(); // ANDROID ONLY
//   }

//   /// ------------------------------------------------------------
//   /// IOS CALLKIT LISTENER (ACCEPT / DECLINE)
//   /// ------------------------------------------------------------
//   void _setupIOSCallKitListener() {
//     if (!Platform.isIOS) return;

//     FlutterCallkitIncoming.onEvent.listen((event) {
//       final eventName = event?.event;
//       final extra = event?.body?['extra'];

//       if (eventName == Event.actionCallAccept && extra != null) {
//         _openCallFromPayload(
//           Map<String, String>.from(extra),
//           autoAccept: true,
//         );
//       }

//       if (eventName == Event.actionCallDecline) {
//         FlutterCallkitIncoming.endAllCalls();
//       }
//     });
//   }

//   /// ------------------------------------------------------------
//   /// ANDROID 14 FULL SCREEN INTENT PERMISSION
//   /// ------------------------------------------------------------
//   Future<void> _ensureAndroidFullScreenIntentPermission() async {
//     if (!Platform.isAndroid) return;

//     try {
//       final can = await FlutterCallkitIncoming.canUseFullScreenIntent();
//       final canUse = (can is bool) ? can : true;

//       if (!canUse) {
//         await FlutterCallkitIncoming.requestFullIntentPermission();
//       }
//     } catch (_) {}
//   }

//   /// ------------------------------------------------------------
//   /// AWESOME ACTION LISTENER (ANDROID)
//   /// ------------------------------------------------------------
//   void _setupAwesomeListener() {
//     AwesomeNotifications().setListeners(
//       onActionReceivedMethod: (action) async {
//         final payload = action.payload ?? {};

//         if (action.buttonKeyPressed == 'DECLINE_CALL') {
//           await AwesomeNotifications().cancel(action.id!);
//           return;
//         }

//         if (action.buttonKeyPressed == 'ACCEPT_CALL' ||
//             action.buttonKeyPressed.isEmpty) {
//           await AwesomeNotifications().cancel(action.id!);

//           WidgetsBinding.instance.addPostFrameCallback((_) {
//             _openCallFromPayload(
//               payload.map((k, v) => MapEntry(k, v.toString())),
//               autoAccept: action.buttonKeyPressed == 'ACCEPT_CALL',
//             );
//           });
//         }
//       },
//     );
//   }

//   /// ------------------------------------------------------------
//   /// FOREGROUND FCM
//   /// ------------------------------------------------------------
//   void _setupForegroundFCM() {
//     FirebaseMessaging.onMessage.listen((message) async {
//       final meta = message.data['meta'];
//       if (meta == null || !meta.toString().contains('Calling')) return;

//       /// 🍎 IOS → CALLKIT
//       if (Platform.isIOS) {
//         final metaJson = jsonDecode(message.data['meta']);
//         final metaData = metaJson['metaData'];

//         await FlutterCallkitIncoming.showCallkitIncoming(
//           CallKitParams(
//             id: metaData['_id'],
//             nameCaller: metaData['doctor']['name'],
//             handle: 'Doctor Call',
//             type: 0,
//             extra: stringifyPayload(message.data),
//           ),
//         );
//         return;
//       }

//       /// 🔴 ANDROID → EXISTING FLOW
//       _openCallFromPayload(stringifyPayload(message.data));

//       await AwesomeNotifications().createNotification(
//         content: NotificationContent(
//           id: 1002,
//           channelKey: 'call_channel',
//           title: 'Incoming Call',
//           body: 'Doctor is calling you',
//           category: NotificationCategory.Call,
//           payload: stringifyPayload(message.data),
//         ),
//       );
//     });
//   }

//   /// ------------------------------------------------------------
//   /// TERMINATED (FCM TAP)
//   /// ------------------------------------------------------------
//   void _setupTerminatedFCM() async {
//     final message = await FirebaseMessaging.instance.getInitialMessage();
//     if (message == null) return;

//     final meta = message.data['meta'] ?? '';
//     if (!meta.toString().contains('Calling')) return;

//     /// ❌ ANDROID: NO AUTO OPEN (AS YOU WANTED)
//     if (Platform.isAndroid) return;

//     /// 🍎 IOS
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _openCallFromPayload(stringifyPayload(message.data));
//     });
//   }

//   /// ------------------------------------------------------------
//   /// TERMINATED (AWESOME BUTTON) ANDROID
//   /// ------------------------------------------------------------
//   void _handleKilledAwesomeAction() async {
//     final action =
//         await AwesomeNotifications().getInitialNotificationAction(
//       removeFromActionEvents: true,
//     );

//     if (action == null) return;
//     if (action.buttonKeyPressed == 'DECLINE_CALL') return;

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _openCallFromPayload(
//         action.payload!.map((k, v) => MapEntry(k, v.toString())),
//         autoAccept: action.buttonKeyPressed == 'ACCEPT_CALL',
//       );
//     });
//   }

//   /// ------------------------------------------------------------
//   /// OPEN CALL (COMMON)
//   /// ------------------------------------------------------------
//   Future<void> _openCallFromPayload(
//     Map<String, String> payload, {
//     bool autoAccept = false,
//   }) async {
//     try {
//       String? channelId;
//       String? token;
//       String? doctorName;
//       String? doctorPhoto;

//       if (payload['meta'] != null && payload['meta']!.isNotEmpty) {
//         final meta = jsonDecode(payload['meta']!);
//         final metaData = meta['metaData'];

//         channelId = metaData['_id'];
//         token = metaData['patientAgoraToken'];

//         final doctor = metaData['doctor'];
//         doctorName = doctor?['name'];
//         doctorPhoto = doctor?['photo'];
//       }

//       final prefs = await SharedPreferences.getInstance();
//       channelId ??= prefs.getString('agora_channel_id');
//       token ??= prefs.getString('patient_agora_token');
//       doctorName ??= prefs.getString('doctor_name') ?? 'Doctor';
//       doctorPhoto ??= prefs.getString('doctor_photo') ?? '';

//       if (channelId == null || token == null) return;

//       Get.to(() => PatientCallScreen(
//             channelId: channelId!,
//             token: token!,
//             doctorName: doctorName!,
//             doctorPhoto: doctorPhoto!,
//             autoAccept: autoAccept,
//           ));
//     } catch (e) {
//       dLog('❌ CALL ERROR: $e');
//     }
//   }

//   /// ------------------------------------------------------------
//   /// LOCALE
//   /// ------------------------------------------------------------
//   Future<void> _restoreLocale() async {
//     final prefs = await SharedPreferences.getInstance();
//     final saved = prefs.getString(languagePrefsKey) ?? 'en';
//     Get.updateLocale(Locale(saved));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: CustomTheme.lightTheme,
//       locale: Get.locale,
//       fallbackLocale: const Locale('en'),
//       home: const SplashScreen(),
//       getPages: [
//         GetPage(
//           name: '/appointment-overview',
//           page: () => const AppointmentOverviewScreen(),
//         ),
//         GetPage(
//           name: '/payment-gateway',
//           page: () => const PaymentGatewayScreen(),
//         ),
//         GetPage(
//           name: '/waiting-for-doctor',
//           page: () => const WaitingForDoctorScreen(),
//         ),
//       ],
//       localizationsDelegates: const [
//         AppLocalizations.delegate,
//         GlobalMaterialLocalizations.delegate,
//         GlobalWidgetsLocalizations.delegate,
//         GlobalCupertinoLocalizations.delegate,
//       ],
//       supportedLocales: AppLocalizations.supportedLocales,
//     );
//   }
// }

// ===== IMPORTS SAME AS YOUR FIRST FILE + SOCKET =====

// import 'dart:async';
// import 'dart:developer' as developer;
// import 'dart:convert';
// import 'dart:io';

// import 'package:display_metrics/display_metrics.dart';
// import 'package:eye_buddy/core/services/utils/handlers/PatientCallSocketHandler.dart';
// import 'package:eye_buddy/features/reason_for_visit/view/appointment_overview_screen.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:awesome_notifications/awesome_notifications.dart';
// import 'dart:ui';

// import 'package:eye_buddy/firebase_options.dart'
//     if (dart.library.html) 'package:eye_buddy/firebase_options_web.dart';

// import 'package:eye_buddy/features/agora_call/view/PatientAgoraCallScreen.dart';
// import 'package:eye_buddy/core/services/utils/config/theme.dart';
// import 'package:eye_buddy/core/services/utils/keys/shared_pref_keys.dart';
// import 'package:eye_buddy/l10n/app_localizations.dart';

// import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:eye_buddy/features/splash/view/splash_screen.dart';
// import 'package:eye_buddy/features/payment_gateway/view/payment_gateway_screen.dart';
// import 'package:eye_buddy/features/waiting_for_doctor/view/waiting_for_doctor_screen.dart';

// import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';

// void dLog(String msg) {
//   if (kDebugMode) developer.log(msg);
// }

// Map<String, String> stringifyPayload(Map<String, dynamic> data) {
//   return data.map((k, v) => MapEntry(k, v?.toString() ?? ''));
// }

// /// ================= BACKGROUND SOCKET REJECT =================

// Future<void> backgroundRejectCall(String appointmentId) async {
//   try {
//     dLog("🟡 BG → START reject flow");
//     dLog("🟡 BG → appointmentId: $appointmentId");

//     final completer = Completer<void>();

//     dLog("🟡 BG → init socket start");

//     await PatientCallSocketHandler.instance.initSocket(
//       appointmentId: appointmentId,

//       onConnected: () {
//         dLog("✅ BG → Socket CONNECTED");
//         if (!completer.isCompleted) completer.complete();
//       },

//       onJoinedEvent: (data) {
//         dLog("🟢 BG Socket → onJoinedEvent $data");
//       },

//       onRejectedEvent: (data) {
//         dLog("🔴 BG Socket → onRejectedEvent $data");
//       },

//       onEndedEvent: (data) {
//         dLog("⚫ BG Socket → onEndedEvent $data");
//       },

//       onError: (err) {
//         dLog("❌ BG Socket ERROR → $err");
//         if (!completer.isCompleted) completer.complete();
//       },
//     );

//     dLog("🟡 BG → socket init done, waiting connect...");

//     try {
//       await completer.future.timeout(const Duration(seconds: 3));
//       dLog("🟢 BG → Socket ready");
//     } catch (_) {
//       dLog("⚠ BG → Socket connect timeout");
//     }

//     await Future.delayed(const Duration(milliseconds: 400));

//     dLog("🟡 BG → emitting reject call");

//     PatientCallSocketHandler.instance.emitRejectCall(
//       appointmentId: appointmentId,
//     );

//     dLog("🟡 BG → reject emitted");

//     await Future.delayed(const Duration(milliseconds: 800));

//     /// ✅ RETRY EMIT (NOT FUNCTION CALL)
//     dLog("🟡 BG → retry emit reject");

//     PatientCallSocketHandler.instance.emitRejectCall(
//       appointmentId: appointmentId,
//     );

//     await Future.delayed(const Duration(milliseconds: 600));

//     dLog("🟡 BG → dispose socket");

//     PatientCallSocketHandler.instance.disposeSocket();

//     dLog("🟢 BG → reject flow DONE");
//   } catch (e, s) {
//     dLog("❌ BG reject error: $e");
//     dLog("📄 BG reject stack: $s");
//   }
// }

// /// ================= BACKGROUND FCM =================
// @pragma('vm:entry-point')
// Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );

//   if (message.data['type'] == "CALL_CANCELLED") {
//     await AwesomeNotifications().cancelAll();
//     return;
//   }

//   final meta = message.data['meta'];
//   if (meta == null || !meta.toString().contains('Calling')) return;

//   await AwesomeNotifications().createNotification(
//     content: NotificationContent(
//       id: 1001,
//       channelKey: 'call_channel',
//       title: 'Incoming Call',
//       body: 'Doctor is calling you',
//       category: NotificationCategory.Call,
//       wakeUpScreen: true,
//       fullScreenIntent: true,
//       locked: true,
//       payload: stringifyPayload(message.data),
//     ),
//     actionButtons: [
//       NotificationActionButton(
//         key: 'ACCEPT_CALL',
//         label: 'Accept',
//         color: Colors.green,
//       ),
//     NotificationActionButton(
//   key: 'DECLINE_CALL',
//   label: 'Decline',
//   color: Colors.red,
//   isDangerousOption: true,
//   actionType: ActionType.SilentBackgroundAction,
// ),

//     ],
//   );
// }

// /// ================= MAIN =================
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   debugPrint('🟢 main(): WidgetsFlutterBinding initialized');

//   // Mobile Ads
//   try {
//     await MobileAds.instance.initialize();
//     debugPrint('🟢 main(): MobileAds initialized');
//   } catch (e) {
//     debugPrint('🔴 main(): MobileAds init failed → $e');
//   }

//   // Awesome Notifications
//   try {
//     await AwesomeNotifications().initialize(
//       null,
//       [
//         NotificationChannel(
//           channelKey: 'call_channel',
//           channelName: 'Incoming Calls',
//           importance: NotificationImportance.Max,
//           locked: true,
//           channelDescription: 'Doctor calling notifications',
//         ),
//       ],
//     );
//     debugPrint('🟢 main(): AwesomeNotifications initialized');
//   } catch (e) {
//     debugPrint('🔴 main(): AwesomeNotifications init failed → $e');
//   }

//   // Firebase
//   try {
//     await Firebase.initializeApp(
//       options: DefaultFirebaseOptions.currentPlatform,
//     );
//     debugPrint('🟢 main(): Firebase initialized');
//   } catch (e) {
//     debugPrint('🔴 main(): Firebase init failed → $e');
//   }

//   // FCM background handler
//   try {
//     FirebaseMessaging.onBackgroundMessage(
//       firebaseMessagingBackgroundHandler,
//     );
//     debugPrint('🟢 main(): Firebase background handler registered');
//   } catch (e) {
//     debugPrint('🔴 main(): FCM background handler failed → $e');
//   }

//   debugPrint('🟡 main(): Starting app with DisplayMetrics');

//   runApp(
//     DisplayMetrics(
//       data: DisplayMetricsData(
//         displays: const [],
//       ),
//       child: const EyeBuddyApp(),
//     ),
//   );

//   debugPrint('🟢 main(): runApp called successfully');
// }

// /// ================= APP =================
// class EyeBuddyApp extends StatefulWidget {
//   const EyeBuddyApp({super.key});

//   @override
//   State<EyeBuddyApp> createState() => _EyeBuddyAppState();
// }

// class _EyeBuddyAppState extends State<EyeBuddyApp> {

//   @override
//   void initState() {
//     super.initState();

//     _restoreLocale();
//     _setupAwesomeListener();
//     _setupForegroundFCM();
//     _setupTerminatedFCM();
//     _handleKilledAwesomeAction();
//     _ensureAndroidFullScreenIntentPermission();
//   }

//   /// ================= ANDROID FULLSCREEN =================
//   Future<void> _ensureAndroidFullScreenIntentPermission() async {
//     if (!Platform.isAndroid) return;

//     try {
//       final can = await FlutterCallkitIncoming.canUseFullScreenIntent();
//       if (can == false) {
//         await FlutterCallkitIncoming.requestFullIntentPermission();
//       }
//     } catch (_) {}
//   }

//   /// ================= AWESOME LISTENER =================
//   void _setupAwesomeListener() {
//     AwesomeNotifications().setListeners(
//       onActionReceivedMethod: (action) async {

//         final payload = action.payload ?? {};

//         /// ===== DECLINE =====
//         if (action.buttonKeyPressed == 'DECLINE_CALL') {

//           String? appointmentId;

//           try {
//             final meta = jsonDecode(payload['meta'] ?? '{}');
//             appointmentId = meta['metaData']?['_id'];
//           } catch (_) {}

//           if (appointmentId != null) {
//             await backgroundRejectCall(appointmentId);
//           }

//           await AwesomeNotifications().cancel(action.id!);
//           return;
//         }

//         /// ===== ACCEPT =====
//         if (action.buttonKeyPressed == 'ACCEPT_CALL' ||
//             action.buttonKeyPressed.isEmpty) {

//           await AwesomeNotifications().cancel(action.id!);

//           WidgetsBinding.instance.addPostFrameCallback((_) {
//             _openCallFromPayload(
//               payload.map((k, v) => MapEntry(k, v.toString())),
//               autoAccept: action.buttonKeyPressed == 'ACCEPT_CALL',
//             );
//           });
//         }
//       },
//     );
//   }

//   /// ================= FOREGROUND =================
//   void _setupForegroundFCM() {

//     FirebaseMessaging.onMessage.listen((message) async {

//       if (message.data['type'] == "CALL_CANCELLED") {
//         await AwesomeNotifications().cancelAll();
//         return;
//       }

//       final meta = message.data['meta'];
//       if (meta == null || !meta.toString().contains('Calling')) return;

//       await AwesomeNotifications().createNotification(
//         content: NotificationContent(
//           id: 1002,
//           channelKey: 'call_channel',
//           title: 'Incoming Call',
//           body: 'Doctor is calling you',
//           category: NotificationCategory.Call,
//           payload: stringifyPayload(message.data),
//         ),
//         actionButtons: [
//           NotificationActionButton(
//             key: 'ACCEPT_CALL',
//             label: 'Accept',
//             color: Colors.green,
//           ),
//         NotificationActionButton(
//   key: 'DECLINE_CALL',
//   label: 'Decline',
//   color: Colors.red,
//   isDangerousOption: true,
//   actionType: ActionType.SilentBackgroundAction,
// ),

//         ],
//       );

//       _openCallFromPayload(stringifyPayload(message.data));
//     });
//   }

//   /// ================= TERMINATED FCM =================
//   void _setupTerminatedFCM() async {

//     final message =
//         await FirebaseMessaging.instance.getInitialMessage();

//     if (message == null) return;

//     final meta = message.data['meta'] ?? '';
//     if (!meta.toString().contains('Calling')) return;

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _openCallFromPayload(stringifyPayload(message.data));
//     });
//   }

//   /// ================= TERMINATED AWESOME =================
//   void _handleKilledAwesomeAction() async {

//     final action =
//         await AwesomeNotifications().getInitialNotificationAction(
//       removeFromActionEvents: true,
//     );

//     if (action == null) return;
//     if (action.buttonKeyPressed == 'DECLINE_CALL') return;

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _openCallFromPayload(
//         action.payload!.map((k, v) => MapEntry(k, v.toString())),
//         autoAccept: action.buttonKeyPressed == 'ACCEPT_CALL',
//       );
//     });
//   }

//   /// ================= OPEN CALL =================
//   Future<void> _openCallFromPayload(
//     Map<String, String> payload, {
//     bool autoAccept = false,
//   }) async {

//     try {
//       String? channelId;
//       String? token;
//       String? doctorName;
//       String? doctorPhoto;

//       if (payload['meta'] != null && payload['meta']!.isNotEmpty) {
//         final meta = jsonDecode(payload['meta']!);
//         final metaData = meta['metaData'];

//         channelId = metaData['_id'];
//         token = metaData['patientAgoraToken'];

//         final doctor = metaData['doctor'];
//         doctorName = doctor?['name'];
//         doctorPhoto = doctor?['photo'];
//       }

//       final prefs = await SharedPreferences.getInstance();

//       channelId ??= prefs.getString('agora_channel_id');
//       token ??= prefs.getString('patient_agora_token');
//       doctorName ??= prefs.getString('doctor_name') ?? 'Doctor';
//       doctorPhoto ??= prefs.getString('doctor_photo') ?? '';

//       if (channelId == null || token == null) return;

//       Get.to(() => PatientCallScreen(
//         channelId: channelId!,
//         token: token!,
//         doctorName: doctorName!,
//         doctorPhoto: doctorPhoto!,
//         autoAccept: autoAccept,
//       ));

//     } catch (e) {
//       dLog('CALL OPEN ERROR $e');
//     }
//   }

//   /// ================= LOCALE =================
//   Future<void> _restoreLocale() async {
//     final prefs = await SharedPreferences.getInstance();
//     final saved = prefs.getString(languagePrefsKey) ?? 'en';
//     Get.updateLocale(Locale(saved));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: CustomTheme.lightTheme,
//       locale: Get.locale,
//       fallbackLocale: const Locale('en'),
//       home: const SplashScreen(),
//       getPages: [
//         GetPage(
//           name: '/appointment-overview',
//           page: () => const AppointmentOverviewScreen(),
//         ),
//         GetPage(
//           name: '/payment-gateway',
//           page: () => const PaymentGatewayScreen(),
//         ),
//         GetPage(
//           name: '/waiting-for-doctor',
//           page: () => const WaitingForDoctorScreen(),
//         ),
//       ],
//       localizationsDelegates: const [
//         AppLocalizations.delegate,
//         GlobalMaterialLocalizations.delegate,
//         GlobalWidgetsLocalizations.delegate,
//         GlobalCupertinoLocalizations.delegate,
//       ],
//       supportedLocales: AppLocalizations.supportedLocales,
//     );
//   }
// }

// crashfixeyestes
import 'dart:async';
import 'dart:developer' as developer;
import 'dart:convert';
import 'dart:io';

import 'package:display_metrics/display_metrics.dart';
import 'package:eye_buddy/core/services/utils/handlers/PatientCallSocketHandler.dart';
import 'package:eye_buddy/features/reason_for_visit/view/appointment_overview_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'dart:ui';

import 'package:eye_buddy/firebase_options.dart'
    if (dart.library.html) 'package:eye_buddy/firebase_options_web.dart';

import 'package:eye_buddy/features/agora_call/view/PatientAgoraCallScreen.dart';
import 'package:eye_buddy/core/services/utils/config/theme.dart';
import 'package:eye_buddy/core/services/utils/keys/shared_pref_keys.dart';
import 'package:eye_buddy/l10n/app_localizations.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:eye_buddy/features/splash/view/splash_screen.dart';
import 'package:eye_buddy/features/payment_gateway/view/payment_gateway_screen.dart';
import 'package:eye_buddy/features/waiting_for_doctor/view/waiting_for_doctor_screen.dart';

import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';

// ✅ EyeTest imports
import 'package:eye_buddy/features/eye_test/controller/eye_test_controller.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:eye_buddy/core/services/utils/keys/token_keys.dart';
import 'dart:convert';

/// Helper to extract the actual appointment map from your nested meta string ONLY FOR IOS
Map<String, dynamic> _getAppointmentData(Map<String, dynamic>? body) {
  try {
    if (body == null || body['extra'] == null) return {};

    // In your new object, the data is a JSON string inside 'meta'
    final String? metaString = body['extra']['meta'];
    if (metaString != null && metaString.isNotEmpty) {
      return jsonDecode(metaString);
    }
  } catch (e) {
    dLog('❌ Error parsing meta JSON: $e');
  }
  return {};
}

void dLog(String msg) {
  if (kDebugMode) developer.log(msg);
}

void log(String message, {Object? error, StackTrace? stackTrace}) {
  if (!kDebugMode) return;
  developer.log(message, error: error, stackTrace: stackTrace);
}

void dPrint(Object? message) {
  if (!kDebugMode) return;
  // ignore: avoid_print
  print(message);
}

void _handleCatch(String context, Object error, StackTrace stackTrace) {
  log('ERROR[$context]: $error', error: error, stackTrace: stackTrace);
  if (kDebugMode) {
    Error.throwWithStackTrace(error, stackTrace);
  }
}

Map<String, String> stringifyPayload(Map<String, dynamic> data) {
  return data.map((k, v) => MapEntry(k, v?.toString() ?? ''));
}

/// ================= BACKGROUND SOCKET REJECT =================

Future<void> backgroundRejectCall(String appointmentId) async {
  try {
    dLog("🟡 BG → START reject flow");
    dLog("🟡 BG → appointmentId: $appointmentId");

    final completer = Completer<void>();

    dLog("🟡 BG → init socket start");

    await PatientCallSocketHandler.instance.initSocket(
      appointmentId: appointmentId,
      onConnected: () {
        dLog("✅ BG → Socket CONNECTED");
        if (!completer.isCompleted) completer.complete();
      },
      onJoinedEvent: (data) {
        dLog("🟢 BG Socket → onJoinedEvent $data");
      },
      onRejectedEvent: (data) {
        dLog("🔴 BG Socket → onRejectedEvent $data");
      },
      onEndedEvent: (data) {
        dLog("⚫ BG Socket → onEndedEvent $data");
      },
      onError: (err) {
        dLog("❌ BG Socket ERROR → $err");
        if (!completer.isCompleted) completer.complete();
      },
    );

    dLog("🟡 BG → socket init done, waiting connect...");

    try {
      await completer.future.timeout(const Duration(seconds: 3));
      dLog("🟢 BG → Socket ready");
    } catch (_) {
      dLog("⚠ BG → Socket connect timeout");
    }

    await Future.delayed(const Duration(milliseconds: 400));

    dLog("🟡 BG → emitting reject call");

    PatientCallSocketHandler.instance.emitRejectCall(
      appointmentId: appointmentId,
    );

    dLog("🟡 BG → reject emitted");

    await Future.delayed(const Duration(milliseconds: 800));

    /// ✅ RETRY EMIT
    dLog("🟡 BG → retry emit reject");

    PatientCallSocketHandler.instance.emitRejectCall(
      appointmentId: appointmentId,
    );

    await Future.delayed(const Duration(milliseconds: 600));

    dLog("🟡 BG → dispose socket");

    PatientCallSocketHandler.instance.disposeSocket();

    dLog("🟢 BG → reject flow DONE");
  } catch (e, s) {
    dLog("❌ BG reject error: $e");
    dLog("📄 BG reject stack: $s");
  }
}

/// ================= BACKGROUND FCM =================
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (message.data['type'] == "CALL_CANCELLED") {
    await AwesomeNotifications().cancelAll();
    return;
  }

  final meta = message.data['meta'];
  if (meta == null || !meta.toString().contains('Calling')) return;

  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: 1001,
      channelKey: 'call_channel',
      title: 'Incoming Call',
      body: 'Doctor is calling you',
      category: NotificationCategory.Call,
      wakeUpScreen: true,
      fullScreenIntent: true,
      locked: true,
      payload: stringifyPayload(message.data),
    ),
    actionButtons: [
      NotificationActionButton(
        key: 'ACCEPT_CALL',
        label: 'Accept',
        color: Colors.green,
      ),
      NotificationActionButton(
        key: 'DECLINE_CALL',
        label: 'Decline',
        color: Colors.red,
        isDangerousOption: true,
        actionType: ActionType.SilentBackgroundAction,
      ),
    ],
  );
}

/// ================= MAIN =================
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('🟢 main(): WidgetsFlutterBinding initialized');

  // Mobile Ads
  try {
    await MobileAds.instance.initialize();
    debugPrint('🟢 main(): MobileAds initialized');
  } catch (e) {
    debugPrint('🔴 main(): MobileAds init failed → $e');
  }

  // Awesome Notifications
  try {
    await AwesomeNotifications().initialize(null, [
      NotificationChannel(
        channelKey: 'call_channel',
        channelName: 'Incoming Calls',
        importance: NotificationImportance.Max,
        locked: true,
        channelDescription: 'Doctor calling notifications',
      ),
    ]);
    debugPrint('🟢 main(): AwesomeNotifications initialized');
  } catch (e) {
    debugPrint('🔴 main(): AwesomeNotifications init failed → $e');
  }

  Future<void> requestNotificationPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');

    // You can check the status to tailor the user experience
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('Permission granted');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('Provisional permission granted (notifications shown quietly)');
    } else {
      print('Permission denied');
    }
  }

  // Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await requestNotificationPermission();
    final String? fcmToken = await FirebaseMessaging.instance.getToken();
    print(fcmToken);

    if (Platform.isIOS) {
      try {
        final voipToken = await FlutterCallkitIncoming.getDevicePushTokenVoIP();
        if (voipToken != null && voipToken.toString().trim().isNotEmpty) {
          voipDeviceToken = voipToken.toString().trim();
        }
        dPrint('[TOKEN] VoIP token: $voipToken');
        log('[TOKEN] VoIP token: $voipToken');
        if (voipDeviceToken.isEmpty) {
          Future.delayed(const Duration(seconds: 4), () async {
            try {
              final retryToken =
                  await FlutterCallkitIncoming.getDevicePushTokenVoIP();
              if (retryToken != null &&
                  retryToken.toString().trim().isNotEmpty) {
                voipDeviceToken = retryToken.toString().trim();
                dPrint('[TOKEN] VoIP token retry: $retryToken');
                log('[TOKEN] VoIP token retry: $retryToken');
              }
            } catch (e, st) {
              _handleCatch('ios.voipTokenRetry', e, st);
            }
          });
        }
      } catch (e, st) {
        _handleCatch('ios.voipToken', e, st);
      }
    }
    debugPrint('🟢 main(): Firebase initialized');
  } catch (e) {
    debugPrint('🔴 main(): Firebase init failed → $e');
  }

  // FCM background handler
  try {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    debugPrint('🟢 main(): Firebase background handler registered');
  } catch (e) {
    debugPrint('🔴 main(): FCM background handler failed → $e');
  }

  debugPrint('🟡 main(): Starting app with DisplayMetrics');

  // ✅ Proper DisplayMetrics integration
  runApp(DisplayMetricsWidget(child: const EyeBuddyApp()));

  debugPrint('🟢 main(): runApp called successfully');
}

// /// ================= CALLKIT DECLINE HANDLER =================
// void _handleCallKitDecline(Map<String, dynamic>? body) async {
//   try {
//     dLog('🚫 CALLKIT: Declining call...');

//     // Extract appointment ID from CallKit body
//     String appointmentId = '';
//     if (body != null) {
//       appointmentId =
//           (body['extra']?['appointmentId'] ?? body['id'] ?? body['uuid'] ?? '')
//               .toString();
//     }

//     if (appointmentId.isNotEmpty) {
//       dLog('📞 CALLKIT: Rejecting appointment: $appointmentId');
//       await backgroundRejectCall(appointmentId);
//     }

//     // Clear any pending call UI
//     await AwesomeNotifications().cancelAll();
//   } catch (e) {
//     dLog('❌ CALLKIT: Decline error - $e');
//   }
// }

// /// ================= CALLKIT END HANDLER =================
// void _handleCallKitEnd(Map<String, dynamic>? body) async {
//   try {
//     dLog('🔚 CALLKIT: Ending call...');

//     // Clear any notifications
//     await AwesomeNotifications().cancelAll();

//     // Clear call state from prefs
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('isCallAccepted', false);
//     await prefs.setBool('pendingIncomingCallOpen', false);

//     dLog('✅ CALLKIT: Call ended successfully');
//   } catch (e) {
//     dLog('❌ CALLKIT: End error - $e');
//   }
// }

// /// ================= CALLKIT ACCEPT HANDLER =================
// void _handleCallKitAccept(Map<String, dynamic>? body) async {
//   try {
//     dLog('🔗 CALLKIT: Connecting call...');

//     // Extract appointment ID from CallKit body
//     String appointmentId = '';
//     if (body != null) {
//       appointmentId =
//           (body['extra']?['appointmentId'] ?? body['id'] ?? body['uuid'] ?? '')
//               .toString();
//     }

//     if (appointmentId.isEmpty) {
//       dLog('❌ CALLKIT: No appointment ID found');
//       return;
//     }

//     dLog('📞 CALLKIT: Connecting to appointment: $appointmentId');

//     // Fetch token from SharedPreferences
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('patient_agora_token');
//     final channelId = prefs.getString('agora_channel_id');

//     dLog(
//       '🔑 CALLKIT: Token found: ${token?.isNotEmpty == true ? "YES" : "NO"}',
//     );
//     dLog(
//       '📺 CALLKIT: Channel found: ${channelId?.isNotEmpty == true ? "YES" : "NO"}',
//     );

//     // Navigate to existing call screen using EyeBuddyApp instance
//     if (Get.context != null) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         // Find the app state and call the existing method
//         final appState = Get.context
//             ?.findAncestorStateOfType<_EyeBuddyAppState>();
//         appState?._openCallFromPayload({
//           'meta': jsonEncode({
//             'metaData': {
//               '_id': appointmentId,
//               'patientAgoraToken': token ?? '',
//               'doctor': {'name': 'Doctor'},
//             },
//           }),
//         }, autoAccept: true);
//       });
//     }
//   } catch (e) {
//     dLog('❌ CALLKIT: Accept error - $e');
//   }
// }

void _handleCallKitDecline(Map<String, dynamic>? body) async {
  try {
    dLog('🚫 CALLKIT: Declining call...');

    final appointmentData = _getAppointmentData(body);
    // Use the real database _id from the parsed meta
    final String appointmentId = (appointmentData['_id'] ?? '').toString();

    if (appointmentId.isNotEmpty) {
      dLog('📞 CALLKIT: Rejecting appointment: $appointmentId');
      await backgroundRejectCall(appointmentId);
    }

    await AwesomeNotifications().cancelAll();
  } catch (e) {
    dLog('❌ CALLKIT: Decline error - $e');
  }
}

void _handleCallKitAccept(Map<String, dynamic>? body) async {
  try {
    dLog('🔗 CALLKIT: Connecting call...');

    final appointmentData = _getAppointmentData(body);

    // Extracting real values directly from the parsed meta object
    final String appointmentId = (appointmentData['_id'] ?? '').toString();
    final String token = (appointmentData['patientAgoraToken'] ?? '')
        .toString();
    final String doctorName = (appointmentData['doctor']?['name'] ?? 'Doctor')
        .toString();
    final String doctorPhoto = (appointmentData['doctor']?['photo'] ?? '')
        .toString();

    if (appointmentId.isEmpty) {
      dLog('❌ CALLKIT: No appointment ID found in meta');
      return;
    }

    dLog('📞 CALLKIT: Data extracted from Meta for ID: $appointmentId');

    if (Get.context != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final appState = Get.context
            ?.findAncestorStateOfType<_EyeBuddyAppState>();

        // We pass the data exactly how your _openCallFromPayload expects it
        appState?._openCallFromPayload({
          'meta': jsonEncode({
            'metaData': {
              '_id': appointmentId,
              'patientAgoraToken': token,
              'doctor': {'name': doctorName, 'photo': doctorPhoto},
            },
          }),
        }, autoAccept: true);
      });
    }
  } catch (e) {
    dLog('❌ CALLKIT: Accept error - $e');
  }
}

void _handleCallKitEnd(Map<String, dynamic>? body) async {
  try {
    dLog('🔚 CALLKIT: Ending call...');
    await AwesomeNotifications().cancelAll();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isCallAccepted', false);
    await prefs.setBool('pendingIncomingCallOpen', false);
  } catch (e) {
    dLog('❌ CALLKIT: End error - $e');
  }
}

/// ================= CALLKIT LISTENER =================
void _setupCallKitListener() {
  if (!Platform.isIOS) return;

  FlutterCallkitIncoming.onEvent.listen((event) {
    if (event == null) return;

    final eventName = event.event.toString();
    final body = event.body;

    dLog('📱 CALLKIT EVENT: $eventName');
    dLog('📱 CALLKIT BODY: $body');

    // Handle accept
    if (eventName.contains('actionCallAccept')) {
      dLog('✅ CALLKIT: Call accepted');
      _handleCallKitAccept(body);
    }

    // Handle decline
    if (eventName.contains('actionCallDecline')) {
      dLog('❌ CALLKIT: Call declined');
      _handleCallKitDecline(body);
    }

    // Handle end
    if (eventName.contains('actionCallEnded') ||
        eventName.contains('actionCallTimeout')) {
      dLog('🔚 CALLKIT: Call ended');
      _handleCallKitEnd(body);
    }
  });

  dLog('📱 CALLKIT: Listener setup complete');
}

/// ================= APP =================
class EyeBuddyApp extends StatefulWidget {
  const EyeBuddyApp({super.key});

  @override
  State<EyeBuddyApp> createState() => _EyeBuddyAppState();
}

class _EyeBuddyAppState extends State<EyeBuddyApp> {
  @override
  void initState() {
    super.initState();

    _restoreLocale();
    _setupAwesomeListener();
    _setupForegroundFCM();
    _setupTerminatedFCM();
    _setupCallKitListener();
    _handleKilledAwesomeAction();
    _ensureAndroidFullScreenIntentPermission();

    // ✅ Register EyeTestController (Lazy Put)
    if (!Get.isRegistered<EyeTestController>()) {
      Get.lazyPut(() => EyeTestController(), fenix: true);
      dLog("🧠 EyeTestController registered (lazy, fenix:true)");
    }
  }

  /// ================= ANDROID FULLSCREEN =================
  Future<void> _ensureAndroidFullScreenIntentPermission() async {
    if (!Platform.isAndroid) return;

    try {
      final can = await FlutterCallkitIncoming.canUseFullScreenIntent();
      if (can == false) {
        await FlutterCallkitIncoming.requestFullIntentPermission();
      }
    } catch (_) {}
  }

  /// ================= AWESOME LISTENER =================
  void _setupAwesomeListener() {
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: (action) async {
        final payload = action.payload ?? {};

        /// ===== DECLINE =====
        if (action.buttonKeyPressed == 'DECLINE_CALL') {
          String? appointmentId;

          try {
            final meta = jsonDecode(payload['meta'] ?? '{}');
            appointmentId = meta['metaData']?['_id'];
          } catch (_) {}

          if (appointmentId != null) {
            await backgroundRejectCall(appointmentId);
          }

          await AwesomeNotifications().cancel(action.id!);
          return;
        }

        /// ===== ACCEPT =====
        if (action.buttonKeyPressed == 'ACCEPT_CALL' ||
            action.buttonKeyPressed.isEmpty) {
          await AwesomeNotifications().cancel(action.id!);

          WidgetsBinding.instance.addPostFrameCallback((_) {
            _openCallFromPayload(
              payload.map((k, v) => MapEntry(k, v.toString())),
              autoAccept: action.buttonKeyPressed == 'ACCEPT_CALL',
            );
          });
        }
      },
    );
  }

  /// ================= FOREGROUND =================
  void _setupForegroundFCM() {
    FirebaseMessaging.onMessage.listen((message) async {
      print("New Message on forground");
      if (message.data['type'] == "CALL_CANCELLED") {
        await AwesomeNotifications().cancelAll();
        return;
      }

      final meta = message.data['meta'];
      debugPrint("received incomming call");
      if (meta == null || !meta.toString().contains('Calling')) return;

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 1002,
          channelKey: 'call_channel',
          title: 'Incoming Call',
          body: 'Doctor is calling you',
          category: NotificationCategory.Call,
          payload: stringifyPayload(message.data),
        ),
        actionButtons: [
          NotificationActionButton(
            key: 'ACCEPT_CALL',
            label: 'Accept',
            color: Colors.green,
          ),
          NotificationActionButton(
            key: 'DECLINE_CALL',
            label: 'Decline',
            color: Colors.red,
            isDangerousOption: true,
            actionType: ActionType.SilentBackgroundAction,
          ),
        ],
      );
      if (Platform.isAndroid) {
        _openCallFromPayload(stringifyPayload(message.data));
      }
    });
  }

  /// ================= TERMINATED FCM =================
  void _setupTerminatedFCM() async {
    final message = await FirebaseMessaging.instance.getInitialMessage();

    if (message == null) return;

    final meta = message.data['meta'] ?? '';
    if (!meta.toString().contains('Calling')) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openCallFromPayload(stringifyPayload(message.data));
    });
  }

  /// ================= TERMINATED AWESOME =================
  void _handleKilledAwesomeAction() async {
    final action = await AwesomeNotifications().getInitialNotificationAction(
      removeFromActionEvents: true,
    );

    if (action == null) return;
    if (action.buttonKeyPressed == 'DECLINE_CALL') return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openCallFromPayload(
        action.payload!.map((k, v) => MapEntry(k, v.toString())),
        autoAccept: action.buttonKeyPressed == 'ACCEPT_CALL',
      );
    });
  }

  /// ================= OPEN CALL =================
  Future<void> _openCallFromPayload(
    Map<String, String> payload, {
    bool autoAccept = false,
  }) async {
    try {
      String? channelId;
      String? token;
      String? doctorName;
      String? doctorPhoto;

      if (payload['meta'] != null && payload['meta']!.isNotEmpty) {
        final meta = jsonDecode(payload['meta']!);
        final metaData = meta['metaData'];

        channelId = metaData['_id'];
        token = metaData['patientAgoraToken'];

        final doctor = metaData['doctor'];
        doctorName = doctor?['name'];
        doctorPhoto = doctor?['photo'];
      }

      final prefs = await SharedPreferences.getInstance();

      channelId ??= prefs.getString('agora_channel_id');
      token ??= prefs.getString('patient_agora_token');
      doctorName ??= prefs.getString('doctor_name') ?? 'Doctor';
      doctorPhoto ??= prefs.getString('doctor_photo') ?? '';

      if (channelId == null || token == null) return;

      Get.to(
        () => PatientCallScreen(
          channelId: channelId!,
          token: token!,
          doctorName: doctorName!,
          doctorPhoto: doctorPhoto!,
          autoAccept: autoAccept,
        ),
      );
    } catch (e) {
      dLog('CALL OPEN ERROR $e');
    }
  }

  /// ================= LOCALE =================
  Future<void> _restoreLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(languagePrefsKey) ?? 'en';
    Get.updateLocale(Locale(saved));
  }

  @override
  Widget build(BuildContext context) {
    return DisplayMetricsWidget(
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        theme: CustomTheme.lightTheme,
        locale: Get.locale,
        fallbackLocale: const Locale('en'),
        home: const SplashScreen(),
        getPages: [
          GetPage(
            name: '/appointment-overview',
            page: () => const AppointmentOverviewScreen(),
          ),
          GetPage(
            name: '/payment-gateway',
            page: () => const PaymentGatewayScreen(),
          ),
          GetPage(
            name: '/waiting-for-doctor',
            page: () => const WaitingForDoctorScreen(),
          ),

          // ✅ Added EyeTest route
          // GetPage(
          //   name: '/eye-test',
          //   page: () => const EyeTestScreen(),
          // ),
        ],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
  }
}
