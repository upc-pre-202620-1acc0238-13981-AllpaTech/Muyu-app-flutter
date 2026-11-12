import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../presentation/rating/rate_buyer_screen.dart';
import 'session_controller.dart';

/// An incident the user reported, as `mobile/incidents` returns it.
class IncidentReport {
  const IncidentReport({
    required this.id,
    required this.type,
    required this.description,
    required this.createdAt,
  });

  final int id;

  /// `technical`, `payment`, `plot` or `other`, the types the backend accepts.
  final String type;
  final String description;
  final DateTime? createdAt;

  factory IncidentReport.fromJson(Map<String, dynamic> json) => IncidentReport(
    id: (json['id'] as num?)?.toInt() ?? 0,
    type: json['type'] as String? ?? 'other',
    description: json['description'] as String? ?? '',
    createdAt: DateTime.tryParse(json['createdAtUtc'] as String? ?? '')?.toLocal(),
  );
}

enum SupportFailure { network, rejected, sessionExpired }

class SupportException implements Exception {
  const SupportException(this.failure);
  final SupportFailure failure;
}

/// Sends incident reports and reads the farmer's finished contracts from the
/// backend routes `mobile/incidents` and `mobile/contracts/finished`.
class SupportService {
  SupportService(this._ref);
  final Ref _ref;

  Future<IncidentReport> reportIncident({required String type, required String description}) =>
      _guard(() async {
        final json = await _ref.read(apiClientProvider).postJson('mobile/incidents', {
          'type': type,
          'description': description.trim(),
        }, token: _token());
        _ref.invalidate(myIncidentsProvider);
        return IncidentReport.fromJson(json);
      });

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on ApiException catch (error) {
      if (error.statusCode == 401) {
        await _ref.read(sessionProvider.notifier).logout();
        throw const SupportException(SupportFailure.sessionExpired);
      }
      throw const SupportException(SupportFailure.rejected);
    } on NetworkException {
      throw const SupportException(SupportFailure.network);
    }
  }

  String _token() {
    final user = _ref.read(sessionProvider).user;
    if (user == null) throw const SupportException(SupportFailure.sessionExpired);
    return user.token;
  }
}

final supportServiceProvider = Provider<SupportService>(SupportService.new);

/// The incidents the signed-in user already reported, newest first.
final myIncidentsProvider = FutureProvider<List<IncidentReport>>((ref) async {
  final user = ref.watch(sessionProvider.select((session) => session.user));
  if (user == null || user.token.isEmpty) return const [];
  final raw = await ref.read(apiClientProvider).getList('mobile/incidents', token: user.token);
  return raw.whereType<Map<String, dynamic>>().map(IncidentReport.fromJson).toList();
}, retry: (retryCount, error) => null);

/// Contracts whose harvest the merchant already received, the ones the farmer can rate.
final finishedContractsProvider = FutureProvider<List<RatingContract>>((ref) async {
  final user = ref.watch(sessionProvider.select((session) => session.user));
  if (user == null || user.token.isEmpty) return const [];
  final raw = await ref
      .read(apiClientProvider)
      .getList('mobile/contracts/finished', token: user.token);
  return raw.whereType<Map<String, dynamic>>().map((json) {
    final buyerEmail = json['buyerEmail'] as String? ?? '';
    final buyerName = json['buyerName'] as String? ?? '';
    return RatingContract(
      plotName: json['plotName'] as String? ?? '',
      buyerName: buyerName.isEmpty ? buyerEmail : buyerName,
      companyName: buyerEmail,
      endedOn: json['endedOn'] as String? ?? '',
    );
  }).toList();
}, retry: (retryCount, error) => null);
