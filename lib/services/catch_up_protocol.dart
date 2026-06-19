import 'dart:convert';
import 'dart:io';

import 'package:rumah/sync/sync_envelope.dart';

const int catchUpPort = 5556;
const String catchUpPath = '/sync/catch-up';

class CatchUpRequest {
  const CatchUpRequest({
    required this.deviceId,
    required this.tailscaleNodeKey,
    required this.houseId,
    required this.inviteHostNodeKey,
    required this.joinCredential,
  });

  final String deviceId;
  final String tailscaleNodeKey;
  final String houseId;
  final String inviteHostNodeKey;
  final String joinCredential;

  Map<String, dynamic> toJson() => {
        'device_id': deviceId,
        'tailscale_node_key': tailscaleNodeKey,
        'house_id': houseId,
        'invite_host_node_key': inviteHostNodeKey,
        'join_credential': joinCredential,
      };

  factory CatchUpRequest.fromJson(Map<String, dynamic> json) => CatchUpRequest(
        deviceId: json['device_id'] as String,
        tailscaleNodeKey: json['tailscale_node_key'] as String,
        houseId: json['house_id'] as String,
        inviteHostNodeKey: json['invite_host_node_key'] as String,
        joinCredential: json['join_credential'] as String,
      );
}

class CatchUpResponse {
  const CatchUpResponse({
    required this.houseJoinSecret,
    required this.rosterSnapshot,
    required this.outboxReplay,
  });

  final String houseJoinSecret;
  final List<Map<String, dynamic>> rosterSnapshot;
  final List<SyncEnvelope> outboxReplay;

  Map<String, dynamic> toJson() => {
        'house_join_secret': houseJoinSecret,
        'roster_snapshot': rosterSnapshot,
        'outbox_replay': outboxReplay.map((e) => e.toJson()).toList(),
      };

  factory CatchUpResponse.fromJson(Map<String, dynamic> json) =>
      CatchUpResponse(
        houseJoinSecret: json['house_join_secret'] as String,
        rosterSnapshot: (json['roster_snapshot'] as List<dynamic>)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList(),
        outboxReplay: (json['outbox_replay'] as List<dynamic>)
            .map(
              (e) => SyncEnvelope.fromJson(
                Map<String, dynamic>.from(e as Map),
              ),
            )
            .toList(),
      );
}

typedef CatchUpHandler = Future<CatchUpResponse> Function(CatchUpRequest request);

class CatchUpServer {
  CatchUpServer({this.port = catchUpPort});

  final int port;
  HttpServer? _server;

  Future<void> start(CatchUpHandler handler) async {
    _server ??= await HttpServer.bind(InternetAddress.anyIPv4, port, shared: true);
    _server!.listen((request) async {
      if (request.method != 'POST' || request.uri.path != catchUpPath) {
        request.response
          ..statusCode = HttpStatus.notFound
          ..close();
        return;
      }
      try {
        final body = await utf8.decoder.bind(request).join();
        final json = jsonDecode(body) as Map<String, dynamic>;
        final catchUpRequest = CatchUpRequest.fromJson(json);
        final response = await handler(catchUpRequest);
        request.response
          ..statusCode = HttpStatus.ok
          ..headers.contentType = ContentType.json
          ..write(jsonEncode(response.toJson()))
          ..close();
      } on Object catch (e) {
        request.response
          ..statusCode = HttpStatus.badRequest
          ..write(jsonEncode({'error': e.toString()}))
          ..close();
      }
    });
  }

  Future<void> stop() async {
    await _server?.close(force: true);
    _server = null;
  }
}

class CatchUpClient {
  const CatchUpClient();

  Future<CatchUpResponse> fetch({
    required String hostMagicDns,
    required CatchUpRequest request,
    int port = catchUpPort,
    HttpClient? httpClient,
  }) async {
    final client = httpClient ?? HttpClient();
    final ownsClient = httpClient == null;
    try {
      final uri = Uri(
        scheme: 'http',
        host: hostMagicDns,
        port: port,
        path: catchUpPath,
      );
      final httpRequest = await client.postUrl(uri);
      httpRequest.headers.contentType = ContentType.json;
      httpRequest.write(jsonEncode(request.toJson()));
      final httpResponse = await httpRequest.close();
      final body = await utf8.decoder.bind(httpResponse).join();
      if (httpResponse.statusCode != HttpStatus.ok) {
        throw HttpException(
          'Catch-up failed (${httpResponse.statusCode}): $body',
          uri: uri,
        );
      }
      return CatchUpResponse.fromJson(
        jsonDecode(body) as Map<String, dynamic>,
      );
    } finally {
      if (ownsClient) {
        client.close(force: true);
      }
    }
  }

}
