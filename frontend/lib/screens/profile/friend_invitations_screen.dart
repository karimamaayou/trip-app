import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/models/user.dart';
import 'package:frontend/services/api_service.dart';

class FriendInvitationsScreen extends StatefulWidget {
  const FriendInvitationsScreen({super.key});

  @override
  _FriendInvitationsScreenState createState() => _FriendInvitationsScreenState();
}

class _FriendInvitationsScreenState extends State<FriendInvitationsScreen> {
  List<dynamic> invitations = [];
  List<dynamic> filteredInvitations = [];
  bool isLoading = true;
  String? error;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchInvitations();
    _searchController.addListener(_filterInvitations);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterInvitations() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredInvitations = List.from(invitations);
      } else {
        filteredInvitations = invitations.where((invitation) {
          final fullName = '${invitation['prenom']} ${invitation['nom']}'.toLowerCase();
          return fullName.contains(query);
        }).toList();
      }
    });
  }

  Future<void> _fetchInvitations() async {
    try {
      final response = await http.get(
        Uri.parse('${Environment.apiHost}/api/friends/invitations/${User.getUserId()}'),
      );

      if (response.statusCode == 200) {
        setState(() {
          invitations = json.decode(response.body);
          filteredInvitations = List.from(invitations);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load invitations');
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _handleInvitation(int senderId, String action) async {
    try {
      final response = await http.post(
        Uri.parse('${Environment.apiHost}/api/friends/invitation/$senderId/respond?currentUserId=${User.getUserId()}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'action': action}),
      );

      if (response.statusCode == 200) {
        setState(() {
          invitations.removeWhere((inv) => inv['id_utilisateur'] == senderId);
          filteredInvitations = List.from(invitations);
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(action == 'accept' 
              ? 'Demande d\'ami acceptée' 
              : 'Demande d\'ami refusée'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to handle invitation');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Rechercher...',
          prefixIcon: const Icon(Icons.search, color: Color(0xFF0054A5)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildInvitationCard(Map<String, dynamic> invitation) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundImage: invitation['photo_profil'] != null
                      ? NetworkImage('${Environment.apiHost}${invitation['photo_profil']}')
                      : const AssetImage('assets/default_user.png') as ImageProvider,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${invitation['prenom']} ${invitation['nom']}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2B54A4),
                        ),
                      ),
                      if (invitation['role'] != null)
                        Text(
                          invitation['role'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (invitation['voyages'] != null && invitation['voyages'].isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Voyages en commun:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2B54A4),
                ),
              ),
              const SizedBox(height: 8),
              ...invitation['voyages'].map<Widget>((voyage) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.card_travel, size: 16, color: Color(0xFF0054A5)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        voyage['titre'],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF2B54A4),
                        ),
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _handleInvitation(invitation['id_utilisateur'], 'reject'),
                  icon: const Icon(Icons.close, color: Colors.red),
                  label: const Text(
                    'Refuser',
                    style: TextStyle(color: Colors.red),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.red.withOpacity(0.1),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                TextButton.icon(
                  onPressed: () => _handleInvitation(invitation['id_utilisateur'], 'accept'),
                  icon: const Icon(Icons.check, color: Colors.white),
                  label: const Text(
                    'Accepter',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF0054A5),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Demandes d\'ami',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0054A5),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0054A5)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Text(
                    'Erreur: $error',
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              : Column(
                  children: [
                    _buildSearchBar(),
                    Expanded(
                      child: filteredInvitations.isEmpty
                          ? const Center(
                              child: Text(
                                'Aucune demande d\'ami',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _fetchInvitations,
                              child: ListView.builder(
                                itemCount: filteredInvitations.length,
                                itemBuilder: (context, index) {
                                  return _buildInvitationCard(filteredInvitations[index]);
                                },
                              ),
                            ),
                    ),
                  ],
                ),
    );
  }
} 