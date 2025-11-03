import 'package:belajar_flutter/models/weather_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/weather/weather_cubit.dart';
import '../../blocs/theme/theme_cubit.dart';
import '../../models/theme_model.dart';
import '../../blocs/bookmark/bookmark_city_cubit.dart';
import 'dart:async';

class WeatherView extends StatefulWidget {
  const WeatherView({super.key});

  @override
  State<WeatherView> createState() => _WeatherViewState();
}

class _WeatherViewState extends State<WeatherView> {
  final TextEditingController _searchController = TextEditingController();
  final List<CitySuggestion> _suggestions = [];
  bool _showSuggestions = false;
  Timer? _debounceTimer;

  void _addCityToBookmarks(Weather weather) {
    final bookmarkCityCubit = context.read<BookmarkCityCubit>();
    bookmarkCityCubit.addBookmarkFromWeather(weather);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${weather.city} added to bookmarks'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _fetchSuggestions(String query) {
    _debounceTimer?.cancel();

    if (query.length < 2) {
      setState(() {
        _suggestions.clear();
        _showSuggestions = false;
      });
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      try {
        final weatherCubit = context.read<WeatherCubit>();
        final newSuggestions = await weatherCubit.getCitySuggestions(query);

        if (mounted) {
          setState(() {
            _suggestions
              ..clear()
              ..addAll(newSuggestions);
            _showSuggestions = newSuggestions.isNotEmpty;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _suggestions.clear();
            _showSuggestions = false;
          });
        }
      }
    });
  }

  void _selectCity(String cityName) {
    context.read<WeatherCubit>().getWeatherByCity(cityName);
    _searchController.clear();
    setState(() {
      _showSuggestions = false;
      _suggestions.clear();
    });
  }

  void _refreshWeather() {
    context.read<WeatherCubit>().getWeatherByLocation();
    setState(() {
      _showSuggestions = false;
      _suggestions.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeModel>(
      builder: (context, themeState) {
        final bool isDarkMode = themeState.isDark;
        final gradientColors = isDarkMode
            ? [Colors.blueGrey[900]!, Colors.blueGrey[800]!]
            : [Colors.blue.shade50, Colors.blue.shade100];

        return Scaffold(
          appBar: AppBar(
            title: const Text('Weather App'),
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.bookmark),
                onPressed: () {
                  Navigator.pushNamed(context, '/bookmark_city');
                },
                tooltip: 'View Bookmarks',
              ),
              IconButton(
                icon: const Icon(Icons.my_location),
                onPressed: _refreshWeather,
                tooltip: 'Use Current Location',
              ),
            ],
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: gradientColors,
              ),
            ),
            child: Column(
              children: [
                _buildSearchSection(context, isDarkMode),
                Expanded(
                  child: BlocBuilder<WeatherCubit, WeatherState>(
                    builder: (context, state) {
                      return _buildWeatherContent(state, isDarkMode);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchSection(BuildContext context, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.blueGrey[800] : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Type city name (min 2 letters)...',
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[500],
                      ),
                      icon: Icon(
                        Icons.search,
                        color: isDarkMode ? Colors.blue[200] : Colors.blue,
                      ),
                    ),
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black87,
                      fontSize: 16,
                    ),
                    onChanged: _fetchSuggestions,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.blue, Colors.purple],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.search, color: Colors.white),
                    onPressed: () {
                      final query = _searchController.text.trim();
                      if (query.isNotEmpty) _selectCity(query);
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          if (_showSuggestions && _suggestions.isNotEmpty)
            _buildSuggestionsList(isDarkMode),
        ],
      ),
    );
  }

  Widget _buildSuggestionsList(bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.blueGrey[800] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: _suggestions
            .map((city) => _buildSuggestionItem(city, isDarkMode))
            .toList(),
      ),
    );
  }

  Widget _buildSuggestionItem(CitySuggestion city, bool isDarkMode) {
    return ListTile(
      leading: Icon(
        Icons.location_on,
        color: isDarkMode ? Colors.blue[200] : Colors.blue,
        size: 20,
      ),
      title: Text(
        city.displayName,
        style: TextStyle(
          fontSize: 14,
          color: isDarkMode ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      dense: true,
      onTap: () => _selectCity(city.name),
    );
  }

  Widget _buildWeatherContent(WeatherState state, bool isDarkMode) {
    return switch (state) {
      WeatherInitial() => _buildInitialState(isDarkMode),
      WeatherLoading() => _buildLoadingState(isDarkMode),
      WeatherLoaded(:final weather) => _buildWeatherData(weather, isDarkMode),
      WeatherError(:final message) => _buildErrorState(message, isDarkMode),
      _ => const SizedBox(),
    };
  }

  Widget _buildInitialState(bool isDarkMode) {
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cloud,
                size: 80,
                color: isDarkMode ? Colors.blue[200] : Colors.blue,
              ),
              const SizedBox(height: 20),
              Text(
                'Welcome to Weather App',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.blue[800],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Search for a city or use your current location',
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.grey[400] : Colors.blue[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: isDarkMode ? Colors.blue[200] : Colors.blue,
          ),
          const SizedBox(height: 20),
          Text(
            'Loading weather data...',
            style: TextStyle(
              fontSize: 16,
              color: isDarkMode ? Colors.grey[400] : Colors.blue[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherData(Weather weather, bool isDarkMode) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${weather.city}, ${weather.country}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.blue[800],
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _formatDate(weather.date),
                      style: TextStyle(
                        fontSize: 16,
                        color: isDarkMode ? Colors.grey[400] : Colors.blue[600],
                      ),
                    ),
                  ],
                ),
              ),
              // TAMBAH TOMBOL BOOKMARK INI ↓
              BlocBuilder<BookmarkCityCubit, BookmarkCityState>(
                builder: (context, state) {
                  final isBookmarked = context
                      .read<BookmarkCityCubit>()
                      .isCityBookmarked(weather.city, weather.country);
                  return IconButton(
                    icon: Icon(
                      isBookmarked ? Icons.bookmark_added : Icons.bookmark_add,
                      color: isBookmarked ? Colors.amber : Colors.grey,
                      size: 30,
                    ),
                    onPressed: isBookmarked
                        ? null
                        : () => _addCityToBookmarks(weather),
                    tooltip: isBookmarked
                        ? 'Already bookmarked'
                        : 'Add to bookmarks',
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 30),
          _buildWeatherCard(weather, isDarkMode),
          const SizedBox(height: 30),
          _buildRefreshButton(),
        ],
      ),
    );
  }

  Widget _buildWeatherCard(Weather weather, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.blueGrey[800] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(
                weather.iconUrl,
                width: 80,
                height: 80,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.cloud,
                    size: 80,
                    color: isDarkMode ? Colors.blue[200] : Colors.blue,
                  );
                },
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    weather.formattedTemperature,
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.blue[800],
                    ),
                  ),
                  Text(
                    weather.formattedFeelsLike,
                    style: TextStyle(
                      fontSize: 16,
                      color: isDarkMode ? Colors.grey[400] : Colors.blue[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            weather.description.toUpperCase(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.blue[200] : Colors.blue,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 30),
          _buildWeatherDetails(weather, isDarkMode),
        ],
      ),
    );
  }

  Widget _buildWeatherDetails(Weather weather, bool isDarkMode) {
    final details = [
      _WeatherDetail(Icons.water_drop, 'Humidity', '${weather.humidity}%'),
      _WeatherDetail(Icons.air, 'Wind Speed', '${weather.windSpeed} m/s'),
      _WeatherDetail(Icons.compress, 'Pressure', '${weather.pressure} hPa'),
      _WeatherDetail(
        Icons.thermostat,
        'Feels Like',
        weather.formattedFeelsLike,
      ),
      _WeatherDetail(Icons.wb_sunny, 'Sunrise', weather.formattedSunrise),
      _WeatherDetail(Icons.nightlight, 'Sunset', weather.formattedSunset),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: details
          .map((detail) => _buildDetailCard(detail, isDarkMode))
          .toList(),
    );
  }

  Widget _buildDetailCard(_WeatherDetail detail, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.blueGrey[700] : Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            detail.icon,
            size: 30,
            color: isDarkMode ? Colors.blue[200] : Colors.blue,
          ),
          const SizedBox(height: 8),
          Text(
            detail.title,
            style: TextStyle(
              fontSize: 12,
              color: isDarkMode ? Colors.grey[400] : Colors.blue[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            detail.value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.blue[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRefreshButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.blue, Colors.purple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ElevatedButton(
        onPressed: _refreshWeather,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.refresh),
            SizedBox(width: 8),
            Text('Refresh Weather'),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message, bool isDarkMode) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.blueGrey[800] : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 70,
                      color: isDarkMode ? Colors.red[300] : Colors.red,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Oops!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.red[800],
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      message,
                      style: TextStyle(
                        fontSize: 16,
                        color: isDarkMode ? Colors.grey[400] : Colors.red[600],
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      child: _buildRefreshButton(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              _buildTipsSection(isDarkMode),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipsSection(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.blueGrey[800] : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            '💡 Tips',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.blue[200] : Colors.blue,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '• Search for cities manually above\n• Ensure stable internet connection\n• Try again in a moment',
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${_getWeekday(date.weekday)}, ${date.day} ${_getMonth(date.month)} ${date.year}';
  }

  String _getWeekday(int weekday) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays[weekday - 1];
  }

  String _getMonth(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}

class _WeatherDetail {
  final IconData icon;
  final String title;
  final String value;

  _WeatherDetail(this.icon, this.title, this.value);
}
