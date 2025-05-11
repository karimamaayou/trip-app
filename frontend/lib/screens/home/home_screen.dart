import 'package:flutter/material.dart';
import 'package:frontend/screens/create_trip/creation_voyage_screen.dart';
import 'package:frontend/screens/home/filter_screen.dart';
import 'package:frontend/screens/home/trip_details.dart';
import 'package:frontend/screens/profile/pofile_screen.dart';

class OffersPage extends StatelessWidget {
  final List<Map<String, String>> offres = [
    {
      'titre': 'Marrakech trip',
      'ville': 'Marrakech',
      'image': 'images/marakich.jpeg',
    },
    {
      'titre': 'Santorini',
      'ville': 'Tanger',
      'image': 'images/marakich.jpeg',
    },
    {
      'titre': 'Marrakech trip',
      'ville': 'Marrakech',
      'image': 'images/marakich.jpeg',
    },
    {
      'titre': 'Santorini',
      'ville': 'Tanger',
      'image': 'images/marakich.jpeg',
    },
        {
      'titre': 'Marrakech trip',
      'ville': 'Marrakech',
      'image': 'images/marakich.jpeg',
    },
    {
      'titre': 'Santorini',
      'ville': 'Tanger',
      'image': 'images/marakich.jpeg',
    },
    {
      'titre': 'Marrakech trip',
      'ville': 'Marrakech',
      'image': 'images/marakich.jpeg',
    },
    {
      'titre': 'Santorini',
      'ville': 'Tanger',
      'image': 'images/marakich.jpeg',
    },
  ];

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
  shape: CircleBorder(), // 🔁 Assure que le bouton reste bien circulaire
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
                    child: const CircleAvatar(
                      radius: 24,
                      backgroundImage: AssetImage('assets/profile.jpg'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text.rich(
                      TextSpan(
                        text: 'Bonjour, ',
                        style: TextStyle(fontSize: 16),
                        children: [
                          TextSpan(
                            text: 'Karim amaayou',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_none),
                    onPressed: () {},
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
              child: GridView.builder(
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
                  return  _buildOffreCard(context, offre);

                },
              ),
            ),
          ],
        ),
      ),
    );
  }
Widget _buildOffreCard(BuildContext context, Map<String, String> offre) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TripDetailsPage(),
        ),
      );
    },
    child: SizedBox(
      width: double.infinity,
      height: 200,
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
        
        child:
         Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  offre['image'] ?? '',
                  width: double.infinity,
                  height: 170,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    offre['titre'] ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          size: 16, color: Colors.grey.shade400),
                      const SizedBox(width: 4),
                      Text(
                        offre['ville'] ?? '',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}



}
