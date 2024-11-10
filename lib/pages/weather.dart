import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nature_connect/services/get_weather_service.dart';
import 'package:nature_connect/services/get_location.dart';
import 'package:intl/intl.dart'; // Add intl package for date formatting

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  Map<String, dynamic>? _weatherData;
  StreamSubscription<Map<String, dynamic>?>? _weatherSubscription;

  @override
  void initState() {
    super.initState();
    _startWeatherStream();
  }

  void _startWeatherStream() async {
    LocationService locationService = LocationService();
    Position? position = await locationService.getCurrentLocation();
    if (position != null) {
      WeatherService weatherService = WeatherService();
      _weatherSubscription =
          weatherService.getWeatherForecastStream(position).listen((data) {
        if (mounted) {
          setState(() {
            _weatherData = data;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _weatherSubscription?.cancel();
    super.dispose();
  }

  double _getAveragePrecipitationProbability(int min, int max) {
    return (min + max) / 2;
  }

  String _formatDay(String date) {
    final DateTime parsedDate = DateTime.parse(date);
    return DateFormat('EEEE').format(parsedDate); // Format to day name
  }

  Widget _buildWeatherRow(Map<String, dynamic> day) {
    String weatherCode = day['weatherCodeMax'].toString();
    int dayOrNight =
        DateTime.now().hour >= 6 && DateTime.now().hour < 18 ? 0 : 1;

    String imagePath = 'assets/images/weather/$weatherCode$dayOrNight.png';
    if (weatherCode == "1001") {
      dayOrNight = 0;
      imagePath = 'assets/images/weather/$weatherCode$dayOrNight.png';
    }

    double avgPrecipitation = _getAveragePrecipitationProbability(
        day['precipitationProbabilityMin'], day['precipitationProbabilityMax']);

    return Container(
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
          )
        ]
      ),
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDay(day['time']), // Format date as day name
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
                Text(
                  "${day['temperatureMax']}\u00b0C",
                  style: TextStyle(
                    color: Colors.green[700],
                  ),
                ),
                Text(
                  "${avgPrecipitation.toStringAsFixed(1)}% chance of raining",
                  style: TextStyle(
                    color: Colors.green[600],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Image.asset(
              imagePath,
              height: 50,
              width: 50,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.image_not_supported, color: Colors.green);
              },
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _weatherData == null
          ? const Text(
              "Fetching weather data...",
              style: TextStyle(color: Colors.green),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "5-Day Weather Forecast:",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _weatherData?['fiveDayForecast']?.length ?? 0,
                    itemBuilder: (context, index) {
                      final day = _weatherData!['fiveDayForecast'][index];
                      return _buildWeatherRow(day);
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
