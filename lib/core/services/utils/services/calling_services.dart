// // ignore_for_file: depend_on_referenced_packages

// import 'dart:developer' as developer;
// import 'dart:math';

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_callkit_incoming/entities/android_params.dart';
// import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
// import 'package:flutter_callkit_incoming/entities/ios_params.dart';
// import 'package:flutter_callkit_incoming/entities/notification_params.dart';
// import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
// import 'package:get/get.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import '../../api/service/api_constants.dart';
// import '../../../../features/agora_call/controller/call_controller.dart';
// import '../../../../features/agora_call/view/agora_call_room_screen.dart';
// import '../handlers/agora_call_socket_handler.dart';
// import '../keys/shared_pref_keys.dart';

// void log(String message, {Object? error, StackTrace? stackTrace}) {
//   if (!kDebugMode) return;
//   developer.log(message, error: error, stackTrace: stackTrace);
// }

// class CallService {
//   static final CallService _instance = CallService._internal();
//   factory CallService() => _instance;
//   CallService._internal();

//   bool _isAppInForeground() {
//     try {
//       final state = WidgetsBinding.instance.lifecycleState;
//       // Treat only `resumed` as foreground. When the phone is locked, many
//       // devices report the app as `inactive` briefly; if we treat that as
//       // foreground we will skip CallKit and the user sees no incoming UI.
//       return state == AppLifecycleState.resumed;
//     } catch (_) {
//       return false;
//     }
//   }

//   final AgoraCallSocketHandler _socketHandler = AgoraCallSocketHandler();
//   String _currentAppointmentId = '';
//   String _currentCallKitId = '';
//   String _currentName = '';
//   String? _currentImage = '';
//   String _currentAppointmentType = '';

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

//   String _newUuidV4() {
//     final rng = Random.secure();
//     final bytes = List<int>.generate(16, (_) => rng.nextInt(256));
//     bytes[6] = (bytes[6] & 0x0f) | 0x40;
//     bytes[8] = (bytes[8] & 0x3f) | 0x80;
//     final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
//     return '${hex.substring(0, 8)}-'
//         '${hex.substring(8, 12)}-'
//         '${hex.substring(12, 16)}-'
//         '${hex.substring(16, 20)}-'
//         '${hex.substring(20)}';
//   }

//   String _resolveCallKitId(String appointmentId) {
//     final trimmed = appointmentId.trim();
//     if (_looksLikeUuid(trimmed)) return trimmed;
//     if (trimmed.isNotEmpty &&
//         trimmed == _currentAppointmentId &&
//         _looksLikeUuid(_currentCallKitId)) {
//       return _currentCallKitId;
//     }
//     return _newUuidV4();
//   }

//   Future<void> _endCallKitSafely({String? callKitId}) async {
//     final id = (callKitId ?? '').trim();
//     if (_looksLikeUuid(id)) {
//       try {
//         await FlutterCallkitIncoming.endCall(id);
//       } catch (_) {
//         // ignore
//       }
//     }
//     try {
//       await FlutterCallkitIncoming.endAllCalls();
//     } catch (_) {
//       // ignore
//     }
//   }

//   Future<bool> _canReceiveCallForAppointment(String appointmentId) async {
//     try {
//       if (appointmentId.trim().isEmpty) return false;
//       final prefs = await SharedPreferences.getInstance();
//       final pastIds = prefs.getStringList('past_appointment_ids') ?? const [];
//       if (pastIds.contains(appointmentId)) return false;

//       final prescribedIds =
//           prefs.getStringList('prescribed_appointment_ids') ?? const [];
//       if (prescribedIds.contains(appointmentId)) return false;

//       // Requirement: allow calls as long as appointment is not past.
//       // Do not block based on active list because it can be stale.
//       return true;
//     } catch (e) {
//       log('CALL SERVICE: _canReceiveCallForAppointment error: $e');
//       return true;
//     }
//   }

