// import 'dart:developer' as developer;
// import 'package:agora_rtc_engine/agora_rtc_engine.dart';
// import 'package:flutter/foundation.dart';
// import 'package:get/get.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:eye_buddy/core/services/api/repo/api_repo.dart';
// import 'package:eye_buddy/features/login/controller/profile_controller.dart';

// void log(String message, {Object? error, StackTrace? stackTrace}) {
//   if (!kDebugMode) return;
//   developer.log(message, error: error, stackTrace: stackTrace);
// }

// /// Singleton Agora Engine Manager - survives controller rebuilds
// class AgoraSingleton extends GetxService {
//   static AgoraSingleton get to => Get.find();
//   static const String _flowTag = 'CALLFLOW';
//   int _flowSeq = 0;

//   static const bool _traceLeaveChannel = false;

//   void _flow(String step, {Object? data}) {
//     _flowSeq++;
//     log(
//       '$_flowTag[${_flowSeq.toString().padLeft(3, '0')}] $step${data == null ? '' : ' | $data'}',
//     );
//   }

//   RtcEngine? _engine;
//   Future<void>? _initFuture;
//   bool _isEngineInitialized = false;
//   bool _isEngineReleased = false;
//   bool _isEventHandlerRegistered = false;
//   bool _isJoining = false;
//   bool _isLeaving = false;
//   String _lastJoinToken = '';
//   String _lastJoinChannelId = '';
//   int _lastJoinUid = 0;
//   bool _hasRetriedJoinRejected = false;
//   final RxString appId = ''.obs;
//   final RxString channelId = ''.obs;
//   final RxInt localUid = 0.obs;
//   final RxInt remoteUserId = 0.obs;
//   final RxBool isInCall = false.obs;
//   final RxBool isConnecting = false.obs;

//   // Event callbacks
//   Function(RtcConnection, int)? onJoinChannelSuccess;
//   Function(RtcConnection, int, int)? onUserJoined;
//   Function(RtcConnection, int, UserOfflineReasonType)? onUserOffline;
//   Function(RtcConnection, ConnectionStateType, ConnectionChangedReasonType)?
//   onConnectionStateChanged;
//   Function(ErrorCodeType, String)? onError;
//   Function(RtcConnection, int, RemoteVideoState, RemoteVideoStateReason, int)?
//   onRemoteVideoStateChanged;
//   Function(RtcConnection, List<AudioVolumeInfo>, int, int)?
//   onAudioVolumeIndication;

//   @override
//   void onInit() {
//     super.onInit();
//     log('[AGORA SINGLETON] onInit() called - initializing permanent engine');
//     _flow('S: singleton.onInit');
//     log('[AGORA SINGLETON] Initial appId.value: "${appId.value}"');

//     // Set default App ID immediately
//     if (appId.value.isEmpty) {
//       appId.value = '0fb1a1ecf5a34db2b51d9896c994652a';
//       log('[AGORA SINGLETON] Set default App ID');
//     }

//     log('[AGORA SINGLETON] Final appId.value: "${appId.value}"');

//     _initFuture = _initializeEngine();
//     log('[AGORA SINGLETON] Initialized successfully');
//   }

//   /// Public: await this before accessing [engine] from UI/controllers.
//   Future<void> ensureReady() async => _ensureEngineReady();

//   Future<void> _initializeEngine() async {
//     try {
//       _isEngineInitialized = false;
//       _isEngineReleased = false;
//       _isEventHandlerRegistered = false;
//       _engine = createAgoraRtcEngine();
//       final engine = _engine!;

//       // Hardcode App ID to ensure it's never empty
//       final appIdToUse = '0fb1a1ecf5a34db2b51d9896c994652a';
//       log('[AGORA SINGLETON] Using hardcoded App ID: $appIdToUse');

