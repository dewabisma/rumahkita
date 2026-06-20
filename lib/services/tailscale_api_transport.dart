import 'dart:convert';
import 'dart:io';

/// HTTP transport for Tailscale Admin API calls.
abstract class TailscaleApiTransport {
  Future<TailscaleHttpResponse> get(
    String path, {
    Map<String, String>? headers,
  });

  Future<TailscaleHttpResponse> post(
    String path, {
    Map<String, String>? headers,
    String? body,
  });
}

class TailscaleHttpResponse {
  const TailscaleHttpResponse({
    required this.statusCode,
    required this.headers,
    required this.body,
  });

  final int statusCode;
  final Map<String, String> headers;
  final String body;
}

/// Production transport using [HttpClient].
class HttpTailscaleApiTransport implements TailscaleApiTransport {
  HttpTailscaleApiTransport({
    required this.apiKey,
    this.baseUrl = 'https://api.tailscale.com/api/v2',
    HttpClient? httpClient,
  }) : _httpClient = httpClient ?? HttpClient();

  final String apiKey;
  final String baseUrl;
  final HttpClient _httpClient;
  bool _ownsClient = true;

  HttpTailscaleApiTransport.withClient({
    required this.apiKey,
    required HttpClient httpClient,
    this.baseUrl = 'https://api.tailscale.com/api/v2',
  }) : _httpClient = httpClient,
       _ownsClient = false;

  Map<String, String> _authHeaders([Map<String, String>? extra]) {
    return {
      'Authorization': 'Bearer $apiKey',
      if (extra != null) ...extra,
    };
  }

  @override
  Future<TailscaleHttpResponse> get(
    String path, {
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final request = await _httpClient.getUrl(uri);
    for (final entry in _authHeaders(headers).entries) {
      request.headers.set(entry.key, entry.value);
    }
    request.headers.set('Accept', 'application/json');
    final response = await request.close();
    final body = await utf8.decoder.bind(response).join();
    return TailscaleHttpResponse(
      statusCode: response.statusCode,
      headers: _responseHeaders(response),
      body: body,
    );
  }

  @override
  Future<TailscaleHttpResponse> post(
    String path, {
    Map<String, String>? headers,
    String? body,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final request = await _httpClient.postUrl(uri);
    for (final entry in _authHeaders(headers).entries) {
      request.headers.set(entry.key, entry.value);
    }
    request.headers.contentType = ContentType.json;
    if (body != null) {
      request.write(body);
    }
    final response = await request.close();
    final responseBody = await utf8.decoder.bind(response).join();
    return TailscaleHttpResponse(
      statusCode: response.statusCode,
      headers: _responseHeaders(response),
      body: responseBody,
    );
  }

  Map<String, String> _responseHeaders(HttpClientResponse response) {
    final map = <String, String>{};
    response.headers.forEach((name, values) {
      map[name.toLowerCase()] = values.join(',');
    });
    return map;
  }

  void close() {
    if (_ownsClient) {
      _httpClient.close(force: true);
    }
  }
}

/// In-memory transport for tests.
class FakeTailscaleApiTransport implements TailscaleApiTransport {
  FakeTailscaleApiTransport({this.handlers = const {}});

  final Map<String, Future<TailscaleHttpResponse> Function(
    String method,
    String path, {
    Map<String, String>? headers,
    String? body,
  })> handlers;

  final List<({
    String method,
    String path,
    Map<String, String>? headers,
    String? body,
  })> requests = [];

  @override
  Future<TailscaleHttpResponse> get(
    String path, {
    Map<String, String>? headers,
  }) async {
    requests.add((method: 'GET', path: path, headers: headers, body: null));
    final handler = handlers['GET $path'] ?? handlers['GET *'];
    if (handler == null) {
      return const TailscaleHttpResponse(
        statusCode: 404,
        headers: {},
        body: '{"message":"not found"}',
      );
    }
    return handler('GET', path, headers: headers);
  }

  @override
  Future<TailscaleHttpResponse> post(
    String path, {
    Map<String, String>? headers,
    String? body,
  }) async {
    requests.add((method: 'POST', path: path, headers: headers, body: body));
    final handler = handlers['POST $path'] ?? handlers['POST *'];
    if (handler == null) {
      return const TailscaleHttpResponse(
        statusCode: 404,
        headers: {},
        body: '{"message":"not found"}',
      );
    }
    return handler('POST', path, headers: headers, body: body);
  }
}
