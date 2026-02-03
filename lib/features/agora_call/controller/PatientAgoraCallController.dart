// import 'dart:developer';
// import 'package:agora_rtc_engine/agora_rtc_engine.dart';
// import 'package:eye_buddy/features/waiting_for_prescription/view/waiting_for_prescription_screen.dart';
// import 'package:get/get.dart';
// import 'package:eye_buddy/core/socket/PatientCallSocketHandler.dart';

// class PatientAgoraCallController extends GetxController {
//   RtcEngine? engine;

//   /// ---------------- STATES ----------------
//   RxBool isJoined = false.obs;
//   RxBool isDoctorJoined = false.obs;
//   RxInt remoteUid = 0.obs;

//   RxBool isMuted = false.obs;
//   RxBool isSpeakerOn = false.obs;
//   RxBool shouldCloseCallScreen = false.obs;
//   final RxBool isRemoteSpeaking = false.obs;

//   /// 🔥 RINGING STATE
//   RxBool isRinging = false.obs;

//   /// ---------------- DATA ----------------
//   String channelId = '';
//   String patientToken = '';

//   RxString doctorName = 'Doctor'.obs;
//   RxString doctorPhoto = ''.obs;

//   bool _joining = false;
//   bool _callEnded = false;

//   /// ---------------- IMAGE BASE URL ----------------
//   static const String imageBaseUrl =
//       'https://beh-app.s3.eu-north-1.amazonaws.com/';

//   /// ---------------- IMAGE GETTER ----------------
//   String get doctorImageUrl {
//     final img = doctorPhoto.value.trim();
//     log('🖼️ doctorImageUrl raw: "$img"');

//     if (img.isEmpty) return '';
//     if (img.startsWith('http')) return img;

//     return imageBaseUrl + img;
//   }

//   /// ---------------- INCOMING CALL ----------------
//   void setIncomingCall({
//     required String channel,
//     required String token,
//     String? doctorName,
//     String? doctorPhoto,
//   }) {
//     log('📞 setIncomingCall');

//     channelId = channel;
//     patientToken = token;
//     this.doctorName.value = doctorName ?? 'Doctor';
//     this.doctorPhoto.value = doctorPhoto ?? '';

//     _callEnded = false;
//     isRinging.value = true;
//   }

//   /// ---------------- ACCEPT ----------------
//   Future<void> acceptCall() async {
//     log('✅ acceptCall()');

//     if (_callEnded) {
//       log('⛔ accept ignored, call already ended');
//       return;
//     }

//     isRinging.value = false;
//     await _joinAgora();
//   }

//   /// ---------------- DECLINE ----------------
//   Future<void> declineCall() async {
//     log('❌ declineCall()');
//     await endCall();
//   }

//   /// ---------------- END CALL (PUBLIC) ----------------

//   Future<void> endCall() async {
//   log('📴 endCall() pressed');

//   if (_callEnded) {
//     log('⛔ endCall ignored — already ended');
//     return;
//   }

//   await _endCall();

//   /// 🔥 NAVIGATION HERE
//   Get.offAll(() => const WaitingForPrescriptionScreen());
// }

//   /// ---------------- JOIN AGORA ----------------
//   Future<void> _joinAgora() async {
//     log('🚀 _joinAgora()');

//     if (_joining || _callEnded) {
//       log('⛔ Join blocked (joining or ended)');
//       return;
//     }

//     if (channelId.isEmpty || patientToken.isEmpty) {
//       log('⛔ channel/token missing');
//       return;
//     }

//     _joining = true;

//     try {
//       engine ??= createAgoraRtcEngine();

//       await engine!.initialize(
//         const RtcEngineContext(
//           appId: '0fb1a1ecf5a34db2b51d9896c994652a',
//           channelProfile: ChannelProfileType.channelProfileCommunication,
//         ),
//       );

//       engine!.registerEventHandler(
//         RtcEngineEventHandler(
//           onJoinChannelSuccess: (_, __) {
//             log('✅ Patient joined channel');
//             isJoined.value = true;
//           },

//           onUserJoined: (_, uid, __) {
//             log('👨‍⚕️ Doctor joined: $uid');
//             remoteUid.value = uid;
//             isDoctorJoined.value = true;
//           },

