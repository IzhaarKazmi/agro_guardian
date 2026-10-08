import 'dart:convert';

import 'package:agro_guardian/services/weather_models.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class WeatherService {
  // Open-Meteo Forecast API (verified): 
  // https://api.open-meteo.com/v1/forecast?latitude=..&longitude=..&current=temperature_2m,...
  static const _defaultLatitude = 31.5204;
  static const _defaultLongitude = 74.3587;

  Future<WeatherSnapshot> fetchCurrentWeather() async {
    final coords = await _resolveCoordinates();
    final uri = Uri.https(
      'api.open-meteo.com',
      '/v1/forecast',
      {
        'latitude': coords.latitude.toStringAsFixed(4),
        'longitude': coords.longitude.toStringAsFixed(4),
        'current':
            'temperature_2m,relative_humidity_2m,precipitation,weather_code,wind_speed_10m',
        'timezone': 'auto',
      },
    );

    final response = await http.get(uri).timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      throw Exception('weather_http_${response.statusCode}');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    if (decoded['error'] == true) {
      throw Exception('weather_api_error');
    }

    final current = decoded['current'] as Map<String, dynamic>?;
    if (current == null) {
      throw Exception('weather_data_missing');
    }

    return WeatherSnapshot(
      latitude: coords.latitude,
      longitude: coords.longitude,
      temperatureC: (current['temperature_2m'] as num?)?.toDouble() ?? 0,
      humidity: (current['relative_humidity_2m'] as num?)?.toDouble() ?? 0,
      precipitationMm: (current['precipitation'] as num?)?.toDouble() ?? 0,
      windSpeedKmh: (current['wind_speed_10m'] as num?)?.toDouble() ?? 0,
      weatherCode: (current['weather_code'] as num?)?.toInt() ?? 0,
    );
  }

  Future<({double latitude, double longitude})> _resolveCoordinates() async {
    final gps = await _tryGpsCoordinates();
    if (gps != null) {
      return gps;
    }

    final ip = await _tryIpCoordinates();
    if (ip != null) {
      return ip;
    }

    return (
      latitude: _defaultLatitude,
      longitude: _defaultLongitude,
    );
  }

  Future<({double latitude, double longitude})?> _tryGpsCoordinates() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (!serviceEnabled ||
          permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) {
        return (latitude: lastKnown.latitude, longitude: lastKnown.longitude);
      }

      final current = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 10),
        ),
      );
      return (latitude: current.latitude, longitude: current.longitude);
    } catch (_) {
      return null;
    }
  }

  Future<({double latitude, double longitude})?> _tryIpCoordinates() async {
    try {
      final response = await http
          .get(Uri.parse('https://get.geojs.io/v1/ip/geo.json'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        return null;
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final lat = double.tryParse('${decoded['latitude']}');
      final lon = double.tryParse('${decoded['longitude']}');
      if (lat == null || lon == null) {
        return null;
      }

      return (latitude: lat, longitude: lon);
    } catch (_) {
      return null;
    }
  }
}
