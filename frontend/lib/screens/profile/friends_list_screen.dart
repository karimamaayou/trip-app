import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/models/user.dart';
import 'package:frontend/services/api_service.dart';

class FriendsListScreen extends StatefulWidget {
  const FriendsListScreen({super.key});

  @override
  _FriendsListScreenState createState() => _FriendsListScreenState();
}

class _FriendsListScreenState extends State<FriendsListScreen> {
  List<Map<String, dynamic>> friends = [];
  List<Map<String, dynamic>> filteredFriends = [];
  bool isLoading = true;
  String? error;
  final TextEditingController _searchController = TextEditingController();
  Map<String, dynamic>? friendToRemove;

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
      if (query.isEmpty) {
        filteredFriends = List.from(friends);
      } else {
        filteredFriends = friends.where((friend) {
          final fullName = '${friend['prenom']} ${friend['nom']}'.toLowerCase();
          return fullName.contains(query);
        }).toList();
      }
    });
  }

  Future<void> _fetchFriends() async {
    try {
      print('Fetching friends for user ${User.id}'); // Debug log
      final response = await http.get(
        Uri.parse('${Environment.apiHost}/api/friends/list/${User.id}'),
        headers: {'Authorization': 'Bearer ${User.token}'},
      );

      print('Response status code: ${response.statusCode}'); // Debug log
      print('Response body: ${response.body}'); // Debug log

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          friends = List<Map<String, dynamic>>.from(data);
          filteredFriends = List.from(friends);
          isLoading = false;
        });
        print('Loaded ${friends.length} friends'); // Debug log
      } else {
        setState(() {
          error = 'Failed to load friends: ${response.body}';
          isLoading = false;
        });
        print('Error loading friends: ${response.body}'); // Debug log
      }
    } catch (e) {
      print('Exception while fetching friends: $e'); // Debug log
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _removeFriend(int friendId) async {
    try {
      final response = await http.delete(
        Uri.parse('${Environment.apiHost}/api/friends/${User.id}/$friendId'),
        headers: {
          'Authorization': 'Bearer ${User.token}',
        },
      );

      if (response.statusCode == 200) {
        // Refresh the friends list
        await _fetchFriends();
        // Close the modal
        if (mounted) {
          Navigator.of(context).pop();
        }
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ami supprimé avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Failed to remove friend');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la suppression: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showRemoveFriendModal(Map<String, dynamic> friend) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Supprimer un ami'),
          content: Text('Êtes-vous sûr de vouloir supprimer ${friend['prenom']} ${friend['nom']} de vos amis ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () => _removeFriend(friend['id_utilisateur']),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2B54A4)),
        title: const Text(
          'Mes amis',
          style: TextStyle(
            color: Color(0xFF2B54A4),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un ami...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF2B54A4)),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          // Friends list
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : error != null
                    ? Center(
                        child: Text(
                          'Erreur: $error',
                          style: const TextStyle(color: Colors.red),
                        ),
                      )
                    : filteredFriends.isEmpty
                        ? const Center(
                            child: Text(
                              'Aucun ami trouvé',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _fetchFriends,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: filteredFriends.length,
                              itemBuilder: (context, index) {
                                final friend = filteredFriends[index];
                                // Adapted design from MembersScreen's _buildMemberTile
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12), // Spacing between cards
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.1),
                                        spreadRadius: 1,
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Adjusted padding from MembersScreen ListTile
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 24, // Profile picture size matching MembersScreen
                                          backgroundImage: friend['photo_profil'] != null && friend['photo_profil'].toString().isNotEmpty
                                              ? NetworkImage('${Environment.apiHost}${friend['photo_profil']}')
                                              : const AssetImage('assets/images/default_avatar.png') as ImageProvider, // Placeholder image
                                          backgroundColor: Colors.transparent,
                                        ),
                                        const SizedBox(width: 16), // Spacing between picture and text
                                        Expanded(
                                          child: Text(
                                            '${friend['prenom']} ${friend['nom']}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600, // Matching font weight
                                              fontSize: 16, // Matching font size
                                            ),
                                          ),
                                        ),
                                        // Remove friend button
                                        IconButton(
                                          onPressed: () => _showRemoveFriendModal(friend),
                                          icon: const Icon(
                                            Icons.person_remove_rounded,
                                            color: Colors.red,
                                          ),
                                          tooltip: 'Supprimer l\'ami',
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
} 