//           onUserOffline: (_, uid, reason) {
//             log('🚪 Doctor offline → $uid | $reason');

//             if (_callEnded) {
//               log('⛔ Already ended, ignore offline');
//               return;
//             }

//             endCall(); // 🔥 ONLY SAFE EXIT
//           },
//         ),
//       );

//       await engine!.setClientRole(
//         role: ClientRoleType.clientRoleBroadcaster,
//       );

//       await engine!.enableVideo();
//       await engine!.enableAudio();

//       await engine!.setupLocalVideo(
//         const VideoCanvas(uid: 0),
//       );

//       await engine!.startPreview();

//       await engine!.joinChannel(
//         token: patientToken,
//         channelId: channelId,
//         uid: 0,
//         options: const ChannelMediaOptions(
//           publishCameraTrack: true,
//           publishMicrophoneTrack: true,
//           autoSubscribeAudio: true,
//           autoSubscribeVideo: true,
//           clientRoleType: ClientRoleType.clientRoleBroadcaster,
//         ),
//       );

//       log('📡 joinChannel sent');
//     } catch (e, s) {
//       log('🔥 JOIN ERROR: $e');
//       log('📄 $s');
//     } finally {
//       _joining = false;
//     }
//   }

//   /// ---------------- CONTROLS ----------------
//   void toggleMute() {
//     isMuted.toggle();
//     engine?.muteLocalAudioStream(isMuted.value);
//     log('🎤 mute: ${isMuted.value}');
//   }

//   void toggleSpeaker() async {
//     isSpeakerOn.toggle();
//     await engine?.setEnableSpeakerphone(isSpeakerOn.value);
//     log('🔊 speaker: ${isSpeakerOn.value}');
//   }

//   void switchCamera() {
//     engine?.switchCamera();
//     log('🔄 camera switched');
//   }

//   /// ---------------- INTERNAL END ----------------
//   Future<void> _endCall() async {
//     if (_callEnded) {
//       log('⛔ _endCall skipped');
//       return;

//     }

//     _callEnded = true;
//     log('🧹 Cleaning call');

//     try {
//       await engine?.leaveChannel();
//       await engine?.stopPreview();
//       await engine?.release();
//       log('🗑️ Agora released');
//     } catch (e) {
//       log('⚠️ end error: $e');
//     }

//     engine = null;

//     isJoined.value = false;
//     isDoctorJoined.value = false;
//     isRinging.value = false;
//     remoteUid.value = 0;
//     shouldCloseCallScreen.value = true;

//     log('✅ Call ended successfully');
//   }

//   @override
//   void onClose() {
//     log('🧨 Controller onClose');

//     if (!_callEnded) {
//       endCall();
//     }

//     super.onClose();
//   }
// }

// import 'dart:developer';
// import 'package:agora_rtc_engine/agora_rtc_engine.dart';
// import 'package:eye_buddy/core/services/utils/handlers/PatientCallSocketHandler.dart';
// import 'package:eye_buddy/features/waiting_for_prescription/view/waiting_for_prescription_screen.dart';
// import 'package:get/get.dart';

// class PatientAgoraCallController extends GetxController {
//   RtcEngine? engine;

//   /// ---------------- STATES ----------------
//   RxBool isJoined = false.obs;
//   RxBool isDoctorJoined = false.obs;
//   RxInt remoteUid = 0.obs;

//   RxBool isMuted = false.obs;
//   RxBool isSpeakerOn = false.obs;
//   RxBool shouldCloseCallScreen = false.obs;
//   final RxBool isRemoteSpeaking = false.obs;

//   /// 🔥 RINGING STATE
//   RxBool isRinging = false.obs;

//   /// ---------------- DATA ----------------
//   String channelId = '';
//   String patientToken = '';

//   RxString doctorName = 'Doctor'.obs;
//   RxString doctorPhoto = ''.obs;

//   bool _joining = false;
//   bool _callEnded = false;

//   late PatientCallSocketHandler _socket;

//   /// ---------------- IMAGE BASE URL ----------------
//   static const String imageBaseUrl =
//       'https://beh-app.s3.eu-north-1.amazonaws.com/';

