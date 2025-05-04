import 'package:flutter/material.dart';
import 'package:frontend/screens/follow_trip/exclusion_screen.dart';
import 'package:frontend/screens/follow_trip/friends_screen.dart';



class MembersScreen extends StatelessWidget {
  const MembersScreen({Key? key}) : super(key: key);

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
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight + 20),
        child: Column(
          children: [
            SizedBox(height: 20),
            AppBar(
              title: const Text(
                'Membres',
                style: TextStyle(
                  color: Color(0xFF2B54A4),
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: false,
              elevation: 0,
              backgroundColor: Colors.white,
              iconTheme: const IconThemeData(color: Color(0xFF2B54A4)),
              actions: [
                Padding(
                  padding:
                      const EdgeInsets.only(right: 12.0), // espace à droite
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const FriendsListScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.person_add,
                        color: Colors.white, size: 20),
                    label: const Text(
                      'Inviter',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.ellipsis,
                        fontSize: 16,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(120, 40),
                      backgroundColor: Color.fromARGB(255, 65, 166, 25),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.centerLeft,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Barre de recherche avec ombre simple
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
                    hintText: 'Search here...',
                    border: InputBorder.none,
                    icon: Icon(Icons.search, color: Colors.grey),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Liste des membres
            Expanded(
              child: ListView.separated(
                itemCount: members.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final member = members[index];
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
                      subtitle: Text(
                        member.role,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      trailing: member.role == 'organisateur'
                          ? const Padding(
                              padding: EdgeInsets.only(right: 10),
                              child: Icon(Icons.star, color: Colors.green),
                            )
                          : IconButton(
                              icon: const Icon(
                                Icons.block,
                                color: Color.fromARGB(255, 250, 0, 0),
                              ),
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
