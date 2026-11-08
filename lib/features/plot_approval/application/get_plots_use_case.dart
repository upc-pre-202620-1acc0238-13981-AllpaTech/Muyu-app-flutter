import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/plot.dart';
import '../domain/plot_repository.dart';
import '../infrastructure/catalog_plot_repository.dart';

class GetPlotsUseCase {
  const GetPlotsUseCase({required this.repository});

  final PlotRepository repository;

  Future<List<Plot>> execute() => repository.getPlots();
}

final getPlotsUseCaseProvider = Provider<GetPlotsUseCase>(
  (ref) => GetPlotsUseCase(repository: ref.watch(plotRepositoryProvider)),
);
