import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:muyu_app/core/network/api_client.dart';
import 'package:muyu_app/core/storage/user_preferences.dart';
import 'package:muyu_app/features/plot_approval/domain/farmer_plot.dart';
import 'package:muyu_app/features/plot_financing/application/merchant_financing_controller.dart';
import 'package:muyu_app/features/plot_financing/domain/payment_method.dart';
import 'package:muyu_app/features/user_management/application/session_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

const merchantEmail = 'merchant@muyu.pe';

Map<String, dynamic> plotJson() => {
  'id': 8,
  'name': 'Esperanza',
  'crop': 'Papa',
  'area': '3.5 ha',
  'harvestDate': '15 Feb 2027',
  'place': 'Cusco',
  'stage': 'Published',
  'progress': 0,
  'status': 'available',
  'amount': 'S/ 8 500',
  'cycle': '6 months',
  'milestones': '4',
  'ownerEmail': 'farmer@muyu.pe',
  'ownerName': 'Miguel Quispe',
  'publishedAt': '2026-11-09T10:00:00Z',
};

Future<ProviderContainer> containerWith(
  Future<http.Response> Function(http.Request) handler,
) async {
  SharedPreferences.setMockInitialValues({
    'session': jsonEncode({
      'email': merchantEmail,
      'firstName': 'Valeria',
      'lastName': 'Mendoza',
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
  await Future<void>.delayed(const Duration(milliseconds: 800));
  return container;
}

void main() {
  Future<Map<String, dynamic>> fundWith(PaymentMethod method) async {
    http.Request? update;
    final container = await containerWith((request) async {
      if (request.method == 'PUT') {
        update = request;
        return http.Response('', 204);
      }
      return http.Response(jsonEncode([plotJson()]), 200);
    });
    await container.read(merchantFinancingProvider.future);

    final result = await container.read(merchantFinancingProvider.notifier).fundPlot(8, method);

    expect(result.paymentMethod, method);
    expect(update!.url.path, '/mobile/plots/8');
    expect(update!.headers['Authorization'], 'Bearer jwt');
    return jsonDecode(update!.body) as Map<String, dynamic>;
  }

  test('card payment funds the plot the way Kotlin does', () async {
    final body = await fundWith(PaymentMethod.card);

    expect(body['status'], 'funded');
    expect(body['stage'], 'Planting');
    expect(body['progress'], 10);
    expect(body['fundedByEmail'], merchantEmail);
    final milestones = (body['milestoneStates'] as List).cast<Map<String, dynamic>>();
    expect(milestones.map((m) => m['key']), ['planting', 'irrigation', 'fertilization', 'harvest']);
    expect(milestones.every((m) => m['status'] == 'pending' && m['photoUri'] == ''), isTrue);
  });

  test('a bank transfer also funds the plot right away, as in Kotlin', () async {
    final body = await fundWith(PaymentMethod.bankTransfer);

    expect(body['status'], 'funded');
    expect(body.containsKey('paymentStatus'), isFalse);
  });

  test('saving a plot keeps the evidence Kotlin recorded on a milestone', () {
    final plot = FarmerPlot.fromJson({
      ...plotJson(),
      'status': 'funded',
      'milestoneStates': [
        {
          'key': 'planting',
          'status': 'submitted',
          'photoUri': 'content://evidence/1.jpg',
          'inputUsed': 'Seed',
          'latitude': -13.5,
          'longitude': -71.9,
          'submittedAtMillis': 1762700000000,
        },
      ],
    });

    final milestone = (plot.toJson()['milestoneStates'] as List).single as Map<String, dynamic>;

    expect(milestone['photoUri'], 'content://evidence/1.jpg');
    expect(milestone['inputUsed'], 'Seed');
    expect(milestone['latitude'], -13.5);
    expect(milestone['submittedAtMillis'], 1762700000000);
    expect(milestone['status'], 'submitted');
  });
}
