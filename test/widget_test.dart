import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muyu_app/app.dart';
import 'package:muyu_app/core/storage/user_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> pumpApp(WidgetTester tester) async {
  // Same phone size the Kotlin previews use (402 x 874 dp).
  tester.view.devicePixelRatio = 3;
  tester.view.physicalSize = const Size(402 * 3, 874 * 3);
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const MuyuApp(),
    ),
  );
  // Let the splash finish restoring the (empty) session.
  await tester.pump(const Duration(milliseconds: 1300));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a new user lands on the login screen in English', (tester) async {
    await pumpApp(tester);

    expect(find.text('Don\'t have an account?'), findsOneWidget);
    expect(find.text('EN'), findsOneWidget);
  });

  testWidgets('the language toggle switches to Latin American Spanish', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('EN'));
    await tester.pumpAndSettle();

    expect(find.text('¿No tienes una cuenta?'), findsOneWidget);
    expect(find.text('ES'), findsOneWidget);
  });

  testWidgets('register opens from login and validates the name first', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Register'));
    await tester.pumpAndSettle();
    final registerButton = find.widgetWithText(FilledButton, 'Register');
    await tester.ensureVisible(registerButton);
    await tester.tap(registerButton);
    await tester.pumpAndSettle();

    expect(find.text('Enter a valid name using 2 to 60 letters.'), findsOneWidget);
  });
}
