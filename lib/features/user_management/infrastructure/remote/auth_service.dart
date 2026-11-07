import '../../../../core/network/api_client.dart';

/// Endpoints of the users resource (`users/login`, `users/register`).
class AuthService {
  const AuthService(this._client);

  final ApiClient _client;

  Future<Map<String, dynamic>> login({required String email, required String password}) =>
      _client.postJson('users/login', {'email': email, 'password': password});

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String birthdate,
    required String password,
  }) => _client.postJson('users/register', {
    'name': name,
    'email': email,
    'phone': phone,
    'birthdate': birthdate,
    'password': password,
  });
}
