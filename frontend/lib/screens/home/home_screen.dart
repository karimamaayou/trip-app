import 'package:flutter/material.dart';
import 'package:frontend/screens/create_trip/creation_voyage_screen.dart';
import 'package:frontend/screens/home/filter_screen.dart';
import 'package:frontend/screens/home/trip_details.dart';
import 'package:frontend/screens/profile/pofile_screen.dart';
import 'package:frontend/screens/notification/notification_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/models/user.dart';
import 'package:frontend/services/api_service.dart';

class OffersPage extends StatefulWidget {
  @override
  _OffersPageState createState() => _OffersPageState();
}

class _OffersPageState extends State<OffersPage> {
  List<Map<String, dynamic>> offres = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    
    // Debug print to verify user data
    print('🏠 HomeScreen - User Status:');
    print('Is User Logged In: ${User.isLoggedIn()}');
    print('User ID: ${User.getUserId()}');
    print('User ID: ${User.profilePicture}');
    
    _fetchTrips();
  }

  Future<void> _fetchTrips() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/api/trips/allTrips'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          offres = data.map((trip) => {
            'titre': trip['titre'].toString(),
            'ville_depart': trip['ville_depart'].toString(),
            'ville_arrivee': trip['ville_arrivee'].toString(),
            'id': trip['id_voyage'].toString(),
            'images': trip['images'] ?? [],
          }).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching trips: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF51D32D),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreationVoyagePage()),
          );
        },
        child: Icon(Icons.add, size: 28, color: Colors.white),
        shape: CircleBorder(),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CustomProfileScreen()),
                      );
                    },
                    child: CircleAvatar(
                      radius: 25,
                      backgroundImage: User.profilePicture != null
                          ? NetworkImage('http://localhost:3000${User.profilePicture}')
                          : const AssetImage('assets/profile.jpg') as ImageProvider,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        text: 'Bonjour, ',
                        style: TextStyle(fontSize: 16),
                        children: [
                          TextSpan(
                            text: '${User.prenom} ${User.nom}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_none),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.grey.shade300, blurRadius: 6),
                  ],
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.grey),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search here..',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.tune, color: Colors.grey),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SearchFilterPage(),
                          ),
                        );
                      },
                    ),
                  ], 
                ),
              ),
            ),
            const SizedBox(height: 25),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 25),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Les voyages",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Grid of cards
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : GridView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.8,
                ),
                itemCount: offres.length,
                itemBuilder: (context, index) {
                  final offre = offres[index];
                        return _buildTripCard(offre);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripCard(Map<String, dynamic> trip) {
    final images = trip['images'] as List<dynamic>;
    String? imageUrl;
    
    if (images.isNotEmpty && images[0] is Map<String, dynamic>) {
      imageUrl = images[0]['chemin']?.toString();
    }
    
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
          MaterialPageRoute(
            builder: (context) => TripDetailsPage(tripId: int.parse(trip['id'])),
          ),
      );
    },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.55),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 7,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    imageUrl != null ? 'http://localhost:3000$imageUrl' : 'http://localhost:3000/assets/default_trip.jpg',
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.error, size: 50),
                      );
                    },
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      trip['titre'] ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 1),
                    Row(
                      children: [
                        Icon(Icons.location_on,
                            size: 16, color: Colors.grey.shade400),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            trip['ville_arrivee'] ?? '',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
      ),
    ),
  );
}
}
