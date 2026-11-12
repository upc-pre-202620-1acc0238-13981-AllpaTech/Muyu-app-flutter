import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../plot_approval/domain/farmer_plot.dart';
import '../../plot_approval/domain/farmer_plot_repository.dart';
import '../../plot_approval/infrastructure/repositories/backend_farmer_plot_repository.dart';
import '../../user_management/application/session_controller.dart';
import '../domain/payment_method.dart';

class MerchantFinancingController extends AsyncNotifier<List<FarmerPlot>> {
  @override
  Future<List<FarmerPlot>> build() => _load();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<FinancingResult> fundPlot(int plotId, PaymentMethod method) async {
    final user = ref.read(sessionProvider).user;
    if (user == null) throw const PlotException(PlotFailure.sessionExpired);

    final current = state.value ?? await _load();
    final matches = current.where((item) => item.id == plotId);
    if (matches.isEmpty || matches.first.status != FarmerPlot.statusAvailable) {
      throw const PlotException(PlotFailure.rejected);
    }

    final updated = matches.first.fundedBy(user.email);

    try {
      await ref.read(farmerPlotRepositoryProvider).save(user.token, updated);
      state = AsyncData([
        for (final item in current)
          if (item.id == updated.id) updated else item,
      ]);
      return FinancingResult(paymentMethod: method);
    } on PlotException catch (error) {
      if (error.failure == PlotFailure.sessionExpired) {
        await ref.read(sessionProvider.notifier).logout();
      }
      rethrow;
    }
  }

  Future<List<FarmerPlot>> _load() async {
    final user = ref.read(sessionProvider).user;
    if (user == null) return const [];
    try {
      return await ref.read(farmerPlotRepositoryProvider).getAll(user.token);
    } on PlotException catch (error) {
      if (error.failure == PlotFailure.sessionExpired) {
        await ref.read(sessionProvider.notifier).logout();
      }
      rethrow;
    }
  }
}

final merchantFinancingProvider =
    AsyncNotifierProvider<MerchantFinancingController, List<FarmerPlot>>(
      MerchantFinancingController.new,
    );
