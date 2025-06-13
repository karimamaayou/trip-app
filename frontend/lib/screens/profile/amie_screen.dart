import 'package:flutter/material.dart';

class AmiePage extends StatelessWidget {
  // Liste statique de membres
  final List<Map<String, String>> fakeMembers = [
    {
      'photo': 'https://via.placeholder.com/150',
      'nom': 'El Mehdi Benali',
      'role': 'Voyageur',
    },
    {
      'photo': 'https://via.placeholder.com/150',
      'nom': 'Sara Hamidi',
      'role': 'Voyageuse',
    },
    {
      'photo': 'https://via.placeholder.com/150',
      'nom': 'Yassir Ait Lahcen',
      'role': 'Chauffeur',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Amis')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: fakeMembers.length,
        itemBuilder: (context, index) {
          final member = fakeMembers[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.grey.shade200, blurRadius: 4),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage(member['photo']!),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member['nom']!,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      member['role']!,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
