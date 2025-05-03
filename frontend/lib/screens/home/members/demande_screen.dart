import 'package:flutter/material.dart';
import 'package:frontend/screens/home/members/exclusion_screen.dart';


class DemandeScreen extends StatelessWidget {
  const DemandeScreen({Key? key}) : super(key: key);

  final List<Member> members = const [
    Member(
      name: 'Hassan Ben Ali',
      role: 'organisateur',
      imageUrl: 'assets/images/outbord2.png',
    ),
    Member(
      name: 'Ahmed Ben Ali',
      role: 'voyageur',
      imageUrl: 'assets/images/image1.png',
    ),
    Member(
      name: 'Khalid Ben Ali',
      role: 'voyageur',
      imageUrl: 'assets/images/outbord3.png',
    ),
    Member(
      name: 'Khalid Ben Ali',
      role: 'voyageur',
      imageUrl: 'assets/images/outbord3.png',
    ),
    Member(
      name: 'Khalid Ben Ali',
      role: 'voyageur',
      imageUrl: 'assets/images/outbord3.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Filtrer uniquement les voyageurs
    final List<Member> voyageurs =
        members.where((m) => m.role != 'organisateur').toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Les demandes',
          style: TextStyle(
            color: Color(0xFF2B54A4),
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Barre de recherche
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search here..',
                    border: InputBorder.none,
                    icon: Icon(Icons.search, color: Colors.grey),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Liste des voyageurs
            Expanded(
              child: ListView.separated(
                itemCount: voyageurs.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final member = voyageurs[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 6,
                          blurRadius: 8,
                          offset: const Offset(1, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      leading: CircleAvatar(
                        radius: 24,
                        backgroundImage: AssetImage(member.imageUrl),
                        backgroundColor: Colors.transparent,
                      ),
                      title: Text(
                        member.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text(
                        'voyageur',
                        style: TextStyle(color: Colors.grey),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check, color: Colors.blue),
                            onPressed: () {
                              // Action accepter
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ExclusionPage(
                                    memberName: member.name,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Member {
  final String name;
  final String role;
  final String imageUrl;

  const Member({
    required this.name,
    required this.role,
    required this.imageUrl,
  });
}
