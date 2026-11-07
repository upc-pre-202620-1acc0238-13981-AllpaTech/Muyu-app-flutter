import 'dart:async';
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
    final http.Response response;
    try {
      response = await _client
          .post(
            Uri.parse('$baseUrl$path'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              if (token != null) 'Authorization': 'Bearer $token',
            },
            body: jsonEncode(body),
          )
          .timeout(Environment.requestTimeout);
    } on TimeoutException catch (e) {
      throw NetworkException(e);
    } on http.ClientException catch (e) {
      throw NetworkException(e);
    }

    final decoded = response.body.isEmpty
        ? const <String, dynamic>{}
        : jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = decoded is Map && decoded['message'] is String
          ? decoded['message'] as String
          : response.reasonPhrase ?? 'Request failed';
      throw ApiException(response.statusCode, message);
    }
    return decoded as Map<String, dynamic>;
  }
}

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient(baseUrl: Environment.baseUrl));