//       await engine.initialize(
//         RtcEngineContext(
//           appId: appIdToUse,
//           channelProfile: ChannelProfileType.channelProfileCommunication,
//         ),
//       );
//       _isEngineInitialized = true;
//       _registerEventHandler();
//       log('[AGORA SINGLETON] Engine initialized successfully');
//     } catch (e) {
//       log('[AGORA SINGLETON] Failed to initialize: $e');
//     }
//   }

//   Future<void> _ensureEngineReady() async {
//     if (_isEngineReleased || _engine == null) {
//       log('[AGORA SINGLETON] Engine was released - reinitializing');
//       _initFuture = _initializeEngine();
//     }
//     _initFuture ??= _initializeEngine();
//     await _initFuture;

//     if (!_isEngineInitialized) {
//       throw Exception('Agora engine initialization failed');
//     }

//     // Defensive: ensure event handler is always registered for the current engine.
//     if (!_isEventHandlerRegistered) {
//       log(
//         '[AGORA SINGLETON] Event handler not registered after init - registering now',
//       );
//       _registerEventHandler();
//     }

//     log(
//       '[AGORA SINGLETON] Engine ready. initialized=$_isEngineInitialized handlerRegistered=$_isEventHandlerRegistered',
//     );
//   }

//   void _registerEventHandler() {
//     if (_isEventHandlerRegistered) {
//       return;
//     }

