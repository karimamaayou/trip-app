import 'package:flutter/material.dart';
import 'package:frontend/screens/chat/chat_screen.dart';
import 'package:frontend/screens/home/trip_details.dart';
import 'package:frontend/screens/home/trip_details_historique.dart';
import 'package:frontend/screens/post/post_screen.dart';
import 'package:frontend/services/api_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/models/user.dart';

class TravelPage extends StatefulWidget {
  const TravelPage({super.key});

  @override
  _TravelPageState createState() => _TravelPageState();
}

class _TravelPageState extends State<TravelPage> {
  int _selectedIndex = 0; // 0 = Mes voyages, 1 = Voyage passé
  final Color primaryGreen = const Color(0xFF24A500);
  final Color marrakechBlue = const Color(0xFF0054A5);
  final Color borderColor = Colors.grey.shade300;
  
  List<Map<String, dynamic>> currentTrips = [];
  List<Map<String, dynamic>> pastTrips = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserTrips();
  }

  Future<void> _fetchUserTrips() async {
    setState(() {
      isLoading = true;
    });

    try {
      final userId = User.getUserId();
      if (userId == null) {
        print('User not logged in');
        return;
      }

      // First get the trips
      final tripsResponse = await http.get(
        Uri.parse('${Environment.apiHost}/api/trips/user/$userId'),
      );

      print('Trips Response Status: ${tripsResponse.statusCode}');
      print('Trips Response Body: ${tripsResponse.body}');

      if (tripsResponse.statusCode == 200) {
        final List<dynamic> tripsData = json.decode(tripsResponse.body);
        final now = DateTime.now();
        
        // For each trip, get the participation count
        for (var trip in tripsData) {
          try {
            // Get participations for this trip
            final participationUrl = '${Environment.apiHost}/api/trips/${trip['id_voyage']}/participants';
            print('Fetching participants from URL: $participationUrl');
            
            final participationResponse = await http.get(
              Uri.parse(participationUrl),
            );
            
            print('Participation Response for trip ${trip['id_voyage']}:');
            print('URL used: $participationUrl');
            print('Status: ${participationResponse.statusCode}');
            print('Body: ${participationResponse.body}');

            if (participationResponse.statusCode == 200) {
              final List<dynamic> participants = json.decode(participationResponse.body);
              // Count ALL accepted participants (both organisateur and voyageur)
              final acceptedCount = participants.where((p) => 
                p['statut'] == 'accepte'
              ).length;
              
              trip['current_members'] = acceptedCount;
              print('Trip ${trip['id_voyage']} - Total capacity: ${trip['capacite_max']}, Accepted members: $acceptedCount');
            } else {
              print('Error fetching participants for trip ${trip['id_voyage']}: ${participationResponse.statusCode}');
              trip['current_members'] = 0;
            }
          } catch (e) {
            print('Error processing participations for trip ${trip['id_voyage']}: $e');
            trip['current_members'] = 0;
          }
        }
        
        setState(() {
          currentTrips = tripsData.where((trip) {
            final returnDate = DateTime.parse(trip['date_retour'] ?? trip['date_depart']);
            // Only include trips where user's status is 'accepte' and return date is in the future
            return trip['statut'] == 'accepte' && returnDate.isAfter(now);
          }).map((trip) => {
            'id': trip['id_voyage'],
            'title': trip['titre'],
            'destination': trip['ville_arrivee'],
            'depart': trip['ville_depart'],
            'budget': '${trip['budget']} MAD',
            'date': trip['date_depart'].toString().split('T')[0],
            'return_date': trip['date_retour']?.toString().split('T')[0] ?? trip['date_depart'].toString().split('T')[0],
            'total_members': trip['capacite_max'] ?? 0,
            'current_members': trip['current_members'] ?? 0,
          }).toList();

          pastTrips = tripsData.where((trip) {
            final returnDate = DateTime.parse(trip['date_retour'] ?? trip['date_depart']);
            // Only include trips where user's status is 'accepte' and return date is in the past
            return trip['statut'] == 'accepte' && returnDate.isBefore(now);
          }).map((trip) => {
            'id': trip['id_voyage'],
            'title': trip['titre'],
            'destination': trip['ville_arrivee'],
            'depart': trip['ville_depart'],
            'budget': '${trip['budget']} MAD',
            'date': trip['date_depart'].toString().split('T')[0],
            'return_date': trip['date_retour']?.toString().split('T')[0] ?? trip['date_depart'].toString().split('T')[0],
            'total_members': trip['capacite_max'] ?? 0,
            'current_members': trip['current_members'] ?? 0,
          }).toList();

          // Debug print to verify the counts
          print('\nFinal Member Counts:');
          print('Current trips:');
          for (var trip in currentTrips) {
            print('Trip ${trip['id']} (${trip['title']}): ${trip['current_members']}/${trip['total_members']} members');
          }
          print('\nPast trips:');
          for (var trip in pastTrips) {
            print('Trip ${trip['id']} (${trip['title']}): ${trip['current_members']}/${trip['total_members']} members');
          }

          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching user trips: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight + 20),
        child: Column(
          children: [
            SizedBox(height: 18),
            AppBar(
              automaticallyImplyLeading: false,
              title: Text(
                'Mes voyages',
                style: TextStyle(
                  color: const Color.fromARGB(255, 15, 6, 141),
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: Colors.white,
              elevation: 0,
              iconTheme: IconThemeData(color: Colors.black),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Onglets
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey.shade200,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildTabButton(0, 'Mes voyages'),
                    _buildTabButton(1, 'Voyage passé'),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            // Contenu selon l'onglet sélectionné
            Expanded(
              child: isLoading
                ? Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: _selectedIndex == 0
                        ? _buildCurrentTrips()
                        : _buildPastTrips(),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentTrips() {
    if (currentTrips.isEmpty) {
      return Center(
        child: Text(
          'Aucun voyage en cours',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Column(
      children: currentTrips.map((trip) => _buildTravelCard(
        title: trip['title'],
        destination: trip['destination'],
        budget: trip['budget'],
        depart: trip['depart'],
        date: trip['date'],
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(tripId: trip['id']),
            ),
          );
        },
      )).toList(),
    );
  }

  Widget _buildPastTrips() {
    if (pastTrips.isEmpty) {
      return Center(
        child: Text(
          'Aucun voyage passé',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Column(
      children: pastTrips.map((trip) => _buildTravelCard(
        title: trip['title'],
        destination: trip['destination'],
        budget: trip['budget'],
        depart: trip['depart'],
        date: trip['date'],
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(tripId: trip['id']),
            ),
          );
        },
      )).toList(),
    );
  }

  Widget _buildTravelCard({
    required String title,
    required String destination,
    required String budget,
    required String depart,
    required String date,
    VoidCallback? onPressed,
  }) {
    // Find the trip data to get the return date and member info
    final tripData = [...currentTrips, ...pastTrips].firstWhere(
      (trip) => trip['title'] == title,
      orElse: () => {
        'return_date': date,
        'total_members': 0,
        'current_members': 0,
      },
    );

    final isCurrentTrip = DateTime.parse(tripData['return_date']).isAfter(DateTime.now());

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.blue.shade50,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with title and status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: Color(0xFF1A237E),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isCurrentTrip ? primaryGreen.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isCurrentTrip ? 'En cours' : 'Terminé',
                          style: TextStyle(
                            color: isCurrentTrip ? primaryGreen : Colors.grey.shade700,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Destination with icon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: marrakechBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.location_on, color: marrakechBlue, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Destination',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                destination,
                                style: TextStyle(
                                  color: marrakechBlue,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Trip Details Grid
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow(
                          Icons.airplanemode_active,
                          'Départ',
                          depart,
                          Icons.calendar_today,
                          'Date départ',
                          date,
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          Icons.airplanemode_active,
                          'Retour',
                          destination,
                          Icons.calendar_today,
                          'Date retour',
                          tripData['return_date'],
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          Icons.account_balance_wallet,
                          'Budget',
                          budget,
                          Icons.group,
                          'Membres',
                          '${tripData['current_members']}/${tripData['total_members']}',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: const Text(
                        'Consulter',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon1,
    String label1,
    String value1,
    IconData icon2,
    String label2,
    String value2,
  ) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Icon(icon1, size: 20, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label1,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      value1,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Row(
            children: [
              Icon(icon2, size: 20, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label2,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      value2,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabButton(int index, String text) {
    final isSelected = _selectedIndex == index;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => _selectedIndex = index),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? primaryGreen : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? primaryGreen : Colors.grey.shade600,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}
