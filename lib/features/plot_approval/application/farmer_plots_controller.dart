import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../user_management/application/session_controller.dart';
import '../../user_management/domain/user.dart';
import '../domain/farmer_plot.dart';
import '../domain/farmer_plot_repository.dart';
import '../infrastructure/repositories/backend_farmer_plot_repository.dart';

/// The signed-in farmer's plots, loaded from the backend.
class FarmerPlotsController extends AsyncNotifier<List<FarmerPlot>> {
  @override
  Future<List<FarmerPlot>> build() async {
    final user = ref.watch(sessionProvider.select((session) => session.user));
    if (user == null) return const [];
    return _ownPlots(user);
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  /// Throws [PlotException] when the plot cannot be saved.
  Future<void> publish(NewFarmerPlot plot) async {
    final user = ref.read(sessionProvider).user;
    if (user == null) throw const PlotException(PlotFailure.sessionExpired);

    try {
      final repository = ref.read(farmerPlotRepositoryProvider);
      // Ids are shared by all farmers, so the next one comes from a fresh list.
      final all = await repository.getAll(user.token);
      final nextId = all.fold<int>(0, (max, p) => p.id > max ? p.id : max) + 1;
      await repository.save(
        user.token,
        FarmerPlot(
          id: nextId,
          name: plot.name,
          crop: plot.crop,
          area: plot.area,
          harvestDate: plot.harvestDate,
          place: plot.place,
          stage: FarmerPlot.stagePublished,
          progress: 0,
          status: FarmerPlot.statusAvailable,
          amount: plot.amount,
          cycle: plot.cycle,
          milestones: FarmerPlot.fixedMilestones,
          ownerEmail: user.email,
          ownerName: user.displayName,
          publishedAt: DateTime.now().millisecondsSinceEpoch.toString(),
        ),
      );
    } on PlotException catch (e) {
      _endSessionIfExpired(e);
      rethrow;
    }
    ref.invalidateSelf();
  }

  Future<List<FarmerPlot>> _ownPlots(User user) async {
    try {
      final plots = await ref.read(farmerPlotRepositoryProvider).getAll(user.token);
      return plots.where((plot) => plot.isOwnedBy(user.email)).toList()
        ..sort((a, b) => b.id.compareTo(a.id));
    } on PlotException catch (e) {
      _endSessionIfExpired(e);
      rethrow;
    }
  }

  void _endSessionIfExpired(PlotException e) {
    if (e.failure == PlotFailure.sessionExpired) ref.read(sessionProvider.notifier).logout();
  }
}

final farmerPlotsProvider = AsyncNotifierProvider<FarmerPlotsController, List<FarmerPlot>>(
  FarmerPlotsController.new,
  // The screen offers its own retry button.
  retry: (retryCount, error) => null,
);
