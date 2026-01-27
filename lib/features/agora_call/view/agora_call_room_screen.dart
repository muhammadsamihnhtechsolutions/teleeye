// import 'dart:async';
// import 'dart:developer' as developer;
// import 'dart:io';

// import 'package:agora_rtc_engine/agora_rtc_engine.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:stop_watch_timer/stop_watch_timer.dart';
// import 'package:wakelock_plus/wakelock_plus.dart';

// import '../controller/agora_singleton.dart';
// import '../controller/call_controller.dart';
// import '../../../core/services/api/service/api_constants.dart';
// import '../../../core/services/api/repo/api_repo.dart';
// import '../../../core/services/api/model/app_test_result_response_model.dart';
// import '../../../core/services/api/model/test_result_response_model.dart';
// import '../../../core/services/utils/keys/shared_pref_keys.dart';
// import '../../waiting_for_prescription/view/waiting_for_prescription_screen.dart';

// void dLog(String message, {Object? error, StackTrace? stackTrace}) {
//   if (!kDebugMode) return;
//   developer.log(message, error: error, stackTrace: stackTrace);
// }

// class AgoraCallScreen extends StatelessWidget {
//   AgoraCallScreen({
//     super.key,
//     required this.name,
//     required this.image,
//     required this.appointmentId,
//     this.asDoctor = false,
//   });

//   final String name;
//   final String? image;
//   final String appointmentId;
//   final bool asDoctor;

//   @override
//   Widget build(BuildContext context) {
//     return _AgoraCallRoomView(
//       name: name,
//       image: image,
//       appointmentId: appointmentId,
//       asDoctor: asDoctor,
//     );
//   }
// }

// class _CallRecordsBottomSheet extends StatefulWidget {
//   const _CallRecordsBottomSheet({required this.apiRepo});

//   final ApiRepo apiRepo;

//   @override
//   State<_CallRecordsBottomSheet> createState() =>
//       _CallRecordsBottomSheetState();
// }

// class _CallRecordsBottomSheetState extends State<_CallRecordsBottomSheet> {
//   late Future<AppTestResultResponseModel> _appTestFuture;
//   late Future<TestResultResponseModel> _clinicalFuture;

//   bool _isImageUrl(String url) {
//     final u = url.toLowerCase();
//     return u.endsWith('.png') ||
//         u.endsWith('.jpg') ||
//         u.endsWith('.jpeg') ||
//         u.endsWith('.webp') ||
//         u.endsWith('.gif');
//   }

//   String _resolveAttachmentUrl(String raw) {
//     final trimmed = raw.trim();
//     if (trimmed.isEmpty) return trimmed;
//     if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
//       return trimmed;
//     }
//     return '${ApiConstants.imageBaseUrl}$trimmed';
//   }

//   @override
//   void initState() {
//     super.initState();
//     _appTestFuture = widget.apiRepo.getAppTestResult();
//     _clinicalFuture = widget.apiRepo.getClinicalTestResultData();
//   }

//   String _fmtEye(String? v) {
//     final s = (v ?? '').trim();
//     if (s.isEmpty || s == '--' || s.toLowerCase() == 'null') return '-';
//     return s;
//   }

//   Widget _kvRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Flexible(
//             child: Text(
//               label,
//               style: const TextStyle(color: Colors.black54, fontSize: 13),
//             ),
//           ),
//           const SizedBox(width: 12),
//           Text(
//             value,
//             style: const TextStyle(
//               color: Colors.black,
//               fontSize: 13,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final height = MediaQuery.of(context).size.height;
//     return SafeArea(
//       child: SizedBox(
//         height: height * 0.7,
//         child: DefaultTabController(
//           length: 2,
//           child: Column(
//             children: [
//               const SizedBox(height: 10),
//               Container(
//                 width: 44,
//                 height: 5,
//                 decoration: BoxDecoration(
//                   color: Colors.black12,
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//               const SizedBox(height: 12),
//               const Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 16),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: Text(
//                         'Patient Records',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w700,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 10),
//               const Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 16),
//                 child: TabBar(
//                   labelColor: Color(0xFF008541),
//                   unselectedLabelColor: Colors.black54,
//                   indicatorColor: Color(0xFF008541),
//                   tabs: [
//                     Tab(text: 'App Test'),
//                     Tab(text: 'Clinical'),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 6),
//               Expanded(
//                 child: TabBarView(
//                   children: [
//                     FutureBuilder<AppTestResultResponseModel>(
//                       future: _appTestFuture,
//                       builder: (context, snapshot) {
//                         if (snapshot.connectionState ==
//                             ConnectionState.waiting) {
//                           return const Center(
//                             child: CircularProgressIndicator(),
//                           );
//                         }
//                         final data = snapshot.data;
//                         final test = data?.appTestData;
//                         if (test == null) {
//                           return const Center(
//                             child: Text('No app test results found'),
//                           );
//                         }

