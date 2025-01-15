import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapInterface extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map'),
        backgroundColor: Colors.white, // Keeping the color scheme consistent
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(28.0339, 1.6596), // Centering the map over Algeria
          initialZoom: 5.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',

          ),

        ],
      ),
    );
  }
}
