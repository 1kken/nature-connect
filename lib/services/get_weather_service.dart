import 'dart:async';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class WeatherService {
  final String apiKey = 'OGQYf1aXfwVrOkNuzC0f4Pvupnda2m0G';

  Stream<Map<String, dynamic>?> getWeatherForecastStream(Position position, {Duration interval = const Duration(minutes: 15)}) async* {
    while (true) {
      yield await getWeatherForecast(position);
      await Future.delayed(interval);
    }
  }

  Future<Map<String, dynamic>?> getWeatherForecast(Position position) async {
    try {
      double latitude = position.latitude;
      double longitude = position.longitude;

      String url =
          'https://api.tomorrow.io/v4/weather/forecast?location=$latitude,$longitude&apikey=$apiKey';

      http.Response response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        List<dynamic> dailyForecasts = data['timelines']['daily'];
        List<Map<String, dynamic>> fiveDayForecast = dailyForecasts.take(5).map((day) => {
          'time': day['time'],
          'precipitationProbabilityMax': day['values']['precipitationProbabilityMax'],
          'precipitationProbabilityMin': day['values']['precipitationProbabilityMin'],
          'temperatureAvg': day['values']['temperatureAvg'],
          'temperatureMax': day['values']['temperatureMax'],
          'weatherCodeMax': day['values']['weatherCodeMax'],
        }).toList();
        return {
          'fiveDayForecast': fiveDayForecast
        };
      } else {
        print('Failed to get weather data. Status Code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }
}