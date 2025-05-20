import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/screens/follow_trip/exclusion_screen.dart';
import 'package:frontend/screens/follow_trip/friends_screen.dart';

class MembersScreen extends StatefulWidget {
  final int tripId;
  const MembersScreen({Key? key, required this.tripId}) : super(key: key);

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  List<Map<String, dynamic>> members = [];
  List<Map<String, dynamic>> filteredMembers = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchMembers();
    _searchController.addListener(_filterMembers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterMembers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredMembers = members.where((member) {
        final fullName = '${member['prenom']} ${member['nom']}'.toLowerCase();
        return fullName.contains(query);
      }).toList();
    });
  }

  Future<void> _fetchMembers() async {
    setState(() { isLoading = true; });
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/trips/${widget.tripId}/participants'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          members = data.map((m) => {
            'id': m['id_voyageur'],
            'nom': m['nom'],
            'prenom': m['prenom'],
            'role': m['role'],
            'photo_profil': m['photo_profil'],
          }).toList();
          filteredMembers = members;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load members');
      }
    } catch (e) {
      setState(() { isLoading = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des membres: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Organisateurs at the top
    final organisateurs = filteredMembers.where((m) => m['role'] == 'organisateur').toList();
    final voyageurs = filteredMembers.where((m) => m['role'] != 'organisateur').toList();

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
                  padding: const EdgeInsets.only(right: 12.0),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => FriendsListScreen(tripId: widget.tripId),
                        ),
                      );
                    },
                    icon: const Icon(Icons.person_add, color: Colors.white, size: 20),
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
                      backgroundColor: const Color.fromARGB(255, 65, 166, 25),
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
            // Liste des membres
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.separated(
                      itemCount: organisateurs.length + voyageurs.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        Map<String, dynamic> member;
                        bool isOrganisateur = false;
                        if (index < organisateurs.length) {
                          member = organisateurs[index];
                          isOrganisateur = true;
                        } else {
                          member = voyageurs[index - organisateurs.length];
                        }
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
                              backgroundImage: member['photo_profil'] != null && member['photo_profil'].toString().isNotEmpty
                                  ? NetworkImage('http://localhost:3000${member['photo_profil']}')
                                  : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
                              backgroundColor: Colors.transparent,
                            ),
                            title: Text(
                              '${member['prenom']} ${member['nom']}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              member['role'],
                              style: const TextStyle(color: Colors.grey),
                            ),
                            trailing: isOrganisateur
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
                                            memberName: '${member['prenom']} ${member['nom']}',
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
