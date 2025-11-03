import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import '../../models/weather_model.dart';

class WeatherCubit extends Cubit<WeatherState> {
  WeatherCubit() : super(WeatherInitial());

  static const String apiKey = 'd14eaf910342935dd505225d2c8db0c7';
  static const String baseUrl = 'https://api.openweathermap.org';

  Future<void> getWeatherByCity(String city) async {
    emit(WeatherLoading());

    if (!await _checkConnection()) {
      emit(WeatherError('No internet connection'));
      return;
    }

    try {
      const maxAttempts = 3;
      for (int attempt = 1; attempt <= maxAttempts; attempt++) {
        try {
          final response = await http
              .get(
                Uri.parse(
                  '$baseUrl/data/2.5/weather?q=$city&appid=$apiKey&units=metric',
                ),
              )
              .timeout(const Duration(seconds: 10));

          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            final weather = Weather.fromJson(data);
            emit(WeatherLoaded(weather: weather));
            return;
          } else if (response.statusCode == 404) {
            emit(WeatherError('City "$city" not found'));
            return;
          }
        } on TimeoutException {
          if (attempt == maxAttempts) {
            emit(WeatherError('Request timeout'));
            return;
          }
        } catch (e) {
          if (attempt == maxAttempts) {
            emit(WeatherError('Network error'));
            return;
          }
        }

        if (attempt < maxAttempts) {
          await Future.delayed(const Duration(seconds: 2));
        }
      }
    } catch (e) {
      emit(WeatherError('Connection failed: ${e.toString()}'));
    }
  }

  Future<void> getWeatherByLocation() async {
    emit(WeatherLoading());

    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        emit(WeatherError('Location service disabled'));
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          emit(WeatherError('Location permission denied'));
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        emit(WeatherError('Location permission permanently denied'));
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      ).timeout(const Duration(seconds: 10));

      if (position.latitude == 0.0 && position.longitude == 0.0) {
        emit(WeatherError('Invalid location coordinates'));
        return;
      }

      if (!await _checkConnection()) {
        emit(WeatherError('No internet connection'));
        return;
      }

      const maxAttempts = 3;
      for (int attempt = 1; attempt <= maxAttempts; attempt++) {
        try {
          final response = await http
              .get(
                Uri.parse(
                  '$baseUrl/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&appid=$apiKey&units=metric',
                ),
              )
              .timeout(const Duration(seconds: 10));

          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            final weather = Weather.fromJson(data);
            emit(WeatherLoaded(weather: weather));
            return;
          } else if (response.statusCode == 404) {
            emit(WeatherError('Weather data not found for location'));
            return;
          }
        } on TimeoutException {
          if (attempt == maxAttempts) {
            emit(WeatherError('Request timeout'));
            return;
          }
        } catch (e) {
          if (attempt == maxAttempts) {
            emit(WeatherError('Network error'));
            return;
          }
        }

        if (attempt < maxAttempts) {
          await Future.delayed(const Duration(seconds: 2));
        }
      }
    } on TimeoutException {
      emit(WeatherError('Location timeout'));
    } catch (e) {
      emit(WeatherError('Location error: ${e.toString()}'));
    }
  }

  Future<List<CitySuggestion>> getCitySuggestions(String query) async {
    if (query.length < 2) return [];

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/geo/1.0/direct?q=$query&limit=5&appid=$apiKey'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => CitySuggestion.fromJson(item)).toList();
      }
    } catch (e) {
      // Silent fail for suggestions
    }
    return [];
  }

  Future<bool> _checkConnection() async {
    try {
      final response = await http
          .get(Uri.parse('https://www.google.com'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<void> getWeatherByCoordinates(double lat, double lon) async {
    emit(WeatherLoading());

    if (!await _checkConnection()) {
      emit(WeatherError('No internet connection'));
      return;
    }

    try {
      const maxAttempts = 3;
      for (int attempt = 1; attempt <= maxAttempts; attempt++) {
        try {
          final response = await http
              .get(
                Uri.parse(
                  '$baseUrl/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric',
                ),
              )
              .timeout(const Duration(seconds: 10));

          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            final weather = Weather.fromJson(data);
            emit(WeatherLoaded(weather: weather));
            return;
          } else if (response.statusCode == 404) {
            emit(WeatherError('Weather data not found for location'));
            return;
          }
        } on TimeoutException {
          if (attempt == maxAttempts) {
            emit(WeatherError('Request timeout'));
            return;
          }
        } catch (e) {
          if (attempt == maxAttempts) {
            emit(WeatherError('Network error'));
            return;
          }
        }

        if (attempt < maxAttempts) {
          await Future.delayed(const Duration(seconds: 2));
        }
      }
    } catch (e) {
      emit(WeatherError('Connection failed: ${e.toString()}'));
    }
  }
}

abstract class WeatherState {}

class WeatherInitial extends WeatherState {}

class WeatherLoading extends WeatherState {}

class WeatherLoaded extends WeatherState {
  final Weather weather;
  WeatherLoaded({required this.weather});
}

class WeatherError extends WeatherState {
  final String message;
  WeatherError(this.message); // Removed 'const' keyword
}

class CitySuggestion {
  final String name;
  final String country;
  final double lat;
  final double lon;

  CitySuggestion({
    required this.name,
    required this.country,
    required this.lat,
    required this.lon,
  });

  factory CitySuggestion.fromJson(Map<String, dynamic> json) {
    return CitySuggestion(
      name: json['name'] ?? '',
      country: json['country'] ?? '',
      lat: (json['lat'] ?? 0).toDouble(),
      lon: (json['lon'] ?? 0).toDouble(),
    );
  }

  String get displayName => '$name, $country';
}
