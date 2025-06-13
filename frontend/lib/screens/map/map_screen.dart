import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/screens/home/trip_details.dart';
import 'package:frontend/services/api_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class Voyage {
  final int id;
  final String nom;
  final String imageUrl;
  final LatLng position;

  Voyage({
    required this.id,
    required this.nom,
    required this.imageUrl,
    required this.position,
  });

  factory Voyage.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      throw Exception('Voyage data is null');
    }

    print('Processing voyage data: $json'); // Debug log

    final id = json['id'] as int? ?? DateTime.now().millisecondsSinceEpoch;
    final nom =
        json['titre'] as String? ?? json['nom'] as String? ?? 'Sans titre';
    final imagePath = json['chemin'] as String? ?? '';

    print('Image path from API: $imagePath'); // Debug log

    final lat = (json['lat'] as num?)?.toDouble() ?? 0.0;
    final lng = (json['lng'] as num?)?.toDouble() ?? 0.0;

    // Construct the full image URL based on the path format
    String imageUrl;
    if (imagePath.isEmpty) {
      imageUrl = '${Environment.apiHost}/uploads/default_trip.jpg';
    } else if (imagePath.startsWith('/uploads/post_images/')) {
      // Format: /uploads/post_images/1748444539324-840482498.png
      imageUrl = '${Environment.apiHost}$imagePath';
    } else if (imagePath.startsWith('/trip-')) {
      // Format: /trip-1748732253867-796251182.png
      imageUrl =
          '${Environment.apiHost}/uploads/trip_images$imagePath'; // Utilisation de /uploads
    } else {
      // Other formats
      imageUrl =
          '${Environment.apiHost}${imagePath.startsWith('/') ? '' : '/'}$imagePath';
    }

    print('Final image URL: $imageUrl'); // Debug log

    return Voyage(
      id: id,
      nom: nom,
      imageUrl: imageUrl,
      position: LatLng(lat, lng),
    );
  }
}

class MoroccoMapDesign extends StatefulWidget {
  const MoroccoMapDesign({super.key});

  @override
  _MoroccoMapDesignState createState() => _MoroccoMapDesignState();
}

class _MoroccoMapDesignState extends State<MoroccoMapDesign> {
  final MapController _mapController = MapController();
  List<Marker> _markers = [];
  bool _isLoading = true;
  String? _errorMessage;
  final LatLngBounds moroccoBounds = LatLngBounds(
    LatLng(27.6, -13.0),
    LatLng(35.9, -0.9),
  );

  @override
  void initState() {
    super.initState();
    _fetchVoyages();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _fetchVoyages() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http
          .get(Uri.parse('${Environment.apiHost}/api/voyages'))
          .timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        final List<Voyage> voyages =
            responseData
                .where((item) => item != null)
                .map<Voyage>((v) => Voyage.fromJson(v as Map<String, dynamic>?))
                .toList();

        setState(() {
          _markers = voyages.map(_createMarker).toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load voyages: ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Erreur de chargement des voyages';
        _isLoading = false;
      });
    }
  }

  Marker _createMarker(Voyage voyage) {
    return Marker(
      point: voyage.position,
      width: 120,
      height: 140,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TripDetailsPage(tripId: voyage.id),
            ),
          );
                },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  voyage.imageUrl,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => Container(
                        width: 40,
                        height: 40,
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image, size: 24),
                      ),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      width: 40,
                      height: 40,
                      color: Colors.grey[200],
                      child: Center(
                        child: CircularProgressIndicator(
                          value:
                              loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Text(
                voyage.nom,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    if (!mounted) return;

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      if (permission == LocationPermission.deniedForever) return;

      Position position = await Geolocator.getCurrentPosition();
      LatLng userPosition = LatLng(position.latitude, position.longitude);

      try {
        await http.post(
          Uri.parse('${Environment.apiHost}/api/map/update'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'userId': int.parse(User.getUserId() ?? '0'),
            'lat': userPosition.latitude,
            'lng': userPosition.longitude,
          }),
        );
      } catch (e) {
        print('Erreur lors de l\'envoi de la position: $e');
      }

      if (!mounted) return;

      setState(() {
        _markers.add(
          Marker(
            point: userPosition,
            width: 40,
            height: 40,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_pin_circle,
                color: Colors.blue,
                size: 40,
              ),
            ),
          ),
        );
        _mapController.move(userPosition, 15.0);
      });
    } catch (e) {
      print('Erreur de localisation: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: const LatLng(31.7917, -7.0926),
              zoom: 6.0,
              maxBounds: moroccoBounds,
              maxZoom: 18,
              minZoom: 5,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: const ['a', 'b', 'c'],
              ),
              MarkerLayer(markers: _markers),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.1),
              child: const Center(child: CircularProgressIndicator()),
            ),
          if (_errorMessage != null)
            Container(
              color: Colors.black.withOpacity(0.1),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            top: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: _getCurrentLocation,
              backgroundColor: Colors.white,
              child: const Icon(Icons.my_location, color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }
}
