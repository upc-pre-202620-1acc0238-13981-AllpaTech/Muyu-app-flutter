import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../plot_approval/application/farmer_plots_controller.dart';
import '../../plot_approval/domain/farmer_plot.dart';
import '../../plot_approval/domain/plot_activity.dart';
import '../../plot_approval/infrastructure/repositories/backend_farmer_plot_repository.dart';
import '../../user_management/application/session_controller.dart';
import '../domain/weather_alert.dart';
import '../infrastructure/open_meteo_repository.dart';

final weatherAlertProvider = FutureProvider.family<WeatherAlert, FarmerPlot>(
  (ref, plot) => ref.watch(weatherRepositoryProvider).alertFor(plot),
  retry: (retryCount, error) => null,
);

String weatherAlertKey(FarmerPlot plot, WeatherAlert alert, DateTime now) =>
    '${plot.id}_${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}_${alert.risk.name}';

WeatherMeasure? recordedMeasures(FarmerPlot plot, String alertKey) {
  for (final item in plot.weatherMeasures) {
    if (item.alertKey == alertKey) return item;
  }
  return null;
}

class WeatherMeasuresController {
  const WeatherMeasuresController(this.ref);

  final Ref ref;

  Future<WeatherMeasure> save({
    required FarmerPlot plot,
    required WeatherAlert alert,
    required Set<WeatherMeasureKind> selected,
  }) async {
    final user = ref.read(sessionProvider).user;
    if (user == null || selected.isEmpty) throw const WeatherException();
    final now = DateTime.now();
    final key = weatherAlertKey(plot, alert, now);
    final measure = WeatherMeasure(
      alertKey: key,
      measures: selected.map((item) => item.name).toList(),
      attendedAt: now.toIso8601String(),
    );
    final retained = plot.weatherMeasures.where((item) => item.alertKey != key).toList();
    await ref
        .read(farmerPlotRepositoryProvider)
        .save(user.token, plot.copyWith(weatherMeasures: [...retained, measure]));
    ref.invalidate(farmerPlotsProvider);
    return measure;
  }
}

final weatherMeasuresControllerProvider = Provider<WeatherMeasuresController>(
  WeatherMeasuresController.new,
);
