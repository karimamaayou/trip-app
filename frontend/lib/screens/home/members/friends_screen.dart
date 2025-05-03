import 'package:flutter/material.dart';
import 'package:frontend/screens/home/members/members_screen.dart';


class FriendsListScreen extends StatelessWidget {
  const FriendsListScreen({Key? key}) : super(key: key);

  final List<Friend> friends = const [
    Friend(
      name: 'Hassan Ben Ali',
      status: 'Inviter',
      imageUrl: 'assets/images/outbord2.png',
    ),
    Friend(
      name: 'Ahmed Ben Ali',
      status: 'Envoye',
      imageUrl: 'assets/images/image1.png',
    ),
    Friend(
      name: 'Khalid Ben Ali',
      status: 'Inviter',
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
            const SizedBox(height: 20), // espace ajouté au-dessus
            AppBar(
              title: const Text(
                'Amis',
                style: TextStyle(
                  color: Color(0xFF2B54A4),
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: false,
              elevation: 0,
              backgroundColor: Colors.white,
              iconTheme: const IconThemeData(color: Color(0xFF2B54A4)),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const MembersScreen(),
                    ),
                  );
                },
              ),
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

            // Liste d'amis
            _buildFriendsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildFriendsList() {
    return Expanded(
      child: ListView.separated(
        itemCount: friends.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return FriendListItem(
            friend: friends[index],
            onActionPressed: () {
              debugPrint('${friends[index].status} ${friends[index].name}');
            },
          );
        },
      ),
    );
  }
}

class Friend {
  final String name;
  final String status;
  final String imageUrl;

  const Friend({
    required this.name,
    required this.status,
    required this.imageUrl,
  });
}

class FriendListItem extends StatelessWidget {
  final Friend friend;
  final VoidCallback onActionPressed;

  const FriendListItem({
    required this.friend,
    required this.onActionPressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: CircleAvatar(
          radius: 24,
          backgroundImage: AssetImage(friend.imageUrl),
          backgroundColor: Colors.transparent,
        ),
        title: Text(
          friend.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        trailing: ElevatedButton(
          onPressed: onActionPressed,
          style: ElevatedButton.styleFrom(
            fixedSize: const Size(100, 40),
            backgroundColor: friend.status == 'Envoye'
                ? Colors.grey
                : const Color.fromARGB(255, 25, 154, 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            friend.status,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
