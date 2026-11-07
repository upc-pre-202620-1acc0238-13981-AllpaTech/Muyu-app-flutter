import 'package:flutter_test/flutter_test.dart';
import 'package:muyu_app/core/router/app_router.dart';
import 'package:muyu_app/core/router/app_routes.dart';
import 'package:muyu_app/features/user_management/application/session_controller.dart';
import 'package:muyu_app/features/user_management/domain/user.dart';

void main() {
  const user = User(
    email: 'ana@example.com',
    firstName: 'Ana',
    lastName: 'Rojas',
    role: 'farmer',
    token: 't',
  );

  test('keeps the splash while the session is being restored', () {
    const session = SessionState.restoring();
    expect(redirectFor(session, AppRoutes.login), AppRoutes.splash);
    expect(redirectFor(session, AppRoutes.splash), isNull);
  });

  test('signed-out users can only see login and register', () {
    const session = SessionState.signedOut();
    expect(redirectFor(session, AppRoutes.splash), AppRoutes.login);
    expect(redirectFor(session, AppRoutes.farmerHome), AppRoutes.login);
    expect(redirectFor(session, AppRoutes.register), isNull);
  });

  test('signed-in users without a role must pick one', () {
    const session = SessionState.signedIn(user);
    expect(redirectFor(session, AppRoutes.login), AppRoutes.role);
    expect(redirectFor(session, AppRoutes.role), isNull);
  });

  test('signed-in users with a role go to that role home', () {
    const session = SessionState.signedIn(user, role: UserRole.merchant);
    expect(redirectFor(session, AppRoutes.splash), AppRoutes.merchantCatalog);
    expect(redirectFor(session, AppRoutes.login), AppRoutes.merchantCatalog);
    expect(redirectFor(session, AppRoutes.farmerHome), isNull);
  });
}
