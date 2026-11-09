import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/user_preferences.dart';
import '../domain/auth_repository.dart';
import '../domain/user.dart';
import '../infrastructure/repositories/auth_repository_impl.dart';

enum SessionStatus { restoring, signedOut, signedIn }

class SessionState {
  const SessionState._(this.status, {this.user, this.role});

  const SessionState.restoring() : this._(SessionStatus.restoring);
  const SessionState.signedOut() : this._(SessionStatus.signedOut);
  const SessionState.signedIn(User user, {UserRole? role})
    : this._(SessionStatus.signedIn, user: user, role: role);

  final SessionStatus status;
  final User? user;

  /// Role picked on the role screen; null until the user chooses one.
  final UserRole? role;
}

/// Owns who is logged in and as which role, like the session kept by the
/// Kotlin app's `BackendStateStore` plus `UserPreferences.KEY_LAST_ROLE`.
class SessionController extends Notifier<SessionState> {
  static const String _sessionKey = 'session';
  static const Duration _minimumSplash = Duration(milliseconds: 700);

  @override
  SessionState build() {
    _restore();
    return const SessionState.restoring();
  }

  Future<void> _restore() async {
    await Future<void>.delayed(_minimumSplash);
    if (!ref.mounted) return;
    final raw = ref.read(sharedPreferencesProvider).getString(_sessionKey);
    if (raw == null) {
      state = const SessionState.signedOut();
      return;
    }
    final user = User.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    state = SessionState.signedIn(user, role: _lastRole(user));
  }

  /// Throws [AuthException] when the login fails.
  ///
  /// Always leaves [SessionState.role] empty so the router sends the user to
  /// role selection, the same sequence as before the merchant catalog existed.
  Future<void> login(String email, String password) async {
    final authenticatedUser = await ref.read(authRepositoryProvider).login(email, password);
    final preferences = ref.read(userPreferencesProvider);
    final storedPhone = preferences.loadString(
      authenticatedUser.email,
      UserPreferences.keyContactPhone,
    );
    final phone = authenticatedUser.phone.trim().isNotEmpty
        ? authenticatedUser.phone
        : (storedPhone ?? '');
    final user = authenticatedUser.copyWith(phone: phone);
    if (authenticatedUser.phone.trim().isNotEmpty) {
      await preferences.saveString(
        authenticatedUser.email,
        UserPreferences.keyContactPhone,
        authenticatedUser.phone,
      );
    }
    await ref.read(sharedPreferencesProvider).setString(_sessionKey, jsonEncode(user.toJson()));
    state = SessionState.signedIn(user);
  }

  Future<void> chooseRole(UserRole role) async {
    final user = state.user;
    if (user == null) return;
    await ref
        .read(userPreferencesProvider)
        .saveString(user.email, UserPreferences.keyLastRole, role.value);
    state = SessionState.signedIn(user, role: role);
  }

  /// Keeps the session but sends the user back to the role screen.
  void clearRole() {
    final user = state.user;
    if (user != null) state = SessionState.signedIn(user);
  }

  Future<void> logout() async {
    await ref.read(sharedPreferencesProvider).remove(_sessionKey);
    state = const SessionState.signedOut();
  }

  /// Phone only. Changing the session email would orphan Yape, Plin, cards
  /// and the last role, which are stored under the original address.
  Future<void> updateContact({required String phone}) async {
    final user = state.user;
    if (user == null) return;
    final updated = user.copyWith(phone: phone);
    await ref.read(sharedPreferencesProvider).setString(_sessionKey, jsonEncode(updated.toJson()));
    await ref
        .read(userPreferencesProvider)
        .saveString(user.email, UserPreferences.keyContactPhone, phone);
    state = SessionState.signedIn(updated, role: state.role);
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    final user = state.user;
    if (user == null) throw const AuthException(AuthFailure.rejected);
    await ref
        .read(authRepositoryProvider)
        .changePassword(
          token: user.token,
          currentPassword: currentPassword,
          newPassword: newPassword,
        );
  }

  UserRole? _lastRole(User user) => UserRole.tryParse(
    ref.read(userPreferencesProvider).loadString(user.email, UserPreferences.keyLastRole),
  );
}

final sessionProvider = NotifierProvider<SessionController, SessionState>(SessionController.new);
