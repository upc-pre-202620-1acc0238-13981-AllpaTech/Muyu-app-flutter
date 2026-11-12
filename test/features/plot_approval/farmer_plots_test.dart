import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:muyu_app/core/designsystem/components/muyu_controls.dart';
import 'package:muyu_app/core/i18n/app_language.dart';
import 'package:muyu_app/core/network/api_client.dart';
import 'package:muyu_app/core/storage/user_preferences.dart';
import 'package:muyu_app/features/plot_approval/application/farmer_plots_controller.dart';
import 'package:muyu_app/features/plot_approval/domain/farmer_plot.dart';
import 'package:muyu_app/features/plot_approval/domain/farmer_plot_repository.dart';
import 'package:muyu_app/features/plot_approval/domain/plot_finance.dart';
import 'package:muyu_app/features/plot_approval/presentation/myplots/my_plots_view.dart';
import 'package:muyu_app/features/plot_approval/presentation/publish/publish_plot_screen.dart';
import 'package:muyu_app/features/user_management/application/session_controller.dart';
import 'package:muyu_app/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

const farmer = 'ana@gmail.com';

Map<String, dynamic> plotJson(int id, String owner, {String status = 'available'}) => {
  'id': id,
  'name': 'Plot $id',
  'crop': 'Papa',
  'area': '3 ha',
  'harvestDate': '1 Mar 2027',
  'place': 'Cusco',
  'status': status,
  'amount': 'S/ 8 500',
  'ownerEmail': owner,
};

const newPlot = NewFarmerPlot(
  name: 'Esperanza',
  crop: 'Papa',
  area: '3.5 ha',
  harvestDate: '1 Mar 2027',
  place: 'Cusco',
  amount: 'S/ 8 500',
  cycle: '6 months',
);

