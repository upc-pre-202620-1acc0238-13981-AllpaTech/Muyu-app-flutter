import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../user_management/application/session_controller.dart';
import '../domain/plot.dart';
import '../domain/plot_repository.dart';
import '../infrastructure/catalog_plot_repository.dart';
import '../infrastructure/repositories/backend_farmer_plot_repository.dart';

class GetPlotsUseCase {
  const GetPlotsUseCase({required this.repository});

  final PlotRepository repository;

  Future<List<Plot>> execute() => repository.getPlots();
}

final plotRepositoryProvider = Provider<PlotRepository>((ref) {
  final token = ref.watch(sessionProvider.select((session) => session.user?.token)) ?? '';
  return CatalogPlotRepository(ref.watch(farmerPlotRepositoryProvider), token);
});

final getPlotsUseCaseProvider = Provider<GetPlotsUseCase>(
  (ref) => GetPlotsUseCase(repository: ref.watch(plotRepositoryProvider)),
);
