


// import 'dart:developer';
// import 'package:agora_rtc_engine/agora_rtc_engine.dart';
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
//   // RxBool isSpeakerOn = false.obs;
//   // RxBool shouldCloseCallScreen = false.obs;

//   /// ---------------- DATA ----------------
//   String channelId = '';
//   String patientToken = '';

//   RxString doctorName = 'Doctor'.obs;
//   RxString doctorPhoto = ''.obs;

//   bool _joining = false;
//   bool _callEnded = false;

//   /// ---------------- IMAGE BASE URL (ADDED) ----------------
//   static const String imageBaseUrl =
//       'https://beh-app.s3.eu-north-1.amazonaws.com/';

//   /// ✅ SAFE GETTER (ADDED)
//   /// UI sirf isko use karegi
//   String get doctorImageUrl {
//     final img = doctorPhoto.value.trim();
//     if (img.isEmpty) return '';

//     if (img.startsWith('http')) {
//       return img;
//     }
//     return imageBaseUrl + img;
//   }

//   /// ---------------- INCOMING CALL ----------------
//   void setIncomingCall({
//     required String channel,
//     required String token,
//     String? doctorName,
//     String? doctorPhoto,
//   }) {
//     channelId = channel;
//     patientToken = token;
//     this.doctorName.value = doctorName ?? 'Doctor';
//     this.doctorPhoto.value = doctorPhoto ?? '';
//     _callEnded = false;
//   }

//   /// ---------------- ACCEPT ----------------
//   Future<void> acceptCall() async {
//     await _joinAgora();
//   }

//   /// ---------------- DECLINE / END ----------------
//   Future<void> declineCall() async {
//     await _endCall();
//   }

//   /// ---------------- JOIN AGORA ----------------
//   Future<void> _joinAgora() async {
//     if (_joining) return;
//     if (channelId.isEmpty || patientToken.isEmpty) return;

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
//             log('✅ Patient joined');
//             isJoined.value = true;
//           },
//           onUserJoined: (_, uid, __) {
//             log('👨‍⚕️ Doctor joined');
//             remoteUid.value = uid;
//             isDoctorJoined.value = true;
//           },
//           onUserOffline: (_, __, ___) {
//             _endCall();
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
//     } catch (e) {
//       log('🔥 Join error: $e');
//     } finally {
//       _joining = false;
//     }
//   }

//   /// ---------------- CONTROLS ----------------
//   void toggleMute() {
//     isMuted.value = !isMuted.value;
//     engine?.muteLocalAudioStream(isMuted.value);
//   }

//   void toggleSpeaker() async {
//     isSpeakerOn.value = !isSpeakerOn.value;
//     await engine?.setEnableSpeakerphone(isSpeakerOn.value);
//   }

//   /// ---------------- END CALL ----------------
//   Future<void> _endCall() async {
//     if (_callEnded) return;
//     _callEnded = true;

//     try {
//       await engine?.leaveChannel();
//       await engine?.release();
//     } catch (_) {}

//     engine = null;
//     shouldCloseCallScreen.value = true;
//     isJoined.value = false;
//     isDoctorJoined.value = false;
//     remoteUid.value = 0;
//   }


//   @override
//   void onClose() {
//     _endCall();
//     super.onClose();
//   }


//   void switchCamera() {
//   engine?.switchCamera();
// }

// }


// import 'dart:developer';
// import 'package:agora_rtc_engine/agora_rtc_engine.dart';
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

//   /// ✅ SAFE IMAGE GETTER
//   String get doctorImageUrl {
//     final img = doctorPhoto.value.trim();
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
//     channelId = channel;
//     patientToken = token;
//     this.doctorName.value = doctorName ?? 'Doctor';
//     this.doctorPhoto.value = doctorPhoto ?? '';
//     _callEnded = false;
//   }

//   /// ---------------- ACCEPT ----------------
//   Future<void> acceptCall() async {
//     await _joinAgora();
//   }

