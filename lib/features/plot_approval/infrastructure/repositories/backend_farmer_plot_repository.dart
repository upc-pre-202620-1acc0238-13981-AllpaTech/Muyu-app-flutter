import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../domain/farmer_plot.dart';
import '../../domain/farmer_plot_repository.dart';
import '../remote/mobile_plot_service.dart';

class BackendFarmerPlotRepository implements FarmerPlotRepository {
  const BackendFarmerPlotRepository(this._service);

  final MobilePlotService _service;

  @override
  Future<List<FarmerPlot>> getAll(String token) => _guard(() async {
    final plots = await _service.getPlots(token);
    return plots.cast<Map<String, dynamic>>().map(FarmerPlot.fromJson).toList();
  });

  @override
  Future<void> save(String token, FarmerPlot plot) =>
      _guard(() => _service.putPlot(token, plot.id, plot.toJson()));

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on ApiException catch (e) {
      throw PlotException(e.statusCode == 401 ? PlotFailure.sessionExpired : PlotFailure.rejected);
    } on NetworkException {
      throw const PlotException(PlotFailure.network);
    }
  }
}

final farmerPlotRepositoryProvider = Provider<FarmerPlotRepository>(
  (ref) => BackendFarmerPlotRepository(MobilePlotService(ref.watch(apiClientProvider))),
);