//     log('[AGORA SINGLETON] Registering event handler on engine');
//     final engine = _engine;
//     if (engine == null) return;
//     engine.registerEventHandler(
//       RtcEngineEventHandler(
//         onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
//           log(
//             '[AGORA SINGLETON] onJoinChannelSuccess: uid=${connection.localUid}',
//           );
//           _flow(
//             'T: onJoinChannelSuccess',
//             data: {
//               'uid': connection.localUid ?? 0,
//               'channel': connection.channelId,
//               'elapsed': elapsed,
//             },
//           );
//           localUid.value = connection.localUid ?? 0;
//           isConnecting.value = false;
//           isInCall.value = true;
//           try {
//             onJoinChannelSuccess?.call(connection, elapsed);
//           } catch (e, st) {
//             _flow('T: onJoinChannelSuccess callback ERROR', data: '$e\n$st');
//           }
//         },
//         onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
//           // log('[AGORA SINGLETON] onUserJoined: remoteUid=$remoteUid');
//           _flow(
//             'U: onUserJoined',
//             data: {
//               'remoteUid': remoteUid,
//               'channel': connection.channelId,
//               'elapsed': elapsed,
//             },
//           );
//           remoteUserId.value = remoteUid;
//           try {
//             onUserJoined?.call(connection, remoteUid, elapsed);
//           } catch (e, st) {
//             _flow('U: onUserJoined callback ERROR', data: '$e\n$st');
//           }
//         },
//         onUserOffline:
//             (
//               RtcConnection connection,
//               int remoteUid,
//               UserOfflineReasonType reason,
//             ) {
//               log('[AGORA SINGLETON] onUserOffline: remoteUid=$remoteUid');
//               _flow(
//                 'V: onUserOffline',
//                 data: {
//                   'remoteUid': remoteUid,
//                   'channel': connection.channelId,
//                   'reason': reason.toString(),
//                 },
//               );
//               if (remoteUserId.value == remoteUid) {
//                 remoteUserId.value = 0;
//               }
//               try {
//                 onUserOffline?.call(connection, remoteUid, reason);
//               } catch (e, st) {
//                 _flow('V: onUserOffline callback ERROR', data: '$e\n$st');
//               }
//             },
//         onConnectionStateChanged:
//             (
//               RtcConnection connection,
//               ConnectionStateType state,
//               ConnectionChangedReasonType reason,
//             ) {
//               log('[AGORA SINGLETON] onConnectionStateChanged: state=$state');
//               onConnectionStateChanged?.call(connection, state, reason);
//             },
//         onRemoteVideoStateChanged:
//             (
//               RtcConnection connection,
//               int remoteUid,
//               RemoteVideoState state,
//               RemoteVideoStateReason reason,
//               int elapsed,
//             ) {
//               log(
//                 '[AGORA SINGLETON] REMOTE VIDEO: uid=$remoteUid state=$state reason=$reason channel=${connection.channelId}',
//               );
//               _flow(
//                 'W: onRemoteVideoStateChanged',
//                 data: {
//                   'remoteUid': remoteUid,
//                   'channel': connection.channelId,
//                   'state': state.toString(),
//                   'reason': reason.toString(),
//                   'elapsed': elapsed,
//                 },
//               );
//               onRemoteVideoStateChanged?.call(
//                 connection,
//                 remoteUid,
//                 state,
//                 reason,
//                 elapsed,
//               );
//             },
//         onAudioVolumeIndication:
//             (
//               RtcConnection connection,
//               List<AudioVolumeInfo> speakers,
//               int totalVolume,
//               int vad,
//             ) {
//               try {
//                 onAudioVolumeIndication?.call(
//                   connection,
//                   speakers,
//                   totalVolume,
//                   vad,
//                 );
//               } catch (_) {
//                 // ignore
//               }
//             },
//         onRemoteAudioStateChanged:
//             (
//               RtcConnection connection,
//               int remoteUid,
//               RemoteAudioState state,
//               RemoteAudioStateReason reason,
//               int elapsed,
//             ) {
//               log(
//                 '[AGORA SINGLETON] REMOTE AUDIO: uid=$remoteUid state=$state reason=$reason channel=${connection.channelId}',
//               );
//             },
//         onLocalAudioStateChanged:
//             (
//               RtcConnection connection,
//               LocalAudioStreamState state,
//               LocalAudioStreamReason reason,
//             ) {
//               log(
//                 '[AGORA SINGLETON] LOCAL AUDIO: state=$state reason=$reason channel=${connection.channelId}',
//               );
//               // If local audio fails to capture, patient will receive no packets
//               if (state == LocalAudioStreamState.localAudioStreamStateFailed ||
//                   reason != LocalAudioStreamReason.localAudioStreamReasonOk) {
//                 log(
//                   '[AGORA SINGLETON] LOCAL AUDIO CAPTURE FAILED - patient may receive no audio',
//                 );
//               }
//             },
//         onLocalVideoStateChanged:
//             (
//               VideoSourceType source,
//               LocalVideoStreamState state,
//               LocalVideoStreamReason reason,
//             ) {
//               log(
//                 '[AGORA SINGLETON] LOCAL VIDEO: source=$source state=$state reason=$reason',
//               );
//               // If local video fails to capture, patient will receive no video
//               if (state == LocalVideoStreamState.localVideoStreamStateFailed ||
//                   reason != LocalVideoStreamReason.localVideoStreamReasonOk) {
//                 log(
//                   '[AGORA SINGLETON] LOCAL VIDEO CAPTURE FAILED - patient may receive no video',
//                 );
//               }
//             },
//         onError: (ErrorCodeType err, String msg) {
//           log('[AGORA SINGLETON] onError: err=$err, msg=$msg');
//           _flow('Z: onError', data: {'err': err.toString(), 'msg': msg});

//           // Handle ERR_JOIN_CHANNEL_REJECTED (-17) safely. In Agora Flutter SDK,
//           // joinChannel does not return an error code; it is surfaced via onError.
//           // We avoid SDK enum name coupling by using string matching.
//           final errStr = err.toString().toLowerCase();
//           final msgStr = msg.toLowerCase();
//           final isJoinRejected =
//               (errStr.contains('join') && errStr.contains('rejected')) ||
//               (msgStr.contains('join') && msgStr.contains('rejected')) ||
//               msgStr.contains('-17');