//   Future<void> showIncomingCall({
//     required String name,
//     required String? image,
//     required String appointmentId,
//     String? appointmentType,
//     BuildContext? context,
//   }) async {
//     try {
//       if (kDebugMode) {
//         debugPrint(
//           'CALL SERVICE(DEBUG): showIncomingCall name=$name appointmentId=$appointmentId',
//         );
//       }
//       final canReceive = await _canReceiveCallForAppointment(appointmentId);
//       if (!canReceive) {
//         log(
//           'CALL SERVICE: Ignoring incoming call because appointment is past/not-active: $appointmentId',
//         );
//         return;
//       }

//       final callKitId = _resolveCallKitId(appointmentId);

//       // Defensive: clear any stale CallKit sessions before showing a new one.
//       // This helps when the same appointment rings multiple times.
//       await _endCallKitSafely(callKitId: callKitId);

//       log(
//         'CALL SERVICE: Showing incoming call for appointment: $appointmentId',
//       );

//       _currentAppointmentId = appointmentId;
//       _currentCallKitId = callKitId;
//       _currentName = name;
//       _currentImage = image;
//       _currentAppointmentType = (appointmentType ?? '').trim();

//       // Foreground UX: do not show CallKit when app is already open.
//       // It causes system ringtone to start (double ring) and can produce MediaPlayer errors.
//       if (_isAppInForeground()) {
//         try {
//           if (Get.isRegistered<CallController>()) {
//             CallController.to.showIncomingCall(
//               appointmentId: appointmentId,
//               callKitId: callKitId,
//               doctorName: name,
//               doctorPhoto: image,
//             );
//           }
//         } catch (_) {
//           // ignore
//         }
//         return;
//       }

//       // Pre-connect socket early so we can join the appointment room as soon as possible.
//       // This reduces the race where doctor cancels before patient has joined the room.
//       try {
//         _socketHandler.preconnect();
//       } catch (_) {
//         // ignore
//       }

//       // Store call data in shared preferences
//       await _storeCallData(
//         name: name,
//         image: image,
//         appointmentId: appointmentId,
//         appointmentType: _currentAppointmentType,
//         callKitId: callKitId,
//       );

//       // Initialize socket connection FIRST (join room ASAP)
//       await _initializeSocket(appointmentId);

//       // Show CallKit incoming call
//       await _showCallKitIncoming(
//         name: name,
//         appointmentId: appointmentId,
//         appointmentType: _currentAppointmentType,
//         callKitId: callKitId,
//       );
//     } catch (e) {
//       log('CALL SERVICE ERROR: Failed to show incoming call - $e');
//     }
//   }

//   Future<void> _storeCallData({
//     required String name,
//     required String? image,
//     required String appointmentId,
//     required String appointmentType,
//     required String callKitId,
//   }) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setString(SharedPrefKeys.incomingCallName, name);
//       await prefs.setString(
//         SharedPrefKeys.incomingCallAppointmentId,
//         appointmentId,
//       );
//       if (callKitId.trim().isNotEmpty) {
//         await prefs.setString(SharedPrefKeys.incomingCallCallKitId, callKitId);
//       } else {
//         await prefs.remove(SharedPrefKeys.incomingCallCallKitId);
//       }
//       if (image != null) {
//         await prefs.setString(SharedPrefKeys.incomingCallImage, image);
//       }
//       if (appointmentType.trim().isNotEmpty) {
//         await prefs.setString(SharedPrefKeys.incomingCallType, appointmentType);
//       } else {
//         await prefs.remove(SharedPrefKeys.incomingCallType);
//       }
//       log('CALL SERVICE: Call data stored in preferences');
//     } catch (e) {
//       log('CALL SERVICE ERROR: Failed to store call data - $e');
//     }
//   }

//   Future<void> _showCallKitIncoming({
//     required String name,
//     required String appointmentId,
//     required String appointmentType,
//     required String callKitId,
//   }) async {
//     try {
//       log('CALL SERVICE: Showing CallKit incoming call');

