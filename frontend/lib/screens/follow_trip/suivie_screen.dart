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

  @override
  void dispose() {
    // Nettoyage des ressources si nécessaire
    super.dispose();
  }

  Future<void> _fetchUserTrips() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      final userId = User.getUserId();
      if (userId == null) {
        print('User not logged in');
        if (!mounted) return;
        setState(() {
          isLoading = false;
        });
        return;
      }

      // First get the trips
      final tripsResponse = await http.get(
        Uri.parse('${Environment.apiHost}/api/trips/user/$userId'),
      );

      if (!mounted) return;

      print('Trips Response Status: ${tripsResponse.statusCode}');
      print('Trips Response Body: ${tripsResponse.body}');

      if (tripsResponse.statusCode == 200) {
        final List<dynamic> tripsData = jsonDecode(tripsResponse.body);
        
        // Séparer les voyages en cours et passés
        final now = DateTime.now();
        final current = <Map<String, dynamic>>[];
        final past = <Map<String, dynamic>>[];

        for (var trip in tripsData) {
          final returnDate = DateTime.parse(trip['return_date']);
          if (returnDate.isAfter(now)) {
            current.add(trip);
          } else {
            past.add(trip);
          }
        }

        setState(() {
          currentTrips = current;
          pastTrips = past;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        print('Failed to load trips: ${tripsResponse.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      print('Error loading trips: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Mes voyages',
          style: TextStyle(
            color: marrakechBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Segmented control
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (!mounted) return;
                      setState(() {
                        _selectedIndex = 0;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _selectedIndex == 0 ? primaryGreen : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Mes voyages',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _selectedIndex == 0 ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (!mounted) return;
                      setState(() {
                        _selectedIndex = 1;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _selectedIndex == 1 ? primaryGreen : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Voyages passés',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _selectedIndex == 1 ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : _selectedIndex == 0
                    ? _buildCurrentTrips()
                    : _buildPastTrips(),
          ),
        ],
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isCurrentTrip ? primaryGreen.withOpacity(0.1) : Colors.grey.shade100,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isCurrentTrip ? primaryGreen : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$depart → $destination',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isCurrentTrip ? primaryGreen : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isCurrentTrip ? 'En cours' : 'Terminé',
                    style: TextStyle(
                      color: isCurrentTrip ? Colors.white : Colors.black87,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoItem('Budget', budget),
                    _buildInfoItem('Date', date),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoItem(
                      'Membres',
                      '${tripData['current_members']}/${tripData['total_members']}',
                    ),
                    if (onPressed != null)
                      TextButton(
                        onPressed: onPressed,
                        child: Text(
                          'Voir le chat',
                          style: TextStyle(
                            color: marrakechBlue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
