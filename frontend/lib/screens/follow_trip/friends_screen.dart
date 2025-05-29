import 'package:flutter/material.dart';
import 'package:frontend/screens/follow_trip/members_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/models/user.dart';

class FriendsListScreen extends StatefulWidget {
  final int tripId;
  const FriendsListScreen({Key? key, required this.tripId}) : super(key: key);

  @override
  State<FriendsListScreen> createState() => _FriendsListScreenState();
}

class _FriendsListScreenState extends State<FriendsListScreen> {
  List<Map<String, dynamic>> friends = [];
  List<Map<String, dynamic>> filteredFriends = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  Map<int, String> friendStatuses = {}; // Store friend participation statuses

  @override
  void initState() {
    super.initState();
    _fetchFriends();
    _searchController.addListener(_filterFriends);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterFriends() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredFriends = friends.where((friend) {
        final fullName = '${friend['prenom']} ${friend['nom']}'.toLowerCase();
        return fullName.contains(query);
      }).toList();
    });
  }

  Future<void> _fetchFriends() async {
    setState(() { isLoading = true; });
    try {
      final userId = User.getUserId();
      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Fetch friends
      final friendsResponse = await http.get(
        Uri.parse('http://localhost:3000/api/friends/list/${User.getUserId()}'),
      );

      if (friendsResponse.statusCode == 200) {
        final List<dynamic> friendsData = json.decode(friendsResponse.body);
        
        // Fetch participation status for each friend
        for (var friend in friendsData) {
          if (friend['id_utilisateur'] == null) continue; // Skip if no user ID
          
          final statusResponse = await http.get(
            Uri.parse('http://localhost:3000/api/trips/${widget.tripId}/participation-status/${friend['id_utilisateur']}'),
          );
          
          if (statusResponse.statusCode == 200) {
            final statusData = json.decode(statusResponse.body);
            friendStatuses[friend['id_utilisateur']] = statusData['status'] ?? 'not_invited';
          }
        }

        setState(() {
          friends = friendsData.where((friend) => friend['id_utilisateur'] != null).map((friend) => {
            'id': friend['id_utilisateur'],
            'nom': friend['nom'] ?? '',
            'prenom': friend['prenom'] ?? '',
            'photo_profil': friend['photo_profil'],
            'status': _getButtonText(friendStatuses[friend['id_utilisateur']] ?? 'not_invited'),
          }).toList();
          filteredFriends = friends;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load friends');
      }
    } catch (e) {
      setState(() { isLoading = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des amis: $e'), backgroundColor: Colors.red),
      );
    }
  }

  String _getButtonText(String status) {
    switch (status) {
      case 'not_invited':
        return 'Inviter';
      case 'en_attente':
        return 'En attente';
      case 'accepte':
        return 'Membre';
      case 'refuse':
        return 'Inviter';
      default:
        return 'Inviter';
    }
  }

  Color _getButtonColor(String status) {
    switch (status) {
      case 'not_invited':
      case 'refuse':
        return const Color.fromARGB(255, 25, 154, 8);
      case 'en_attente':
      case 'accepte':
        return Colors.grey;
      default:
        return const Color.fromARGB(255, 25, 154, 8);
    }
  }

  bool _isButtonEnabled(String status) {
    return status == 'not_invited' || status == 'refuse';
  }

  Future<void> _handleInvite(int friendId) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/api/trips/${widget.tripId}/invite'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'userId': friendId}),
      );

      if (response.statusCode == 200) {
        // Update the friend's status
        setState(() {
          friendStatuses[friendId] = 'en_attente';
          final index = friends.indexWhere((f) => f['id'] == friendId);
          if (index != -1) {
            friends[index]['status'] = _getButtonText('en_attente');
            filteredFriends = friends;
          }
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invitation envoyée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to send invitation');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'envoi de l\'invitation: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight + 20),
        child: Column(
          children: [
            const SizedBox(height: 20),
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
                  // Pop back to members screen with a result to indicate a member was added
                  Navigator.of(context).pop(true);
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search here...',
                    border: InputBorder.none,
                    icon: Icon(Icons.search, color: Colors.grey),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredFriends.isEmpty
                  ? const Center(
                      child: Text(
                        'Aucun ami trouvé',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.separated(
                      itemCount: filteredFriends.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final friend = filteredFriends[index];
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
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            leading: CircleAvatar(
                              radius: 24,
                              backgroundImage: friend['photo_profil'] != null && friend['photo_profil'].toString().isNotEmpty
                                ? NetworkImage('http://localhost:3000${friend['photo_profil']}')
                                : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
                              backgroundColor: Colors.transparent,
                            ),
                            title: Text(
                              '${friend['prenom']} ${friend['nom']}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            trailing: ElevatedButton(
                              onPressed: _isButtonEnabled(friendStatuses[friend['id']] ?? 'not_invited')
                                ? () => _handleInvite(friend['id'])
                                : null,
                              style: ElevatedButton.styleFrom(
                                fixedSize: const Size(100, 40),
                                backgroundColor: _getButtonColor(friendStatuses[friend['id']] ?? 'not_invited'),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                friend['status'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              ),
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
