import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:rumah/sync/sync_envelope.dart';

const int syncTransportPort = 5555;

/// Framed JSON [SyncEnvelope] transport over TCP :5555.
class TailscaleSyncTransport {
  TailscaleSyncTransport({this.port = syncTransportPort});

  final int port;
  ServerSocket? _server;
  final _envelopeController = StreamController<SyncEnvelope>.broadcast();

  Stream<SyncEnvelope> get incomingEnvelopes => _envelopeController.stream;

  Future<void> start() async {
    _server ??= await ServerSocket.bind(
      InternetAddress.anyIPv4,
      port,
      shared: true,
    );
    _server!.listen(_handleConnection);
  }

  Future<void> stop() async {
    await _server?.close();
    _server = null;
  }

  Future<void> sendEnvelope(String host, SyncEnvelope envelope) async {
    final socket = await Socket.connect(host, port);
    try {
      await _writeFramed(socket, jsonEncode(envelope.toJson()));
    } finally {
      await socket.close();
    }
  }

  void _handleConnection(Socket socket) {
    final buffer = <int>[];
  socket.listen(
      (data) {
        buffer.addAll(data);
        while (buffer.length >= 4) {
          final length = ByteData.sublistView(
            Uint8List.fromList(buffer.sublist(0, 4)),
          ).getUint32(0, Endian.big);
          if (buffer.length < 4 + length) {
            break;
          }
          final payload = utf8.decode(buffer.sublist(4, 4 + length));
          buffer.removeRange(0, 4 + length);
          final json = jsonDecode(payload) as Map<String, dynamic>;
          _envelopeController.add(SyncEnvelope.fromJson(json));
        }
      },
      onDone: () => socket.close(),
      onError: (_) => socket.close(),
    );
  }

  Future<void> _writeFramed(Socket socket, String payload) async {
    final bytes = utf8.encode(payload);
    final header = ByteData(4)..setUint32(0, bytes.length, Endian.big);
    socket.add(header.buffer.asUint8List());
    socket.add(bytes);
    await socket.flush();
  }
}
