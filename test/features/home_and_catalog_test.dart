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
import 'package:muyu_app/features/plot_approval/presentation/home/farmer_home_screen.dart';
import 'package:muyu_app/features/plot_financing/presentation/catalog/merchant_catalog_screen.dart';
import 'package:muyu_app/features/user_management/application/session_controller.dart';
import 'package:muyu_app/features/user_management/presentation/incident/report_incident_screen.dart';
import 'package:muyu_app/features/user_management/presentation/rating/rate_buyer_screen.dart';
import 'package:muyu_app/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

const farmer = 'ana@gmail.com';
const emptyMessage = 'You have not published any plots yet.';

final plots = jsonEncode([
  {
    'id': 1,
    'name': 'Esperanza',
    'crop': 'Papa',
    'area': '3 ha',
    'place': 'Cusco',
    'status': 'available',
    'amount': 'S/ 8 500',
    'ownerEmail': farmer,
    'ownerName': 'Ana Rojas',
  },
]);

Future<ProviderContainer> containerWith(
  Future<http.Response> Function(http.Request) handler,
) async {
  SharedPreferences.setMockInitialValues({
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

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 3; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<ProviderContainer> show(
  WidgetTester tester,
  Widget screen,
  Future<http.Response> Function(http.Request) handler, {
  Size size = const Size(1000, 1000),
}) async {
  // Wide enough for the placeholder font flutter_test renders text with.
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);
  final container = (await tester.runAsync(() => containerWith(handler)))!;
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
  await settle(tester);
  return container;
}

void main() {
  testWidgets('Home lists the farmer plots instead of the empty message', (tester) async {
    await show(tester, const FarmerHomeScreen(), (_) async => http.Response(plots, 200));

    expect(find.text('Esperanza'), findsOneWidget);
    expect(find.text('Current stage:  —'), findsOneWidget);
    expect(find.text('0% complete'), findsOneWidget);
    expect(find.text('Pending'), findsWidgets);
    expect(find.text(emptyMessage), findsNothing);
  });

  testWidgets('Home keeps the empty message for a new farmer', (tester) async {
    await show(tester, const FarmerHomeScreen(), (_) async => http.Response('[]', 200));

    expect(find.text(emptyMessage), findsOneWidget);
    expect(find.text('Available'), findsOneWidget);
    expect(find.text('Pending'), findsNothing);
  });

  testWidgets('Home with a real plot fits the Figma phone size', (tester) async {
    await show(
      tester,
      const FarmerHomeScreen(),
      (_) async => http.Response(plots, 200),
      size: const Size(402, 874),
    );

    expect(find.text('Esperanza'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the catalog reports a backend failure and can retry', (tester) async {
    var healthy = false;
    await show(
      tester,
      const MerchantCatalogScreen(),
      (_) async => healthy ? http.Response(plots, 200) : http.Response('{}', 500),
    );

    expect(find.text('Unable to load plots. Please try again.'), findsOneWidget);
    expect(find.text('No plots available yet'), findsNothing);

    healthy = true;
    await tester.tap(find.text('Try again'));
    await settle(tester);

    expect(find.text('Esperanza'), findsOneWidget);
  });

  testWidgets('the catalog signs out when the token expired', (tester) async {
    final container = await show(
      tester,
      const MerchantCatalogScreen(),
      (_) async => http.Response('{}', 401),
    );

    expect(container.read(sessionProvider).status, SessionStatus.signedOut);
  });

  testWidgets('tapping a catalog card opens the merchant plot details', (tester) async {
    await show(tester, const MerchantCatalogScreen(), (_) async => http.Response(plots, 200));

    await tester.tap(find.text('Esperanza'));
    await tester.pumpAndSettle();

    expect(find.text('Plot details'), findsOneWidget);
    expect(find.text('Farmer'), findsOneWidget);
    expect(find.text('Ana Rojas'), findsOneWidget);
    expect(find.textContaining('Funds are held in escrow'), findsOneWidget);
  });

  testWidgets('the merchant funds a plot from its details', (tester) async {
    Map<String, dynamic>? saved;
    await show(tester, const MerchantCatalogScreen(), (request) async {
      if (request.method == 'PUT') {
        saved = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response('', 204);
      }
      return http.Response(plots, 200);
    });

    await tester.tap(find.text('Esperanza'));
    await tester.pumpAndSettle();
    final fund = find.text('Fund this plot');
    await tester.ensureVisible(fund);
    await tester.tap(fund);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Bank transfer'));
    await tester.pump();
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pump();
    final confirm = find.text('Confirm and pay S/ 8 500');
    await tester.ensureVisible(confirm);
    await tester.tap(confirm);
    await tester.pumpAndSettle();

    expect(find.text('Financing confirmed'), findsOneWidget);
    expect(saved!['status'], 'funded');
    expect(saved!['stage'], 'Planting');
  });

  testWidgets('rating without a contract shows no demo data', (tester) async {
    await show(tester, const RateBuyerScreen(), (_) async => http.Response('[]', 200));

    expect(find.text('You have no finished contracts to rate yet.'), findsOneWidget);
    expect(find.textContaining('Valeria'), findsNothing);
    expect(find.textContaining('La Cosecha'), findsNothing);
  });

  testWidgets('rating shows the contract it receives', (tester) async {
    const contract = RatingContract(
      plotName: 'Real plot',
      buyerName: 'Real buyer',
      companyName: 'Real company',
      endedOn: '1 Mar 2027',
    );
    await show(
      tester,
      const RateBuyerScreen(contract: contract),
      (_) async => http.Response('[]', 200),
    );

    expect(find.text('Real plot'), findsOneWidget);
    expect(find.text('Real company'), findsOneWidget);
  });

  testWidgets('the incident screen opens the farmer report form', (tester) async {
    await show(tester, const ReportIncidentScreen(), (_) async => http.Response('[]', 200));

    expect(find.text('Issue type'), findsOneWidget);
    expect(find.text('Send report'), findsOneWidget);
    expect(find.text('Call technical support'), findsNothing);
  });
}
