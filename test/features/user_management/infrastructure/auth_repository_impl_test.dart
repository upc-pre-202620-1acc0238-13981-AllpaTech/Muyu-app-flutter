import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:muyu_app/core/network/api_client.dart';
import 'package:muyu_app/features/user_management/domain/auth_repository.dart';
import 'package:muyu_app/features/user_management/infrastructure/remote/auth_service.dart';
import 'package:muyu_app/features/user_management/infrastructure/repositories/auth_repository_impl.dart';

AuthRepositoryImpl repositoryFor(Future<http.Response> Function(http.Request) handler) =>
    AuthRepositoryImpl(
      AuthService(ApiClient(baseUrl: 'https://api.test/api/v1/', client: MockClient(handler))),
    );

http.Response loginResponse(
  String role, {
  String displayName = 'Ana Maria Rojas',
  String phone = '987123456',
}) => http.Response(
  jsonEncode({
    'accessToken': 'jwt',
    'expiresAtUtc': '2026-11-10T00:00:00Z',
    'user': {
      'id': 'u1',
      'email': 'ana@example.com',
      'displayName': displayName,
      'role': role,
      'phone': phone,
    },
  }),
  200,
);

void main() {
  test('login posts to auth/login and maps the backend response', () async {
    late http.Request sent;
    final repo = repositoryFor((request) async {
      sent = request;
      return loginResponse('AGRICULTOR');
    });

    final user = await repo.login('ana@example.com', 'Muyu*2026');

    expect(sent.url.toString(), 'https://api.test/api/v1/auth/login');
    expect(jsonDecode(sent.body), {'email': 'ana@example.com', 'password': 'Muyu*2026'});
    expect(user.token, 'jwt');
    expect(user.firstName, 'Ana');
    expect(user.lastName, 'Maria Rojas');
    expect(user.role, 'farmer');
    expect(user.phone, '987123456');
  });

  test('COMERCIANTE maps to merchant and a single name has no last name', () async {
    final user = await repositoryFor((_) async => loginResponse('COMERCIANTE', displayName: 'Ana'))
        .login('ana@example.com', 'Muyu*2026');

    expect(user.role, 'merchant');
    expect(user.firstName, 'Ana');
    expect(user.lastName, '');
  });

  test('register posts every field the backend requires', () async {
    late http.Request sent;
    await repositoryFor((request) async {
      sent = request;
      return http.Response('{"id":"u1","email":"ana@example.com"}', 201);
    }).register(
      name: 'Ana Rojas',
      email: 'ana@example.com',
      phone: '987123456',
      birthdate: '03 May 2000',
      password: 'Muyu*2026',
      dni: '12345678',
    );

    expect(sent.url.path, '/api/v1/auth/register');
    expect(
      (jsonDecode(sent.body) as Map).keys,
      containsAll(['name', 'email', 'phone', 'birthdate', 'password', 'dni']),
    );
  });

  test('a TLS or connection failure becomes a network failure', () {
    final repo = repositoryFor((_) async => throw const FormatException('handshake failed'));
    expect(
      repo.login('ana@example.com', 'Muyu*2026'),
      throwsA(isA<AuthException>().having((e) => e.failure, 'failure', AuthFailure.network)),
    );
  });

  for (final (status, failure) in [
    (401, AuthFailure.invalidCredentials),
    (400, AuthFailure.rejected),
    (409, AuthFailure.rejected),
  ]) {
    test('HTTP $status becomes $failure', () {
      final repo = repositoryFor((_) async => http.Response('{}', status));
      expect(
        repo.login('ana@example.com', 'Muyu*2026'),
        throwsA(isA<AuthException>().having((e) => e.failure, 'failure', failure)),
      );
    });
  }
}
