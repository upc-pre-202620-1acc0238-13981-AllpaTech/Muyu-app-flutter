import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:muyu_app/core/network/api_client.dart';
import 'package:muyu_app/core/storage/user_preferences.dart';
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
  test('card payment funds the plot and persists the escrow state', () async {
    http.Request? update;
    final container = await containerWith((request) async {
      if (request.method == 'PUT') {
        update = request;
        return http.Response('', 204);
      }
      return http.Response(jsonEncode([plotJson()]), 200);
    });
    await container.read(merchantFinancingProvider.future);

    final result = await container
        .read(merchantFinancingProvider.notifier)
        .fundPlot(8, PaymentMethod.card);

    expect(result.pendingVerification, isFalse);
    expect(update!.url.path, '/mobile/plots/8');
    expect(update!.headers['Authorization'], 'Bearer jwt');
    final body = jsonDecode(update!.body) as Map<String, dynamic>;
    expect(body['status'], 'funded');
    expect(body['stage'], 'Funds in Escrow');
    expect(body['paymentStatus'], 'held_in_escrow');
    expect(body['fundedByEmail'], merchantEmail);
    expect(body['paymentReference'], startsWith('MUYU-8-'));
  });

  test('bank transfer is persisted as payment under verification', () async {
    http.Request? update;
    final container = await containerWith((request) async {
      if (request.method == 'PUT') {
        update = request;
        return http.Response('', 204);
      }
      return http.Response(jsonEncode([plotJson()]), 200);
    });
    await container.read(merchantFinancingProvider.future);

    final result = await container
        .read(merchantFinancingProvider.notifier)
        .fundPlot(8, PaymentMethod.bankTransfer);

    expect(result.pendingVerification, isTrue);
    final body = jsonDecode(update!.body) as Map<String, dynamic>;
    expect(body['status'], 'payment_verification');
    expect(body['stage'], 'Payment verification');
    expect(body['paymentStatus'], 'pending_verification');
  });
}
