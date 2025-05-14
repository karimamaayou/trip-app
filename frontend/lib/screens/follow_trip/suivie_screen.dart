import 'package:flutter/material.dart';
import 'package:frontend/screens/chat/chat_screen.dart';
import 'package:frontend/screens/home/trip_details.dart';
import 'package:frontend/screens/home/trip_details_historique.dart';
import 'package:frontend/screens/post/post_screen.dart';

class TravelPage extends StatefulWidget {
  @override
  _TravelPageState createState() => _TravelPageState();
}

class _TravelPageState extends State<TravelPage> {
  int _selectedIndex = 0; // 0 = Mes voyages, 1 = Voyage passé
  final Color primaryGreen = const Color(0xFF24A500);
  final Color marrakechBlue = const Color(0xFF0054A5);
  final Color borderColor = Colors.grey.shade300;

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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Onglets
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color.fromARGB(255, 226, 226, 226),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Row(
                  children: [
                    Expanded(child: _buildTabButton(0, 'Mes voyages')),
                    Expanded(child: _buildTabButton(1, 'Voyage passé')),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            // Contenu selon l'onglet sélectionné
            Expanded(
              child: SingleChildScrollView(
                child:
                    _selectedIndex == 0
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
    return Column(
      children: [
        _buildTravelCard(
          title: 'Marrakech trip',
          destination: 'Marrakech',
          budget: '1500 MAD',
          depart: 'Agadir',
          date: 'juin 25 2025',

          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ChatScreen()),
            );
          },
        ),
        _buildTravelCard(
          title: 'Essaouira Adventure',
          destination: 'Essaouira',
          budget: '900 MAD',
          depart: 'Agadir',
          date: 'juillet 5 2025',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ChatScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPastTrips() {
    return Column(
      children: [
        _buildTravelCard(
          title: 'Fès trip',
          destination: 'Fès',
          budget: '1200 MAD',
          depart: 'Casablanca',
          date: 'avril 14 2024',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TripDetailsHistorique(tripId: 11),
              ),
            );
          },
        ),
        _buildTravelCard(
          title: 'Tanger trip',
          destination: 'Tanger',
          budget: '1300 MAD',
          depart: 'Rabat',
          date: 'février 3 2024',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TripDetailsHistorique(tripId: 12),
              ),
            );
          },
        ),
        _buildTravelCard(
          title: 'Tanger trip',
          destination: 'Tanger',
          budget: '1300 MAD',
          depart: 'Rabat',
          date: 'février 3 2024',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TripDetailsHistorique(tripId: 13),
              ),
            );
          },
        ),
      ],
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
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
            _buildInfoRow(
              'Destination',
              destination,
              textColor: marrakechBlue,
              isBold: true,
              valueSize: 20,
            ),
            _buildInfoRow('Budget', budget),
            _buildInfoRow('Lieu de départ', depart),
            _buildInfoRow(
              'Date départ',
              date,
              isLink: true,
              textColor: Colors.black,
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 22),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Consulter',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(int index, String text) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => _selectedIndex = index),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 14),
          margin: EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: _selectedIndex == index ? primaryGreen : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFB0B0B0), width: 2),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color:
                    _selectedIndex == index
                        ? Colors.white
                        : const Color.fromARGB(255, 86, 86, 86),
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    bool isBold = false,
    bool isLink = false,
    Color? textColor,
    double valueSize = 14,
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
                fontSize: valueSize,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: textColor ?? Colors.black,
                decoration:
                    isLink ? TextDecoration.underline : TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
