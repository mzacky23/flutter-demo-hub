class Weather {
  final String city;
  final String country;
  final double temperature;
  final double feelsLike;
  final String description;
  final String icon;
  final int humidity;
  final double windSpeed;
  final int pressure;
  final DateTime date;
  final DateTime sunrise;
  final DateTime sunset;
  final double lat;
  final double lon;

  Weather({
    required this.city,
    required this.country,
    required this.temperature,
    required this.feelsLike,
    required this.description,
    required this.icon,
    required this.humidity,
    required this.windSpeed,
    required this.pressure,
    required this.date,
    required this.sunrise,
    required this.sunset,
    required this.lat,
    required this.lon,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      city: json['name'] ?? 'Unknown',
      country: json['sys']['country'] ?? '',
      temperature: (json['main']['temp'] ?? 0).toDouble(),
      feelsLike: (json['main']['feels_like'] ?? 0).toDouble(),
      description: (json['weather'][0]['description'] ?? '').toString(),
      icon: json['weather'][0]['icon'] ?? '01d',
      humidity: json['main']['humidity'] ?? 0,
      windSpeed: (json['wind']['speed'] ?? 0).toDouble(),
      pressure: json['main']['pressure'] ?? 0,
      date: DateTime.fromMillisecondsSinceEpoch((json['dt'] ?? 0) * 1000),
      sunrise: DateTime.fromMillisecondsSinceEpoch((json['sys']['sunrise'] ?? 0) * 1000),
      sunset: DateTime.fromMillisecondsSinceEpoch((json['sys']['sunset'] ?? 0) * 1000),
      lat: (json['coord']['lat'] ?? 0).toDouble(),
      lon: (json['coord']['lon'] ?? 0).toDouble(),
    );
  }

  String get iconUrl => 'https://openweathermap.org/img/wn/$icon@2x.png';
  String get formattedTemperature => '${temperature.round()}°C';
  String get formattedFeelsLike => 'Feels like ${feelsLike.round()}°C';

  String get formattedSunrise => _formatTime(sunrise);
  String get formattedSunset => _formatTime(sunset);
  
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
  
  bool get isDaytime {
    final now = DateTime.now();
    return now.isAfter(sunrise) && now.isBefore(sunset);
  }
  
  String get dayNightStatus => isDaytime ? '☀️ Daytime' : '🌙 Nighttime';
}

class Forecast {
  final DateTime date;
  final double temp;
  final String description;
  final String icon;
  final double pop;

  Forecast({
    required this.date,
    required this.temp,
    required this.description,
    required this.icon,
    required this.pop,
  });

  factory Forecast.fromJson(Map<String, dynamic> json) {
    return Forecast(
      date: DateTime.fromMillisecondsSinceEpoch((json['dt'] ?? 0) * 1000),
      temp: (json['main']['temp'] ?? 0).toDouble(),
      description: (json['weather'][0]['description'] ?? '').toString(),
      icon: json['weather'][0]['icon'] ?? '01d',
      pop: (json['pop'] ?? 0).toDouble(),
    );
  }

  String get iconUrl => 'https://openweathermap.org/img/wn/$icon.png';
  String get formattedTemp => '${temp.round()}°C';
  String get formattedPop => '${(pop * 100).round()}%';
}