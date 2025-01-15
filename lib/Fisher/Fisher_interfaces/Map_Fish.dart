import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';


class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  // Variables to hold user input values for temperature and chlorophyll concentration
  TextEditingController temperatureController = TextEditingController();
  TextEditingController chlorophyllController = TextEditingController();

  // Example data for seas with temperature and chlorophyll concentration (you can replace with actual data)
  final List<Map<String, dynamic>> seaData = [
    {
      'name': 'Sea 1',
      'coordinates': LatLng(30.0, 10.0),
      'temperature': 22.0,
      'chlorophyll': 3.0,
    },
    {
      'name': 'Sea 2',
      'coordinates': LatLng(32.0, 12.0),
      'temperature': 24.0,
      'chlorophyll': 2.0,
    },
    {
      'name': 'Sea 3',
      'coordinates': LatLng(34.0, 14.0),
      'temperature': 20.0,
      'chlorophyll': 4.0,
    },
  ];

  // Filtered list of matching seas
  List<Map<String, dynamic>> matchingSeas = [];

  // Function to filter seas based on user input
  void filterSeas() {
    double? enteredTemperature = double.tryParse(temperatureController.text);
    double? enteredChlorophyll = double.tryParse(chlorophyllController.text);

    if (enteredTemperature != null && enteredChlorophyll != null) {
      setState(() {
        matchingSeas = seaData.where((sea) {
          return sea['temperature'] == enteredTemperature &&
              sea['chlorophyll'] == enteredChlorophyll;
        }).toList();
      });
    } else {
      // Show an error message if the user enters invalid input
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter valid numbers')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map Page'),
      ),
      body: Column(
        children: [
          // TextField for entering temperature
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: temperatureController,
              decoration: InputDecoration(
                labelText: 'Enter Temperature (°C)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ),

          // TextField for entering chlorophyll concentration
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: chlorophyllController,
              decoration: InputDecoration(
                labelText: 'Enter Chlorophyll (mg/m³)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ),

          // Button to filter the seas based on input values
          ElevatedButton(
            onPressed: filterSeas,
            child: Text('Find Matching Seas'),
          ),

          // Expanded widget to display the map
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(28.0339, 1.6596), // Center over Algeria
                initialZoom: 5.0, // Adjust zoom level as needed
              ),
              children: [
                TileLayer(
                  urlTemplate:
                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                  maxNativeZoom: 19,
                ),
                MarkerLayer(
                  markers: matchingSeas.map((sea) {
                    return Marker(
                      point: sea['coordinates'],
                      width: 80,
                      height: 80,
                      child: Icon(
                        Icons.location_on,
                        color: Colors.green, // Color can change based on values
                        size: 40,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // Display the coordinates of matching seas
          if (matchingSeas.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: matchingSeas.map((sea) {
                  return Text(
                      'Matching Sea: ${sea['name']} at (${sea['coordinates'].latitude}, ${sea['coordinates'].longitude})');
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
