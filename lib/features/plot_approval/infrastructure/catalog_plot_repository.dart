import '../domain/farmer_plot.dart';
import '../domain/farmer_plot_repository.dart';
import '../domain/plot.dart';
import '../domain/plot_repository.dart';

/// Merchant catalog, filled from `GET mobile/plots` like [BackendFarmerPlotRepository].
class CatalogPlotRepository implements PlotRepository {
  const CatalogPlotRepository(this._repository, this._token);

  final FarmerPlotRepository _repository;
  final String _token;

  @override
  Future<List<Plot>> getPlots() async {
    if (_token.isEmpty) return const [];
    final plots = await _repository.getAll(_token);
    return plots.map(_toPlot).toList();
  }

  Plot _toPlot(FarmerPlot plot) => Plot(
    id: plot.id,
    name: plot.name,
    crop: plot.crop,
    area: plot.area,
    place: plot.place,
    amount: plot.amount,
    status: plot.status,
    ownerName: plot.ownerName,
    ownerEmail: plot.ownerEmail,
    harvestDate: plot.harvestDate,
    stage: plot.stage,
    progress: plot.progress,
    cycle: plot.cycle,
    milestones: plot.milestones,
    imageUri: plot.imageUri,
    latitude: plot.latitude,
    longitude: plot.longitude,
  );
}
