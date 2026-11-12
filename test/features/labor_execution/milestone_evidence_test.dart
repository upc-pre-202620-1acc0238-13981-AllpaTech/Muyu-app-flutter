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
import 'package:muyu_app/features/labor_execution/application/milestone_evidence_service.dart';
import 'package:muyu_app/features/labor_execution/presentation/record_evidence_screen.dart';
import 'package:muyu_app/features/plot_approval/domain/farmer_plot.dart';
import 'package:muyu_app/features/plot_approval/domain/plot_activity.dart';
import 'package:muyu_app/features/plot_financing/presentation/evidence/merchant_evidence_screens.dart';
import 'package:muyu_app/features/user_management/application/session_controller.dart';
import 'package:muyu_app/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

const farmerEmail = 'ana@gmail.com';
const merchantEmail = 'luis@gmail.com';
const photo = 'data:image/jpeg;base64,AAAA';
const cusco = EvidenceLocation(latitude: -13.531, longitude: -71.967, accuracyMeters: 8);

Map<String, dynamic> milestoneJson(String key, String status) => {
  'key': key,
  'status': status,
  'dueLabel': '',
  'photoUri': '',
  'inputUsed': '',
  'amountApplied': '',
  'notes': '',
  'recordedAt': '',
  'submittedAtMillis': 0,
  'latitude': null,
  'longitude': null,
  'accuracyMeters': null,
  'extensionDate': '',
  'extensionReason': '',
};

FarmerPlot fundedPlot({List<Map<String, dynamic>>? milestones}) => FarmerPlot.fromJson({
  'id': 8,
  'name': 'Esperanza',
  'crop': 'Papa',
  'area': '3 ha',
  'place': 'Cusco',
  'stage': 'Planting',
  'progress': 25,
  'status': 'funded',
  'amount': 'S/ 8 500',
  'ownerEmail': farmerEmail,
  'ownerName': 'Ana Rojas',
  'fundedByEmail': merchantEmail,
  'milestoneStates':
      milestones ??
      [
        milestoneJson('planting', 'approved'),
        milestoneJson('irrigation', 'pending'),
        milestoneJson('fertilization', 'pending'),
        milestoneJson('harvest', 'pending'),
      ],
});

