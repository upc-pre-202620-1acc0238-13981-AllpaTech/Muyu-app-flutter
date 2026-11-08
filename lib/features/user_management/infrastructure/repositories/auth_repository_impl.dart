import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../domain/auth_repository.dart';
import '../../domain/user.dart';
import '../remote/auth_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._service);

  final AuthService _service;

  @override
  Future<User> login(String email, String password) => _guard(() async {
    return _userFromLogin(await _service.login(email: email, password: password));
  });

  @override
  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String birthdate,
    required String password,
    required String dni,
  }) => _guard(
    () => _service.register(
      name: name,
      email: email,
      phone: phone,
      birthdate: birthdate,
      password: password,
      dni: dni,
    ),
  );

  @override
  Future<void> changePassword({
    required String token,
    required String currentPassword,
    required String newPassword,
  }) => _guard(
    () => _service.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
      token: token,
    ),
  );

  /// Maps the backend `LoginResponse` to the app's user, like `LoginResponseDto.kt`.
  User _userFromLogin(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>;
    final displayName = (user['displayName'] as String? ?? '').trim();
    final separator = displayName.indexOf(' ');
    return User(
      email: user['email'] as String? ?? '',
      firstName: separator < 0 ? displayName : displayName.substring(0, separator),
      lastName: separator < 0 ? '' : displayName.substring(separator + 1).trim(),
      role: (user['role'] as String? ?? '').toUpperCase() == 'COMERCIANTE'
          ? UserRole.merchant.value
          : UserRole.farmer.value,
      token: json['accessToken'] as String? ?? '',
    );
  }

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on ApiException catch (e) {
      throw AuthException(
        e.statusCode == 401 ? AuthFailure.invalidCredentials : AuthFailure.rejected,
      );
    } on NetworkException {
      throw const AuthException(AuthFailure.network);
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(AuthService(ref.watch(apiClientProvider))),
);