//           if (isJoinRejected && !_hasRetriedJoinRejected) {
//             _hasRetriedJoinRejected = true;
//             log(
//               '[AGORA SINGLETON] Join rejected. Retrying once after leave...',
//             );
//             Future<void>.delayed(const Duration(milliseconds: 600), () async {
//               if (_lastJoinToken.isEmpty || _lastJoinChannelId.isEmpty) {
//                 return;
//               }
//               try {
//                 await leaveChannel();
//               } catch (_) {
//                 // ignore
//               }
//               try {
//                 await joinChannel(
//                   token: _lastJoinToken,
//                   channelId: _lastJoinChannelId,
//                   uid: _lastJoinUid,
//                 );
//               } catch (_) {
//                 // ignore
//               }
//             });
//           }

//           onError?.call(err, msg);
//         },
//       ),
//     );
//     _isEventHandlerRegistered = true;
//     log('[AGORA SINGLETON] Event handler registered');
//   }

//   Future<void> joinChannel({
//     required String token,
//     required String channelId,
//     int uid = 0,
//     bool isDoctor = true,
//     bool enableVideo = true,
//   }) async {
//     if (_isJoining) {
//       log('[AGORA SINGLETON] joinChannel ignored (already joining)');
//       return;
//     }
//     _isJoining = true;
//     try {
//       _flow('P: joinChannel.enter', data: {'channelId': channelId, 'uid': uid});
//       await _ensureEngineReady();
//       final engine = _engine;
//       if (engine == null) {
//         throw Exception('Agora engine is not ready');
//       }

//       // If we're already in-call/connecting on the same channel, don't disrupt
//       // the session by calling leaveChannel.
//       if ((isInCall.value || isConnecting.value) &&
//           this.channelId.value.isNotEmpty &&
//           this.channelId.value == channelId &&
//           !_isLeaving) {
//         log(
//           '[AGORA SINGLETON] joinChannel ignored (already active on same channel) channel=$channelId',
//         );
//         return;
//       }

//       log(
//         '[AGORA SINGLETON] joinChannel preflight: initialized=$_isEngineInitialized released=$_isEngineReleased handlerRegistered=$_isEventHandlerRegistered',
//       );

//       // Save last join params for a potential single retry in onError.
//       _lastJoinToken = token;
//       _lastJoinChannelId = channelId;
//       _lastJoinUid = uid;
//       _hasRetriedJoinRejected = false;

//       // Only attempt a pre-join leave when we are switching channels.
//       // Unconditional leave here can drop an active call unexpectedly.
//       final shouldPreLeave =
//           this.channelId.value.isNotEmpty &&
//           this.channelId.value != channelId &&
//           !isInCall.value;
//       if (shouldPreLeave) {
//         try {
//           await leaveChannel(reason: 'pre_join_cleanup');
//           await Future<void>.delayed(const Duration(milliseconds: 200));
//         } catch (_) {
//           // ignore
//         }
//       }

//       isConnecting.value = true;
//       this.channelId.value = channelId;

//       log('[AGORA SINGLETON] Joining channel: $channelId');
//       log('[AGORA SINGLETON] Token length: ${token.length}');
//       log('[AGORA SINGLETON] UID: $uid');
//       _flow('Q: joinChannel.engineConfig');

//       await engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
//       log('[AGORA SINGLETON] Client role set to broadcaster');

//       if (enableVideo) {
//         await engine.enableVideo();
//         log('[AGORA SINGLETON] Video enabled');
//       } else {
//         try {
//           await engine.disableVideo();
//         } catch (_) {
//           // ignore
//         }
//         log('[AGORA SINGLETON] Video disabled (audio-only)');
//       }

//       await engine.enableAudio();
//       log('[AGORA SINGLETON] Audio enabled');

//       try {
//         await engine.enableAudioVolumeIndication(
//           interval: 200,
//           smooth: 3,
//           reportVad: true,
//         );
//         log('[AGORA SINGLETON] Audio volume indication enabled');
//       } catch (e) {
//         log('[AGORA SINGLETON] Failed to enable audio volume indication: $e');
//       }