//   /// ---------------- IMAGE GETTER ----------------
//   String get doctorImageUrl {
//     final img = doctorPhoto.value.trim();
//     log('🖼️ doctorImageUrl raw: "$img"');

//     if (img.isEmpty) return '';
//     if (img.startsWith('http')) return img;

//     return imageBaseUrl + img;
//   }

//   /// ---------------- INCOMING CALL ----------------
//   void setIncomingCall({
//     required String channel,
//     required String token,
//     String? doctorName,
//     String? doctorPhoto,
//   }) {
//     log('📞 setIncomingCall');

//     channelId = channel;
//     patientToken = token;
//     this.doctorName.value = doctorName ?? 'Doctor';
//     this.doctorPhoto.value = doctorPhoto ?? '';

//     _callEnded = false;
//     isRinging.value = true;

//     /// 🔥 SOCKET INIT
//     _socket = PatientCallSocketHandler.instance;

//     _socket.initSocket(
//       appointmentId: channelId,
//       onAcceptedEvent: (data) {
//         log('📡 SOCKET: call_accepted → $data');
//       },
//       onRejectedEvent: (data) {
//         log('📡 SOCKET: call_rejected → $data');
//         _handleDoctorEndedCall();
//       },
//       onEndedEvent: (data) {
//         log('📡 SOCKET: call_ended → $data');
//         _handleDoctorEndedCall();
//       },
//     );

//     log('🔗 Socket initialized for appointmentId: $channelId');
//   }

//   /// 🔥 DOCTOR CUT HANDLER (RINGING + IN CALL)
//   Future<void> _handleDoctorEndedCall() async {
//     if (_callEnded) {
//       log('⛔ Doctor end ignored — already ended');
//       return;
//     }

//     log('🚨 Doctor ended call (ringing or active)');

//     _callEnded = true;
//     isRinging.value = false;

//     await _endCall();

//     log('🚪 Navigating to WaitingForPrescriptionScreen (doctor cut)');
//     Get.offAll(() => const WaitingForPrescriptionScreen());
//   }

//   /// ---------------- ACCEPT ----------------
//   // Future<void> acceptCall() async {
//   //   log('✅ acceptCall()');

//   //   if (_callEnded) {
//   //     log('⛔ accept ignored, call already ended');
//   //     return;
//   //   }

//   //   isRinging.value = false;
//   //   await _joinAgora();
//   // }
// Future<void> acceptCall() async {
//   if (_callEnded) return;

//   /// ✅ FIXED EVENT NAME
//   _socket.socket.emit('joinedCall', {
//     'appointmentId': channelId,
//   });

//   isRinging.value = false;

//   await _joinAgora();
// }

//   /// ---------------- DECLINE ----------------
//   Future<void> declineCall() async {
//     log('❌ declineCall()');

//     if (!_callEnded) {
//       log('📡 SOCKET EMIT: call_rejected');
//       _socket.socket.emit('call_rejected', {
//         'appointmentId': channelId,
//       });
//     }

//     await endCall();
//   }

//   /// ---------------- END CALL (PUBLIC) ----------------
//   Future<void> endCall() async {
//     log('📴 endCall() pressed');

//     if (_callEnded) {
//       log('⛔ endCall ignored — already ended');
//       return;
//     }

//     log('📡 SOCKET EMIT: call_ended');
//     _socket.socket.emit('call_ended', {
//       'appointmentId': channelId,
//     });

//     await _endCall();

//     log('🚪 Navigating to WaitingForPrescriptionScreen');
//     Get.offAll(() => const WaitingForPrescriptionScreen());
//   }

//   /// ---------------- JOIN AGORA ----------------
//   Future<void> _joinAgora() async {
//     log('🚀 _joinAgora()');

//     if (_joining || _callEnded) {
//       log('⛔ Join blocked (joining or ended)');
//       return;
//     }

//     if (channelId.isEmpty || patientToken.isEmpty) {
//       log('⛔ channel/token missing');
//       return;
//     }

//     _joining = true;

//     try {
//       engine ??= createAgoraRtcEngine();

