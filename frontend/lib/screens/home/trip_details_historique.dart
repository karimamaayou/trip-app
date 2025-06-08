import 'package:flutter/material.dart';
import 'package:frontend/screens/follow_trip/demande_screen.dart';
import 'package:frontend/screens/follow_trip/members_screen.dart';
import 'package:frontend/screens/home/quitte_screen.dart';
import 'package:frontend/services/api_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/screens/home/info_conf_screen.dart';
import 'package:frontend/screens/home/members_screen.dart';
import 'package:frontend/screens/home/demande_envoyer_screen.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/screens/profile/member_profile_screen.dart';
import 'package:frontend/screens/home/delete_trip_confirmation_screen.dart';
import 'package:frontend/screens/chat/chat_screen.dart';
import 'package:frontend/main_screen.dart';
import 'package:frontend/screens/home/quit_confirmation_screen.dart';

class TripDetailsHistorique extends StatefulWidget {
  final int tripId;

  const TripDetailsHistorique({super.key, required this.tripId});

  @override
  _TripDetailsPageState createState() => _TripDetailsPageState();
}

class _TripDetailsPageState extends State<TripDetailsHistorique> with WidgetsBindingObserver {
  final PageController _controller = PageController();
  int _currentPage = 0;
  Map<String, dynamic>? tripData;
  bool isLoading = true;
  bool isSendingRequest = false;
  String? userParticipationStatus;
  String? currentUserRole;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fetchTripDetails();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _fetchTripDetails();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh trip details when screen becomes active
    final route = ModalRoute.of(context);
    if (route != null && route.isCurrent) {
      _fetchTripDetails();
    }
  }

  Future<void> _fetchTripDetails() async {
    try {
      final response = await http.get(
        Uri.parse('${Environment.apiHost}/api/trips/details/${widget.tripId}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Trip details response: $data'); // Debug print
        
        // Store the previous navigation state
        final previousRoute = ModalRoute.of(context);
        
        setState(() {
          tripData = data;
          // Check if current user is in participants list
          final participants = tripData!['participants'] as List;
          final currentUserId = int.parse(User.getUserId() ?? '0');
          print('Current user ID: $currentUserId'); // Debug print
          print('Participants: $participants'); // Debug print
          final userParticipation = participants.firstWhere(
            (p) => p['id_voyageur'] == currentUserId,
            orElse: () => null,
          );
          userParticipationStatus = userParticipation?['statut'];
          currentUserRole = userParticipation?['role'];
          isLoading = false;
        });

        // If user is no longer a participant (not the organizer), pop to chat screen
        if (userParticipationStatus == null && currentUserRole != 'organisateur') {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pop();
          });
        }
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
        body: json.encode({'userId': int.parse(User.getUserId() ?? '0')}),
      );

      if (response.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DemandeEnvoyerScreen()),
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
    // Determine if the current user is the organizer
    final isOrganizer = currentUserRole == 'organisateur';

    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Show "Consulter les demandes" button only if the user is an organisateur
          if (isOrganizer)
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 34, 233, 3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DemandeScreen(tripId: widget.tripId),
                  ),
                ).then((_) {
                  _fetchTripDetails();
                });
              },
              child: const Text(
                'Consulter les demandes',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
          ),
          // Add a SizedBox for spacing only if the demande button is visible
          if (isOrganizer)
          const SizedBox(height: 12),

          // Show "Supprimer voyage" for organizer, "Quitter le voyage" for others
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isOrganizer ? const Color(0xFFE45517) : const Color.fromARGB(255, 241, 66, 2), // Red for delete, Orange for quit
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: isOrganizer
                  ? () async { // Made onPressed async to await result
                      // Organizer's delete action
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DeleteTripConfirmationScreen(
                            tripId: widget.tripId,
                            tripTitle: tripData!['0']['titre'], // Pass trip title to confirmation screen
                          ),
                        ),
                      );
                      // If result is true, it means the trip was deleted, so pop this screen
                      if (result == true) {
                         Navigator.of(context).pop(true); // Pop TripDetailsHistorique with true
                      }
                    }
                  : () async { // Made onPressed async for non-organizer's quit action
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => QuitConfirmationScreen(
                            tripId: widget.tripId,
                          ),
                        ),
                      );
                      // If result is true, it means the user quit, so pop this screen
                      if (result == true) {
                        Navigator.of(context).pop(true);
                      }
                    },
              child: Text(
                isOrganizer ? 'Supprimer voyage' : 'Quitter le voyage', // Button text changes based on role
                style: const TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (tripData == null) {
      return const Scaffold(body: Center(child: Text('Trip not found')));
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
                  child:
                      images.isNotEmpty
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
                            child: const Icon(
                              Icons.image_not_supported,
                              size: 50,
                            ),
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
                            color:
                                _currentPage == index
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
                      onPressed: () {
                        // Always return to chat screen by replacing the current screen
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(tripId: widget.tripId),
                          ),
                        );
                      },
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
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    trip['description'],
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Activités",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children:
                        activities
                            .map((activity) => _chip(activity['nom_activity']))
                            .toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Date",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
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
                  const Text(
                    "Départ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _chip(trip['ville_depart']),
                  const SizedBox(height: 16),
                  const Text(
                    "Destination",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _chip(trip['ville_arrivee']),
                  const SizedBox(height: 16),
                  const Text(
                    "Budget",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${trip['budget']} DH',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Membre (${participants.length}/${trip['capacite_max']})",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      GestureDetector(
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MembersScreen(
                                tripId: widget.tripId,
                                currentUserRole: currentUserRole,
                              ),
                            ),
                          );
                          // If a member was added or removed, refresh trip details
                          if (result == true) {
                            _fetchTripDetails();
                          }
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
                    children: participants
                        .take(4) // Only show first 4 members
                        .map<Widget>((member) {
                      final currentUserId = int.parse(User.getUserId() ?? '0');
                      final isCurrentUser = member['id_voyageur'] == currentUserId;
                      
                      return GestureDetector(
                        onTap: isCurrentUser ? null : () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MemberProfileScreen(
                                memberId: member['id_voyageur'],
                                memberName: '${member['prenom']} ${member['nom']}',
                                memberPhoto: member['photo_profil'] ?? '',
                                currentUserRole: currentUserRole,
                                tripId: widget.tripId,
                              ),
                            ),
                          );
                          // If a member was removed, refresh trip details
                          if (result == true) {
                            _fetchTripDetails();
                          }
                        },
                        child: _memberCard(
                          '${member['id_voyageur']}_${member['prenom']} ${member['nom']}',
                          member['role'] ?? 'Voyageur',
                          '${Environment.apiHost}${member['photo_profil']}',
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  _buildActionButton(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _chip(String label) {
    return Chip(label: Text(label), backgroundColor: Colors.white);
  }

  static Widget _memberCard(String name, String role, String imagePath) {
    // Extract member ID from the name (format: "id_name")
    final parts = name.split('_');
    final memberId = int.tryParse(parts[0]);
    final displayName = parts.skip(1).join('_');
    final currentUserId = int.parse(User.getUserId() ?? '0');
    final isCurrentUser = memberId == currentUserId;

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
          CircleAvatar(radius: 24, backgroundImage: NetworkImage(imagePath)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Text(
                  isCurrentUser ? '$displayName (Vous)' : displayName,
                  style: const TextStyle(fontWeight: FontWeight.bold)
                ),
              Text(role, style: const TextStyle(color: Colors.grey)),
            ],
            ),
          ),
          if (!isCurrentUser) // Only show arrow for other members
            const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}
