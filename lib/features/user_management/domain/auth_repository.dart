import 'user.dart';

/// Why a login or registration did not go through.
enum AuthFailure { invalidCredentials, rejected, network }

class AuthException implements Exception {
  const AuthException(this.failure);

  final AuthFailure failure;

  @override
  String toString() => 'AuthException($failure)';
}

abstract interface class AuthRepository {
  /// Throws [AuthException] when the credentials are rejected or the API is unreachable.
  Future<User> login(String email, String password);

  Future<User> register({
    required String name,
    required String email,
    required String phone,
    required String birthdate,
    required String password,
  });
}
