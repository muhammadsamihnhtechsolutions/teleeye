import 'dart:convert';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class PatientCallSocketHandler {
  static final PatientCallSocketHandler instance = PatientCallSocketHandler._();
  late IO.Socket socket;

  PatientCallSocketHandler._();

  void initSocket({
    required String appointmentId,
    required Function onAcceptedEvent,
    required Function onRejectedEvent,
    required Function onEndedEvent,
  }) {
    socket = IO.io('https://your-server-url.com', IO.OptionBuilder()
        .setTransports(['websocket'])
        .build());

    socket.onConnect((_) {
      print("Connected to socket!");
      socket.emit('join', appointmentId);
    });

    socket.on('call_accepted', (data) {
      onAcceptedEvent(data);
    });

    socket.on('call_rejected', (data) {
      onRejectedEvent(data);
    });

    socket.on('call_ended', (data) {
      onEndedEvent(data);
    });
  }

  void disposeSocket() {
    socket.disconnect();
  }
}
