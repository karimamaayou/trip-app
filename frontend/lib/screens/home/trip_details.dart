import 'package:flutter/material.dart';
import 'package:frontend/screens/home/info_conf_screen.dart';
import 'package:frontend/screens/home/members_screen.dart';



class TripDetailsPage extends StatefulWidget {
  const TripDetailsPage({super.key});

  @override
  State<TripDetailsPage> createState() => _TripDetailsPageState();
}

class _TripDetailsPageState extends State<TripDetailsPage> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final Map<String, dynamic> tripData = {
    'images': [
      'images/marakich.jpeg',
      'images/image1.png',
      'images/image2.png',
    ],
    'title': 'Marrakech Trip',
    'description':
        'Bonjour je cherche un groupe pour voyage à Marrakech le mois prochain pour faire des activités.',
    'activities': ['Nager', 'Quad', 'Montagne'],
    'startDate': '25 juin 2025',
    'endDate': '30 juin 2025',
    'destinations': ['Marrakech', 'Casablanca', 'Tanger'],
    'budget': '1400dh/person',
    'members': [
      {'name': 'Hassan Rochdi', 'role': 'organisateur', 'image': 'images/image.png'},
      {'name': 'Fatima Zahra', 'role': 'voyageur', 'image': 'images/image.png'},
      {'name': 'Youssef El Amrani', 'role': 'voyageur', 'image': 'images/image.png'},
      {'name': 'Amina Benali', 'role': 'voyageur', 'image': 'images/image.png'},
    ]
  };

  @override
  Widget build(BuildContext context) {
    final images = tripData['images'];
    final members = tripData['members'];

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
              // Carousel d'images
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15),
                    ),
                    child: SizedBox(
                      height: 400,
                      width: double.infinity,
                      child: PageView.builder(
                        itemCount: images.length,
                        controller: _controller,
                        onPageChanged: (index) {
                          setState(() {
                            _currentPage = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          return Image.asset(
                            images[index],
                            fit: BoxFit.cover,
                          );
                        },
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
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(images.length, (index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(
                            Icons.circle,
                            size: 10,
                            color: _currentPage == index
                                ? Colors.black
                                : Colors.grey[300],
                          ),
                        );
                      }),
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
                      tripData['title'],
                      style:
                          const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      tripData['description'],
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    const Text("Activités", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: (tripData['activities'] as List<String>)
                          .map((activity) => _chip(activity))
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                    const Text("Date", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _chip(tripData['startDate']),
                        const SizedBox(width: 15),
                        const Text("à"),
                        const SizedBox(width: 15),
                        _chip(tripData['endDate']),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text("Destination", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: (tripData['destinations'] as List<String>)
                          .map((dest) => _chip(dest))
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Budget (${tripData['budget']})",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Membre (${members.length}/6)",
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
            backgroundImage: AssetImage(imagePath),
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
