import 'package:belajar_flutter/blocs/weather/weather_cubit.dart';
import 'package:hive/hive.dart';
import 'weather_model.dart';

part 'bookmark_city.g.dart';

@HiveType(typeId: 2)
class BookmarkCity {
  @HiveField(0)
  final String city;
  
  @HiveField(1)
  final String country;
  
  @HiveField(2)
  final double lat;
  
  @HiveField(3)
  final double lon;
  
  @HiveField(4)
  final DateTime savedAt;
  
  @HiveField(5)
  final String? lastTemperature;
  
  @HiveField(6)
  final String? lastDescription;

  BookmarkCity({
    required this.city,
    required this.country,
    required this.lat,
    required this.lon,
    required this.savedAt,
    this.lastTemperature,
    this.lastDescription,
  });

  String get displayName => '$city, $country';

  BookmarkCity copyWith({
    String? lastTemperature,
    String? lastDescription,
  }) {
    return BookmarkCity(
      city: city,
      country: country,
      lat: lat,
      lon: lon,
      savedAt: savedAt,
      lastTemperature: lastTemperature ?? this.lastTemperature,
      lastDescription: lastDescription ?? this.lastDescription,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'country': country,
      'lat': lat,
      'lon': lon,
      'savedAt': savedAt.toIso8601String(),
      'lastTemperature': lastTemperature,
      'lastDescription': lastDescription,
    };
  }

  factory BookmarkCity.fromJson(Map<String, dynamic> json) {
    return BookmarkCity(
      city: json['city'],
      country: json['country'],
      lat: json['lat'],
      lon: json['lon'],
      savedAt: DateTime.parse(json['savedAt']),
      lastTemperature: json['lastTemperature'],
      lastDescription: json['lastDescription'],
    );
  }

  factory BookmarkCity.fromWeather(Weather weather) {
    return BookmarkCity(
      city: weather.city,
      country: weather.country,
      lat: weather.lat,
      lon: weather.lon,
      savedAt: DateTime.now(),
      lastTemperature: weather.formattedTemperature,
      lastDescription: weather.description,
    );
  }

  factory BookmarkCity.fromCitySuggestion(CitySuggestion city) {
    return BookmarkCity(
      city: city.name,
      country: city.country,
      lat: city.lat,
      lon: city.lon,
      savedAt: DateTime.now(),
    );
  }
}