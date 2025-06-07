import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/screens/follow_trip/exclusion_screen.dart';
import 'package:frontend/screens/follow_trip/friends_screen.dart';
import 'package:frontend/screens/profile/member_profile_screen.dart';
import 'package:frontend/models/user.dart';

class MembersScreen extends StatefulWidget {
  final int tripId;
  final String? currentUserRole;
  const MembersScreen({super.key, required this.tripId, this.currentUserRole});

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> with WidgetsBindingObserver {
  List<Map<String, dynamic>> members = [];
  List<Map<String, dynamic>> filteredMembers = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fetchMembers();
    _searchController.addListener(_filterMembers);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _fetchMembers();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh members when screen becomes active
    final route = ModalRoute.of(context);
    if (route != null && route.isCurrent) {
      _fetchMembers();
    }
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
        Uri.parse('http://localhost:3000/api/trips/${widget.tripId}/all-participants'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          members = data.map((m) => {
            'id': m['id_voyageur'],
            'nom': m['nom'],
            'prenom': m['prenom'],
            'role': m['role'],
            'statut': m['statut'],
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
    return WillPopScope(
      onWillPop: () async {
        // Refresh members before popping
        await _fetchMembers();
        return true;
      },
      child: Scaffold(
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
                      onPressed: () async {
                        final result = await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => FriendsListScreen(tripId: widget.tripId),
                          ),
                        );
                        // If a member was added, update the members list
                        if (result == true) {
                          _fetchMembers();
                        }
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
              // Search bar
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
              // Members list
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredMembers.isEmpty
                        ? const Center(
                            child: Text(
                              'Aucun membre trouvé',
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          )
                        : ListView(
                            children: [
                              if (members.where((m) => m['role'] == 'organisateur').isNotEmpty) ...[
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(
                                    'Organisateurs',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2B54A4),
                                    ),
                                  ),
                                ),
                                ...members.where((m) => m['role'] == 'organisateur').map((member) => _buildMemberTile(member)),
                                const SizedBox(height: 16),
                              ],
                              if (members.where((m) => m['role'] != 'organisateur').isNotEmpty) ...[
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(
                                    'Voyageurs',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2B54A4),
                                    ),
                                  ),
                                ),
                                ...members.where((m) => m['role'] != 'organisateur').map((member) => _buildMemberTile(member)),
                              ],
                            ],
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMemberTile(Map<String, dynamic> member) {
    final bool isCurrentUser = member['id'].toString() == User.getUserId();
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 24,
          backgroundImage: member['photo_profil'] != null && member['photo_profil'].toString().isNotEmpty
              ? NetworkImage('http://localhost:3000${member['photo_profil']}')
              : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
          backgroundColor: Colors.transparent,
        ),
        title: Text(
          isCurrentUser 
              ? '${member['prenom']} ${member['nom']} (Vous)'
              : '${member['prenom']} ${member['nom']}',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          member['role'] ?? 'Voyageur',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        trailing: isCurrentUser ? null : const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: isCurrentUser ? null : () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MemberProfileScreen(
                memberId: member['id'],
                memberName: '${member['prenom']} ${member['nom']}',
                memberPhoto: member['photo_profil'] ?? '',
                currentUserRole: widget.currentUserRole,
                tripId: widget.tripId,
              ),
            ),
          );
          if (result == true) {
            _fetchMembers();
          }
        },
      ),
    );
  }
}
