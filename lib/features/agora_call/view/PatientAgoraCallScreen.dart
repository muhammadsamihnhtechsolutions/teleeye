
// import 'package:agora_rtc_engine/agora_rtc_engine.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:flutter/scheduler.dart';
// import '../controller/PatientAgoraCallController.dart';

// class PatientCallScreen extends StatefulWidget {
//   final String channelId;
//   final String token;
//   final String doctorName;
//   final String doctorPhoto;
//   final bool autoAccept;

//   const PatientCallScreen({
//     super.key,
//     required this.channelId,
//     required this.token,
//     required this.doctorName,
//     required this.doctorPhoto,
//       this.autoAccept = false,
//   });

//   @override
//   State<PatientCallScreen> createState() => _PatientCallScreenState();
// }

// class _PatientCallScreenState extends State<PatientCallScreen> {
//   late PatientAgoraCallController controller;

//   static const String imageBaseUrl =
//       'https://beh-app.s3.eu-north-1.amazonaws.com/';

 

// @override
// void initState() {
//   super.initState();

//   controller = Get.put(
//     PatientAgoraCallController(),
//     tag: widget.channelId,
//   );

//   controller.setIncomingCall(
//     channel: widget.channelId,
//     token: widget.token,
//     doctorName: widget.doctorName,
//     doctorPhoto: widget.doctorPhoto,
//   );

//   /// 🔥 AUTO JOIN IF FROM NOTIFICATION
//   if (widget.autoAccept) {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       controller.acceptCall(); // 👈 yahin se direct video join hota hai
//     });
//   }
// }

//   @override
//   void dispose() {
//     Get.delete<PatientAgoraCallController>(tag: widget.channelId);
//     super.dispose();
//   }

