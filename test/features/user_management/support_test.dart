import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:muyu_app/core/i18n/app_language.dart';
import 'package:muyu_app/core/network/api_client.dart';
import 'package:muyu_app/core/storage/user_preferences.dart';
import 'package:muyu_app/core/theme/muyu_theme.dart';
import 'package:muyu_app/features/user_management/application/session_controller.dart';
import 'package:muyu_app/features/user_management/presentation/incident/report_incident_screen.dart';
import 'package:muyu_app/features/user_management/presentation/rating/rate_buyer_screen.dart';
import 'package:muyu_app/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProviderContainer> farmerContainer(
  Future<http.Response> Function(http.Request) handler,
) async {
  SharedPreferences.setMockInitialValues({
    'session': jsonEncode({
      'email': 'ana@gmail.com',
      'firstName': 'Ana',
      'lastName': 'Rojas',
      'role': 'farmer',
      'token': 'jwt',
    }),
  });
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      apiClientProvider.overrideWithValue(
        ApiClient(baseUrl: 'https://api.test/', client: MockClient(handler)),
      ),
    ],
  );
  addTearDown(container.dispose);
  container.listen(sessionProvider, (_, _) {});
  await Future<void>.delayed(const Duration(milliseconds: 1300));
  return container;
}

/// Opens [screen] from a home page, so popping it leaves something on screen.
Future<void> openScreen(WidgetTester tester, ProviderContainer container, Widget screen) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(1000, 1600);
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: buildMuyuTheme(),
        locale: AppLanguage.english.locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () =>
                    Navigator.of(context).push<void>(MaterialPageRoute(builder: (_) => screen)),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  for (var i = 0; i < 4; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
    await tester.pump(const Duration(milliseconds: 300));
  }
}

void main() {
  testWidgets('an incident report is sent to the backend', (tester) async {
    http.Request? posted;
    final container = (await tester.runAsync(
      () => farmerContainer((request) async {
        if (request.method == 'POST') {
          posted = request;
          return http.Response(
            jsonEncode({
              'id': 7,
              'type': 'payment',
              'description': 'The payment did not arrive',
              'createdAtUtc': '2026-11-12T15:00:00Z',
            }),
            201,
          );
        }
        return http.Response('[]', 200);
      }),
    ))!;
    await openScreen(tester, container, const ReportIncidentScreen());

    expect(find.text('No Connection'), findsNothing);
    await tester.tap(find.text('Technical issue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Payment issue').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'The payment did not arrive');
    await tester.pump();
    await tester.tap(find.text('Send report'));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
    await tester.pumpAndSettle();

    expect(posted!.url.path, '/mobile/incidents');
    expect(jsonDecode(posted!.body), {
      'type': 'payment',
      'description': 'The payment did not arrive',
    });
    expect(find.text('Report #7 sent. The support team will review it.'), findsOneWidget);
    expect(find.text('open'), findsOneWidget);
  });

  testWidgets('a report that cannot reach the server says so and stays open', (tester) async {
    final container = (await tester.runAsync(
      () => farmerContainer((request) async {
        if (request.method == 'POST') throw http.ClientException('offline');
        return http.Response('[]', 200);
      }),
    ))!;
    await openScreen(tester, container, const ReportIncidentScreen());

    await tester.enterText(find.byType(TextField), 'The app closes when I publish');
    await tester.pump();
    await tester.tap(find.text('Send report'));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
    await tester.pumpAndSettle();

    expect(find.textContaining('No connection. Your report was not sent'), findsOneWidget);
    expect(find.text('Send report'), findsOneWidget);
  });

  testWidgets('the farmer rates one of their finished contracts', (tester) async {
    final container = (await tester.runAsync(
      () => farmerContainer((request) async {
        if (request.url.path == '/mobile/contracts/finished') {
          return http.Response(
            jsonEncode([
              {
                'plotId': 8,
                'plotName': 'Esperanza',
                'buyerEmail': 'luis@gmail.com',
                'buyerName': 'Luis Vega',
                'endedOn': '13 Feb 2027, 09:00',
              },
              {
                'plotId': 9,
                'plotName': 'La Fortaleza',
                'buyerEmail': 'eva@gmail.com',
                'buyerName': '',
                'endedOn': '20 Mar 2027, 10:30',
              },
            ]),
            200,
          );
        }
        return http.Response('[]', 200);
      }),
    ))!;
    await openScreen(tester, container, const RateBuyerScreen());

    expect(find.text('Which contract do you want to rate?'), findsOneWidget);
    expect(find.text('eva@gmail.com · 20 Mar 2027, 10:30'), findsOneWidget);
    await tester.tap(find.text('Esperanza'));
    await tester.pumpAndSettle();

    expect(find.text('Esperanza'), findsOneWidget);
    expect(find.textContaining('Luis Vega'), findsWidgets);
  });

  testWidgets('a farmer without finished contracts sees no contract to rate', (tester) async {
    final container = (await tester.runAsync(
      () => farmerContainer((_) async => http.Response('[]', 200)),
    ))!;
    await openScreen(tester, container, const RateBuyerScreen());

    expect(find.text('You have no finished contracts to rate yet.'), findsOneWidget);
  });
}
