class WeatherSnapshot {
  const WeatherSnapshot({
    required this.latitude,
    required this.longitude,
    required this.temperatureC,
    required this.humidity,
    required this.precipitationMm,
    required this.windSpeedKmh,
    required this.weatherCode,
  });

  final double latitude;
  final double longitude;
  final double temperatureC;
  final double humidity;
  final double precipitationMm;
  final double windSpeedKmh;
  final int weatherCode;

  bool get isWet => precipitationMm > 0.2 || humidity >= 75;
  bool get isHumid => humidity >= 65;
  bool get isHot => temperatureC >= 30;
  bool get isMild => temperatureC >= 15 && temperatureC < 28;
  bool get isCool => temperatureC < 18;
}

enum DiseaseRiskLevel { low, moderate, high }

class WeatherDiseaseAdvice {
  const WeatherDiseaseAdvice({
    required this.riskLevel,
    required this.summary,
    required this.commonDiseases,
    required this.recommendations,
  });

  final DiseaseRiskLevel riskLevel;
  final String summary;
  final List<String> commonDiseases;
  final List<String> recommendations;
}
