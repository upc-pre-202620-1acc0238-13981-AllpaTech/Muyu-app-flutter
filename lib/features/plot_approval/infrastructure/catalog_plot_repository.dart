import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/plot.dart';
import '../domain/plot_repository.dart';

/// Local catalog. New users start with no plots until a farmer publishes one.
class CatalogPlotRepository implements PlotRepository {
  const CatalogPlotRepository();

  @override
  Future<List<Plot>> getPlots() async => const [];
}

final plotRepositoryProvider = Provider<PlotRepository>((ref) => const CatalogPlotRepository());
