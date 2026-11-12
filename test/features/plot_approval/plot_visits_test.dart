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
import 'package:muyu_app/features/plot_approval/application/plot_visits_controller.dart';
import 'package:muyu_app/features/plot_approval/domain/plot.dart';
import 'package:muyu_app/features/plot_approval/domain/plot_visit.dart';
import 'package:muyu_app/features/plot_approval/presentation/visits/farmer_visits_card.dart';
import 'package:muyu_app/features/plot_financing/presentation/visit/visit_request_screen.dart';
import 'package:muyu_app/features/user_management/application/session_controller.dart';
import 'package:muyu_app/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

const farmerEmail = 'ana@gmail.com';
const merchantEmail = 'luis@gmail.com';

Map<String, dynamic> visitJson(String status, {String outcome = ''}) => {
  'id': 41,
  'plotId': 8,
  'plotName': 'Esperanza',
  'plotPlace': 'Cusco',
  'farmerEmail': farmerEmail,
  'farmerName': 'Ana Rojas',
  'merchantEmail': merchantEmail,
  'merchantName': 'Luis Vega',
  'date': '20/11/2026',
  'time': '10:00',
  'message': 'I would like to see the potatoes',
  'status': status,
  'outcome': outcome,
  'agreedPrice': '',
};

const plot = Plot(
  id: 8,
  name: 'Esperanza',
  crop: 'Papa',
  area: '3 ha',
  place: 'Cusco',
  harvestDate: '15 Feb 2027',
  cycle: '6 months',
  milestones: '4',
  amount: 'S/ 8 500',
  status: 'available',
  ownerName: 'Ana Rojas',
  ownerEmail: farmerEmail,
);

Future<ProviderContainer> containerAs(
  String email,
  String role,
  Future<http.Response> Function(http.Request) handler,
) async {
  SharedPreferences.setMockInitialValues({
    'session': jsonEncode({
      'email': email,
      'firstName': role == 'farmer' ? 'Ana' : 'Luis',
      'lastName': role == 'farmer' ? 'Rojas' : 'Vega',
      'role': role,
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

Future<void> pumpScreen(WidgetTester tester, ProviderContainer container, Widget screen) async {
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
        home: Scaffold(body: screen),
      ),
    ),
  );
  for (var i = 0; i < 3; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  test('a Kotlin request saved as pending still waits for the farmer', () {
    expect(PlotVisit.fromJson(visitJson('pending')).isRequested, isTrue);
    expect(
      PlotVisit.fromJson({...visitJson('confirmed'), 'outcome': 'agreement'}).isCompleted,
      isTrue,
    );
  });

  test('the merchant request carries what Kotlin and the backend expect', () async {
    http.Request? put;
    final container = await containerAs(merchantEmail, 'merchant', (request) async {
      if (request.method == 'PUT') {
        put = request;
        return http.Response('', 204);
      }
      return http.Response('[]', 200);
    });
    await container.read(plotVisitsProvider.future);

    final visit = await container
        .read(plotVisitsProvider.notifier)
        .request(plot: plot, date: DateTime(2026, 11, 20), time: '09:00', message: ' Hello ');

    final body = jsonDecode(put!.body) as Map<String, dynamic>;
    expect(put!.url.path, '/mobile/visits/${visit.id}');
    expect(body['farmerEmail'], farmerEmail);
    expect(body['merchantEmail'], merchantEmail);
    expect(body['merchantName'], 'Luis Vega');
    expect(body['date'], '20/11/2026');
    expect(body['time'], '09:00');
    expect(body['message'], 'Hello');
    expect(body['status'], 'requested');
    expect(container.read(plotVisitsProvider).value, hasLength(1));
  });

  test('only visits the user takes part in are listed', () async {
    final container = await containerAs(farmerEmail, 'farmer', (_) async {
      return http.Response(
        jsonEncode([
          visitJson('requested'),
          {...visitJson('requested'), 'id': 42, 'farmerEmail': 'other@gmail.com'},
        ]),
        200,
      );
    });

    final visits = await container.read(plotVisitsProvider.future);

    expect(visits.map((visit) => visit.id), [41]);
  });

  testWidgets('the merchant requests a visit from the plot details', (tester) async {
    Map<String, dynamic>? saved;
    final container = (await tester.runAsync(
      () => containerAs(merchantEmail, 'merchant', (request) async {
        if (request.method == 'PUT') {
          saved = jsonDecode(request.body) as Map<String, dynamic>;
          return http.Response('', 204);
        }
        return http.Response('[]', 200);
      }),
    ))!;
    await pumpScreen(
      tester,
      container,
      const SingleChildScrollView(child: MerchantVisitPanel(plot: plot)),
    );

    await tester.tap(find.text('Request a visit'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('14:00'));
    await tester.pump();
    await tester.tap(find.text('Send request'));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
    await tester.pumpAndSettle();

    expect(saved!['time'], '14:00');
    expect(find.text('Awaiting reply'), findsOneWidget);
    expect(find.text('Request a visit'), findsNothing);
  });

  testWidgets('the farmer accepts a request and records an agreement', (tester) async {
    final saved = <Map<String, dynamic>>[];
    final container = (await tester.runAsync(
      () => containerAs(farmerEmail, 'farmer', (request) async {
        if (request.method == 'PUT') {
          saved.add(jsonDecode(request.body) as Map<String, dynamic>);
          return http.Response('', 204);
        }
        return http.Response(jsonEncode([visitJson('requested')]), 200);
      }),
    ))!;
    await pumpScreen(
      tester,
      container,
      const SingleChildScrollView(child: FarmerVisitsCard(plotId: 8)),
    );

    expect(find.text('Luis Vega'), findsOneWidget);
    await tester.tap(find.text('Accept'));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
    await tester.pumpAndSettle();
    expect(saved.last['status'], 'confirmed');

    await tester.tap(find.text('Record outcome'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('We reached an agreement'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'S/ 1.20 per kg');
    await tester.pump();
    await tester.tap(find.text('Save outcome'));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
    await tester.pumpAndSettle();

    expect(saved.last['status'], 'completed');
    expect(saved.last['outcome'], 'agreement');
    expect(saved.last['agreedPrice'], 'S/ 1.20 per kg');
    expect(find.text('Agreed price: S/ 1.20 per kg'), findsOneWidget);
  });
}
