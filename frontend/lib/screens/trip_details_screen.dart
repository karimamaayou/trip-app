import 'package:flutter/material.dart';
import 'package:frontend/widgets/image_carousel.dart';
import 'package:frontend/screens/home/info_conf_screen.dart';
import 'package:frontend/screens/home/members_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TripDetailsPage extends StatefulWidget {
  final int tripId;

  const TripDetailsPage({
    super.key,
    required this.tripId,
  });

  @override
  State<TripDetailsPage> createState() => _TripDetailsPageState();
}

class _TripDetailsPageState extends State<TripDetailsPage> {
  Map<String, dynamic>? tripData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTripDetails();
  }

  Future<void> _fetchTripDetails() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/trips/${widget.tripId}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          tripData = {
            ...data,
            'images': (data['images'] as List<dynamic>).map((img) => 
              'http://localhost:3000${img['chemin']?.toString() ?? ''}'
            ).toList(),
            'members': (data['participants'] as List<dynamic>).map((member) => {
              'name': '${member['prenom']} ${member['nom']}',
              'role': member['role'],
              'image': member['photo_profil'] != null 
                ? 'http://localhost:3000${member['photo_profil'].toString()}'
                : 'http://localhost:3000/assets/profile.jpg'
            }).toList(),
          };
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load trip details');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (tripData == null) {
      return const Scaffold(
        body: Center(
          child: Text('Failed to load trip details'),
        ),
      );
    }

    final images = tripData!['images'] as List<String>;
    final members = tripData!['members'] as List<Map<String, dynamic>>;

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF24A500),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => InfpConfirmationScreen(),
                ),
              );
            },
            child: const Text(
              'Rejoindre',
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              ImageCarousel(
                images: images,
                height: 400,
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tripData!['titre'],
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      tripData!['description'],
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    const Text("Activités", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: (tripData!['activities'] as List<String>)
                          .map((activity) => _chip(activity))
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                    const Text("Date", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _chip(tripData!['date_depart']),
                        const SizedBox(width: 15),
                        const Text("à"),
                        const SizedBox(width: 15),
                        _chip(tripData!['date_retour']),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text("Destination", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: (tripData!['destinations'] as List<String>)
                          .map((dest) => _chip(dest))
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Budget (${tripData!['budget']} DH)",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Membre (${members.length}/${tripData!['capacite_max']})",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MembersPage(members: members),
                              ),
                            );
                          },
                          child: const Text(
                            "Voir tout",
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Column(
                      children: members.map<Widget>((member) {
                        return _memberCard(
                          member['name'],
                          member['role'],
                          member['image'],
                        );
                      }).toList(),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  static Widget _chip(String label) {
    return Chip(
      label: Text(label),
      backgroundColor: Colors.white,
    );
  }

  static Widget _memberCard(String name, String role, String imagePath) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 4)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage(imagePath),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(role, style: const TextStyle(color: Colors.grey)),
            ],
          )
        ],
      ),
    );
  }
} 