import 'package:flutter/material.dart';
import 'package:frontend/screens/create_trip/creation_voyage_screen.dart';
import 'package:frontend/screens/home/filter_screen.dart';


class OffersPage extends StatelessWidget {
  final List<Map<String, String>> offres = [
    {
      'titre': 'Marrakech trip',
      'description':
          'Bonjour je cherche un group pour voyage a marrakech le mois...',
      'ville': 'Agadir',
      'image': 'images/marakich.jpeg',
    },
    {
      'titre': 'Marrakech trip',
      'description':
          'Bonjour je cherche un group pour voyage a marrakech le mois...',
      'ville': 'Agadir',
      'image': 'images/marakich.jpeg',
    },
    {
      'titre': 'Marrakech trip',
      'description':
          'Bonjour je cherche un group pour voyage a marrakech le mois...',
      'ville': 'Agadir',
      'image': 'images/marakich.jpeg',
    },
    {
      'titre': 'Marrakech trip',
      'description':
          'Bonjour je cherche un group pour voyage a marrakech le mois...',
      'ville': 'Agadir',
      'image': 'images/marakich.jpeg',
    },

  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 30),
            // AppBar personnalisée
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundImage:
                        AssetImage('assets/profile.jpg'), // à changer
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text.rich(
                      TextSpan(
                        text: 'Bonjour, ',
                        style:
                            TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
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
            const SizedBox(height: 30),
            // Barre de recherche
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(color: Colors.grey.shade300, blurRadius: 6)
                  ],
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // ✅ Bouton centré "Suivant"
            Center(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF24A500),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(color: Colors.grey.shade300, blurRadius: 6),
                  ],
                ),
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreationVoyagePage(),
                      ),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 125, vertical: 12),
                    child: Text(
                      'Cree voyage',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Titre
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

            const SizedBox(height: 30),

            // Offres (ListView)
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: offres.length,
                itemBuilder: (context, index) {
                  final offre = offres[index];
                  return _buildOffreCard(offre);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOffreCard(Map<String, String> offre) {
    return Card(
      color: Colors.white,
      elevation: 3,
      shadowColor: Colors.grey.shade300,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                offre['image'] ?? '',
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    offre['titre'] ?? '',
                    style:
                        const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    offre['description'] ?? '',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              color: Colors.grey, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            offre['ville'] ?? '',
                            style:
                                const TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF24A500),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                        ),
                        child: const Text(
                          'Consulter',
                          style:
                              TextStyle(color: Colors.white, fontSize: 13),
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
    );
  }
}
