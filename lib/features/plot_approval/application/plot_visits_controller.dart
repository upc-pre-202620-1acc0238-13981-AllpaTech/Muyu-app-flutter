import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/network/api_client.dart';
import '../../user_management/application/session_controller.dart';
import '../../user_management/domain/user.dart';
import '../domain/farmer_plot_repository.dart';
import '../domain/plot.dart';
import '../domain/plot_visit.dart';

/// Visits the signed-in user takes part in, read from `mobile/visits`.
class PlotVisitsController extends AsyncNotifier<List<PlotVisit>> {
  @override
  Future<List<PlotVisit>> build() async {
    final user = ref.watch(sessionProvider.select((session) => session.user));
    if (user == null || user.token.isEmpty) return const [];
    final raw = await _guard(
      () => ref.read(apiClientProvider).getList('mobile/visits', token: user.token),
    );
    final visits =
        raw
            .whereType<Map<String, dynamic>>()
            .map(PlotVisit.fromJson)
            .where((visit) => visit.involves(user.email))
            .toList()
          ..sort((a, b) => b.id.compareTo(a.id));
    return visits;
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  /// The merchant asks to visit [plot] on [date] at [time].
  Future<PlotVisit> request({
    required Plot plot,
    required DateTime date,
    required String time,
    required String message,
  }) async {
    final user = _user();
    final visit = PlotVisit(
      // Unique without reading every visit: seconds since 2020 fit the backend int.
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000 - 1577836800,
      plotId: plot.id,
      plotName: plot.name,
      plotPlace: plot.place,
      farmerEmail: plot.ownerEmail,
      farmerName: plot.ownerName,
      merchantEmail: user.email,
      merchantName: user.displayName.isEmpty ? user.email : user.displayName,
      date: DateFormat('dd/MM/yyyy').format(date),
      time: time,
      message: message.trim(),
      status: PlotVisit.statusRequested,
    );
    await _save(visit);
    return visit;
  }

  /// The farmer accepts or declines a request.
  Future<PlotVisit> answer(PlotVisit visit, {required bool accepted}) => _save(
    visit.copyWith(status: accepted ? PlotVisit.statusConfirmed : PlotVisit.statusRejected),
  );

  /// The farmer records whether the visit ended in an agreement.
  Future<PlotVisit> recordOutcome(
    PlotVisit visit, {
    required bool agreement,
    String agreedPrice = '',
  }) => _save(
    visit.copyWith(
      status: PlotVisit.statusCompleted,
      outcome: agreement ? PlotVisit.outcomeAgreement : PlotVisit.outcomeNoAgreement,
      agreedPrice: agreement ? agreedPrice.trim() : '',
    ),
  );

  Future<PlotVisit> _save(PlotVisit visit) async {
    final user = _user();
    await _guard(
      () => ref
          .read(apiClientProvider)
          .putJson('mobile/visits/${visit.id}', visit.toJson(), token: user.token),
    );
    final current = state.value ?? const <PlotVisit>[];
    final exists = current.any((item) => item.id == visit.id);
    state = AsyncData(
      exists
          ? [for (final item in current) item.id == visit.id ? visit : item]
          : [visit, ...current],
    );
    return visit;
  }

  User _user() {
    final user = ref.read(sessionProvider).user;
    if (user == null) throw const PlotException(PlotFailure.sessionExpired);
    return user;
  }

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on ApiException catch (error) {
      if (error.statusCode == 401) {
        await ref.read(sessionProvider.notifier).logout();
        throw const PlotException(PlotFailure.sessionExpired);
      }
      throw const PlotException(PlotFailure.rejected);
    } on NetworkException {
      throw const PlotException(PlotFailure.network);
    }
  }
}

final plotVisitsProvider = AsyncNotifierProvider<PlotVisitsController, List<PlotVisit>>(
  PlotVisitsController.new,
  retry: (retryCount, error) => null,
);