//   String resolveDoctorImage(String path) {
//     final p = path.trim();
//     if (p.isEmpty) return '';
//     if (p.startsWith('http')) return p;
//     return '$imageBaseUrl$p';
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Obx(() {
//         if (controller.shouldCloseCallScreen.value) {
//           Future.microtask(() => Get.back());
//         }

//         if (!controller.isJoined.value) {
//           return IncomingCallUI(
//             doctorName: controller.doctorName.value,
//             imageUrl: resolveDoctorImage(controller.doctorPhoto.value),
//             onAccept: controller.acceptCall,
//             onDecline: controller.declineCall,
//           );
//         }

//         return InCallOverlayUI(
//           controller: controller,
//           channelId: widget.channelId,
//         );
//       }),
//     );
//   }
// }

// /// ================= INCOMING CALL UI =================
// class IncomingCallUI extends StatelessWidget {
//   final String doctorName;
//   final String imageUrl;
//   final VoidCallback onAccept;
//   final VoidCallback onDecline;

//   const IncomingCallUI({
//     super.key,
//     required this.doctorName,
//     required this.imageUrl,
//     required this.onAccept,
//     required this.onDecline,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 24),
//         child: Column(
//           children: [
//             const SizedBox(height: 24),

//             /// Incoming text
//             const Text(
//               'Incoming call...',
//               style: TextStyle(
//                 color: Colors.grey,
//                 fontSize: 14,
//               ),
//             ),

//             const SizedBox(height: 10),

//             /// Doctor name
//             Text(
//               doctorName,
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                 fontSize: 22,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),

//             const SizedBox(height: 40),

//             /// PROFILE IMAGE (TRUE CENTER)
//             Expanded(
//               child: Center(
//                 child: Container(
//                   padding: const EdgeInsets.all(6),
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     border: Border.all(color: Colors.green, width: 5),
//                   ),
//                   child: CircleAvatar(
//                     radius: 90,
//                     backgroundColor: Colors.grey.shade200,
//                     child: ClipOval(
//                       child: imageUrl.isNotEmpty
//                           ? Image.network(
//                               imageUrl,
//                               width: 180,
//                               height: 180,
//                               fit: BoxFit.cover,
//                               loadingBuilder:
//                                   (context, child, loadingProgress) {
//                                 if (loadingProgress == null) return child;
//                                 return const Center(
//                                   child: SizedBox(
//                                     width: 28,
//                                     height: 28,
//                                     child: CircularProgressIndicator(
//                                       strokeWidth: 2.5,
//                                       color: Colors.green,
//                                     ),
//                                   ),
//                                 );
//                               },
//                               errorBuilder: (_, __, ___) {
//                                 return const Icon(
//                                   Icons.person,
//                                   size: 70,
//                                   color: Colors.white,
//                                 );
//                               },
//                             )
//                           : const Icon(
//                               Icons.person,
//                               size: 70,
//                               color: Colors.white,
//                             ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),

//             /// BUTTONS (CENTERED + BALANCED)
//             Padding(
//               padding: const EdgeInsets.only(bottom: 30, top: 20),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   AgoraCallButton(
//                     buttonColor: Colors.red,
//                     icon: Icons.call_end,
//                     iconColor: Colors.white,
//                     callBackFunction: onDecline,
//                   ),
//                   const SizedBox(width: 60),
//                   AgoraCallButton(
//                     buttonColor: Colors.green,
//                     icon: Icons.call,
//                     iconColor: Colors.white,
//                     callBackFunction: onAccept,
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// /// ================= IN CALL UI =================
// class InCallOverlayUI extends StatefulWidget {
//   final PatientAgoraCallController controller;
//   final String channelId;

//   const InCallOverlayUI({
//     super.key,
//     required this.controller,
//     required this.channelId,
//   });

//   @override
//   State<InCallOverlayUI> createState() => _InCallOverlayUIState();
// }

// class _InCallOverlayUIState extends State<InCallOverlayUI>
//     with SingleTickerProviderStateMixin {
//   late final Stopwatch _stopwatch;
//   late final Ticker _ticker;

//   late AnimationController _waveController;
//   late Animation<double> _waveAnimation;

//   @override
//   void initState() {
//     super.initState();

//     _stopwatch = Stopwatch();
//     _ticker = Ticker((_) {
//       if (mounted) setState(() {});
//     })..start();

//     _waveController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 700),
//     );

//     _waveAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _waveController,
//         curve: Curves.easeInOut,
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _ticker.dispose();
//     _waveController.dispose();
//     super.dispose();
//   }

//   String _formatTime() {
//     final d = _stopwatch.elapsed;
//     final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
//     final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
//     return '$m:$s';
//   }

//   String _resolveDoctorImage(String path) {
//     if (path.isEmpty) return '';
//     if (path.startsWith('http')) return path;
//     return 'https://beh-app.s3.eu-north-1.amazonaws.com/$path';
//   }

//   @override
//   Widget build(BuildContext context) {
//     final c = widget.controller;

//     if (!_stopwatch.isRunning && c.remoteUid.value > 0) {
//       _stopwatch.start();
//     }

//     return Obx(() {
//       final img = _resolveDoctorImage(c.doctorPhoto.value);

//       if (c.isSpeakerOn.value) {
//         if (!_waveController.isAnimating) {
//           _waveController.repeat(reverse: true);
//         }
//       } else {
//         _waveController.stop();
//         _waveController.reset();
//       }

//       return Stack(
//         children: [
//           if (c.engine != null && c.remoteUid.value > 0)
//             Positioned.fill(
//               child: AgoraVideoView(
//                 controller: VideoViewController.remote(
//                   rtcEngine: c.engine!,
//                   canvas: VideoCanvas(uid: c.remoteUid.value),
//                   connection:
//                       RtcConnection(channelId: widget.channelId),
//                 ),
//               ),
//             ),

//           if (c.engine != null)
//             Positioned(
//               top: 48,
//               right: 16,
//               width: 110,
//               height: 150,
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(14),
//                 child: AgoraVideoView(
//                   controller: VideoViewController(
//                     rtcEngine: c.engine!,
//                     canvas: const VideoCanvas(uid: 0),
//                   ),
//                 ),
//               ),
//             ),

//           if (c.remoteUid.value > 0)
//             Positioned(
//               left: 16,
//               right: 16,
//               bottom: 110,
//               child: Container(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.6),
//                   borderRadius: BorderRadius.circular(40),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.12),
//                       blurRadius: 8,
//                     ),
//                   ],
//                 ),
//                 child: Row(
//                   children: [
//                     CircleAvatar(
//                       radius: 24,
//                       backgroundColor: Colors.grey.shade300,
//                       backgroundImage:
//                           img.isNotEmpty ? NetworkImage(img) : null,
//                       child: img.isEmpty
//                           ? const Icon(Icons.person)
//                           : null,
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             c.doctorName.value,
//                             style: const TextStyle(
//                                 fontWeight: FontWeight.w600),
//                           ),
//                           Text(
//                             _formatTime(),
//                             style: const TextStyle(fontSize: 12),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Container(
//                       height: 40,
//                       width: 40,
//                       decoration: const BoxDecoration(
//                         color: Colors.green,
//                         shape: BoxShape.circle,
//                       ),
//                       child: ScaleTransition(
//                         scale: _waveAnimation,
//                         child: const Icon(Icons.graphic_eq,
//                             color: Colors.white),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//           Positioned(
//             left: 0,
//             right: 0,
//             bottom: 30,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 AgoraCallButton(
//                   buttonColor: const Color(0xFFCCE7D9),
//                   icon: Icons.fiber_manual_record,
//                   iconColor: Colors.red,
//                   callBackFunction: () {},
//                 ),
//                 const SizedBox(width: 16),
//                 AgoraCallButton(
//                   buttonColor: const Color(0xFFCCE7D9),
//                   icon: c.isSpeakerOn.value
//                       ? Icons.volume_up
//                       : Icons.volume_off,
//                   iconColor: const Color(0xFF008541),
//                   callBackFunction: c.toggleSpeaker,
//                 ),
//                 const SizedBox(width: 16),
//                 AgoraCallButton(
//                   buttonColor: const Color(0xFFCCE7D9),
//                   icon: Icons.flip_camera_ios_outlined,
//                   iconColor: const Color(0xFF008541),
//                   callBackFunction: c.switchCamera,
//                 ),
//                 const SizedBox(width: 16),
//                 AgoraCallButton(
//                   buttonColor: const Color(0xFFEFEFEF),
//                   icon: c.isMuted.value
//                       ? Icons.mic_off_outlined
//                       : Icons.mic_none_outlined,
//                   iconColor:
//                       c.isMuted.value ? Colors.red : Colors.black,
//                   callBackFunction: c.toggleMute,
//                 ),
//                 const SizedBox(width: 16),
//                 AgoraCallButton(
//                   buttonColor: const Color(0xFFF14F4A),
//                   icon: Icons.phone,
//                   iconColor: Colors.white,
//                   callBackFunction: c.endCall,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       );
//     });
//   }
// }

// /// ================= REUSABLE BUTTON =================
// class AgoraCallButton extends StatelessWidget {
//   final Color buttonColor;
//   final IconData icon;
//   final Color iconColor;
//   final VoidCallback callBackFunction;

//   const AgoraCallButton({
//     super.key,
//     required this.buttonColor,
//     required this.icon,
//     required this.iconColor,
//     required this.callBackFunction,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: callBackFunction,
//       borderRadius: BorderRadius.circular(40),
//       child: Container(
//         width: 60,
//         height: 60,
//         decoration: BoxDecoration(
//           color: buttonColor,
//           shape: BoxShape.circle,
//         ),
//         child: Icon(icon, color: iconColor, size: 26),
//       ),
//     );
//   }
// }




// import 'package:agora_rtc_engine/agora_rtc_engine.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:flutter/scheduler.dart';
// import '../controller/PatientAgoraCallController.dart';

// class PatientCallScreen extends StatefulWidget {
//   final String channelId;
//   final String token;
//   final String doctorName;
//   final String doctorPhoto;
//   final bool autoAccept;

//   const PatientCallScreen({
//     super.key,
//     required this.channelId,
//     required this.token,
//     required this.doctorName,
//     required this.doctorPhoto,
//       this.autoAccept = false,
//   });

//   @override
//   State<PatientCallScreen> createState() => _PatientCallScreenState();
// }

// class _PatientCallScreenState extends State<PatientCallScreen> {
//   late PatientAgoraCallController controller;

//   static const String imageBaseUrl =
//       'https://beh-app.s3.eu-north-1.amazonaws.com/';

 

// @override
// void initState() {
//   super.initState();

//   controller = Get.put(
//     PatientAgoraCallController(),
//     tag: widget.channelId,
//   );

//   controller.setIncomingCall(
//     channel: widget.channelId,
//     token: widget.token,
//     doctorName: widget.doctorName,
//     doctorPhoto: widget.doctorPhoto,
//   );

//   /// 🔥 AUTO JOIN IF FROM NOTIFICATION
//   if (widget.autoAccept) {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       controller.acceptCall(); // 👈 yahin se direct video join hota hai
//     });
//   }
// }

//   @override
//   void dispose() {
//     Get.delete<PatientAgoraCallController>(tag: widget.channelId);
//     super.dispose();
//   }

//   String resolveDoctorImage(String path) {
//     final p = path.trim();
//     if (p.isEmpty) return '';
//     if (p.startsWith('http')) return p;
//     return '$imageBaseUrl$p';
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Obx(() {
//         if (controller.shouldCloseCallScreen.value) {
//           Future.microtask(() => Get.back());
//         }

//         if (!controller.isJoined.value) {
//           return IncomingCallUI(
//             doctorName: controller.doctorName.value,
//             imageUrl: resolveDoctorImage(controller.doctorPhoto.value),
//             onAccept: controller.acceptCall,
//             onDecline: controller.declineCall,
//           );
//         }

//         return InCallOverlayUI(
//           controller: controller,
//           channelId: widget.channelId,
//         );
//       }),
//     );
//   }
// }

// /// ================= INCOMING CALL UI =================
// class IncomingCallUI extends StatelessWidget {
//   final String doctorName;
//   final String imageUrl;
//   final VoidCallback onAccept;
//   final VoidCallback onDecline;

//   const IncomingCallUI({
//     super.key,
//     required this.doctorName,
//     required this.imageUrl,
//     required this.onAccept,
//     required this.onDecline,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 24),
//         child: Column(
//           children: [
//             const SizedBox(height: 24),

//             /// Incoming text
//             const Text(
//               'Incoming call...',
//               style: TextStyle(
//                 color: Colors.grey,
//                 fontSize: 14,
//               ),
//             ),

//             const SizedBox(height: 10),

//             /// Doctor name
//             Text(
//               doctorName,
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                 fontSize: 22,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),

//             const SizedBox(height: 40),

//             /// PROFILE IMAGE (TRUE CENTER)
//             Expanded(
//               child: Center(
//                 child: Container(
//                   padding: const EdgeInsets.all(6),
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     border: Border.all(color: Colors.green, width: 5),
//                   ),
//                   child: CircleAvatar(
//                     radius: 90,
//                     backgroundColor: Colors.grey.shade200,
//                     child: ClipOval(
//                       child: imageUrl.isNotEmpty
//                           ? Image.network(
//                               imageUrl,
//                               width: 180,
//                               height: 180,
//                               fit: BoxFit.cover,
//                               loadingBuilder:
//                                   (context, child, loadingProgress) {
//                                 if (loadingProgress == null) return child;
//                                 return const Center(
//                                   child: SizedBox(
//                                     width: 28,
//                                     height: 28,
//                                     child: CircularProgressIndicator(
//                                       strokeWidth: 2.5,
//                                       color: Colors.green,
//                                     ),
//                                   ),
//                                 );
//                               },
//                               errorBuilder: (_, __, ___) {
//                                 return const Icon(
//                                   Icons.person,
//                                   size: 70,
//                                   color: Colors.white,
//                                 );
//                               },
//                             )
//                           : const Icon(
//                               Icons.person,
//                               size: 70,
//                               color: Colors.white,
//                             ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),

//             /// BUTTONS (CENTERED + BALANCED)
//             Padding(
//               padding: const EdgeInsets.only(bottom: 30, top: 20),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   AgoraCallButton(
//                     buttonColor: Colors.red,
//                     icon: Icons.call_end,
//                     iconColor: Colors.white,
//                     callBackFunction: onDecline,
//                   ),
//                   const SizedBox(width: 60),
//                   AgoraCallButton(
//                     buttonColor: Colors.green,
//                     icon: Icons.call,
//                     iconColor: Colors.white,
//                     callBackFunction: onAccept,
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// /// ================= IN CALL UI =================
// class InCallOverlayUI extends StatefulWidget {
//   final PatientAgoraCallController controller;
//   final String channelId;

//   const InCallOverlayUI({
//     super.key,
//     required this.controller,
//     required this.channelId,
//   });

//   @override
//   State<InCallOverlayUI> createState() => _InCallOverlayUIState();
// }

// class _InCallOverlayUIState extends State<InCallOverlayUI>
//     with SingleTickerProviderStateMixin {
//   late final Stopwatch _stopwatch;
//   late final Ticker _ticker;

//   late AnimationController _waveController;
//   late Animation<double> _waveAnimation;

//   @override
//   void initState() {
//     super.initState();

//     _stopwatch = Stopwatch();
//     _ticker = Ticker((_) {
//       if (mounted) setState(() {});
//     })..start();

//     _waveController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 700),
//     );

//     _waveAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _waveController,
//         curve: Curves.easeInOut,
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _ticker.dispose();
//     _waveController.dispose();
//     super.dispose();
//   }

//   String _formatTime() {
//     final d = _stopwatch.elapsed;
//     final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
//     final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
//     return '$m:$s';
//   }

//   String _resolveDoctorImage(String path) {
//     if (path.isEmpty) return '';
//     if (path.startsWith('http')) return path;
//     return 'https://beh-app.s3.eu-north-1.amazonaws.com/$path';
//   }

//   @override
//   Widget build(BuildContext context) {
//     final c = widget.controller;

//     if (!_stopwatch.isRunning && c.remoteUid.value > 0) {
//       _stopwatch.start();
//     }

//     return Obx(() {
//       final img = _resolveDoctorImage(c.doctorPhoto.value);

//       if (c.isSpeakerOn.value) {
//         if (!_waveController.isAnimating) {
//           _waveController.repeat(reverse: true);
//         }
//       } else {
//         _waveController.stop();
//         _waveController.reset();
//       }

//       return Stack(
//         children: [
//           if (c.engine != null && c.remoteUid.value > 0)
//             Positioned.fill(
//               child: AgoraVideoView(
//                 controller: VideoViewController.remote(
//                   rtcEngine: c.engine!,
//                   canvas: VideoCanvas(uid: c.remoteUid.value),
//                   connection:
//                       RtcConnection(channelId: widget.channelId),
//                 ),
//               ),
//             ),

//           if (c.engine != null)
//             Positioned(
//               top: 48,
//               right: 16,
//               width: 110,
//               height: 150,
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(14),
//                 child: AgoraVideoView(
//                   controller: VideoViewController(
//                     rtcEngine: c.engine!,
//                     canvas: const VideoCanvas(uid: 0),
//                   ),
//                 ),
//               ),
//             ),

//           if (c.remoteUid.value > 0)
//             Positioned(
//               left: 16,
//               right: 16,
//               bottom: 110,
//               child: Container(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.6),
//                   borderRadius: BorderRadius.circular(40),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.12),
//                       blurRadius: 8,
//                     ),
//                   ],
//                 ),
//                 child: Row(
//                   children: [
//                     CircleAvatar(
//                       radius: 24,
//                       backgroundColor: Colors.grey.shade300,
//                       backgroundImage:
//                           img.isNotEmpty ? NetworkImage(img) : null,
//                       child: img.isEmpty
//                           ? const Icon(Icons.person)
//                           : null,
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             c.doctorName.value,
//                             style: const TextStyle(
//                                 fontWeight: FontWeight.w600),
//                           ),
//                           Text(
//                             _formatTime(),
//                             style: const TextStyle(fontSize: 12),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Container(
//                       height: 40,
//                       width: 40,
//                       decoration: const BoxDecoration(
//                         color: Colors.green,
//                         shape: BoxShape.circle,
//                       ),
//                       child: ScaleTransition(
//                         scale: _waveAnimation,
//                         child: const Icon(Icons.graphic_eq,
//                             color: Colors.white),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//           Positioned(
//             left: 0,
//             right: 0,
//             bottom: 30,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 AgoraCallButton(
//                   buttonColor: const Color(0xFFCCE7D9),
//                   icon: Icons.fiber_manual_record,
//                   iconColor: Colors.red,
//                   callBackFunction: () {},
//                 ),
//                 const SizedBox(width: 16),
//                 AgoraCallButton(
//                   buttonColor: const Color(0xFFCCE7D9),
//                   icon: c.isSpeakerOn.value
//                       ? Icons.volume_up
//                       : Icons.volume_off,
//                   iconColor: const Color(0xFF008541),
//                   callBackFunction: c.toggleSpeaker,
//                 ),
//                 const SizedBox(width: 16),
//                 AgoraCallButton(
//                   buttonColor: const Color(0xFFCCE7D9),
//                   icon: Icons.flip_camera_ios_outlined,
//                   iconColor: const Color(0xFF008541),
//                   callBackFunction: c.switchCamera,
//                 ),
//                 const SizedBox(width: 16),
//                 AgoraCallButton(
//                   buttonColor: const Color(0xFFEFEFEF),
//                   icon: c.isMuted.value
//                       ? Icons.mic_off_outlined
//                       : Icons.mic_none_outlined,
//                   iconColor:
//                       c.isMuted.value ? Colors.red : Colors.black,
//                   callBackFunction: c.toggleMute,
//                 ),
//                 const SizedBox(width: 16),
//                 AgoraCallButton(
//                   buttonColor: const Color(0xFFF14F4A),
//                   icon: Icons.phone,
//                   iconColor: Colors.white,
//                   callBackFunction: c.endCall,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       );
//     });
//   }
// }

// /// ================= REUSABLE BUTTON =================
// class AgoraCallButton extends StatelessWidget {
//   final Color buttonColor;
//   final IconData icon;
//   final Color iconColor;
//   final VoidCallback callBackFunction;

//   const AgoraCallButton({
//     super.key,
//     required this.buttonColor,
//     required this.icon,
//     required this.iconColor,
//     required this.callBackFunction,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: callBackFunction,
//       borderRadius: BorderRadius.circular(40),
//       child: Container(
//         width: 60,
//         height: 60,
//         decoration: BoxDecoration(
//           color: buttonColor,
//           shape: BoxShape.circle,
//         ),
//         child: Icon(icon, color: iconColor, size: 26),
//       ),
//     );
//   }
// }


// import 'package:agora_rtc_engine/agora_rtc_engine.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:flutter/scheduler.dart';
// import '../controller/PatientAgoraCallController.dart';

// class PatientCallScreen extends StatefulWidget {
//   final String channelId;
//   final String token;
//   final String doctorName;
//   final String doctorPhoto;
//   final bool autoAccept;

//   const PatientCallScreen({
//     super.key,
//     required this.channelId,
//     required this.token,
//     required this.doctorName,
//     required this.doctorPhoto,
//     this.autoAccept = false,
//   });

//   @override
//   State<PatientCallScreen> createState() => _PatientCallScreenState();
// }

// class _PatientCallScreenState extends State<PatientCallScreen> {
//   late PatientAgoraCallController controller;

//   static const String imageBaseUrl =
//       'https://beh-app.s3.eu-north-1.amazonaws.com/';

//   @override
//   void initState() {
//     super.initState();

//     controller = Get.put(
//       PatientAgoraCallController(),
//       tag: widget.channelId,
//     );

//     controller.setIncomingCall(
//       channel: widget.channelId,
//       token: widget.token,
//       doctorName: widget.doctorName,
//       doctorPhoto: widget.doctorPhoto,
//     );

//     /// 🔥 AUTO JOIN IF FROM NOTIFICATION (TERMINATED SAFE)
//     if (widget.autoAccept) {
//       Future.delayed(const Duration(milliseconds: 700), () {
//         if (mounted) {
//           controller.acceptCall(); // ✅ SAFE AUTO JOIN
//         }
//       });
//     }
//   }

//   @override
//   void dispose() {
//     try {
//       final c =
//           Get.find<PatientAgoraCallController>(tag: widget.channelId);
//       c.engine?.leaveChannel();
//       c.engine?.release(); // 🔥 VERY IMPORTANT
//     } catch (_) {}

//     Get.delete<PatientAgoraCallController>(tag: widget.channelId);
//     super.dispose();
//   }

//   String resolveDoctorImage(String path) {
//     final p = path.trim();
//     if (p.isEmpty) return '';
//     if (p.startsWith('http')) return p;
//     return '$imageBaseUrl$p';
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Obx(() {
   

//         if (!controller.isJoined.value) {
//           return IncomingCallUI(
//             doctorName: controller.doctorName.value,
//             imageUrl: resolveDoctorImage(controller.doctorPhoto.value),
//             onAccept: controller.acceptCall,
//             onDecline: controller.declineCall,
//           );
//         }

//         return InCallOverlayUI(
//           controller: controller,
//           channelId: widget.channelId,
//         );
//       }),
//     );
//   }
// }

// /// ================= INCOMING CALL UI =================
// class IncomingCallUI extends StatelessWidget {
//   final String doctorName;
//   final String imageUrl;
//   final VoidCallback onAccept;
//   final VoidCallback onDecline;

//   const IncomingCallUI({
//     super.key,
//     required this.doctorName,
//     required this.imageUrl,
//     required this.onAccept,
//     required this.onDecline,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 24),
//         child: Column(
//           children: [
//             const SizedBox(height: 24),
//             const Text(
//               'Incoming call...',
//               style: TextStyle(color: Colors.grey, fontSize: 14),
//             ),
//             const SizedBox(height: 10),
//             Text(
//               doctorName,
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                 fontSize: 22,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 40),
//             Expanded(
//               child: Center(
//                 child: Container(
//                   padding: const EdgeInsets.all(6),
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     border: Border.all(color: Colors.green, width: 5),
//                   ),
//                   child: CircleAvatar(
//                     radius: 90,
//                     backgroundColor: Colors.grey.shade200,
//                     child: ClipOval(
//                       child: imageUrl.isNotEmpty
//                           ? Image.network(
//                               imageUrl,
//                               width: 180,
//                               height: 180,
//                               fit: BoxFit.cover,
//                               loadingBuilder:
//                                   (context, child, loadingProgress) {
//                                 if (loadingProgress == null) return child;
//                                 return const Center(
//                                   child: SizedBox(
//                                     width: 28,
//                                     height: 28,
//                                     child: CircularProgressIndicator(
//                                       strokeWidth: 2.5,
//                                       color: Colors.green,
//                                     ),
//                                   ),
//                                 );
//                               },
//                               errorBuilder: (_, __, ___) {
//                                 return const Icon(
//                                   Icons.person,
//                                   size: 70,
//                                   color: Colors.white,
//                                 );
//                               },
//                             )
//                           : const Icon(
//                               Icons.person,
//                               size: 70,
//                               color: Colors.white,
//                             ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.only(bottom: 30, top: 20),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   AgoraCallButton(
//                     buttonColor: Colors.red,
//                     icon: Icons.call_end,
//                     iconColor: Colors.white,
//                     callBackFunction: onDecline,
//                   ),
//                   const SizedBox(width: 60),
//                   AgoraCallButton(
//                     buttonColor: Colors.green,
//                     icon: Icons.call,
//                     iconColor: Colors.white,
//                     callBackFunction: onAccept,
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


// // /// ================= IN CALL UI =================
// class InCallOverlayUI extends StatefulWidget {
//   final PatientAgoraCallController controller;
//   final String channelId;

//   const InCallOverlayUI({
//     super.key,
//     required this.controller,
//     required this.channelId,
//   });

//   @override
//   State<InCallOverlayUI> createState() => _InCallOverlayUIState();
// }

// class _InCallOverlayUIState extends State<InCallOverlayUI>
//     with SingleTickerProviderStateMixin {
//   late final Stopwatch _stopwatch;
//   late final Ticker _ticker;

//   late AnimationController _waveController;
//   late Animation<double> _waveAnimation;

//   @override
//   void initState() {
//     super.initState();

//     _stopwatch = Stopwatch();
//     _ticker = Ticker((_) {
//       if (mounted) setState(() {});
//     })..start();

//     _waveController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 700),
//     );

//     _waveAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _waveController,
//         curve: Curves.easeInOut,
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _ticker.dispose();
//     _waveController.dispose();
//     super.dispose();
//   }

//   String _formatTime() {
//     final d = _stopwatch.elapsed;
//     final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
//     final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
//     return '$m:$s';
//   }

//   String _resolveDoctorImage(String path) {
//     if (path.isEmpty) return '';
//     if (path.startsWith('http')) return path;
//     return 'https://beh-app.s3.eu-north-1.amazonaws.com/$path';
//   }

//   @override
//   Widget build(BuildContext context) {
//     final c = widget.controller;

//     if (!_stopwatch.isRunning && c.remoteUid.value > 0) {
//       _stopwatch.start();
//     }

//     return Obx(() {
//       final img = _resolveDoctorImage(c.doctorPhoto.value);

//       if (c.isSpeakerOn.value) {
//         if (!_waveController.isAnimating) {
//           _waveController.repeat(reverse: true);
//         }
//       } else {
//         _waveController.stop();
//         _waveController.reset();
//       }

//       return Stack(
//         children: [
//           if (c.engine != null && c.remoteUid.value > 0)
//             Positioned.fill(
//               child: AgoraVideoView(
//                 controller: VideoViewController.remote(
//                   rtcEngine: c.engine!,
//                   canvas: VideoCanvas(uid: c.remoteUid.value),
//                   connection:
//                       RtcConnection(channelId: widget.channelId),
//                 ),
//               ),
//             ),

//           if (c.engine != null)
//             Positioned(
//               top: 48,
//               right: 16,
//               width: 110,
//               height: 150,
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(14),
//                 child: AgoraVideoView(
//                   controller: VideoViewController(
//                     rtcEngine: c.engine!,
//                     canvas: const VideoCanvas(uid: 0),
//                   ),
//                 ),
//               ),
//             ),

//           if (c.remoteUid.value > 0)
//             Positioned(
//               left: 16,
//               right: 16,
//               bottom: 110,
//               child: Container(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.6),
//                   borderRadius: BorderRadius.circular(40),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.12),
//                       blurRadius: 8,
//                     ),
//                   ],
//                 ),
//                 child: Row(
//                   children: [
//                     CircleAvatar(
//                       radius: 24,
//                       backgroundColor: Colors.grey.shade300,
//                       backgroundImage:
//                           img.isNotEmpty ? NetworkImage(img) : null,
//                       child: img.isEmpty
//                           ? const Icon(Icons.person)
//                           : null,
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             c.doctorName.value,
//                             style: const TextStyle(
//                                 fontWeight: FontWeight.w600),
//                           ),
//                           Text(
//                             _formatTime(),
//                             style: const TextStyle(fontSize: 12),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Container(
//                       height: 40,
//                       width: 40,
//                       decoration: const BoxDecoration(
//                         color: Colors.green,
//                         shape: BoxShape.circle,
//                       ),
//                       child: ScaleTransition(
//                         scale: _waveAnimation,
//                         child: const Icon(Icons.graphic_eq,
//                             color: Colors.white),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//           Positioned(
//             left: 0,
//             right: 0,
//             bottom: 30,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 AgoraCallButton(
//                   buttonColor: const Color(0xFFCCE7D9),
//                   icon: Icons.fiber_manual_record,
//                   iconColor: Colors.red,
//                   callBackFunction: () {},
//                 ),
//                 const SizedBox(width: 16),
//                 AgoraCallButton(
//                   buttonColor: const Color(0xFFCCE7D9),
//                   icon: c.isSpeakerOn.value
//                       ? Icons.volume_up
//                       : Icons.volume_off,
//                   iconColor: const Color(0xFF008541),
//                   callBackFunction: c.toggleSpeaker,
//                 ),
//                 const SizedBox(width: 16),
//                 AgoraCallButton(
//                   buttonColor: const Color(0xFFCCE7D9),
//                   icon: Icons.flip_camera_ios_outlined,
//                   iconColor: const Color(0xFF008541),
//                   callBackFunction: c.switchCamera,
//                 ),
//                 const SizedBox(width: 16),
//                 AgoraCallButton(
//                   buttonColor: const Color(0xFFEFEFEF),
//                   icon: c.isMuted.value
//                       ? Icons.mic_off_outlined
//                       : Icons.mic_none_outlined,
//                   iconColor:
//                       c.isMuted.value ? Colors.red : Colors.black,
//                   callBackFunction: c.toggleMute,
//                 ),
//                 const SizedBox(width: 16),
//                 AgoraCallButton(
//                   buttonColor: const Color(0xFFF14F4A),
//                   icon: Icons.phone,
//                   iconColor: Colors.white,
//                   callBackFunction: c.endCall,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       );
//     });
//   }
// }

// // /// ================= REUSABLE BUTTON =================
// class AgoraCallButton extends StatelessWidget {
//   final Color buttonColor;
//   final IconData icon;
//   final Color iconColor;
//   final VoidCallback callBackFunction;

//   const AgoraCallButton({
//     super.key,
//     required this.buttonColor,
//     required this.icon,
//     required this.iconColor,
//     required this.callBackFunction,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: callBackFunction,
//       borderRadius: BorderRadius.circular(40),
//       child: Container(
//         width: 60,
//         height: 60,
//         decoration: BoxDecoration(
//           color: buttonColor,
//           shape: BoxShape.circle,
//         ),
//         child: Icon(icon, color: iconColor, size: 26),
//       ),
//     );
//   }
// }


import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/scheduler.dart';
import '../controller/PatientAgoraCallController.dart';

class PatientCallScreen extends StatefulWidget {
  final String channelId;
  final String token;
  final String doctorName;
  final String doctorPhoto;
  final bool autoAccept;

  const PatientCallScreen({
    super.key,
    required this.channelId,
    required this.token,
    required this.doctorName,
    required this.doctorPhoto,
    this.autoAccept = false,
  });

  @override
  State<PatientCallScreen> createState() => _PatientCallScreenState();
}

class _PatientCallScreenState extends State<PatientCallScreen> {
  late PatientAgoraCallController controller;
final RxBool _callAccepted = false.obs;

  static const String imageBaseUrl =
      'https://beh-app.s3.eu-north-1.amazonaws.com/';

  @override
  void initState() {
    super.initState();

    controller = Get.put(
      PatientAgoraCallController(),
      tag: widget.channelId,
    );

    controller.setIncomingCall(
      channel: widget.channelId,
      token: widget.token,
      doctorName: widget.doctorName,
      doctorPhoto: widget.doctorPhoto,
    );

    /// 🔥 AUTO JOIN IF FROM NOTIFICATION (TERMINATED SAFE)
if (widget.autoAccept) {
  _callAccepted.value = true; // 👈 ADD THIS
  Future.delayed(const Duration(milliseconds: 700), () {
    if (mounted) {
      controller.acceptCall();
    }
  });
}
  }

  @override
  void dispose() {
    try {
      final c =
          Get.find<PatientAgoraCallController>(tag: widget.channelId);
      c.engine?.leaveChannel();
      c.engine?.release(); // 🔥 VERY IMPORTANT
    } catch (_) {}

    Get.delete<PatientAgoraCallController>(tag: widget.channelId);
    super.dispose();
  }

  String resolveDoctorImage(String path) {
    final p = path.trim();
    if (p.isEmpty) return '';
    if (p.startsWith('http')) return p;
    return '$imageBaseUrl$p';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
   
if (!_callAccepted.value) {
  return IncomingCallUI(
    doctorName: controller.doctorName.value,
    imageUrl: resolveDoctorImage(controller.doctorPhoto.value),
    onAccept: () {
      _callAccepted.value = true;
      controller.acceptCall();
    },
    onDecline: controller.declineCall,
  );
}

return InCallOverlayUI(
  controller: controller,
  channelId: widget.channelId,
);

      }),
    );
  }
}

