// import 'dart:developer' as developer;

// import 'package:flutter/material.dart';
// import 'package:lottie/lottie.dart';
// import '../../../core/services/utils/assets/app_assets.dart';
// import '../../../core/services/utils/config/app_colors.dart';
// import '../../../core/services/utils/services/navigator_services.dart';
// import '../../../core/services/utils/handlers/agora_call_socket_handler.dart';
// import '../../../core/services/utils/size_config.dart';
// import '../../global_widgets/inter_text.dart';
// import '../../global_widgets/common_network_image_widget.dart';
// import 'agora_call_room_screen.dart';

// class DoctorCallingView extends StatefulWidget {
//   const DoctorCallingView({
//     super.key,
//     required this.name,
//     required this.image,
//     required this.appointmentId,
//   });

//   final String name;
//   final String? image;
//   final String appointmentId;

//   @override
//   State<DoctorCallingView> createState() => _DoctorCallingViewState();
// }

// class _DoctorCallingViewState extends State<DoctorCallingView> {
//   bool _didDisposeSocket = false;

//   @override
//   void initState() {
//     super.initState();

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _initSocket();
//     });
//   }

//   void _disposeSocket({required String reason}) {
//     if (_didDisposeSocket) return;
//     _didDisposeSocket = true;
//     try {
//       // Only remove listeners; keep connection available for the call room.
//       AgoraCallSocketHandler().disposeSocket(disconnect: false);
//     } catch (_) {
//       // ignore
//     }
//   }

//   void _initSocket() {
//     AgoraCallSocketHandler().initSocket(
//       appointmentId: widget.appointmentId,
//       onJoinedEvent: () {
//         if (!mounted) return;
//         developer.log('JOIN FLOW: Doctor joined call (socket event)');
//       },
//       onRejectedEvent: () {
//         if (!mounted) return;
//         developer.log('JOIN FLOW: Doctor rejected call');
//         _disposeSocket(reason: 'doctor_calling_rejected');
//         Navigator.pop(context);
//       },
//       onEndedEvent: () {
//         if (!mounted) return;
//         developer.log('JOIN FLOW: Doctor ended call');
//         _disposeSocket(reason: 'doctor_calling_ended');
//         Navigator.pop(context);
//       },
//     );
//   }

//   @override
//   void dispose() {
//     _disposeSocket(reason: 'doctor_calling_dispose');
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     SizeConfig().init(context);

//     return PopScope(
//       canPop: false,
//       onPopInvokedWithResult: (didPop, result) {},
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         body: Stack(
//           children: [
//             Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     children: [
//                       InterText(
//                         title: 'Calling…',
//                         fontSize: 16,
//                         textColor: Colors.black54,
//                       ),
//                       const SizedBox(height: 8),
//                       InterText(
//                         title: widget.name,
//                         fontSize: 25,
//                         textColor: Colors.black,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 25),
//                 Container(
//                   decoration: BoxDecoration(
//                     border: Border.all(color: AppColors.primaryColor, width: 5),
//                     borderRadius: BorderRadius.circular(
//                       SizeConfig.screenWidth / 2,
//                     ),
//                   ),
//                   padding: const EdgeInsets.all(5),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(
//                       SizeConfig.screenWidth / 2,
//                     ),
//                     child: Container(
//                       height: SizeConfig.screenWidth / 2,
//                       width: SizeConfig.screenWidth / 2,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(
//                           SizeConfig.screenWidth / 2,
//                         ),
//                       ),
//                       child: CommonNetworkImageWidget(
//                         imageLink: widget.image ?? '',
//                         memCacheWidth: 256,
//                         memCacheHeight: 256,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 50),
//               ],
//             ),
//             Positioned(
//               left: 25,
//               bottom: 23,
//               child: InkWell(
//                 onTap: () {
//                   developer.log('DoctorCallingView: call cancelled');
//                   AgoraCallSocketHandler().emitRejectCall(
//                     appointmentId: widget.appointmentId,
//                   );
//                   _disposeSocket(reason: 'doctor_calling_cancel');
//                   Navigator.pop(context);
//                 },
//                 child: Image.asset(AppAssets.endCall, width: 100),
//               ),
//             ),
//             Positioned(
//               right: 0,
//               bottom: 0,
//               child: InkWell(
//                 onTap: () {
//                   _disposeSocket(reason: 'doctor_calling_enter_room');
//                   NavigatorServices().toReplacement(
//                     context: context,
//                     widget: AgoraCallScreen(
//                       name: widget.name,
//                       image: widget.image,
//                       appointmentId: widget.appointmentId,
//                       asDoctor: true,
//                     ),
//                   );
//                 },
//                 child: SizedBox(
//                   height: 140,
//                   child: Align(
//                     child: LottieBuilder.asset(AppAssets.acceptCall),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

