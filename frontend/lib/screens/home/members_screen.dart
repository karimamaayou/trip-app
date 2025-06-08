import 'package:flutter/material.dart';
import 'package:frontend/services/api_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/models/user.dart';

class MembersPage extends StatefulWidget {
  final List<Map<String, dynamic>> members;

  const MembersPage({super.key, required this.members});

  @override
  State<MembersPage> createState() => _MembersPageState();
}

class _MembersPageState extends State<MembersPage> {
  bool isOrganizer = false;
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  void _checkUserRole() {
    currentUserId = User.getUserId();
    if (currentUserId != null) {
      final currentUser = widget.members.firstWhere(
        (member) => member['id_voyageur'].toString() == currentUserId,
        orElse: () => {'role': ''},
      );
      setState(() {
        isOrganizer = currentUser['role'] == 'organisateur';
      });
    }
  }

  Future<void> _banParticipant(String participantId, String participantName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmer l\'exclusion'),
          content: Text('Êtes-vous sûr de vouloir exclure $participantName du voyage ?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Annuler'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Exclure', style: TextStyle(color: Colors.red)),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        final response = await http.delete(
          Uri.parse('${Environment.apiHost}/api/trips/participants/$participantId'),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode == 200) {
          setState(() {
            widget.members.removeWhere((member) => member['id_voyageur'].toString() == participantId);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Participant exclu avec succès')),
          );
        } else {
          throw Exception('Failed to ban participant');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'exclusion: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
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
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: widget.members.length,
        itemBuilder: (context, index) {
          final member = widget.members[index];
          final isCurrentUser = member['id_voyageur'].toString() == currentUserId;
          
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
                  backgroundImage: NetworkImage('${Environment.apiHost}${member['photo_profil']}'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${member['prenom']} ${member['nom']}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(member['role'], style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                if (isOrganizer && !isCurrentUser && member['role'] != 'organisateur')
                  IconButton(
                    icon: const Icon(Icons.block, color: Colors.red),
                    onPressed: () => _banParticipant(
                      member['id_voyageur'].toString(),
                      '${member['prenom']} ${member['nom']}',
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
