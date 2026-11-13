import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../../plot_approval/domain/farmer_plot.dart';
import '../domain/weather_alert.dart';

class WeatherException implements Exception {
  const WeatherException();
}

typedef WeatherCoordinates = (double, double);

Future<WeatherCoordinates?> deviceWeatherCoordinates() async {
  try {
    if (!await Geolocator.isLocationServiceEnabled()) return null;
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      return null;
    }
    final last = await Geolocator.getLastKnownPosition();
    if (last != null) return (last.latitude, last.longitude);
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 8),
      ),
    );
    return (position.latitude, position.longitude);
  } on Exception {
    return null;
  }
}

final weatherLocatorProvider = Provider<Future<WeatherCoordinates?> Function()>(
  (ref) => deviceWeatherCoordinates,
);

class OpenMeteoRepository {
  OpenMeteoRepository({http.Client? client, Future<WeatherCoordinates?> Function()? deviceLocation})
    : _client = client ?? http.Client(),
      _deviceLocation = deviceLocation;

  final http.Client _client;
  final Future<WeatherCoordinates?> Function()? _deviceLocation;

  Future<WeatherAlert> alertFor(FarmerPlot plot) async {
    try {
      final coordinates = await _coordinates(plot);
      final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
        'latitude': '${coordinates.$1}',
        'longitude': '${coordinates.$2}',
        'current': 'temperature_2m,weather_code',
        'daily': 'weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max',
        'hourly': 'temperature_2m,precipitation_probability',
        'timezone': 'auto',
        'forecast_days': '5',
      });
      final response = await _client.get(uri).timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) throw const WeatherException();
      return weatherAlertFromOpenMeteo(jsonDecode(response.body) as Map<String, dynamic>);
    } on WeatherException {
      rethrow;
    } on Exception {
      throw const WeatherException();
    }
  }

  Future<WeatherCoordinates> _coordinates(FarmerPlot plot) async {
    final gps = await _deviceLocation?.call();
    if (gps != null) return gps;
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
}

WeatherAlert weatherAlertFromOpenMeteo(Map<String, dynamic> json) {
  final daily = json['daily'] as Map<String, dynamic>? ?? const {};
  final current = json['current'] as Map<String, dynamic>? ?? const {};
  final hourly = json['hourly'] as Map<String, dynamic>? ?? const {};
  final forecast = _forecastDays(daily);
  final tonightMin = _tonightMinimum(hourly) ?? _firstNumber(daily['temperature_2m_min']);
  final rain = _firstNumber(daily['precipitation_probability_max']).round();
  final maximum = _firstNumber(daily['temperature_2m_max']);
  final minimum = _firstNumber(daily['temperature_2m_min']);
  final code =
      (current['weather_code'] as num?)?.toInt() ??
      (forecast.isEmpty ? 0 : forecast.first.weatherCode);
  final risk = tonightMin <= 0 || rain >= 70
      ? WeatherRisk.high
      : tonightMin <= 3 || rain >= 45
      ? WeatherRisk.medium
      : WeatherRisk.low;
  final timing = tonightMin <= 3 ? WeatherTiming.tonight : WeatherTiming.today;
  return WeatherAlert(
    temperature: (current['temperature_2m'] as num?)?.toDouble() ?? maximum,
    minimumTemperature: tonightMin <= 3 ? tonightMin : minimum,
    maximumTemperature: maximum,
    rainProbability: rain,
    risk: risk,
    weatherCode: code,
    elevationMeters: (json['elevation'] as num?)?.toDouble(),
    timing: timing,
    forecast: forecast,
    measures: rain >= 45
        ? const [WeatherMeasureKind.drainage, WeatherMeasureKind.cover, WeatherMeasureKind.monitor]
        : tonightMin <= 3
        ? const [
            WeatherMeasureKind.cover,
            WeatherMeasureKind.irrigation,
            WeatherMeasureKind.monitor,
          ]
        : const [WeatherMeasureKind.monitor, WeatherMeasureKind.irrigation],
  );
}

List<WeatherForecastDay> _forecastDays(Map<String, dynamic> daily) {
  final times = daily['time'] as List<dynamic>? ?? const [];
  final maxs = daily['temperature_2m_max'] as List<dynamic>? ?? const [];
  final mins = daily['temperature_2m_min'] as List<dynamic>? ?? const [];
  final rains = daily['precipitation_probability_max'] as List<dynamic>? ?? const [];
  final codes = daily['weather_code'] as List<dynamic>? ?? const [];
  final days = <WeatherForecastDay>[];
  for (var i = 0; i < times.length && i < 5; i++) {
    days.add(
      WeatherForecastDay(
        date: DateTime.tryParse('${times[i]}') ?? DateTime.now().add(Duration(days: i)),
        maximumTemperature: (maxs.elementAtOrNull(i) as num?)?.toDouble() ?? 0,
        minimumTemperature: (mins.elementAtOrNull(i) as num?)?.toDouble() ?? 0,
        rainProbability: (rains.elementAtOrNull(i) as num?)?.round() ?? 0,
        weatherCode: (codes.elementAtOrNull(i) as num?)?.toInt() ?? 0,
      ),
    );
  }
  return days;
}

double? _tonightMinimum(Map<String, dynamic> hourly) {
  final times = hourly['time'] as List<dynamic>? ?? const [];
  final temps = hourly['temperature_2m'] as List<dynamic>? ?? const [];
  if (times.isEmpty || temps.isEmpty) return null;
  final now = DateTime.now();
  final end = now.add(const Duration(hours: 12));
  double? min;
  for (var i = 0; i < times.length && i < temps.length; i++) {
    final parsed = DateTime.tryParse('${times[i]}');
    if (parsed == null || parsed.isBefore(now) || parsed.isAfter(end)) continue;
    final value = (temps[i] as num?)?.toDouble();
    if (value == null) continue;
    min = min == null ? value : (value < min ? value : min);
  }
  if (min != null) return min;
  return temps
      .take(24)
      .map((item) => (item as num?)?.toDouble())
      .whereType<double>()
      .fold<double?>(null, (lowest, value) => lowest == null || value < lowest ? value : lowest);
}

double _firstNumber(Object? value) {
  final list = value as List<dynamic>? ?? const [];
  return (list.isEmpty ? null : list.first as num?)?.toDouble() ?? 0;
}

final weatherRepositoryProvider = Provider<OpenMeteoRepository>(
  (ref) => OpenMeteoRepository(deviceLocation: ref.watch(weatherLocatorProvider)),
);
