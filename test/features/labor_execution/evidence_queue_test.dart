import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:muyu_app/core/network/api_client.dart';
import 'package:muyu_app/core/storage/user_preferences.dart';
import 'package:muyu_app/core/theme/muyu_theme.dart';
import 'package:muyu_app/features/labor_execution/application/evidence_queue.dart';
import 'package:muyu_app/features/labor_execution/application/milestone_evidence_service.dart';
import 'package:muyu_app/features/labor_execution/presentation/sync_view.dart';
import 'package:muyu_app/features/plot_approval/domain/farmer_plot.dart';
import 'package:muyu_app/features/user_management/application/session_controller.dart';
import 'package:muyu_app/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

const farmerEmail = 'ana@gmail.com';
const photo = 'data:image/jpeg;base64,AAAA';
const cusco = EvidenceLocation(latitude: -13.531, longitude: -71.967, accuracyMeters: 8);

Map<String, dynamic> milestoneJson(String key, String status) => {
  'key': key,
  'status': status,
  'photoUri': '',
  'inputUsed': '',
  'amountApplied': '',
  'notes': '',
  'recordedAt': '',
  'submittedAtMillis': 0,
};

Map<String, dynamic> plotJson() => {
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
  'fundedByEmail': 'luis@gmail.com',
  'milestoneStates': [
    milestoneJson('planting', 'approved'),
    milestoneJson('irrigation', 'pending'),
    milestoneJson('fertilization', 'pending'),
    milestoneJson('harvest', 'pending'),
  ],
};

/// A fake backend that can lose signal.
class FieldBackend {
  bool online = true;
  final List<Map<String, dynamic>> saved = [];

  Future<http.Response> handle(http.Request request) async {
    if (!online) throw http.ClientException('no signal');
    if (request.method == 'PUT') {
      saved.add(jsonDecode(request.body) as Map<String, dynamic>);
      return http.Response('', 204);
    }
    return http.Response(jsonEncode([plotJson()]), 200);
  }
}

Future<ProviderContainer> farmerContainer(FieldBackend backend) async {
  SharedPreferences.setMockInitialValues({
    'session': jsonEncode({
      'email': farmerEmail,
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
        ApiClient(baseUrl: 'https://api.test/', client: MockClient(backend.handle)),
      ),
      evidenceLocatorProvider.overrideWithValue(() async => cusco),
      evidencePhotoPickerProvider.overrideWithValue((_) async => photo),
    ],
  );
  addTearDown(container.dispose);
  container.listen(sessionProvider, (_, _) {});
  container.listen(evidenceQueueProvider, (_, _) {});
  await Future<void>.delayed(const Duration(milliseconds: 1300));
  return container;
}

Future<EvidenceSubmission> recordIrrigation(ProviderContainer container) => container
    .read(milestoneEvidenceServiceProvider)
    .submitEvidence(
      plot: FarmerPlot.fromJson(plotJson()),
      milestoneKey: 'irrigation',
      photoUri: photo,
      inputUsed: 'Water',
      amountApplied: '200 L',
      notes: '',
      location: cusco,
    );

void main() {
  test('evidence recorded without signal waits on the phone as queued', () async {
    final backend = FieldBackend()..online = false;
    final container = await farmerContainer(backend);

    final result = await recordIrrigation(container);

    expect(result.queued, isTrue);
    expect(result.plot.milestone('irrigation')?.isQueued, isTrue);
    final state = container.read(evidenceQueueProvider);
    expect(state.queue.single.milestoneKey, 'irrigation');
    expect(state.queue.single.hasLocation, isTrue);
    expect(state.offline, isTrue);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getKeys().any((key) => key.contains('evidence_queue')), isTrue);
  });

  test('syncing sends the queued evidence and records it in the history', () async {
    final backend = FieldBackend()..online = false;
    final container = await farmerContainer(backend);
    await recordIrrigation(container);
    backend.online = true;

    final sent = await container.read(evidenceQueueProvider.notifier).syncAll();

    expect(sent, 1);
    final irrigation = (backend.saved.single['milestoneStates'] as List)
        .cast<Map<String, dynamic>>()
        .firstWhere((m) => m['key'] == 'irrigation');
    expect(irrigation['status'], 'submitted');
    expect(irrigation['photoUri'], photo);
    expect(irrigation['latitude'], -13.531);
    final state = container.read(evidenceQueueProvider);
    expect(state.queue, isEmpty);
    expect(state.history.single.plotName, 'Esperanza');
    expect(state.offline, isFalse);
  });

  test('syncing without signal keeps the evidence queued', () async {
    final backend = FieldBackend()..online = false;
    final container = await farmerContainer(backend);
    await recordIrrigation(container);

    final sent = await container.read(evidenceQueueProvider.notifier).syncAll();

    expect(sent, 0);
    expect(container.read(evidenceQueueProvider).queue, hasLength(1));
    expect(container.read(evidenceQueueProvider).offline, isTrue);
  });

  testWidgets('the sync tab starts empty and lists what waits for signal', (tester) async {
    final backend = FieldBackend()..online = false;
    final container = (await tester.runAsync(() => farmerContainer(backend)))!;

    Widget app() => UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: buildMuyuTheme(),
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(body: SyncView()),
      ),
    );

    await tester.pumpWidget(app());
    await tester.pump();
    expect(find.text('Todo está al día'), findsOneWidget);
    expect(find.text('Evidencias sincronizadas (0)'), findsOneWidget);

    await tester.runAsync(() => recordIrrigation(container));
    await tester.pump();
    expect(find.text('1 evidencia(s) sin enviar'), findsOneWidget);
    expect(find.text('Ubicación GPS registrada'), findsOneWidget);

    backend.online = true;
    await tester.tap(find.text('Sincronizar ahora'));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
    await tester.pump();
    expect(find.text('Todo está al día'), findsOneWidget);
    expect(find.text('Evidencias sincronizadas (1)'), findsOneWidget);
  });
}
