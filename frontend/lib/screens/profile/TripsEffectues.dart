import 'package:flutter/material.dart';
import 'package:frontend/screens/home/trip_details_historique.dart';

class TripsEffectuesPage extends StatelessWidget {
  final Color primaryGreen = const Color(0xFF24A500);
  final Color marrakechBlue = const Color(0xFF0054A5);

  // Liste des voyages effectués
  final List<Map<String, dynamic>> tripsEffectues = [
    {
      "title": "Trip à Rabat",
      "destination": "Rabat",
      "budget": "1100 MAD",
      "depart": "Fès",
      "date": "mars 12 2024",
      "tripId": 21,
    },
    {
      "title": "Découverte de Chefchaouen",
      "destination": "Chefchaouen",
      "budget": "950 MAD",
      "depart": "Tétouan",
      "date": "janvier 29 2024",
      "tripId": 22,
    },
    {
      "title": "Excursion Ouarzazate",
      "destination": "Ouarzazate",
      "budget": "1300 MAD",
      "depart": "Marrakech",
      "date": "décembre 18 2023",
      "tripId": 23,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Voyages effectués',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: marrakechBlue,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 1,
      ),
      backgroundColor: Colors.white,
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tripsEffectues.length,
        itemBuilder: (context, index) {
          final trip = tripsEffectues[index];
          return _buildTravelCard(
            context: context,
            title: trip['title'],
            destination: trip['destination'],
            budget: trip['budget'],
            depart: trip['depart'],
            date: trip['date'],
            tripId: trip['tripId'],
          );
        },
      ),
    );
  }

  Widget _buildTravelCard({
    required BuildContext context,
    required String title,
    required String destination,
    required String budget,
    required String depart,
    required String date,
    required int tripId,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: const Color.fromARGB(255, 86, 86, 86),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Divider(height: 1, color: Colors.grey.shade300),
            SizedBox(height: 12),
            _buildInfoRow('Destination', destination, textColor: marrakechBlue, isBold: true),
            _buildInfoRow('Budget', budget),
            _buildInfoRow('Départ', depart),
            _buildInfoRow('Date', date),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
            
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    bool isBold = false,
    Color? textColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: textColor ?? Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
