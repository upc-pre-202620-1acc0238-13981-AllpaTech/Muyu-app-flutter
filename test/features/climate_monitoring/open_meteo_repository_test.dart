import 'package:flutter_test/flutter_test.dart';
import 'package:muyu_app/features/climate_monitoring/domain/weather_alert.dart';
import 'package:muyu_app/features/climate_monitoring/infrastructure/open_meteo_repository.dart';

void main() {
  test('parses current temperature, risk and a 5-day forecast', () {
    final alert = weatherAlertFromOpenMeteo({
      'elevation': 3400,
      'current': {'temperature_2m': 12.4, 'weather_code': 1},
      'daily': {
        'time': ['2026-11-12', '2026-11-13', '2026-11-14', '2026-11-15', '2026-11-16'],
        'temperature_2m_max': [18, 17, 16, 15, 14],
        'temperature_2m_min': [6, 5, 4, 3, 2],
        'precipitation_probability_max': [20, 40, 55, 10, 5],
        'weather_code': [1, 2, 61, 0, 3],
      },
    });

    expect(alert.temperature, 12.4);
    expect(alert.elevationMeters, 3400);
    expect(alert.forecast, hasLength(5));
    expect(alert.forecast.first.maximumTemperature, 18);
    expect(alert.risk, WeatherRisk.low);
  });

  test('marks frost from tonight hourly minimum', () {
    final now = DateTime.now().add(const Duration(hours: 2));
    final iso =
        '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}T${now.hour.toString().padLeft(2, '0')}:00';
    final alert = weatherAlertFromOpenMeteo({
      'current': {'temperature_2m': 4},
      'daily': {
        'time': ['2026-11-12'],
        'temperature_2m_max': [10],
        'temperature_2m_min': [4],
        'precipitation_probability_max': [10],
        'weather_code': [0],
      },
      'hourly': {
        'time': [iso],
        'temperature_2m': [-1.2],
      },
    });

    expect(alert.risk, WeatherRisk.high);
    expect(alert.timing, WeatherTiming.tonight);
    expect(alert.isFrost, isTrue);
  });
}
