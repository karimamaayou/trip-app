import 'package:flutter/material.dart';
import 'package:frontend/services/api_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/screens/home/info_conf_screen.dart';
import 'package:frontend/screens/home/members_screen.dart';
import 'package:frontend/screens/home/demande_envoyer_screen.dart';
import 'package:frontend/models/user.dart';

class TripDetailsPage extends StatefulWidget {
  final int tripId;

  const TripDetailsPage({super.key, required this.tripId});

  @override
  _TripDetailsPageState createState() => _TripDetailsPageState();
}

class _TripDetailsPageState extends State<TripDetailsPage> {
  final PageController _controller = PageController();
  int _currentPage = 0;
  Map<String, dynamic>? tripData;
  bool isLoading = true;
  bool isSendingRequest = false;
  String? userParticipationStatus;

  @override
  void initState() {
    super.initState();
    _fetchTripDetails();
  }

  Future<void> _fetchTripDetails() async {
    try {
      final response = await http.get(
        Uri.parse('${Environment.apiHost}/api/trips/details/${widget.tripId}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Trip details response: $data'); // Debug print
        
        setState(() {
          tripData = data;
          // Check if current user is in participants list
          final participants = tripData!['participants'] as List;
          final currentUserId = int.parse(User.getUserId() ?? '0');
          print('Current user ID: $currentUserId'); // Debug print
          print('Participants: $participants'); // Debug print
          
          // Find user's participation
          final userParticipation = participants.firstWhere(
            (p) => p['id_voyageur'] == currentUserId,
            orElse: () => null,
          );
          
          // Update participation status
          if (userParticipation != null) {
            userParticipationStatus = userParticipation['statut'];
            print('User participation status: $userParticipationStatus'); // Debug print
          } else {
            // If user is not in participants list, check if they have a pending request
            final pendingResponse = http.get(
              Uri.parse('${Environment.apiHost}/api/trips/${widget.tripId}/participation-status/$currentUserId'),
            ).then((response) {
              if (response.statusCode == 200) {
                final statusData = json.decode(response.body);
                if (statusData['status'] == 'en_attente') {
                  setState(() {
                    userParticipationStatus = 'en_attente';
                  });
                }
              }
            });
          }
          
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching trip details: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _sendJoinRequest() async {
    setState(() {
      isSendingRequest = true;
    });

    try {
      final response = await http.post(
        Uri.parse('${Environment.apiHost}/api/trips/${widget.tripId}/join'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': int.parse(User.getUserId() ?? '0'),
        }),
      );

      if (response.statusCode == 200) {
        // Set the status to en_attente immediately
        setState(() {
          userParticipationStatus = 'en_attente';
        });
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DemandeEnvoyerScreen(),
          ),
        ).then((_) {
          // Refresh trip details when returning
          _fetchTripDetails();
        });
      }
    } catch (e) {
      print('Error sending join request: $e');
    } finally {
      setState(() {
        isSendingRequest = false;
      });
    }
  }

  Widget _buildActionButton() {
    if (isSendingRequest) {
      return const SizedBox(
        width: double.infinity,
        height: 50,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (userParticipationStatus == 'en_attente') {
      return SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[300],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: null,
          child: const Text(
            'En attente',
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
        ),
      );
    }

    if (userParticipationStatus == 'accepte') {
      return SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[400],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: null,
          child: const Text(
            'Membre',
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF24A500),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: _sendJoinRequest,
        child: const Text(
          'Rejoindre',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (tripData == null) {
      return const Scaffold(
        body: Center(child: Text('Trip not found')),
      );
    }

    final trip = tripData!['0'];
    final participants = tripData!['participants'] as List;
    final activities = tripData!['activities'] as List;
    final images = tripData!['images'] as List;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Carousel d'images
            Stack(
              children: [
                SizedBox(
                  height: 400,
                  width: double.infinity,
                  child: images.isNotEmpty 
                    ? PageView.builder(
                        controller: _controller,
                        onPageChanged: (index) {
                          setState(() {
                            _currentPage = index;
                          });
                        },
                        itemCount: images.length,
                        itemBuilder: (context, index) {
                          return ClipRRect(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(15),
                              bottomRight: Radius.circular(15),
                            ),
                            child: Image.network(
                              '${Environment.apiHost}${images[index]['chemin']}',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.error, size: 50),
                                );
                              },
                            ),
                          );
                        },
                      )
                    : Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported, size: 50),
                      ),
                ),
                // Page indicator
                if (images.length > 1)
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        images.length,
                        (index) => Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentPage == index
                                ? Colors.white
                                : Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: 40,
                  left: 10,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trip['titre'],
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    trip['description'],
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  const Text("Activités", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: activities.map((activity) => _chip(activity['nom_activity'])).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text("Date", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _chip(trip['date_depart'].toString().split('T')[0]),
                      const SizedBox(width: 15),
                      const Text("à"),
                      const SizedBox(width: 15),
                      _chip(trip['date_retour'].toString().split('T')[0]),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text("Départ", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _chip(trip['ville_depart']),
                  const SizedBox(height: 16),
                  const Text("Destination", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _chip(trip['ville_arrivee']),
                  const SizedBox(height: 16),
                  const Text("Budget", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('${trip['budget']} DH', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Membre (${participants.length}/${trip['capacite_max']})",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MembersPage(
                                members: participants.map((p) => {
                                  'nom':  '${p['nom']}',
                                  'prenom':  '${p['prenom']}',
                                  'role': p['role'],
                                  'photo_profil': '${p['photo_profil']}',
                                }).toList(),
                              ),
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
                    children: participants.map<Widget>((member) {
                      return _memberCard(
                        '${member['prenom']} ${member['nom']}',
                        member['role'],
                        '${Environment.apiHost}${member['photo_profil']}',
                      );
                    }).toList(),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildActionButton(),
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
