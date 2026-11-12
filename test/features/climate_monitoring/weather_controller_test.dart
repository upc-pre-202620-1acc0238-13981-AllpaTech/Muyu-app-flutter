import 'package:flutter_test/flutter_test.dart';
import 'package:muyu_app/features/climate_monitoring/application/weather_controller.dart';
import 'package:muyu_app/features/climate_monitoring/domain/weather_alert.dart';
import 'package:muyu_app/features/plot_approval/domain/farmer_plot.dart';

void main() {
  test('weather alert keys separate plot date and risk', () {
    const plot = FarmerPlot(
      id: 12,
      name: 'La Esperanza',
      crop: 'Café',
      area: '1 ha',
      harvestDate: '',
      place: 'Junín',
      stage: '',
      progress: 0,
      status: 'funded',
      amount: '1000',
      cycle: '2026',
      milestones: '4',
      ownerEmail: 'a@b.com',
      ownerName: 'Ana',
      publishedAt: '',
    );
    const alert = WeatherAlert(
      temperature: 2,
      minimumTemperature: -1,
      maximumTemperature: 8,
      rainProbability: 10,
      risk: WeatherRisk.high,
      measures: [WeatherMeasureKind.cover],
    );

    expect(
      weatherAlertKey(plot, alert, DateTime(2026, 11, 9)),
      '12_2026-11-09_high',
    );
  });
}