Future<ProviderContainer> containerAs(
  String email,
  String role,
  Future<http.Response> Function(http.Request) handler,
) async {
  SharedPreferences.setMockInitialValues({
    'session': jsonEncode({
      'email': email,
      'firstName': 'Ana',
      'lastName': 'Rojas',
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
      evidenceLocatorProvider.overrideWithValue(() async => cusco),
      evidencePhotoPickerProvider.overrideWithValue((_) async => photo),
    ],
  );
  addTearDown(container.dispose);
  container.listen(sessionProvider, (_, _) {});
  await Future<void>.delayed(const Duration(milliseconds: 1300));
  return container;
}

void main() {
  group('plot milestones', () {
    test('a milestone sent back for correction comes before the pending ones', () {
      final plot = fundedPlot(
        milestones: [
          milestoneJson('planting', 'needs_correction'),
          milestoneJson('irrigation', 'pending'),
        ],
      );

      expect(plot.currentMilestone?.key, 'planting');
    });

    test('submitting a milestone moves the stage and progress like Kotlin', () {
      final plot = fundedPlot();
      final submitted = plot.milestone('irrigation')!.copyWith(status: 'submitted');

      final next = plot.withMilestone(submitted);

      expect(next.stage, 'Irrigation');
      expect(next.progress, 50);
      expect(next.currentMilestone?.key, 'fertilization');
    });
  });

  group('evidence service', () {
    test('the farmer evidence carries the photo, input and GPS Kotlin reads', () async {
      Map<String, dynamic>? saved;
      final container = await containerAs(farmerEmail, 'farmer', (request) async {
        if (request.method == 'PUT') {
          saved = jsonDecode(request.body) as Map<String, dynamic>;
          return http.Response('', 204);
        }
        return http.Response('[]', 200);
      });

      await container
          .read(milestoneEvidenceServiceProvider)
          .submitEvidence(
            plot: fundedPlot(),
            milestoneKey: 'irrigation',
            photoUri: photo,
            inputUsed: 'Water',
            amountApplied: '200 L',
            notes: 'Morning irrigation',
            location: cusco,
          );

      final milestones = (saved!['milestoneStates'] as List).cast<Map<String, dynamic>>();
      final irrigation = milestones.firstWhere((m) => m['key'] == 'irrigation');
      expect(irrigation['status'], 'submitted');
      expect(irrigation['photoUri'], photo);
      expect(irrigation['inputUsed'], 'Water');
      expect(irrigation['amountApplied'], '200 L');
      expect(irrigation['latitude'], -13.531);
      expect(irrigation['accuracyMeters'], 8);
      expect(irrigation['submittedAtMillis'], greaterThan(0));
      expect(saved!['stage'], 'Irrigation');
      expect(saved!['progress'], 50);
      expect(milestones.firstWhere((m) => m['key'] == 'planting')['status'], 'approved');
    });

    test('the merchant approves a submitted milestone', () async {
      Map<String, dynamic>? saved;
      final container = await containerAs(merchantEmail, 'merchant', (request) async {
        if (request.method == 'PUT') {
          saved = jsonDecode(request.body) as Map<String, dynamic>;
          return http.Response('', 204);
        }
        return http.Response('[]', 200);
      });
      final plot = fundedPlot(
        milestones: [
          milestoneJson('planting', 'approved'),
          {...milestoneJson('irrigation', 'submitted'), 'photoUri': photo},
        ],
      );

      await container
          .read(milestoneEvidenceServiceProvider)
          .review(plot: plot, milestoneKey: 'irrigation', approved: true);

      final irrigation = (saved!['milestoneStates'] as List).cast<Map<String, dynamic>>().last;
      expect(irrigation['status'], 'approved');
      expect(irrigation['photoUri'], photo);
      expect(irrigation['reviewedAtMillis'], greaterThan(0));
    });

    test('the merchant asks for a correction with a reason', () async {
      Map<String, dynamic>? saved;
      final container = await containerAs(merchantEmail, 'merchant', (request) async {
        if (request.method == 'PUT') {
          saved = jsonDecode(request.body) as Map<String, dynamic>;
          return http.Response('', 204);
        }
        return http.Response('[]', 200);
      });
      final plot = fundedPlot(milestones: [milestoneJson('planting', 'submitted')]);

      final next = await container
          .read(milestoneEvidenceServiceProvider)
          .review(
            plot: plot,
            milestoneKey: 'planting',
            approved: false,
            reason: 'The photo is blurry',
          );

      final planting = (saved!['milestoneStates'] as List).cast<Map<String, dynamic>>().single;
      expect(planting['status'], 'needs_correction');
      expect(planting['reviewComment'], 'The photo is blurry');
      expect(next.currentMilestone?.key, 'planting');
    });
  });

  testWidgets('the farmer records evidence from the evidence screen', (tester) async {
    Map<String, dynamic>? saved;
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1000, 1600);
    addTearDown(tester.view.reset);
    final container = (await tester.runAsync(
      () => containerAs(farmerEmail, 'farmer', (request) async {
        if (request.method == 'PUT') {
          saved = jsonDecode(request.body) as Map<String, dynamic>;
          return http.Response('', 204);
        }
        return http.Response('[]', 200);
      }),
    ))!;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: buildMuyuTheme(),
          locale: AppLanguage.english.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: RecordEvidenceScreen(plot: fundedPlot(), milestoneKey: 'irrigation'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Location recorded'), findsOneWidget);
    await tester.tap(find.text('Take photo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Input used'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Water').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Amount applied'), '200 L');
    await tester.pump();
    await tester.tap(find.text('Send evidence'));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
    await tester.pumpAndSettle();

    final irrigation = (saved!['milestoneStates'] as List).cast<Map<String, dynamic>>().firstWhere(
      (m) => m['key'] == 'irrigation',
    );
    expect(irrigation['status'], 'submitted');
    expect(irrigation['photoUri'], photo);
    expect(irrigation['inputUsed'], 'Water');
  });

  testWidgets('the merchant approves evidence and sees the amount released', (tester) async {
    Map<String, dynamic>? saved;
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1000, 1600);
    addTearDown(tester.view.reset);
    final container = (await tester.runAsync(
      () => containerAs(merchantEmail, 'merchant', (request) async {
        if (request.method == 'PUT') {
          saved = jsonDecode(request.body) as Map<String, dynamic>;
          return http.Response('', 204);
        }
        return http.Response('[]', 200);
      }),
    ))!;
    final plot = fundedPlot(
      milestones: [
        {...milestoneJson('planting', 'submitted'), 'inputUsed': 'Compost', 'latitude': -13.531},
      ],
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: buildMuyuTheme(),
          locale: AppLanguage.english.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: MilestoneEvidenceReviewScreen(plot: plot, milestoneKey: 'planting'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Compost'), findsOneWidget);
    expect(find.text('Approving releases S/ 2 000 from escrow.'), findsOneWidget);
    await tester.tap(find.text('Approve milestone'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Approve and release'));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
    await tester.pumpAndSettle();

    final planting = (saved!['milestoneStates'] as List).cast<Map<String, dynamic>>().single;
    expect(planting['status'], 'approved');
    expect(saved!['progress'], 25);
  });

  test('MilestoneState keeps the review fields when copied', () {
    final state = MilestoneState.fromJson({
      ...milestoneJson('harvest', 'submitted'),
      'photoUri': photo,
    }).copyWith(status: 'approved', extra: {'reviewedAtMillis': 1762700000000});

    expect(state.photoUri, photo);
    expect(state.reviewedAt, isNotNull);
    expect(state.toJson()['reviewedAtMillis'], 1762700000000);
  });
}
