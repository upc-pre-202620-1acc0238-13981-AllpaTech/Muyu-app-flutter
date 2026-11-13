enum WeatherRisk { low, medium, high }

enum WeatherMeasureKind { drainage, cover, irrigation, monitor }

enum WeatherTiming { today, tonight }

class WeatherForecastDay {
  const WeatherForecastDay({
    required this.date,
    required this.maximumTemperature,
    required this.minimumTemperature,
    this.rainProbability = 0,
    this.weatherCode = 0,
  });

  final DateTime date;
  final double maximumTemperature;
  final double minimumTemperature;
  final int rainProbability;
  final int weatherCode;
}

class WeatherAlert {
  const WeatherAlert({
    required this.temperature,
    required this.minimumTemperature,
    required this.maximumTemperature,
    required this.rainProbability,
    required this.risk,
    required this.measures,
    this.forecast = const [],
    this.timing = WeatherTiming.today,
    this.weatherCode = 0,
    this.elevationMeters,
  });

  final double temperature;
  final double minimumTemperature;
  final double maximumTemperature;
  final int rainProbability;
  final WeatherRisk risk;
  final List<WeatherMeasureKind> measures;
  final List<WeatherForecastDay> forecast;
  final WeatherTiming timing;
  final int weatherCode;
  final double? elevationMeters;

  bool get isFrost => minimumTemperature <= 3;
  bool get isRain => rainProbability >= 45;
}
