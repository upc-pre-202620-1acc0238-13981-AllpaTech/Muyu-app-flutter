import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muyu_app/core/storage/user_preferences.dart';
import 'package:muyu_app/features/user_management/application/session_controller.dart';
import 'package:muyu_app/features/user_management/domain/auth_repository.dart';
import 'package:muyu_app/features/user_management/domain/user.dart';
import 'package:muyu_app/features/user_management/infrastructure/repositories/auth_repository_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _AuthRepositoryWithoutPhone implements AuthRepository {
  @override
  Future<User> login(String email, String password) async => User(
    email: email,
    firstName: 'Ana',
    lastName: 'Rojas',
    role: UserRole.farmer.value,
    token: 'jwt',
  );

  @override
  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String birthdate,
    required String password,
    required String dni,
  }) async {}

  @override
  Future<void> changePassword({
    required String token,
    required String currentPassword,
    required String newPassword,
  }) async {}
}

void main() {
  test('login restores the phone saved during registration when the API omits it', () async {
    SharedPreferences.setMockInitialValues({
      'user:ana@example.com:${UserPreferences.keyContactPhone}': '987123456',
    });
    final sharedPreferences = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        authRepositoryProvider.overrideWithValue(_AuthRepositoryWithoutPhone()),
      ],
    );
    addTearDown(container.dispose);

    await container.read(sessionProvider.notifier).login('ana@example.com', 'Muyu*2026');

    expect(container.read(sessionProvider).user?.phone, '987123456');
    final savedSession =
        jsonDecode(sharedPreferences.getString('session')!) as Map<String, dynamic>;
    expect(savedSession['phone'], '987123456');
  });
}
