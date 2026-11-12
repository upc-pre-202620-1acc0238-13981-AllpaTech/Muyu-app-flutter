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
import 'package:muyu_app/features/plot_approval/domain/farmer_plot.dart';
import 'package:muyu_app/features/plot_approval/domain/harvest_delivery.dart';
import 'package:muyu_app/features/plot_financing/application/harvest_delivery_service.dart';
import 'package:muyu_app/features/plot_financing/presentation/harvest/harvest_delivery_screens.dart';
import 'package:muyu_app/features/user_management/application/session_controller.dart';
import 'package:muyu_app/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

const merchantEmail = 'luis@gmail.com';

FarmerPlot plotWith({
  String harvestStatus = 'approved',
  String status = 'funded',
  Map<String, dynamic> extra = const {},
}) => FarmerPlot.fromJson({
  'id': 8,
  'name': 'Esperanza',
  'crop': 'Papa',
  'area': '3 ha',
  'place': 'Cusco',
  'harvestDate': '15 Feb 2027',
  'stage': 'Harvest',
  'progress': 100,
  'status': status,
  'amount': 'S/ 8 500',
  'ownerEmail': 'ana@gmail.com',
  'ownerName': 'Ana Rojas',
  'fundedByEmail': merchantEmail,
  'milestoneStates': [
    {
      'key': 'harvest',
      'status': harvestStatus,
      'amountApplied': '40 sacks',
      'recordedAt': '10 Feb 2027',
    },
  ],
  ...extra,
});

Future<ProviderContainer> merchantContainer(
  Future<http.Response> Function(http.Request) handler,
) async {
  SharedPreferences.setMockInitialValues({
    'session': jsonEncode({
      'email': merchantEmail,
      'firstName': 'Luis',
      'lastName': 'Vega',
      'role': 'merchant',
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
        home: screen,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('harvest delivery state', () {
    test('it opens only after the harvest milestone is approved', () {
      expect(
        plotWith(harvestStatus: 'submitted').harvestDeliveryState,
        HarvestDeliveryState.notReady,
      );
      expect(plotWith().harvestDeliveryState, HarvestDeliveryState.pending);
    });

    test('an incident keeps it open and a receipt closes it', () {
      final withIncident = plotWith().withHarvestIncident(
        const HarvestIncident(
          reason: 'late',
          details: 'Arrived two days late',
          reportedAt: '12 Feb 2027, 10:00',
          reportedAtMillis: 1,
          reportedBy: merchantEmail,
        ),
      );
      expect(withIncident.harvestDeliveryState, HarvestDeliveryState.withIncident);

      final received = withIncident.harvestReceived(by: merchantEmail, at: '13 Feb 2027, 09:00');
      expect(received.harvestDeliveryState, HarvestDeliveryState.received);
      expect(received.stage, 'Harvest received');
    });
  });

  test('confirming the receipt writes what Kotlin and finished contracts read', () async {
    Map<String, dynamic>? saved;
    final container = await merchantContainer((request) async {
      if (request.method == 'PUT') {
        saved = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response('', 204);
      }
      return http.Response('[]', 200);
    });

    await container.read(harvestDeliveryServiceProvider).confirmReceipt(plotWith());

    expect(saved!['harvestReceivedBy'], merchantEmail);
    expect(
      saved!['harvestReceivedAt'],
      matches(RegExp(r'^\d{1,2} [A-Z][a-z]{2} \d{4}, \d{2}:\d{2}$')),
    );
    expect(saved!['stage'], 'Harvest received');
    expect(saved!['status'], 'funded');
  });

  testWidgets('the merchant reports an incident only with enough detail', (tester) async {
    Map<String, dynamic>? saved;
    final container = (await tester.runAsync(
      () => merchantContainer((request) async {
        if (request.method == 'PUT') {
          saved = jsonDecode(request.body) as Map<String, dynamic>;
          return http.Response('', 204);
        }
        return http.Response('[]', 200);
      }),
    ))!;
    await pumpScreen(tester, container, HarvestIncidentScreen(plot: plotWith()));

    await tester.tap(find.text('Quality issue'));
    await tester.enterText(find.byType(TextField), 'Bad');
    await tester.tap(find.text('Send incident'));
    await tester.pump();
    expect(find.text('Write at least 10 characters.'), findsOneWidget);
    expect(saved, isNull);

    await tester.enterText(find.byType(TextField), 'Several sacks were wet');
    await tester.tap(find.text('Send incident'));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
    await tester.pumpAndSettle();

    final incident = (saved!['harvestIncidents'] as List).single as Map<String, dynamic>;
    expect(incident['reason'], 'quality');
    expect(incident['details'], 'Several sacks were wet');
    expect(incident['reportedBy'], merchantEmail);
    expect(saved!['harvestReceivedAt'], '');
  });

  testWidgets('the merchant confirms the receipt after agreeing', (tester) async {
    final container = (await tester.runAsync(
      () => merchantContainer((request) async {
        if (request.method == 'PUT') return http.Response('', 204);
        return http.Response('[]', 200);
      }),
    ))!;
    await pumpScreen(tester, container, HarvestReceiptScreen(plot: plotWith()));

    expect(find.text('40 sacks'), findsOneWidget);
    final confirm = find.widgetWithText(FilledButton, 'Confirm receipt');
    expect(tester.widget<FilledButton>(confirm).onPressed, isNull);

    await tester.tap(find.byType(CheckboxListTile));
    await tester.pump();
    await tester.tap(confirm);
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Harvest received. The agreement with Ana Rojas is closed.'),
      findsOneWidget,
    );
  });

  testWidgets('the farmer sees when the merchant received the harvest', (tester) async {
    final container = (await tester.runAsync(
      () => merchantContainer((_) async => http.Response('[]', 200)),
    ))!;
    final received = plotWith().harvestReceived(by: merchantEmail, at: '13 Feb 2027, 09:00');
    await pumpScreen(tester, container, Scaffold(body: FarmerHarvestNotice(plot: received)));

    expect(find.text('The merchant received your harvest'), findsOneWidget);
    expect(find.textContaining('13 Feb 2027, 09:00'), findsOneWidget);
  });
}
