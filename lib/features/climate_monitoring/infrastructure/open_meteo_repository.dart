import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../plot_approval/domain/farmer_plot.dart';
import '../domain/weather_alert.dart';

class WeatherException implements Exception {
  const WeatherException();
}

class OpenMeteoRepository {
  OpenMeteoRepository({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<WeatherAlert> alertFor(FarmerPlot plot) async {
    try {
      final coordinates = await _coordinates(plot);
      final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
        'latitude': '${coordinates.$1}',
        'longitude': '${coordinates.$2}',
        'current': 'temperature_2m',
        'daily': 'temperature_2m_max,temperature_2m_min,precipitation_probability_max',
        'timezone': 'auto',
        'forecast_days': '5',
      });
      final response = await _client.get(uri).timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) throw const WeatherException();
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final daily = json['daily'] as Map<String, dynamic>? ?? const {};
      final current = json['current'] as Map<String, dynamic>? ?? const {};
      final minimum = _firstNumber(daily['temperature_2m_min']);
      final maximum = _firstNumber(daily['temperature_2m_max']);
      final rain = _firstNumber(daily['precipitation_probability_max']).round();
      final risk = minimum <= 0 || rain >= 70
          ? WeatherRisk.high
          : minimum <= 3 || rain >= 45
          ? WeatherRisk.medium
          : WeatherRisk.low;
      return WeatherAlert(
        temperature: (current['temperature_2m'] as num?)?.toDouble() ?? maximum,
        minimumTemperature: minimum,
        maximumTemperature: maximum,
        rainProbability: rain,
        risk: risk,
        measures: rain >= 45
            ? const [
                WeatherMeasureKind.drainage,
                WeatherMeasureKind.cover,
                WeatherMeasureKind.monitor,
              ]
            : minimum <= 3
            ? const [
                WeatherMeasureKind.cover,
                WeatherMeasureKind.irrigation,
                WeatherMeasureKind.monitor,
              ]
            : const [WeatherMeasureKind.monitor, WeatherMeasureKind.irrigation],
      );
    } on WeatherException {
      rethrow;
    } on Exception {
      throw const WeatherException();
    }
  }

  Future<(double, double)> _coordinates(FarmerPlot plot) async {
    if (plot.latitude != null && plot.longitude != null) {
      return (plot.latitude!, plot.longitude!);
    }
    if (plot.place.trim().isEmpty) throw const WeatherException();
    final uri = Uri.https('geocoding-api.open-meteo.com', '/v1/search', {
      'name': plot.place,
      'count': '1',
      'language': 'es',
      'format': 'json',
    });
    final response = await _client.get(uri).timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) throw const WeatherException();
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final results = json['results'] as List<dynamic>? ?? const [];
    if (results.isEmpty) throw const WeatherException();
    final first = results.first as Map<String, dynamic>;
    return ((first['latitude'] as num).toDouble(), (first['longitude'] as num).toDouble());
  }

  double _firstNumber(Object? value) {
    final list = value as List<dynamic>? ?? const [];
    return (list.isEmpty ? null : list.first as num?)?.toDouble() ?? 0;
  }
}

final weatherRepositoryProvider = Provider<OpenMeteoRepository>((ref) => OpenMeteoRepository());