//       // Defensive: ensure local tracks are enabled/unmuted before join so the
//       // remote party receives media packets.
//       await engine.enableLocalAudio(true);
//       await engine.muteLocalAudioStream(false);
//       await engine.enableLocalVideo(enableVideo);
//       await engine.muteLocalVideoStream(!enableVideo);

//       await engine.setDefaultAudioRouteToSpeakerphone(true);
//       log('[AGORA SINGLETON] Speakerphone enabled by default');

//       if (enableVideo) {
//         await engine.startPreview();
//         log('[AGORA SINGLETON] Preview started');
//       }

//       await engine.joinChannel(
//         token: token,
//         channelId: channelId,
//         uid: uid,
//         options: ChannelMediaOptions(
//           channelProfile: ChannelProfileType.channelProfileCommunication,
//           clientRoleType: ClientRoleType.clientRoleBroadcaster,
//           autoSubscribeAudio: true,
//           autoSubscribeVideo: true,
//           publishCameraTrack: enableVideo,
//           publishMicrophoneTrack: true,
//           enableAudioRecordingOrPlayout: true,
//         ),
//       );

//       log('[AGORA SINGLETON] joinChannel called successfully');
//       _flow('R: joinChannel.called');
//     } catch (e) {
//       log('[AGORA SINGLETON] Failed to join channel: $e');
//       _flow('P: joinChannel.ERROR', data: e);
//       isConnecting.value = false;
//     } finally {
//       _isJoining = false;
//     }
//   }

//   Future<void> leaveChannel({String reason = ''}) async {
//     if (_isLeaving) {
//       log(
//         '[AGORA SINGLETON] leaveChannel ignored (already leaving) reason=$reason',
//       );
//       if (_traceLeaveChannel) {
//         print(
//           '[AGORA SINGLETON] leaveChannel ignored (already leaving) reason=$reason',
//         );
//       }
//       return;
//     }
//     _isLeaving = true;
//     try {
//       final engine = _engine;
//       if (engine == null) {
//         isInCall.value = false;
//         isConnecting.value = false;
//         channelId.value = '';
//         localUid.value = 0;
//         remoteUserId.value = 0;
//         return;
//       }
//       log(
//         '[AGORA SINGLETON] leaveChannel called reason=$reason channel=${channelId.value} inCall=${isInCall.value} connecting=${isConnecting.value}',
//       );
//       if (_traceLeaveChannel) {
//         print(
//           '[AGORA SINGLETON] leaveChannel called reason=$reason channel=${channelId.value} inCall=${isInCall.value} connecting=${isConnecting.value}',
//         );
//         print('[AGORA SINGLETON] leaveChannel stack:\n${StackTrace.current}');
//       } else if (!kReleaseMode) {
//         log('[AGORA SINGLETON] leaveChannel stack:\n${StackTrace.current}');
//       }
//       _flow('Y: leaveChannel.begin', data: {'reason': reason});
//       await engine.leaveChannel();
//       localUid.value = 0;
//       remoteUserId.value = 0;
//       isInCall.value = false;
//       isConnecting.value = false;
//       channelId.value = '';
//       log('[AGORA SINGLETON] Left channel');
//       if (_traceLeaveChannel) {
//         print('[AGORA SINGLETON] Left channel');
//       }
//       _flow('Y: leaveChannel.done');
//     } catch (e) {
//       log('[AGORA SINGLETON] Failed to leave channel: $e');
//       if (_traceLeaveChannel) {
//         print('[AGORA SINGLETON] Failed to leave channel: $e');
//       }
//       _flow('Y: leaveChannel.ERROR', data: e);
//     } finally {
//       _isLeaving = false;
//     }
//   }

//   void emitEndCall({required String appointmentId}) {
//     log('[AGORA SINGLETON] Emitting endCall for appointment: $appointmentId');
//     // Note: Socket emission should be handled by AgoraCallSocketHandler
//     // This is a placeholder for the socket emission logic
//   }

