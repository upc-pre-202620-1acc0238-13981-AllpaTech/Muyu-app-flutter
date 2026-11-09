import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../environment/environment.dart';

/// Error raised when the API answers with a non-2xx status.
class ApiException implements Exception {
  const ApiException(this.statusCode, this.message);

  final int statusCode;
  final String message;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// Error raised when the API cannot be reached at all.
class NetworkException implements Exception {
  const NetworkException(this.cause);

  final Object cause;

  @override
  String toString() => 'NetworkException: $cause';
}

/// Thin JSON client over `package:http`, the Flutter counterpart of the
/// Kotlin app's Retrofit setup.
class ApiClient {
  ApiClient({required this.baseUrl, http.Client? client}) : _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> body, {
    String? token,
  }) async {
    final response = await _send(
      () => _client.post(_uri(path), headers: _headers(token), body: jsonEncode(body)),
    );
    return _decode(response) as Map<String, dynamic>;
  }

  Future<List<dynamic>> getList(String path, {String? token}) async {
    final response = await _send(() => _client.get(_uri(path), headers: _headers(token)));
    return (_decode(response) as List<dynamic>?) ?? const [];
  }

  Future<void> putJson(String path, Map<String, dynamic> body, {String? token}) async {
    await _send(() => _client.put(_uri(path), headers: _headers(token), body: jsonEncode(body)));
  }

  Future<void> delete(String path, {String? token}) async {
    await _send(() => _client.delete(_uri(path), headers: _headers(token)));
  }

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Map<String, String> _headers(String? token) => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  Future<http.Response> _send(Future<http.Response> Function() request) async {
    final http.Response response;
    try {
      response = await request().timeout(Environment.requestTimeout);
    } on Exception catch (e) {
      // Timeouts, lost connections and TLS failures (HandshakeException is not
      // wrapped by package:http) all mean the same thing to the user.
      throw NetworkException(e);
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final decoded = _tryDecode(response);
      final message = decoded is Map && decoded['message'] is String
          ? decoded['message'] as String
          : response.reasonPhrase ?? 'Request failed';
      throw ApiException(response.statusCode, message);
    }
    return response;
  }

  dynamic _decode(http.Response response) {
    if (response.body.isEmpty) return <String, dynamic>{};
    return jsonDecode(utf8.decode(response.bodyBytes));
  }

  dynamic _tryDecode(http.Response response) {
    try {
      return _decode(response);
    } on FormatException {
      return null;
    }
  }
}

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient(baseUrl: Environment.baseUrl));