/// Signs a farmer in and answers API calls with [handler].
Future<ProviderContainer> containerWith(
  Future<http.Response> Function(http.Request) handler, {
  bool signedIn = true,
}) async {
  SharedPreferences.setMockInitialValues({
    if (signedIn)
      'session': jsonEncode({
        'email': farmer,
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

Future<void> pumpScreen(WidgetTester tester, ProviderContainer container, Widget child) async {
  tester.view.devicePixelRatio = 3;
  tester.view.physicalSize = const Size(402 * 3, 874 * 3);
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        locale: AppLanguage.english.locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Scaffold(body: child),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('PlotFinance', () {
    test('formats amounts like the Kotlin app', () {
      expect(PlotFinance.formatAmount(8500), 'S/ 8 500');
      expect(PlotFinance.formatAmount(950), 'S/ 950');
      expect(PlotFinance.formatAmount(1250000), 'S/ 1 250 000');
    });

    test('parses formatted amounts', () => expect(PlotFinance.parseAmount('S/ 8 500'), 8500));

    test('the four milestones add up to the total', () {
      final steps = PlotFinance.disbursement(8500);
      expect(steps, hasLength(4));
      expect(steps.reduce((a, b) => a + b), closeTo(8500, 0.001));
      expect(steps.first.round(), 2000);
      expect(steps.last.round(), 2500);
    });
  });

  group('FarmerPlotsController', () {
    test('lists only the signed-in farmer\'s plots, newest first', () async {
      late http.Request sent;
      final c = await containerWith((request) async {
        sent = request;
        return http.Response(
          jsonEncode([
            plotJson(1, 'ANA@gmail.com'),
            plotJson(2, 'luis@gmail.com'),
            plotJson(3, farmer),
          ]),
          200,
        );
      });

      final plots = await c.read(farmerPlotsProvider.future);

      expect(plots.map((p) => p.id), [3, 1]);
      expect(sent.url.toString(), 'https://api.test/mobile/plots');
      expect(sent.headers['Authorization'], 'Bearer jwt');
    });

    test('publishes with the next shared id and the Kotlin record fields', () async {
      http.Request? put;
      final c = await containerWith((request) async {
        if (request.method == 'PUT') {
          put = request;
          return http.Response('', 200);
        }
        return http.Response(jsonEncode([plotJson(7, 'luis@gmail.com')]), 200);
      });

      await c.read(farmerPlotsProvider.notifier).publish(newPlot);

      expect(put!.url.path, '/mobile/plots/8');
      final body = jsonDecode(put!.body) as Map<String, dynamic>;
      expect(body['id'], 8);
      expect(body['ownerEmail'], farmer);
      expect(body['ownerName'], 'Ana Rojas');
      expect(body['status'], 'available');
      expect(body['stage'], 'Published');
      expect(body['milestones'], '4');
      expect(body['milestoneStates'], isEmpty);
    });

    test('an expired token signs the user out', () async {
      final c = await containerWith((_) async => http.Response('{}', 401));

      await expectLater(
        c.read(farmerPlotsProvider.future),
        throwsA(
          isA<PlotException>().having((e) => e.failure, 'failure', PlotFailure.sessionExpired),
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(c.read(sessionProvider).status, SessionStatus.signedOut);
    });

    test('a backend rejection is reported when publishing', () async {
      final c = await containerWith(
        (request) async =>
            request.method == 'PUT' ? http.Response('{}', 403) : http.Response('[]', 200),
      );

      await expectLater(
        c.read(farmerPlotsProvider.notifier).publish(newPlot),
        throwsA(isA<PlotException>().having((e) => e.failure, 'failure', PlotFailure.rejected)),
      );
    });

    test('updates a plot in the backend and in the current list', () async {
      http.Request? put;
      final c = await containerWith((request) async {
        if (request.method == 'PUT') {
          put = request;
          return http.Response('', 204);
        }
        return http.Response(jsonEncode([plotJson(4, farmer)]), 200);
      });
      final original = (await c.read(farmerPlotsProvider.future)).single;

      await c
          .read(farmerPlotsProvider.notifier)
          .updatePlot(original.copyWith(name: 'Updated plot', area: '5 ha'));

      expect(put!.url.path, '/mobile/plots/4');
      expect(put!.headers['Authorization'], 'Bearer jwt');
      final body = jsonDecode(put!.body) as Map<String, dynamic>;
      expect(body['name'], 'Updated plot');
      expect(body['area'], '5 ha');
      expect(c.read(farmerPlotsProvider).value!.single.name, 'Updated plot');
    });

    test('deletes a plot from the backend and the current list', () async {
      http.Request? deleted;
      final c = await containerWith((request) async {
        if (request.method == 'DELETE') {
          deleted = request;
          return http.Response('', 204);
        }
        return http.Response(jsonEncode([plotJson(5, farmer)]), 200);
      });
      await c.read(farmerPlotsProvider.future);

      await c.read(farmerPlotsProvider.notifier).delete(5);

      expect(deleted!.url.path, '/mobile/plots/5');
      expect(deleted!.headers['Authorization'], 'Bearer jwt');
      expect(c.read(farmerPlotsProvider).value, isEmpty);
    });
  });

  group('screens', () {
    testWidgets('a new farmer sees the empty state, without demo plots', (tester) async {
      final c = (await tester.runAsync(
        () => containerWith((_) async => http.Response('[]', 200)),
      ))!;
      await pumpScreen(tester, c, const MyPlotsView());
      await tester.runAsync(() => c.read(farmerPlotsProvider.future));
      await tester.pumpAndSettle();

      expect(find.text('You have not published any plots yet.'), findsOneWidget);
    });

    testWidgets('search and filters narrow the list', (tester) async {
      final body = jsonEncode([
        plotJson(1, farmer),
        {...plotJson(2, farmer), 'status': 'funded'},
      ]);
      final c = (await tester.runAsync(
        () => containerWith((_) async => http.Response(body, 200)),
      ))!;
      await pumpScreen(tester, c, const MyPlotsView());
      await tester.runAsync(() => c.read(farmerPlotsProvider.future));
      await tester.pumpAndSettle();
      expect(find.text('Plot 1'), findsOneWidget);
      expect(find.text('Plot 2'), findsOneWidget);

      await tester.tap(find.widgetWithText(MuyuFilterChip, 'Funded'));
      await tester.pumpAndSettle();
      expect(find.text('Plot 1'), findsNothing);
      expect(find.text('Plot 2'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'nothing like this');
      await tester.pumpAndSettle();
      expect(find.text('No plots match your search or filter.'), findsOneWidget);
    });

    testWidgets('tapping an owned plot opens its details and management actions', (tester) async {
      final c = (await tester.runAsync(
        () => containerWith((_) async => http.Response(jsonEncode([plotJson(1, farmer)]), 200)),
      ))!;
      await pumpScreen(tester, c, const MyPlotsView());
      await tester.runAsync(() => c.read(farmerPlotsProvider.future));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Plot 1'));
      await tester.pumpAndSettle();

      expect(find.text('Plot details'), findsOneWidget);
      // The visits card sits above the actions, so scroll down to them.
      await tester.scrollUntilVisible(find.text('Delete plot'), 200);
      expect(find.text('Edit plot'), findsOneWidget);
      expect(find.text('Delete plot'), findsOneWidget);
    });

    testWidgets('the publish flow requires the first step before moving on', (tester) async {
      final c = (await tester.runAsync(
        () => containerWith((_) async => http.Response('[]', 200)),
      ))!;
      await pumpScreen(tester, c, const PublishPlotScreen());

      await tester.tap(find.text('Next: location'));
      await tester.pumpAndSettle();

      expect(find.text('Complete this field.'), findsWidgets);
      expect(find.text('Next: financing'), findsNothing);
    });
  });
}