/// ================= INCOMING CALL UI =================
class IncomingCallUI extends StatelessWidget {
  final String doctorName;
  final String imageUrl;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const IncomingCallUI({
    super.key,
    required this.doctorName,
    required this.imageUrl,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 24),
            const Text(
              'Incoming call...',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 10),
            Text(
              doctorName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            Expanded(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.green, width: 5),
                  ),
                  child: CircleAvatar(
                    radius: 90,
                    backgroundColor: Colors.grey.shade200,
                    child: ClipOval(
                      child: imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              width: 180,
                              height: 180,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(
                                  child: SizedBox(
                                    width: 28,
                                    height: 28,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.green,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (_, __, ___) {
                                return const Icon(
                                  Icons.person,
                                  size: 70,
                                  color: Colors.white,
                                );
                              },
                            )
                          : const Icon(
                              Icons.person,
                              size: 70,
                              color: Colors.white,
                            ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 30, top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AgoraCallButton(
                    buttonColor: Colors.red,
                    icon: Icons.call_end,
                    iconColor: Colors.white,
                    callBackFunction: onDecline,
                  ),
                  const SizedBox(width: 60),
                  AgoraCallButton(
                    buttonColor: Colors.green,
                    icon: Icons.call,
                    iconColor: Colors.white,
                    callBackFunction: onAccept,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// /// ================= IN CALL UI =================
class InCallOverlayUI extends StatefulWidget {
  final PatientAgoraCallController controller;
  final String channelId;

  const InCallOverlayUI({
    super.key,
    required this.controller,
    required this.channelId,
  });

  @override
  State<InCallOverlayUI> createState() => _InCallOverlayUIState();
}

class _InCallOverlayUIState extends State<InCallOverlayUI>
    with SingleTickerProviderStateMixin {
  late final Stopwatch _stopwatch;
  late final Ticker _ticker;

  late AnimationController _waveController;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();

    _stopwatch = Stopwatch();
    _ticker = Ticker((_) {
      if (mounted) setState(() {});
    })..start();

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _waveAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _waveController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _ticker.dispose();
    _waveController.dispose();
    super.dispose();
  }

  String _formatTime() {
    final d = _stopwatch.elapsed;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String _resolveDoctorImage(String path) {
    if (path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    return 'https://beh-app.s3.eu-north-1.amazonaws.com/$path';
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;

    if (!_stopwatch.isRunning && c.remoteUid.value > 0) {
      _stopwatch.start();
    }

    return Obx(() {
      final img = _resolveDoctorImage(c.doctorPhoto.value);

      if (c.isSpeakerOn.value) {
        if (!_waveController.isAnimating) {
          _waveController.repeat(reverse: true);
        }
      } else {
        _waveController.stop();
        _waveController.reset();
      }

      return Stack(
        children: [
          if (c.engine != null && c.remoteUid.value > 0)
            Positioned.fill(
              child: AgoraVideoView(
                controller: VideoViewController.remote(
                  rtcEngine: c.engine!,
                  canvas: VideoCanvas(uid: c.remoteUid.value),
                  connection:
                      RtcConnection(channelId: widget.channelId),
                ),
              ),
            ),

          if (c.engine != null)
            Positioned(
              top: 48,
              right: 16,
              width: 110,
              height: 150,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: AgoraVideoView(
                  controller: VideoViewController(
                    rtcEngine: c.engine!,
                    canvas: const VideoCanvas(uid: 0),
                  ),
                ),
              ),
            ),

          if (c.remoteUid.value > 0)
            Positioned(
              left: 16,
              right: 16,
              bottom: 110,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.grey.shade300,
                      backgroundImage:
                          img.isNotEmpty ? NetworkImage(img) : null,
                      child: img.isEmpty
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c.doctorName.value,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600),
                          ),
                          Text(
                            _formatTime(),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 40,
                      width: 40,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: ScaleTransition(
                        scale: _waveAnimation,
                        child: const Icon(Icons.graphic_eq,
                            color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 30,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AgoraCallButton(
                  buttonColor: const Color(0xFFCCE7D9),
                  icon: Icons.fiber_manual_record,
                  iconColor: Colors.red,
                  callBackFunction: () {},
                ),
                const SizedBox(width: 16),
                AgoraCallButton(
                  buttonColor: const Color(0xFFCCE7D9),
                  icon: c.isSpeakerOn.value
                      ? Icons.volume_up
                      : Icons.volume_off,
                  iconColor: const Color(0xFF008541),
                  callBackFunction: c.toggleSpeaker,
                ),
                const SizedBox(width: 16),
                AgoraCallButton(
                  buttonColor: const Color(0xFFCCE7D9),
                  icon: Icons.flip_camera_ios_outlined,
                  iconColor: const Color(0xFF008541),
                  callBackFunction: c.switchCamera,
                ),
                const SizedBox(width: 16),
                AgoraCallButton(
                  buttonColor: const Color(0xFFEFEFEF),
                  icon: c.isMuted.value
                      ? Icons.mic_off_outlined
                      : Icons.mic_none_outlined,
                  iconColor:
                      c.isMuted.value ? Colors.red : Colors.black,
                  callBackFunction: c.toggleMute,
                ),
                const SizedBox(width: 16),
                AgoraCallButton(
                  buttonColor: const Color(0xFFF14F4A),
                  icon: Icons.phone,
                  iconColor: Colors.white,
                  callBackFunction: c.endCall,
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}

// /// ================= REUSABLE BUTTON =================
class AgoraCallButton extends StatelessWidget {
  final Color buttonColor;
  final IconData icon;
  final Color iconColor;
  final VoidCallback callBackFunction;

  const AgoraCallButton({
    super.key,
    required this.buttonColor,
    required this.icon,
    required this.iconColor,
    required this.callBackFunction,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: callBackFunction,
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: buttonColor,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 26),
      ),
    );
  }
}
