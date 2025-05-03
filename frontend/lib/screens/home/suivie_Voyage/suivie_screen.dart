import 'package:flutter/material.dart';

class TravelPage extends StatefulWidget {
  @override
  _TravelPageState createState() => _TravelPageState();
}

class _TravelPageState extends State<TravelPage> {
  int _selectedIndex = 0; // 0 for "Mes voyages", 1 for "voyage passé"
  final Color primaryGreen = const Color(0xFF24A500);
  final Color marrakechBlue = const Color(0xFF0054A5);
  final Color borderColor = Colors.grey.shade300;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight + 20), // Add extra height
        child: Column(
          children: [
            SizedBox(height: 20), // Space above the title
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
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cadre unifié pour les onglets
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color.fromARGB(255, 161, 156, 156),
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Expanded(child: _buildTabButton(0, 'Mes voyages')),
                  Container(
                    width: 1,
                    height: 50,
                    margin: EdgeInsets.symmetric(
                      vertical: 10,
                    ), // Ajustez selon vos besoin
                  ),
                  Expanded(child: _buildTabButton(1, 'voyage passé')),
                ],
              ),
            ),
            SizedBox(height: 24),
            // Marrakech trip card
            _buildTravelCard(),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTravelCard() {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Marrakech trip',
              style: TextStyle(
                color: const Color.fromARGB(255, 86, 86, 86),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Divider(height: 1, color: Colors.grey.shade300),
            SizedBox(height: 12),
            _buildInfoRow('Destination', 'Marrakech',
                textColor: marrakechBlue, isBold: true, valueSize: 20),
            _buildInfoRow('Budget', '1500'),
            _buildInfoRow('Lieu de départ', 'Agadir'),
            _buildInfoRow(
              'Date départ',
              'juin 25 2025',
              isLink: true,
              textColor:
                  Color.fromARGB(255, 0, 0, 0), // Sera bien noir maintenant
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
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
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.horizontal(
          left: index == 0 ? Radius.circular(7) : Radius.zero,
          right: index == 1 ? Radius.circular(7) : Radius.zero,
        ),
        onTap: () => setState(() => _selectedIndex = index),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 14),
          margin: EdgeInsets.all(4), // Espace interne
          decoration: BoxDecoration(
            color: _selectedIndex == index ? primaryGreen : Colors.white,
            borderRadius: BorderRadius.horizontal(
              left: index == 0 ? Radius.circular(5) : Radius.zero,
              right: index == 1 ? Radius.circular(5) : Radius.zero,
            ),
            border: Border.all(
              color: _selectedIndex == index ? Colors.black : borderColor,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: _selectedIndex == index
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
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
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
