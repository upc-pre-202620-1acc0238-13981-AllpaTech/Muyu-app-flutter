enum WeatherRisk { low, medium, high }

enum WeatherMeasureKind { drainage, cover, irrigation, monitor }

class WeatherAlert {
  const WeatherAlert({
    required this.temperature,
    required this.minimumTemperature,
    required this.maximumTemperature,
    required this.rainProbability,
    required this.risk,
    required this.measures,
  });

  final double temperature;
  final double minimumTemperature;
  final double maximumTemperature;
  final int rainProbability;
  final WeatherRisk risk;
  final List<WeatherMeasureKind> measures;

  bool get isFrost => minimumTemperature <= 3;
  bool get isRain => rainProbability >= 45;
}