//   /// ---------------- DECLINE ----------------
//   Future<void> declineCall() async {
//     await _endCall();
//   }

//   /// ✅ PUBLIC END CALL (FOR UI BUTTON)
//   /// ❗ UI `c.endCall()` isi ko call karegi
//   Future<void> endCall({bool goBack = true}) async {
//     await _endCall();
//   }

//   /// ---------------- JOIN AGORA ----------------
//   Future<void> _joinAgora() async {
//     if (_joining) return;
//     if (channelId.isEmpty || patientToken.isEmpty) return;

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
//             log('✅ Patient joined');
//             isJoined.value = true;
//           },
//           onUserJoined: (_, uid, __) {
//             log('👨‍⚕️ Doctor joined');
//             remoteUid.value = uid;
//             isDoctorJoined.value = true;
//           },
//           onUserOffline: (_, __, ___) {
//             _endCall();
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
//     } catch (e) {
//       log('🔥 Join error: $e');
//     } finally {
//       _joining = false;
//     }
//   }

//   /// ---------------- CONTROLS ----------------
//   void toggleMute() {
//     isMuted.value = !isMuted.value;
//     engine?.muteLocalAudioStream(isMuted.value);
//   }

//   void toggleSpeaker() async {
//     isSpeakerOn.value = !isSpeakerOn.value;
//     await engine?.setEnableSpeakerphone(isSpeakerOn.value);
//   }

//   void switchCamera() {
//     engine?.switchCamera();
//   }

//   /// ---------------- INTERNAL END CALL ----------------
//   Future<void> _endCall() async {
//     if (_callEnded) return;
//     _callEnded = true;

//     try {
//       await engine?.leaveChannel();
//       await engine?.stopPreview();
//       await engine?.release();
//     } catch (_) {}

//     engine = null;
//     isJoined.value = false;
//     isDoctorJoined.value = false;
//     remoteUid.value = 0;
//     shouldCloseCallScreen.value = true;
//   }

//   @override
//   void onClose() {
//     _endCall();
//     super.onClose();
//   }
// }

import 'dart:developer';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:eye_buddy/features/waiting_for_prescription/view/waiting_for_prescription_screen.dart';
import 'package:get/get.dart';

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
  }

  /// ---------------- ACCEPT ----------------
  Future<void> acceptCall() async {
    log('✅ acceptCall()');

    if (_callEnded) {
      log('⛔ accept ignored, call already ended');
      return;
    }

    isRinging.value = false;
    await _joinAgora();
  }

  /// ---------------- DECLINE ----------------
  Future<void> declineCall() async {
    log('❌ declineCall()');
    await endCall();
  }

  /// ---------------- END CALL (PUBLIC) ----------------


  Future<void> endCall() async {
  log('📴 endCall() pressed');

  if (_callEnded) {
    log('⛔ endCall ignored — already ended');
    return;
  }

  await _endCall();

  /// 🔥 NAVIGATION HERE
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
            log('🚪 Doctor offline → $uid | $reason');

            if (_callEnded) {
              log('⛔ Already ended, ignore offline');
              return;
            }

            endCall(); // 🔥 ONLY SAFE EXIT
          },
        ),
      );

      await engine!.setClientRole(
        role: ClientRoleType.clientRoleBroadcaster,
      );

      await engine!.enableVideo();
      await engine!.enableAudio();

      await engine!.setupLocalVideo(
        const VideoCanvas(uid: 0),
      );

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

      log('📡 joinChannel sent');
    } catch (e, s) {
      log('🔥 JOIN ERROR: $e');
      log('📄 $s');
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
    if (_callEnded) {
      log('⛔ _endCall skipped');
      return;
      
    }

    _callEnded = true;
    log('🧹 Cleaning call');

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

    if (!_callEnded) {
      endCall();
    }

    super.onClose();
  }
}