//                         final vaLeft = _fmtEye(test.visualAcuity?.left?.os);
//                         final vaRight = _fmtEye(test.visualAcuity?.right?.od);
//                         final nearLeft = _fmtEye(test.nearVision?.left?.os);
//                         final nearRight = _fmtEye(test.nearVision?.right?.od);
//                         final colorLeft = _fmtEye(test.colorVision?.left);
//                         final colorRight = _fmtEye(test.colorVision?.right);
//                         final amdLeft = _fmtEye(test.amdVision?.left);
//                         final amdRight = _fmtEye(test.amdVision?.right);

//                         return ListView(
//                           padding: const EdgeInsets.all(16),
//                           children: [
//                             Container(
//                               padding: const EdgeInsets.all(14),
//                               decoration: BoxDecoration(
//                                 color: Colors.grey.shade100,
//                                 borderRadius: BorderRadius.circular(14),
//                               ),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   const Text(
//                                     'Visual Acuity',
//                                     style: TextStyle(
//                                       fontWeight: FontWeight.w700,
//                                     ),
//                                   ),
//                                   _kvRow('Left (OS)', vaLeft),
//                                   _kvRow('Right (OD)', vaRight),
//                                 ],
//                               ),
//                             ),
//                             const SizedBox(height: 12),
//                             Container(
//                               padding: const EdgeInsets.all(14),
//                               decoration: BoxDecoration(
//                                 color: Colors.grey.shade100,
//                                 borderRadius: BorderRadius.circular(14),
//                               ),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   const Text(
//                                     'Near Vision',
//                                     style: TextStyle(
//                                       fontWeight: FontWeight.w700,
//                                     ),
//                                   ),
//                                   _kvRow('Left (OS)', nearLeft),
//                                   _kvRow('Right (OD)', nearRight),
//                                 ],
//                               ),
//                             ),
//                             const SizedBox(height: 12),
//                             Container(
//                               padding: const EdgeInsets.all(14),
//                               decoration: BoxDecoration(
//                                 color: Colors.grey.shade100,
//                                 borderRadius: BorderRadius.circular(14),
//                               ),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   const Text(
//                                     'Color Vision',
//                                     style: TextStyle(
//                                       fontWeight: FontWeight.w700,
//                                     ),
//                                   ),
//                                   _kvRow('Left', colorLeft),
//                                   _kvRow('Right', colorRight),
//                                 ],
//                               ),
//                             ),
//                             const SizedBox(height: 12),
//                             Container(
//                               padding: const EdgeInsets.all(14),
//                               decoration: BoxDecoration(
//                                 color: Colors.grey.shade100,
//                                 borderRadius: BorderRadius.circular(14),
//                               ),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   const Text(
//                                     'AMD Vision',
//                                     style: TextStyle(
//                                       fontWeight: FontWeight.w700,
//                                     ),
//                                   ),
//                                   _kvRow('Left', amdLeft),
//                                   _kvRow('Right', amdRight),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         );
//                       },
//                     ),
//                     FutureBuilder<TestResultResponseModel>(
//                       future: _clinicalFuture,
//                       builder: (context, snapshot) {
//                         if (snapshot.connectionState ==
//                             ConnectionState.waiting) {
//                           return const Center(
//                             child: CircularProgressIndicator(),
//                           );
//                         }
//                         final docs =
//                             snapshot.data?.data?.docs ?? const <TestResult>[];
//                         if (docs.isEmpty) {
//                           return const Center(
//                             child: Text('No clinical results found'),
//                           );
//                         }
//                         return ListView.separated(
//                           padding: const EdgeInsets.all(16),
//                           itemCount: docs.length,
//                           separatorBuilder: (_, __) =>
//                               const SizedBox(height: 10),
//                           itemBuilder: (context, index) {
//                             final item = docs[index];
//                             final title = (item.title ?? '').trim().isEmpty
//                                 ? 'Clinical Result'
//                                 : (item.title ?? '').trim();
//                             final createdAt = (item.createdAt ?? '').toString();
//                             final attachment = (item.attachment ?? '')
//                                 .toString();
//                             final attachmentUrl = _resolveAttachmentUrl(
//                               attachment,
//                             );
//                             final showImageThumb =
//                                 attachmentUrl.isNotEmpty &&
//                                 _isImageUrl(attachmentUrl);
//                             return Container(
//                               padding: const EdgeInsets.all(14),
//                               decoration: BoxDecoration(
//                                 color: Colors.grey.shade100,
//                                 borderRadius: BorderRadius.circular(14),
//                               ),
//                               child: Row(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Expanded(
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Text(
//                                           title,
//                                           style: const TextStyle(
//                                             fontWeight: FontWeight.w700,
//                                           ),
//                                         ),
//                                         const SizedBox(height: 6),
//                                         if (createdAt.trim().isNotEmpty)
//                                           Text(
//                                             createdAt,
//                                             style: const TextStyle(
//                                               color: Colors.black54,
//                                               fontSize: 12,
//                                             ),
//                                           ),
//                                         if (attachment.trim().isNotEmpty) ...[
//                                           const SizedBox(height: 6),
//                                           Text(
//                                             attachment,
//                                             maxLines: 1,
//                                             overflow: TextOverflow.ellipsis,
//                                             style: const TextStyle(
//                                               color: Colors.black54,
//                                               fontSize: 12,
//                                             ),
//                                           ),
//                                         ],
//                                       ],
//                                     ),
//                                   ),
//                                   if (showImageThumb) ...[
//                                     const SizedBox(width: 10),
//                                     GestureDetector(
//                                       onTap: () {
//                                         showDialog<void>(
//                                           context: context,
//                                           builder: (_) {
//                                             return Dialog(
//                                               insetPadding:
//                                                   const EdgeInsets.all(16),
//                                               child: InteractiveViewer(
//                                                 child: Image.network(
//                                                   attachmentUrl,
//                                                   fit: BoxFit.contain,
//                                                   errorBuilder: (_, __, ___) {
//                                                     return const Center(
//                                                       child: Text(
//                                                         'Failed to load image',
//                                                       ),
//                                                     );
//                                                   },
//                                                 ),
//                                               ),
//                                             );
//                                           },
//                                         );
//                                       },
//                                       child: ClipRRect(
//                                         borderRadius: BorderRadius.circular(10),
//                                         child: Container(
//                                           width: 72,
//                                           height: 72,
//                                           color: Colors.white,
//                                           child: Image.network(
//                                             attachmentUrl,
//                                             fit: BoxFit.cover,
//                                             errorBuilder: (_, __, ___) {
//                                               return Container(
//                                                 color: Colors.grey.shade200,
//                                                 child: const Icon(
//                                                   Icons.broken_image,
//                                                   color: Colors.grey,
//                                                 ),
//                                               );
//                                             },
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ],
//                               ),
//                             );
//                           },
//                         );
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _VoiceWave extends StatefulWidget {
//   final bool isActive;
//   const _VoiceWave({required this.isActive});

//   @override
//   State<_VoiceWave> createState() => _VoiceWaveState();
// }

// class _VoiceWaveState extends State<_VoiceWave>
//     with SingleTickerProviderStateMixin {
//   late final AnimationController _controller;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 500),
//     );

//     if (widget.isActive) {
//       _controller.repeat();
//     }
//   }

//   @override
//   void didUpdateWidget(covariant _VoiceWave oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (widget.isActive) {
//       if (!_controller.isAnimating) {
//         _controller.repeat();
//       }
//     } else {
//       _controller.stop();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 20,
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: List.generate(4, (index) {
//           return AnimatedBuilder(
//             animation: _controller,
//             builder: (_, __) {
//               final value = (_controller.value + index * 0.2) % 1;
//               final height = 6 + (value * 10);

//               return Container(
//                 margin: const EdgeInsets.symmetric(horizontal: 1.5),
//                 width: 3,
//                 height: height,
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(3),
//                 ),
//               );
//             },
//           );
//         }),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
// }

// class _AgoraCallRoomView extends StatefulWidget {
//   _AgoraCallRoomView({
//     required this.name,
//     required this.image,
//     required this.appointmentId,
//     required this.asDoctor,
//   });

//   final String name;
//   final String? image;
//   final String appointmentId;
//   final bool asDoctor;

//   @override
//   State<_AgoraCallRoomView> createState() => _AgoraCallRoomViewState();
// }

// class _AgoraCallRoomViewState extends State<_AgoraCallRoomView> {
//   final CallController _callController = CallController.to;
//   final AgoraSingleton _agoraSingleton = AgoraSingleton.to;
//   final ApiRepo _apiRepo = ApiRepo();
//   bool _hasLeftChannel = false;
//   late final Future<void> _readyFuture;
//   RtcEngine? _engine;

//   VideoViewController? _localVideoViewController;
//   VideoViewController? _remoteVideoViewController;
//   int _lastRemoteUid = 0;
//   String _lastRemoteChannelId = '';
//   final stopWatchTimer = StopWatchTimer();
//   Timer? _joinTimeoutTimer;
//   Worker? _callStateWorker;
//   bool _didInitAfterReady = false;
//   bool _hasHandledEnd = false;
//   bool _didAutoRetry = false;
//   DateTime _callAttemptStartedAt = DateTime.now();

//   void _openRecordsBottomSheet() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.white,
//       barrierColor: Colors.black.withOpacity(.35),
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (_) => _CallRecordsBottomSheet(apiRepo: _apiRepo),
//     );
//   }

//   @override
//   void initState() {
//     super.initState();
//     _readyFuture = _agoraSingleton.ensureReady();
//     _readyFuture.then((_) {
//       if (!mounted) return;
//       _initAfterReady();
//     });
//   }

//   void _initAfterReady() {
//     if (_didInitAfterReady) return;
//     _didInitAfterReady = true;

//     _callController.isCallUiVisible.value = true;
//     _callAttemptStartedAt = DateTime.now();
//     _didAutoRetry = false;

//     // Safe now: ensureReady() completed.
//     _engine = _agoraSingleton.engine;

//     _localVideoViewController = VideoViewController(
//       rtcEngine: _engine!,
//       canvas: const VideoCanvas(uid: 0),
//     );

//     _callStateWorker = everAll(
//       [
//         _callController.isInCall,
//         _callController.isConnecting,
//         _callController.callStatus,
//       ],
//       (_) {
//         final status = _callController.callStatus.value.toLowerCase();
//         final endedByStatus = status == 'ended' || status == 'error';
//         if (endedByStatus && mounted) {
//           _handleCallEnded();
//         }
//       },
//     );
//     _startJoinTimeout();
//     _startCall();
//   }

//   @override
//   void dispose() {
//     _joinTimeoutTimer?.cancel();
//     _callStateWorker?.dispose();
//     WakelockPlus.disable();
//     _callController.isCallUiVisible.value = false;
//     stopWatchTimer.dispose();
//     // Best-effort cleanup in case the view is disposed unexpectedly.
//     unawaited(_callController.cleanupAfterCall(reason: 'view_dispose'));
//     _leaveChannelOnce();
//     _localVideoViewController = null;
//     _remoteVideoViewController = null;
//     super.dispose();
//   }

//   void _ensureRemoteVideoController({
//     required int remoteUid,
//     required String channelId,
//   }) {
//     if (remoteUid == 0) {
//       _remoteVideoViewController = null;
//       _lastRemoteUid = 0;
//       _lastRemoteChannelId = '';
//       return;
//     }
//     if (_remoteVideoViewController != null &&
//         _lastRemoteUid == remoteUid &&
//         _lastRemoteChannelId == channelId) {
//       return;
//     }
//     _lastRemoteUid = remoteUid;
//     _lastRemoteChannelId = channelId;
//     _remoteVideoViewController = VideoViewController.remote(
//       rtcEngine: _engine!,
//       canvas: VideoCanvas(uid: remoteUid),
//       connection: RtcConnection(channelId: channelId),
//     );
//   }

//   Future<void> _leaveChannelOnce() async {
//     if (_hasLeftChannel) return;
//     _hasLeftChannel = true;
//     try {
//       await _agoraSingleton.leaveChannel(reason: 'call_room_leave_once');
//     } catch (e) {
//       dLog('Error leaving channel (leave once): $e');
//     }
//   }

//   void _startJoinTimeout() {
//     // If doctor/local join does not lead to an active call within 30 seconds,
//     // automatically end the call to avoid the user being stuck.
//     _joinTimeoutTimer?.cancel();
//     _joinTimeoutTimer = Timer(const Duration(seconds: 30), () async {
//       final status = _callController.callStatus.value.toLowerCase();
//       final hasRemote = _callController.remoteUserId.value != 0;
//       final isEnded = status == 'ended' || status == 'error';

//       // If we never see the remote join, treat as a stuck call and clean up.
//       if (!isEnded && !hasRemote) {
//         try {
//           final prefs = await SharedPreferences.getInstance();
//           final accepted = prefs.getBool(isCallAccepted) ?? false;
//           if (Platform.isIOS && accepted) {
//             dLog(
//               'CALL FLOW: Join timeout reached, but call is accepted on iOS. Keeping call room open.',
//             );
//             return;
//           }
//         } catch (_) {
//           // ignore
//         }
//         dLog(
//           'CALL FLOW: Join timeout reached (30s). Ending call automatically.',
//         );
//         try {
//           await _callController.endCall();
//         } catch (e) {
//           dLog('CALL FLOW: Error while ending call on timeout - $e');
//         }
//         if (mounted) {
//           _handleCallEnded();
//         }
//       }
//     });
//   }

//   Widget _remoteVideo({required int uid}) {
//     final resolvedChannelId = _callController.channelId.value.isNotEmpty
//         ? _callController.channelId.value
//         : widget.appointmentId;
//     final int remoteUid = _callController.remoteUserId.value;

//     _ensureRemoteVideoController(
//       remoteUid: remoteUid,
//       channelId: resolvedChannelId,
//     );
//     if (remoteUid != 0) {
//       return ClipRRect(
//         borderRadius: const BorderRadius.only(
//           bottomLeft: Radius.circular(25),
//           bottomRight: Radius.circular(25),
//         ),
//         child: Stack(
//           children: [
//             if (_remoteVideoViewController != null)
//               AgoraVideoView(controller: _remoteVideoViewController!),
//             if (!_callController.isRemoteVideoActive.value)
//               Container(
//                 color: Colors.black54,
//                 child: const Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(Icons.videocam_off, color: Colors.white, size: 48),
//                       SizedBox(height: 8),
//                       Text(
//                         'Video is off',
//                         style: TextStyle(color: Colors.white, fontSize: 16),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       );
//     } else {
//       return Container(
//         color: Colors.white,
//         child: const Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.person, color: Colors.grey, size: 200),
//             SizedBox(height: 16),
//             Text(
//               'Waiting for doctor to join...',
//               textAlign: TextAlign.center,
//               style: TextStyle(color: Colors.black54, fontSize: 16),
//             ),
//           ],
//         ),
//       );
//     }
//   }

//   Future<void> _startCall() async {
//     WakelockPlus.enable();

//     final permissionStatuses = await [
//       Permission.microphone,
//       Permission.camera,
//     ].request();
//     final micOk =
//         permissionStatuses[Permission.microphone]?.isGranted ??
//         permissionStatuses[Permission.microphone]?.isLimited ??
//         false;
//     final camOk =
//         permissionStatuses[Permission.camera]?.isGranted ??
//         permissionStatuses[Permission.camera]?.isLimited ??
//         false;
//     if (!micOk || !camOk) {
//       if (!micOk) {
//         _showErrorAndExit('Microphone permission denied');
//         return;
//       }
//       // Camera is optional; proceed with audio-only.
//       _callController.isLocalCameraActive.value = false;
//     }

//     try {
//       // Engine/channel join is handled by CallController.startCall -> AgoraSingleton.joinChannel
//       dLog('CALL FLOW: Starting call via controller (singleton join)');
//       stopWatchTimer.onStartTimer();
//       await _callController.startCall(
//         appointmentId: widget.appointmentId,
//         asDoctor: widget.asDoctor,
//         enableVideo: camOk,
//       );
//     } catch (e) {
//       dLog('CALL FLOW: Error while starting call - $e');
//       _showErrorAndExit("Failed to start call: $e");
//     }
//   }

//   void _showErrorAndExit(String error) {
//     dLog("CALL FLOW ERROR: $error");
//     if (mounted) {
//       showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: const Text('Call Error'),
//           content: Text(error),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 Navigator.of(context).pop(); // Exit call screen
//               },
//               child: const Text('OK'),
//             ),
//           ],
//         ),
//       );
//     }
//   }

//   void _handleCallEnded() {
//     if (_hasHandledEnd) return;
//     final elapsed = DateTime.now().difference(_callAttemptStartedAt);
//     final hasRemote = _callController.remoteUserId.value != 0;

//     // If the call "ends" immediately after accept (common with synthetic end events
//     // or transient join issues), don't kick the user out to prescription screen.
//     // Retry joining once and keep the call UI visible.
//     if (!hasRemote && elapsed < const Duration(seconds: 6) && !_didAutoRetry) {
//       _didAutoRetry = true;
//       try {
//         // Get.snackbar(
//         //   'Reconnecting',
//         //   'Retrying to join call...',
//         //   snackPosition: SnackPosition.BOTTOM,
//         //   duration: const Duration(seconds: 2),
//         // );
//       } catch (_) {
//         // ignore
//       }
//       _callAttemptStartedAt = DateTime.now();
//       unawaited(() async {
//         try {
//           await Future<void>.delayed(const Duration(milliseconds: 600));
//           await _callController.startCall(
//             appointmentId: widget.appointmentId,
//             asDoctor: widget.asDoctor,
//             enableVideo: _callController.isLocalCameraActive.value,
//           );
//         } catch (e) {
//           dLog('CALL FLOW: reconnect retry failed - $e');
//         }
//       }());
//       return;
//     }

//     _hasHandledEnd = true;
//     // Use singleton to leave channel instead of direct engine call
//     _leaveChannelOnce().whenComplete(() {
//       WakelockPlus.disable();
//       Get.offAll(() => const WaitingForPrescriptionScreen());
//     });
//   }

//   String formatStopwatchTime(int seconds) {
//     final minutes = seconds ~/ 60;
//     final remainingSeconds = seconds % 60;
//     return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<void>(
//       future: _readyFuture,
//       builder: (context, snapshot) {
//         final ready =
//             snapshot.connectionState == ConnectionState.done && _engine != null;
//         if (!ready) {
//           return const Scaffold(
//             backgroundColor: Colors.white,
//             body: Center(child: Text('Initializing call…')),
//           );
//         }
//         return Scaffold(
//           backgroundColor: Colors.transparent,
//           appBar: PreferredSize(
//             preferredSize: const Size.fromHeight(0),
//             child: AppBar(),
//           ),
//           body: Obx(
//             () => Stack(
//               children: [
//                 SizedBox(
//                   height: MediaQuery.of(context).size.height,
//                   width: MediaQuery.of(context).size.width,
//                   child: Column(
//                     children: [
//                       Expanded(
//                         child: Stack(
//                           children: [
//                             Container(
//                               height: double.maxFinite,
//                               width: double.maxFinite,
//                               decoration: const BoxDecoration(
//                                 color: Colors.white,
//                               ),
//                               alignment: Alignment.center,
//                               child: const Text(
//                                 "Joining...",
//                                 style: TextStyle(color: Colors.black),
//                               ),
//                             ),
//                             Container(
//                               height: double.maxFinite,
//                               width: double.maxFinite,
//                               decoration: const BoxDecoration(
//                                 color: Colors.white,
//                               ),
//                               child: Stack(
//                                 children: [
//                                   Center(
//                                     child: _remoteVideo(
//                                       uid: _callController.remoteUserId.value,
//                                     ),
//                                   ),
//                                   Positioned(
//                                     top: 20,
//                                     right: 20,
//                                     child: ClipRRect(
//                                       borderRadius: BorderRadius.circular(20),
//                                       child: SizedBox(
//                                         width: 120,
//                                         height: 140,
//                                         child: Center(
//                                           child:
//                                               _localVideoViewController == null
//                                               ? const SizedBox.shrink()
//                                               : AgoraVideoView(
//                                                   controller:
//                                                       _localVideoViewController!,
//                                                 ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                   Positioned(
//                                     top: 20,
//                                     left: 20,
//                                     child: GestureDetector(
//                                       onTap: _openRecordsBottomSheet,
//                                       child: Container(
//                                         padding: const EdgeInsets.symmetric(
//                                           horizontal: 12,
//                                           vertical: 10,
//                                         ),
//                                         decoration: BoxDecoration(
//                                           color: Colors.white.withOpacity(.85),
//                                           borderRadius: BorderRadius.circular(
//                                             22,
//                                           ),
//                                           border: Border.all(
//                                             color: const Color(0xFF008541),
//                                           ),
//                                         ),
//                                         child: const Row(
//                                           mainAxisSize: MainAxisSize.min,
//                                           children: [
//                                             Icon(
//                                               Icons.assignment_outlined,
//                                               size: 18,
//                                               color: Color(0xFF008541),
//                                             ),
//                                             SizedBox(width: 6),
//                                             Text(
//                                               'Records',
//                                               style: TextStyle(
//                                                 color: Color(0xFF008541),
//                                                 fontWeight: FontWeight.w600,
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             Positioned(
//                               bottom: 100,
//                               left: 0,
//                               right: 0,
//                               child: Padding(
//                                 padding: const EdgeInsets.symmetric(
//                                   horizontal: 22,
//                                 ),
//                                 child: Container(
//                                   decoration: BoxDecoration(
//                                     color: Colors.white.withOpacity(.6),
//                                     borderRadius: BorderRadius.circular(46),
//                                   ),
//                                   padding: const EdgeInsets.all(12),
//                                   child: Row(
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       Expanded(
//                                         child: Row(
//                                           children: [
//                                             Container(
//                                               decoration: BoxDecoration(
//                                                 border: Border.all(
//                                                   color: const Color(
//                                                     0xFF008541,
//                                                   ),
//                                                   width: 5,
//                                                 ),
//                                                 borderRadius:
//                                                     BorderRadius.circular(45),
//                                               ),
//                                               padding: const EdgeInsets.all(5),
//                                               child: ClipRRect(
//                                                 borderRadius:
//                                                     BorderRadius.circular(45),
//                                                 child: Container(
//                                                   height: 45,
//                                                   width: 45,
//                                                   decoration: BoxDecoration(
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                           45,
//                                                         ),
//                                                   ),
//                                                   child: widget.image != null
//                                                       ? Image.network(
//                                                           '${ApiConstants.imageBaseUrl}${widget.image}',
//                                                           fit: BoxFit.cover,
//                                                           errorBuilder: (_, __, ___) {
//                                                             return Container(
//                                                               color: Colors
//                                                                   .grey[300],
//                                                               child: const Icon(
//                                                                 Icons.person,
//                                                                 color:
//                                                                     Colors.grey,
//                                                               ),
//                                                             );
//                                                           },
//                                                         )
//                                                       : Container(
//                                                           color:
//                                                               Colors.grey[300],
//                                                           child: const Icon(
//                                                             Icons.person,
//                                                             color: Colors.grey,
//                                                           ),
//                                                         ),
//                                                 ),
//                                               ),
//                                             ),
//                                             const SizedBox(width: 8),
//                                             Flexible(
//                                               child: Column(
//                                                 mainAxisSize: MainAxisSize.min,
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment.center,
//                                                 crossAxisAlignment:
//                                                     CrossAxisAlignment.start,
//                                                 children: [
//                                                   Text(
//                                                     widget.name,
//                                                     maxLines: 1,
//                                                     overflow:
//                                                         TextOverflow.ellipsis,
//                                                     style: const TextStyle(
//                                                       fontWeight:
//                                                           FontWeight.bold,
//                                                       color: Colors.black,
//                                                     ),
//                                                   ),
//                                                   const SizedBox(height: 2),
//                                                   StreamBuilder<int>(
//                                                     stream: stopWatchTimer
//                                                         .secondTime,
//                                                     initialData: 0,
//                                                     builder: (context, snap) {
//                                                       final value = snap.data;
//                                                       return Text(
//                                                         formatStopwatchTime(
//                                                           int.parse(
//                                                             value.toString(),
//                                                           ),
//                                                         ),
//                                                         style: const TextStyle(
//                                                           color: Colors.black,
//                                                         ),
//                                                       );
//                                                     },
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                       Container(
//                                         height: 45,
//                                         width: 45,
//                                         decoration: BoxDecoration(
//                                           color: const Color(0xFF008541),
//                                           borderRadius: BorderRadius.circular(
//                                             55,
//                                           ),
//                                         ),
//                                         child: Center(
//                                           child: Obx(() {
//                                             final isActive =
//                                                 _callController
//                                                     .isRemoteAudioActive
//                                                     .value &&
//                                                 _callController
//                                                     .isRemoteSpeaking
//                                                     .value;
//                                             return _VoiceWave(
//                                               isActive: isActive,
//                                             );
//                                           }),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Positioned(
//                   left: 0,
//                   right: 0,
//                   bottom: 0,
//                   child: SafeArea(
//                     top: false,
//                     child: Padding(
//                       padding: const EdgeInsets.only(bottom: 8),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           AgoraCallButton(
//                             buttonColor: const Color(0xFFCCE7D9),
//                             icon: _callController.isRemoteAudioActive.value
//                                 ? Icons.volume_up_outlined
//                                 : Icons.volume_off_outlined,
//                             iconColor: const Color(0xFF008541),
//                             callBackFunction: () {
//                               _callController.toggleRemoteAudio();
//                             },
//                           ),
//                           const SizedBox(width: 16),
//                           AgoraCallButton(
//                             buttonColor: const Color(0xFFEFEFEF),
//                             icon: _callController.isLocalMicActive.value
//                                 ? Icons.mic_none_outlined
//                                 : Icons.mic_off_outlined,
//                             iconColor: Colors.black,
//                             callBackFunction: () {
//                               _callController.toggleMicrophone();
//                             },
//                           ),
//                           const SizedBox(width: 16),
//                           AgoraCallButton(
//                             buttonColor: const Color(0xFFF14F4A),
//                             icon: Icons.phone,
//                             iconColor: Colors.white,
//                             callBackFunction: () async {
//                               try {
//                                 if (Get.isRegistered<CallController>()) {
//                                   await CallController.to.stopRingtone();
//                                 }
//                               } catch (_) {
//                                 // ignore
//                               }
//                               try {
//                                 await _callController.endCall();
//                               } catch (_) {
//                                 // ignore
//                               }
//                               _handleCallEnded();
//                             },
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// class AgoraCallButton extends StatelessWidget {
//   const AgoraCallButton({
//     required this.buttonColor,
//     required this.icon,
//     required this.iconColor,
//     required this.callBackFunction,
//     super.key,
//   });

//   final Color buttonColor;
//   final Color iconColor;
//   final IconData icon;
//   final VoidCallback callBackFunction;

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: callBackFunction,
//       child: Container(
//         height: 55,
//         width: 55,
//         decoration: BoxDecoration(
//           color: buttonColor,
//           borderRadius: BorderRadius.circular(55),
//         ),
//         child: Icon(icon, color: iconColor),
//       ),
//     );
//   }
// }


