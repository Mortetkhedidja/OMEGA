import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:intl/intl.dart';

class WeatherService {
  final String apiKey = 'b56f9fb85ca23251e120d737d10d9caa';

  // Fetch current weather by coordinates
  Future<Map<String, dynamic>> fetchCurrentWeatherByCoordinates(
      double latitude, double longitude) async {
    final url =
        'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&units=metric&appid=$apiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load current weather');
    }
  }

  // Fetch 5-day forecast by coordinates (every 3 hours)


  Future<List<Map<String, dynamic>>> fetchFiveDayForecastByCoordinates(
      double latitude, double longitude) async {
    final url =
        'https://api.openweathermap.org/data/2.5/forecast?lat=$latitude&lon=$longitude&units=metric&appid=$apiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> forecastList = data['list'];

      // Map to hold one entry per day (key is the date)
      Map<String, Map<String, dynamic>> dailyForecasts = {};

      // Iterate over the forecast list
      for (var entry in forecastList) {
        // Extract date (format: yyyy-MM-dd)
        String date = DateFormat('yyyy-MM-dd').format(DateTime.parse(entry['dt_txt']));

        // Choose an entry at a fixed hour (e.g., 12:00 PM)
        String time = DateFormat('HH:mm:ss').format(DateTime.parse(entry['dt_txt']));
        if (time == '12:00:00') {
          dailyForecasts[date] = entry;
        }
      }
      // Debug print to show filtered forecast data
      print('Filtered Forecast Data: ${dailyForecasts.values.toList()}');


      // Return only the values (forecast data) from the dailyForecasts map
      return dailyForecasts.values.toList();
    } else {
      throw Exception('Failed to load forecast data');
    }
  }


  // Fetch hourly forecast data (next 48 hours)
  Future<List<dynamic>> fetchHourlyForecast(double latitude, double longitude) async {
    final url =
        'https://api.openweathermap.org/data/2.5/forecast?lat=$latitude&lon=$longitude&units=metric&appid=$apiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // Return data for the first 48 hours (hourly forecast is available in 3-hour intervals)
      return data['list'].take(16).toList(); // For ~48 hours
    } else {
      throw Exception('Failed to load hourly forecast');
    }
  }
}
