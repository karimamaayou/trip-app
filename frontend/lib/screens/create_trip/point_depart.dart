import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:frontend/screens/create_trip/infos_voyage_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LocationPickerScreen extends StatefulWidget {
  final LatLng initialPosition;
  final Function(LatLng) onLocationSelected;
  final Map<String, dynamic> formData;

  const LocationPickerScreen({
    Key? key,
    required this.initialPosition,
    required this.onLocationSelected,
    required this.formData,
  }) : super(key: key);

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  final MapController _mapController = MapController();
  LatLng? _currentMapCenter;
  bool _isLoading = false;
  final LatLngBounds moroccoBounds = LatLngBounds(
    LatLng(27.6, -13.0),
    LatLng(35.9, -0.9),
  );

  Future<void> _savePositionToAPI() async {
    if (_currentMapCenter == null) return;

    setState(() => _isLoading = true);

    try {
      // Stocker les coordonnées dans formData
      widget.formData['latitude_depart'] = _currentMapCenter!.latitude;
      widget.formData['longitude_depart'] = _currentMapCenter!.longitude;

      // Naviguer vers la page suivante
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InfosVoyagePage(formData: widget.formData),
          ),
        );
      }
    } catch (e) {
      print('Error: $e'); // Debug log
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _currentMapCenter = widget.initialPosition;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_currentMapCenter != null) {
        _mapController.move(_currentMapCenter!, _mapController.zoom);
        _mapController.mapEventStream.listen((event) {
          setState(() {
            _currentMapCenter = event.camera.center;
          });
        });
      } else {
        _mapController.move(
          const LatLng(31.7917, -7.0926),
          _mapController.zoom,
        );
        _mapController.mapEventStream.listen((event) {
          setState(() {
            _currentMapCenter = event.camera.center;
          });
        });
      }
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sélection de position')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      center:
                          _currentMapCenter ??
                          widget.initialPosition ??
                          const LatLng(31.7917, -7.0926),
                      zoom: 6.0,
                      maxBounds: moroccoBounds,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                        subdomains: const ['a', 'b', 'c'],
                      ),
                    ],
                  ),
                  const Center(
                    child: Icon(
                      Icons.location_pin,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF24A500),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  onPressed:
                      _isLoading
                          ? null
                          : () async {
                            if (_currentMapCenter != null) {
                              widget.formData['latitude'] =
                                  _currentMapCenter!.latitude;
                              widget.formData['longitude'] =
                                  _currentMapCenter!.longitude;

                              await _savePositionToAPI();

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => InfosVoyagePage(
                                        formData: widget.formData,
                                      ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Impossible d\'obtenir la position actuelle de la carte.',
                                  ),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                            }
                          },
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            'Suivant',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
