import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class MoroccoMapDesign extends StatefulWidget {
  @override
  _MoroccoMapDesignState createState() => _MoroccoMapDesignState();
}

class _MoroccoMapDesignState extends State<MoroccoMapDesign> {
  final MapController _mapController = MapController();
  final List<Marker> _markers = [];

  // Limites approximatives du Maroc
  final LatLngBounds moroccoBounds = LatLngBounds(
    LatLng(27.6, -13.0), // Sud-ouest
    LatLng(35.9, -0.9),  // Nord-est
  );

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Vérifie si les services de localisation sont activés
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Les services de localisation sont désactivés.');
    }

    // Vérifie les permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('La permission est refusée.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('La permission est refusée de façon permanente.');
    }

    // Obtenir la position actuelle
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final LatLng userPosition = LatLng(position.latitude, position.longitude);

    setState(() {
      _markers.clear();
      _markers.add(
      Marker(
       point: LatLng(position.latitude, position.longitude),
       width: 40,
       height: 40,
       child: Icon(Icons.location_on),
       ),

      );
      _mapController.move(userPosition, 15.0); // Zoom sur la position
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: LatLng(31.7917, -7.0926), // Centre du Maroc
              zoom: 6.0,
              maxBounds: moroccoBounds,
              maxZoom: 18,
              minZoom: 5,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: _markers,
              ),
            ],
          ),
          Positioned(
            top: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: _getCurrentLocation,
              child: Icon(Icons.my_location),
            ),
          ),
        ],
      ),
    );
  }
}
