import 'farmer_plot.dart';

/// Why a plot could not be loaded or saved.
enum PlotFailure { sessionExpired, rejected, network }

class PlotException implements Exception {
  const PlotException(this.failure);

  final PlotFailure failure;

  @override
  String toString() => 'PlotException($failure)';
}

abstract interface class FarmerPlotRepository {
  /// Every plot on the backend, from all farmers. Throws [PlotException].
  Future<List<FarmerPlot>> getAll(String token);

  /// Creates or replaces a plot. Throws [PlotException].
  Future<void> save(String token, FarmerPlot plot);
}
