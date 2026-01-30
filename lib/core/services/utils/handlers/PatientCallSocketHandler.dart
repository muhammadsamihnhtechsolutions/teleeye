// import 'dart:convert';
// import 'package:socket_io_client/socket_io_client.dart' as IO;

// class PatientCallSocketHandler {
//   static final PatientCallSocketHandler instance = PatientCallSocketHandler._();
//   late IO.Socket socket;

//   PatientCallSocketHandler._();

//   void initSocket({
//     required String appointmentId,
//     required Function onAcceptedEvent,
//     required Function onRejectedEvent,
//     required Function onEndedEvent,
//   }) {
//     socket = IO.io('https://your-server-url.com', IO.OptionBuilder()
//         .setTransports(['websocket'])
//         .build());

//     socket.onConnect((_) {
//       print("Connected to socket!");
//       socket.emit('join', appointmentId);
//     });

//     socket.on('call_accepted', (data) {
//       onAcceptedEvent(data);
//     });

//     socket.on('call_rejected', (data) {
//       onRejectedEvent(data);
//     });

//     socket.on('call_ended', (data) {
//       onEndedEvent(data);
//     });
//   }

//   void disposeSocket() {
//     socket.disconnect();
//   }
// }



import 'dart:developer';
import 'package:eye_buddy/core/services/api/service/api_constants.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

typedef SocketCallback = void Function(dynamic data);

class PatientCallSocketHandler {
  PatientCallSocketHandler._internal();

  static final PatientCallSocketHandler instance =
      PatientCallSocketHandler._internal();

  IO.Socket? socket;

  bool _connected = false;
  String? _currentAppointmentId;

  Future<void> initSocket({
    required String appointmentId,
    required SocketCallback onJoinedEvent,
    required SocketCallback onRejectedEvent,
    required SocketCallback onEndedEvent,
    void Function()? onConnected,
    void Function(dynamic)? onError, 
  }) async {
    /// 🟢 SAME APPOINTMENT + CONNECTED → REBIND ONLY
    if (socket != null &&
        _connected &&
        _currentAppointmentId == appointmentId) {
      log("🟡 PATIENT Socket already connected — rebinding listeners");

      socket!
        ..off('joinedCall')
        ..off('rejectCall')
        ..off('endCall');

      _bindListeners(
        onJoinedEvent,
        onRejectedEvent,
        onEndedEvent,
      );

      return;
    }

    /// 🔴 DIFFERENT APPOINTMENT → RESET SOCKET
    if (socket != null) {
      disposeSocket();
    }

    _currentAppointmentId = appointmentId;

    log("🟢 PATIENT Creating socket connection");

    socket = IO.io(
      ApiConstants.baseUrl,
      {
        'path': '/socket',
        'transports': ['websocket'],
        'autoConnect': true,
      },
    );

    /// 🟢 CONNECT
    socket?.onConnect((_) {
      _connected = true;
      log("✅ PATIENT Socket connected");

      if (onConnected != null) onConnected();

      /// JOIN SAME ROOM AS DOCTOR
      socket?.emit(
        'joinAppointmentRoom',
        {'appointmentId': appointmentId},
      );

      log("📡 PATIENT emitted joinAppointmentRoom → $appointmentId");
    });

    /// 🟢 LISTEN EVENTS
    _bindListeners(
      onJoinedEvent,
      onRejectedEvent,
      onEndedEvent,
    );

    /// 🔴 DISCONNECT
    socket?.onDisconnect((_) {
      _connected = false;
      log("🔴 PATIENT Socket disconnected");
    });

    /// 🔴 ERROR
    socket?.onConnectError((err) {
      log("❌ PATIENT Socket connect error → $err");
      if (onError != null) onError(err);
    });

    socket?.onError((err) {
      log("❌ PATIENT Socket error → $err");
      if (onError != null) onError(err);
    });
  }

  /// 🟢 EVENT LISTENERS
  void _bindListeners(
    SocketCallback onJoinedEvent,
    SocketCallback onRejectedEvent,
    SocketCallback onEndedEvent,
  ) {
    socket?.on('joinedCall', (data) {
      log("📡 PATIENT RECEIVED joinedCall → $data");
      onJoinedEvent(data);
    });

    socket?.on('rejectCall', (data) {
      log("📡 PATIENT RECEIVED rejectCall → $data");
      onRejectedEvent(data);
    });

    socket?.on('endCall', (data) {
      log("📡 PATIENT RECEIVED endCall → $data");
      onEndedEvent(data);
    });
  }

  /// 🔴 DISPOSE
  void disposeSocket() {
    try {
      socket
        ?..off('joinedCall')
        ..off('rejectCall')
        ..off('endCall')
        ..off('connect')
        ..off('disconnect')
        ..off('connect_error')
        ..off('error');

      socket?.disconnect();
      socket = null;

      _connected = false;
      _currentAppointmentId = null;

      log("🧹 PATIENT Socket disposed");
    } catch (e) {
      log("❌ PATIENT dispose error → $e");
    }
  }

  /// 🟢 EMITS (MATCH DOCTOR EXACTLY)

  void emitJoinedCall({required String appointmentId}) {
    socket?.emit('joinedCall', {'appointmentId': appointmentId});
    log("📡 PATIENT EMIT joinedCall → $appointmentId");
  }

  void emitRejectCall({required String appointmentId}) {
    socket?.emit('rejectCall', {'appointmentId': appointmentId});
    log("📡 PATIENT EMIT rejectCall → $appointmentId");
  }

  void emitEndCall({required String appointmentId}) {
    socket?.emit('endCall', {'appointmentId': appointmentId});
    log("📡 PATIENT EMIT endCall → $appointmentId");
  }
}
