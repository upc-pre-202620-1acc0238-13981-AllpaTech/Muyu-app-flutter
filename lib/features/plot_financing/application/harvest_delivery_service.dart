import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../plot_approval/domain/farmer_plot.dart';
import '../../plot_approval/domain/farmer_plot_repository.dart';
import '../../plot_approval/domain/harvest_delivery.dart';
import '../../plot_approval/infrastructure/repositories/backend_farmer_plot_repository.dart';
import '../../user_management/application/session_controller.dart';
import '../../user_management/domain/user.dart';
import 'merchant_financing_controller.dart';

/// Kotlin `PlotFinance.timestampNow`: `12 Nov 2026, 14:05`.
String harvestTimestamp(DateTime moment) => DateFormat('d MMM yyyy, HH:mm', 'en_US').format(moment);

/// The merchant closes the agreement by confirming the harvest, or reports a
/// delivery problem, writing the fields Kotlin `BackendStateStore` writes.
class HarvestDeliveryService {
  HarvestDeliveryService(this._ref);
  final Ref _ref;

  Future<FarmerPlot> confirmReceipt(FarmerPlot plot) async {
    if (plot.harvestReceivedAt.isNotEmpty) return plot;
    final user = _user();
    return _save(plot.harvestReceived(by: user.email, at: harvestTimestamp(DateTime.now())));
  }

  Future<FarmerPlot> reportIncident(
    FarmerPlot plot, {
    required String reason,
    required String details,
  }) async {
    if (plot.harvestReceivedAt.isNotEmpty) return plot;
    final user = _user();
    final now = DateTime.now();
    return _save(
      plot.withHarvestIncident(
        HarvestIncident(
          reason: reason,
          details: details.trim(),
          reportedAt: harvestTimestamp(now),
          reportedAtMillis: now.millisecondsSinceEpoch,
          reportedBy: user.email,
        ),
      ),
    );
  }

  User _user() {
    final user = _ref.read(sessionProvider).user;
    if (user == null) throw const PlotException(PlotFailure.sessionExpired);
    return user;
  }

  Future<FarmerPlot> _save(FarmerPlot next) async {
    final user = _ref.read(sessionProvider).user!;
    try {
      await _ref.read(farmerPlotRepositoryProvider).save(user.token, next);
    } on PlotException catch (error) {
      if (error.failure == PlotFailure.sessionExpired) {
        await _ref.read(sessionProvider.notifier).logout();
      }
      rethrow;
    }
    await _ref.read(merchantFinancingProvider.notifier).refresh();
    return next;
  }
}

final harvestDeliveryServiceProvider = Provider<HarvestDeliveryService>(HarvestDeliveryService.new);
