
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

import 'package:omegaproject/Fisher/Fisher_interfaces/Weather_interface/weather_services.dart';

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final WeatherService _weatherService = WeatherService();
  Map<String, dynamic>? currentWeather;
  List<dynamic>? fiveDayForecast;
  bool isLoading = true;

  StreamSubscription<Position>? positionStream;

  @override
  void initState() {
    super.initState();
    fetchWeatherForCurrentLocation();
    // Start listening for location changes
    positionStream = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100, // Update weather data when moving more than 100 meters
      ),
    ).listen((Position position) {
      fetchWeatherForCurrentLocation(); // Refresh weather data
    });
  }

  @override
  void dispose() {
    positionStream?.cancel(); // Stop listening to location changes
    super.dispose();
  }

  // Function to get user's current location
  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    // Check for location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // Get the user's current location
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  // Function to fetch weather data for the current location
  void fetchWeatherForCurrentLocation() async {
    try {
      Position position = await _getCurrentLocation();
      final weather = await _weatherService.fetchCurrentWeatherByCoordinates(
          position.latitude, position.longitude);
      final forecast = await _weatherService.fetchFiveDayForecastByCoordinates(
          position.latitude, position.longitude);

      // Process the forecast to filter unique dates
      List<dynamic> uniqueForecast = [];
      Set<String> seenDates = {};

      for (var day in forecast) {
        String date = day['dt_txt'].split(' ')[0]; // Extract date from dt_txt
        if (!seenDates.contains(date)) {
          seenDates.add(date);
          uniqueForecast.add(day);
        }
      }

      setState(() {
        currentWeather = weather;
        fiveDayForecast = uniqueForecast; // Set the unique forecast
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching weather data for current location: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Function to get the appropriate weather icon based on the condition
  IconData getWeatherIcon(String weatherDescription) {
    if (weatherDescription.contains('rain')) {
      return Icons.umbrella; // Use umbrella icon for rain
    } else if (weatherDescription.contains('cloud')) {
      return Icons.cloud; // Use cloud icon for cloudy weather
    } else if (weatherDescription.contains('clear')) {
      return Icons.wb_sunny; // Use sun icon for clear weather
    } else {
      return Icons.wb_cloudy; // Default icon for other weather conditions
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather'),
        backgroundColor: Colors.teal,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF012B2E), Color(0xFF0F4235)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (currentWeather != null) ...[
              Text(
                currentWeather!['name'], // Display the city name
                style: TextStyle(fontSize: 28, color: Colors.white),
              ),
              SizedBox(height: 10),
              Icon(
                getWeatherIcon(currentWeather!['weather'][0]['description']),
                color: Colors.white,
                size: 80,
              ),
              Text(
                '${currentWeather!['main']['temp']}°C', // Display temperature
                style: TextStyle(fontSize: 50, color: Colors.white),
              ),
              SizedBox(height: 20),
              Text(
                currentWeather!['weather'][0]['description'], // Weather description
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              Text(
                'Humidity: ${currentWeather!['main']['humidity']}%', // Humidity
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              Text(
                'Wind Speed: ${currentWeather!['wind']['speed']} m/s', // Wind speed
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ],
            SizedBox(height: 40),
            if (fiveDayForecast != null)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: fiveDayForecast!.take(5).map((day) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        children: [
                          Text(
                            '${day['dt_txt'].split(' ')[0]}', // Date of forecast
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                          Icon(
                            getWeatherIcon(day['weather'][0]['description']),
                            color: Colors.white,
                            size: 40,
                          ),
                          Text(
                            '${day['main']['temp']}°C', // Temperature of forecast
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}