//       await engine!.initialize(
//         const RtcEngineContext(
//           appId: '0fb1a1ecf5a34db2b51d9896c994652a',
//           channelProfile: ChannelProfileType.channelProfileCommunication,
//         ),
//       );

//       engine!.registerEventHandler(
//         RtcEngineEventHandler(
//           onJoinChannelSuccess: (_, __) {
//             log('✅ Patient joined channel');
//             isJoined.value = true;
//           },
//           onUserJoined: (_, uid, __) {
//             log('👨‍⚕️ Doctor joined: $uid');
//             remoteUid.value = uid;
//             isDoctorJoined.value = true;
//           },
//           onUserOffline: (_, uid, reason) {
//             log('🚪 Doctor offline → $uid | reason: $reason');

//             if (_callEnded) {
//               log('⛔ Already ended, ignore offline');
//               return;
//             }

//             endCall();
//           },
//         ),
//       );

//       await engine!.setClientRole(
//         role: ClientRoleType.clientRoleBroadcaster,
//       );

//       await engine!.enableVideo();
//       await engine!.enableAudio();

//       await engine!.setupLocalVideo(
//         const VideoCanvas(uid: 0),
//       );

//       await engine!.startPreview();

//       await engine!.joinChannel(
//         token: patientToken,
//         channelId: channelId,
//         uid: 0,
//         options: const ChannelMediaOptions(
//           publishCameraTrack: true,
//           publishMicrophoneTrack: true,
//           autoSubscribeAudio: true,
//           autoSubscribeVideo: true,
//           clientRoleType: ClientRoleType.clientRoleBroadcaster,
//         ),
//       );

//       log('📡 joinChannel request sent');
//     } catch (e, s) {
//       log('🔥 JOIN ERROR: $e');
//       log('📄 STACK: $s');
//     } finally {
//       _joining = false;
//     }
//   }

//   /// ---------------- CONTROLS ----------------
//   void toggleMute() {
//     isMuted.toggle();
//     engine?.muteLocalAudioStream(isMuted.value);
//     log('🎤 mute: ${isMuted.value}');
//   }

//   void toggleSpeaker() async {
//     isSpeakerOn.toggle();
//     await engine?.setEnableSpeakerphone(isSpeakerOn.value);
//     log('🔊 speaker: ${isSpeakerOn.value}');
//   }

//   void switchCamera() {
//     engine?.switchCamera();
//     log('🔄 camera switched');
//   }

//   /// ---------------- INTERNAL END ----------------
//   Future<void> _endCall() async {
//     if (_callEnded == false) {
//       _callEnded = true;
//     }

//     log('🧹 Cleaning call resources');

//     try {
//       await engine?.leaveChannel();
//       await engine?.stopPreview();
//       await engine?.release();
//       log('🗑️ Agora released');
//     } catch (e) {
//       log('⚠️ end error: $e');
//     }

//     engine = null;

//     isJoined.value = false;
//     isDoctorJoined.value = false;
//     isRinging.value = false;
//     remoteUid.value = 0;
//     shouldCloseCallScreen.value = true;

//     log('✅ Call ended successfully');
//   }

//   @override
//   void onClose() {
//     log('🧨 Controller onClose');

//     try {
//       _socket.disposeSocket();
//       log('🔌 Socket disposed');
//     } catch (_) {}

//     super.onClose();
//   }
// }