//       final avatarUrl = _resolveAvatarUrl(_currentImage);
//       final handleLabel =
//           appointmentType.trim().isNotEmpty ? appointmentType.trim() : 'Appointment';
//       final callKitParams = CallKitParams(
//         id: callKitId,
//         nameCaller: name,
//         appName: 'Eye Buddy',
//         avatar: avatarUrl,
//         // Shown on the system banner/notification (avoid showing raw appointmentId).
//         handle: handleLabel,
//         type: 0,
//         duration: 30000,
//         textAccept: 'Accept',
//         textDecline: 'Decline',
//         missedCallNotification: NotificationParams(
//           showNotification: true,
//           isShowCallback: false,
//           subtitle: 'Missed call from $name',
//           callbackText: 'Call back',
//         ),
//         extra: <String, dynamic>{
//           'appointmentId': appointmentId,
//           'callKitId': callKitId,
//           if (appointmentType.trim().isNotEmpty)
//             'appointmentType': appointmentType.trim(),
//         },
//         android: const AndroidParams(
//           // Use default notification UI. Custom notifications require additional
//           // Android resources; if missing, some devices won't show anything.
//           isCustomNotification: false,
//           isShowLogo: false,
//           ringtonePath: 'system_ringtone_default',
//           backgroundColor: '#0955fa',
//           actionColor: '#4CAF50',
//           incomingCallNotificationChannelName: 'Incoming Call',
//           missedCallNotificationChannelName: 'Missed Call',
//           // Critical for lock screen: show full-screen incoming UI over keyguard.
//           isShowFullLockedScreen: true,
//           // Mark as important so the system treats it like a call alert.
//           isImportant: true,
//           isBot: false,
//         ),
//         ios: const IOSParams(
//           iconName: 'CallKitLogo',
//           handleType: 'generic',
//           supportsVideo: true,
//           maximumCallGroups: 2,
//           maximumCallsPerCallGroup: 1,
//           audioSessionMode: 'default',
//           ringtonePath: 'system_ringtone_default',
//         ),
//       );

//       await FlutterCallkitIncoming.showCallkitIncoming(callKitParams);
//       log('CALL SERVICE: CallKit incoming call shown');
//     } catch (e) {
//       log('CALL SERVICE ERROR: Failed to show CallKit - $e');
//       if (kDebugMode) {
//         debugPrint('CALL SERVICE(DEBUG): showCallkitIncoming threw: $e');
//       }
//     }
//   }

//   String? _resolveAvatarUrl(String? raw) {
//     final v = (raw ?? '').trim();
//     if (v.isEmpty) return null;
//     final lower = v.toLowerCase();
//     if (lower == 'null' || lower == 'undefined') return null;

//     final uri = Uri.tryParse(v);
//     if (uri != null && uri.isAbsolute) return v;

//     final base = ApiConstants.imageBaseUrl;
//     if (v.startsWith('/')) {
//       final normalizedBase = base.endsWith('/')
//           ? base.substring(0, base.length - 1)
//           : base;
//       return '$normalizedBase$v';
//     }
//     final normalizedBase = base.endsWith('/') ? base : '$base/';
//     return '$normalizedBase$v';
//   }

//   Future<void> _initializeSocket(String appointmentId) async {
//     try {
//       log('CALL SERVICE: Initializing socket for incoming call');

//       await _socketHandler.initSocket(
//         appointmentId: appointmentId,
//         onJoinedEvent: () {
//           log('CALL SERVICE: Doctor joined the call');
//         },
//         onRejectedEvent: () {
//           log('CALL SERVICE: Call was rejected');
//           _handleCallRejected();
//         },
//         onEndedEvent: () {
//           log('CALL SERVICE: Call ended');
//           _handleCallEnded();
//         },
//       );
//     } catch (e) {
//       log('CALL SERVICE ERROR: Failed to initialize socket - $e');
//     }
//   }

//   Future<void> acceptCall(BuildContext context) async {
//     try {
//       log(
//         'CALL SERVICE: Accepting call for appointment: $_currentAppointmentId',
//       );

//       // If in-app incoming UI/ringtone is active, stop it immediately on accept.
//       try {
//         if (Get.isRegistered<CallController>()) {
//           await CallController.to.markIncomingAccepted();
//         }
//       } catch (_) {
//         // ignore
//       }

