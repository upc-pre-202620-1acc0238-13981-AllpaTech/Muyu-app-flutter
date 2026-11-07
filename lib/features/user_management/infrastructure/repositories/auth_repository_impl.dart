import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../domain/auth_repository.dart';
import '../../domain/user.dart';
import '../remote/auth_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._service);

  final AuthService _service;

  @override
  Future<User> login(String email, String password) =>
      _guard(() => _service.login(email: email, password: password));

  @override
  Future<User> register({
    required String name,
    required String email,
    required String phone,
    required String birthdate,
    required String password,
  }) => _guard(
    () => _service.register(
      name: name,
      email: email,
      phone: phone,
      birthdate: birthdate,
      password: password,
    ),
  );

  Future<User> _guard(Future<Map<String, dynamic>> Function() call) async {
    try {
      return User.fromJson(await call());
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