import 'dart:developer';
import 'dart:io';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:eye_buddy/core/services/utils/handlers/PatientCallSocketHandler.dart';
import 'package:eye_buddy/features/waiting_for_prescription/view/waiting_for_prescription_screen.dart';
import 'package:get/get.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PatientAgoraCallController extends GetxController {
  RtcEngine? engine;

  /// ---------------- STATES ----------------
  RxBool isJoined = false.obs;
  RxBool isDoctorJoined = false.obs;
  RxInt remoteUid = 0.obs;

  RxBool isMuted = false.obs;
  RxBool isSpeakerOn = false.obs;
  RxBool shouldCloseCallScreen = false.obs;
  final RxBool isRemoteSpeaking = false.obs;

  /// 🔥 RINGING STATE
  RxBool isRinging = false.obs;

  /// ---------------- DATA ----------------
  String channelId = '';
  String patientToken = '';

  RxString doctorName = 'Doctor'.obs;
  RxString doctorPhoto = ''.obs;

  bool _joining = false;
  bool _callEnded = false;

  late PatientCallSocketHandler _socket;

  /// ---------------- IMAGE BASE URL ----------------
  static const String imageBaseUrl =
      'https://beh-app.s3.eu-north-1.amazonaws.com/';

  /// ---------------- IMAGE GETTER ----------------
  String get doctorImageUrl {
    final img = doctorPhoto.value.trim();
    log('🖼️ doctorImageUrl raw: "$img"');

    if (img.isEmpty) return '';
    if (img.startsWith('http')) return img;

    return imageBaseUrl + img;
  }

  /// ---------------- INCOMING CALL ----------------
  void setIncomingCall({
    required String channel,
    required String token,
    String? doctorName,
    String? doctorPhoto,
  }) {
    log('📞 setIncomingCall');

    channelId = channel;
    patientToken = token;
    this.doctorName.value = doctorName ?? 'Doctor';
    this.doctorPhoto.value = doctorPhoto ?? '';

    _callEnded = false;
    isRinging.value = true;

    /// 🔥 SOCKET INIT
    _socket = PatientCallSocketHandler.instance;

    _socket.initSocket(
      appointmentId: channelId,

      onRejectedEvent: (data) {
        log('📡 SOCKET: call_rejected → $data');
        _handleDoctorEndedCall();
      },
      onEndedEvent: (data) {
        log('📡 SOCKET: call_ended → $data');
        _handleDoctorEndedCall();
      },
      onJoinedEvent: (data) {},
    );

    log('🔗 Socket initialized for appointmentId: $channelId');
  }

  /// 🔥 DOCTOR CUT HANDLER (RINGING + IN CALL)
  Future<void> _handleDoctorEndedCall() async {
    if (_callEnded) {
      log('⛔ Doctor end ignored — already ended');
      return;
    }

    log('🚨 Doctor ended call (ringing or active)');

    _callEnded = true;
    isRinging.value = false;
    if (!_callEnded) {
      log('📡 SOCKET EMIT: rejectCall');

      /// ✅ FIXED
      _socket.socket?.emit('rejectCall', {'appointmentId': channelId});
    }

    if (Platform.isIOS) {
      /// ✅ FIXED
      _socket.socket?.emit('endCall', {'appointmentId': channelId});
      await FlutterCallkitIncoming.endCall(channelId);

      // 2. Clear all system notifications
      await FlutterCallkitIncoming.endAllCalls();
      await AwesomeNotifications().cancelAll();

      // 3. Clean up Agora (Assuming you have an engine instance)
      // await _engine.leaveChannel();
      // await _engine.release();

      // 4. Update your local state/UI
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isCallAccepted', false);
    }

    await _endCall();

    log('🚪 Navigating to WaitingForPrescriptionScreen (doctor cut)');
    Get.offAll(() => const WaitingForPrescriptionScreen());
  }

  /// ---------------- ACCEPT ----------------
  Future<void> acceptCall() async {
    if (_callEnded) return;

    /// ✅ FIXED
    _socket.socket?.emit('joinedCall', {'appointmentId': channelId});

    isRinging.value = false;

    await _joinAgora();
  }

  /// ---------------- DECLINE ----------------
  Future<void> declineCall() async {
    log('❌ declineCall()');

    if (!_callEnded) {
      log('📡 SOCKET EMIT: rejectCall');

      if (Platform.isIOS) {
        /// ✅ FIXED
        _socket.socket?.emit('endCall', {'appointmentId': channelId});
        await FlutterCallkitIncoming.endCall(channelId);

        // 2. Clear all system notifications
        await FlutterCallkitIncoming.endAllCalls();
        await AwesomeNotifications().cancelAll();

        // 3. Clean up Agora (Assuming you have an engine instance)
        // await _engine.leaveChannel();
        // await _engine.release();

        // 4. Update your local state/UI
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isCallAccepted', false);
      }

      /// ✅ FIXED
      _socket.socket?.emit('rejectCall', {'appointmentId': channelId});
    }

    await endCall();
  }

  /// ---------------- END CALL (PUBLIC) ----------------
  Future<void> endCall() async {
    log('📴 endCall() pressed');

    if (_callEnded) {
      log('⛔ endCall ignored — already ended');
      return;
    }

    log('📡 SOCKET EMIT: endCall');

    if (Platform.isIOS) {
      /// ✅ FIXED
      _socket.socket?.emit('endCall', {'appointmentId': channelId});
      await FlutterCallkitIncoming.endCall(channelId);

      // 2. Clear all system notifications
      await FlutterCallkitIncoming.endAllCalls();
      await AwesomeNotifications().cancelAll();

      // 3. Clean up Agora (Assuming you have an engine instance)
      // await _engine.leaveChannel();
      // await _engine.release();

      // 4. Update your local state/UI
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isCallAccepted', false);
    }

    await _endCall();

    log('🚪 Navigating to WaitingForPrescriptionScreen');
    Get.offAll(() => const WaitingForPrescriptionScreen());
  }

  /// ---------------- JOIN AGORA ----------------
  Future<void> _joinAgora() async {
    log('🚀 _joinAgora()');

    if (_joining || _callEnded) {
      log('⛔ Join blocked (joining or ended)');
      return;
    }

    if (channelId.isEmpty || patientToken.isEmpty) {
      log('⛔ channel/token missing');
      return;
    }

    _joining = true;

    try {
      engine ??= createAgoraRtcEngine();

      await engine!.initialize(
        const RtcEngineContext(
          appId: '0fb1a1ecf5a34db2b51d9896c994652a',
          channelProfile: ChannelProfileType.channelProfileCommunication,
        ),
      );

      engine!.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (_, __) {
            log('✅ Patient joined channel');
            isJoined.value = true;
          },
          onUserJoined: (_, uid, __) {
            log('👨‍⚕️ Doctor joined: $uid');
            remoteUid.value = uid;
            isDoctorJoined.value = true;
          },
          onUserOffline: (_, uid, reason) {
            log('🚪 Doctor offline → $uid | reason: $reason');

            if (_callEnded) return;

            endCall();
          },
        ),
      );

      await engine!.setClientRole(role: ClientRoleType.clientRoleBroadcaster);

      await engine!.enableVideo();
      await engine!.enableAudio();

      await engine!.setupLocalVideo(const VideoCanvas(uid: 0));

      await engine!.startPreview();

      await engine!.joinChannel(
        token: patientToken,
        channelId: channelId,
        uid: 0,
        options: const ChannelMediaOptions(
          publishCameraTrack: true,
          publishMicrophoneTrack: true,
          autoSubscribeAudio: true,
          autoSubscribeVideo: true,
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
        ),
      );

      log('📡 joinChannel request sent');
    } catch (e, s) {
      log('🔥 JOIN ERROR: $e');
      log('📄 STACK: $s');
    } finally {
      _joining = false;
    }
  }

  /// ---------------- CONTROLS ----------------
  void toggleMute() {
    isMuted.toggle();
    engine?.muteLocalAudioStream(isMuted.value);
    log('🎤 mute: ${isMuted.value}');
  }

  void toggleSpeaker() async {
    isSpeakerOn.toggle();
    await engine?.setEnableSpeakerphone(isSpeakerOn.value);
    log('🔊 speaker: ${isSpeakerOn.value}');
  }

  void switchCamera() {
    engine?.switchCamera();
    log('🔄 camera switched');
  }

  /// ---------------- INTERNAL END ----------------
  Future<void> _endCall() async {
    if (_callEnded == false) {
      _callEnded = true;
    }

    log('🧹 Cleaning call resources');

    try {
      await engine?.leaveChannel();
      await engine?.stopPreview();
      await engine?.release();
      log('🗑️ Agora released');
    } catch (e) {
      log('⚠️ end error: $e');
    }

    engine = null;

    isJoined.value = false;
    isDoctorJoined.value = false;
    isRinging.value = false;
    remoteUid.value = 0;
    shouldCloseCallScreen.value = true;

    log('✅ Call ended successfully');
  }

  @override
  void onClose() {
    log('🧨 Controller onClose');

    try {
      _socket.disposeSocket();
      log('🔌 Socket disposed');
    } catch (_) {}

    super.onClose();
  }
}