//   /// Best-effort fetch of Agora credentials (channel + tokens) for an appointment.
//   /// Used when CallKit/FCM accept payload lacks tokens (common on banner/lock-screen).
//   Future<Map<String, String>> hydrateCallCredentials(String appointmentId) async {
//     final result = <String, String>{};
//     if (appointmentId.trim().isEmpty) return result;

//     try {
//       // Resolve patient id (needed by API).
//       String patientId = '';
//       try {
//         final profileCtrl = Get.isRegistered<ProfileController>()
//             ? Get.find<ProfileController>()
//             : Get.put(ProfileController(), permanent: true);
//         if (profileCtrl.profileData.value.profile == null) {
//           await profileCtrl.getProfileData();
//         }
//         patientId = profileCtrl.profileData.value.profile?.sId ?? '';
//       } catch (_) {
//         // ignore
//       }

//       final api = ApiRepo();
//       final resp = await api.getAppointments('upcoming', patientId);
//       List<dynamic>? docs;
//       if (resp is Map<String, dynamic>) {
//         final data = resp['data'];
//         if (data is Map<String, dynamic> && data['docs'] is List) {
//           docs = data['docs'] as List;
//         }
//       }
//       if (docs != null) {
//         for (final doc in docs) {
//           if (doc is Map &&
//               (doc['_id'] ?? '').toString().trim() == appointmentId) {
//             final patientToken =
//                 (doc['patientAgoraToken'] ?? '').toString().trim();
//             final doctorToken =
//                 (doc['doctorAgoraToken'] ?? '').toString().trim();
//             final channelId =
//                 (doc['agoraChannelId'] ?? doc['channelId'] ?? appointmentId)
//                     .toString()
//                     .trim();
//             if (patientToken.isNotEmpty) {
//               result['patientToken'] = patientToken;
//             }
//             if (doctorToken.isNotEmpty) {
//               result['doctorToken'] = doctorToken;
//             }
//             if (channelId.isNotEmpty) {
//               result['channelId'] = channelId;
//             }
//             break;
//           }
//         }
//       }

//       // Cache hydrated values for future resumes.
//       if (result.isNotEmpty) {
//         try {
//           final prefs = await SharedPreferences.getInstance();
//           if (result['patientToken']?.isNotEmpty == true) {
//             final v = result['patientToken']!;
//             await prefs.setString('patient_agora_token', v);
//             await prefs.setString('patient_agora_token_$appointmentId', v);
//           }
//           if (result['doctorToken']?.isNotEmpty == true) {
//             final v = result['doctorToken']!;
//             await prefs.setString('doctor_agora_token', v);
//             await prefs.setString('doctor_agora_token_$appointmentId', v);
//           }
//           if (result['channelId']?.isNotEmpty == true) {
//             final v = result['channelId']!;
//             await prefs.setString('agora_channel_id', v);
//             await prefs.setString('agora_channel_id_$appointmentId', v);
//           }
//         } catch (_) {
//           // ignore
//         }
//       }
//     } catch (_) {
//       // ignore
//     }

//     return result;
//   }

//   /// Release the Agora engine
//   Future<void> releaseEngine() async {
//     try {
//       final engine = _engine;
//       if (engine == null) return;
//       await engine.release();
//       _isEngineReleased = true;
//       _isEngineInitialized = false;
//       _isEventHandlerRegistered = false;
//       _initFuture = null;
//       _engine = null;
//       log('[AGORA SINGLETON] Engine released');
//     } catch (e) {
//       log('[AGORA SINGLETON] Failed to release engine: $e');
//     }
//   }

//   // Getters for UI
//   RtcEngine get engine {
//     final engine = _engine;
//     if (engine == null) {
//       throw StateError('Agora engine not initialized. Call ensureReady() first.');
//     }
//     return engine;
//   }
//   bool get hasRemoteUser => remoteUserId.value != 0;
// }