//       // Close CallKit UI
//       await _endCallKitSafely(callKitId: _currentCallKitId);

//       // Navigate to call screen
//       if (context.mounted) {
//         await Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => AgoraCallScreen(
//               name: _currentName,
//               image: _currentImage,
//               appointmentId: _currentAppointmentId,
//             ),
//           ),
//         );
//       }
//     } catch (e) {
//       log('CALL SERVICE ERROR: Failed to accept call - $e');
//     }
//   }

//   Future<void> rejectCall() async {
//     try {
//       log(
//         'CALL SERVICE: Rejecting call for appointment: $_currentAppointmentId',
//       );

//       // Close CallKit UI
//       await _endCallKitSafely(callKitId: _currentCallKitId);

//       // Notify socket
//       _socketHandler.emitRejectCall(appointmentId: _currentAppointmentId);

//       // Clear call data
//       await _clearCallData();
//     } catch (e) {
//       log('CALL SERVICE ERROR: Failed to reject call - $e');
//     }
//   }

//   Future<void> endCall() async {
//     try {
//       log('CALL SERVICE: Ending call for appointment: $_currentAppointmentId');

//       // Close CallKit UI
//       await _endCallKitSafely(callKitId: _currentCallKitId);

//       // Notify socket
//       _socketHandler.emitEndCall(appointmentId: _currentAppointmentId);

//       // Clear call data
//       await _clearCallData();
//     } catch (e) {
//       log('CALL SERVICE ERROR: Failed to end call - $e');
//     }
//   }

//   Future<void> _handleCallRejected() async {
//     try {
//       log('CALL SERVICE: Handling call rejection');

//       // Close CallKit UI
//       await _endCallKitSafely(callKitId: _currentCallKitId);

//       // Clear call data
//       await _clearCallData();
//     } catch (e) {
//       log('CALL SERVICE ERROR: Failed to handle call rejection - $e');
//     }
//   }

//   Future<void> _handleCallEnded() async {
//     try {
//       log('CALL SERVICE: Handling call end');

//       // Close CallKit UI
//       await _endCallKitSafely(callKitId: _currentCallKitId);

//       // Clear call data
//       await _clearCallData();
//     } catch (e) {
//       log('CALL SERVICE ERROR: Failed to handle call end - $e');
//     }
//   }

//   Future<void> _clearCallData() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.remove(SharedPrefKeys.incomingCallName);
//       await prefs.remove(SharedPrefKeys.incomingCallAppointmentId);
//       await prefs.remove(SharedPrefKeys.incomingCallImage);
//       await prefs.remove(SharedPrefKeys.incomingCallCallKitId);
//       await prefs.remove(SharedPrefKeys.incomingCallType);
//       await prefs.setBool(pendingIncomingCallOpen, false);

//       _currentAppointmentId = '';
//       _currentCallKitId = '';
//       _currentName = '';
//       _currentImage = null;
//       _currentAppointmentType = '';

//       log('CALL SERVICE: Call data cleared');
//     } catch (e) {
//       log('CALL SERVICE ERROR: Failed to clear call data - $e');
//     }
//   }

//   Future<void> dispose() async {
//     try {
//       log('CALL SERVICE: Disposing call service');

//       // Close CallKit UI
//       await _endCallKitSafely(callKitId: _currentCallKitId);

//       // Dispose socket
//       _socketHandler.disposeSocket(disconnect: true);

//       try {
//         _socketHandler.preconnect();
//       } catch (_) {
//         // ignore
//       }

//       // Clear data
//       await _clearCallData();
//     } catch (e) {
//       log('CALL SERVICE ERROR: Failed to dispose call service - $e');
//     }
//   }
// }

// // Global function for backward compatibility
// Future<void> ShowCaller({
//   required String name,
//   required String? image,
//   required String appointmentId,
//   String? appointmentType,
//   BuildContext? context,
// }) async {
//   await CallService().showIncomingCall(
//     name: name,
//     image: image,
//     appointmentId: appointmentId,
//     appointmentType: appointmentType,
//     context: context,
//   );
// }
