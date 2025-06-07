import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/screens/home/reject_request_screen.dart';

class DemandeScreen extends StatefulWidget {
  final int tripId;

  const DemandeScreen({super.key, required this.tripId});

  @override
  _DemandeScreenState createState() => _DemandeScreenState();
}

class _DemandeScreenState extends State<DemandeScreen> {
  List<Map<String, dynamic>> pendingRequests = [];
  List<Map<String, dynamic>> filteredRequests = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchPendingRequests();
    _searchController.addListener(_filterRequests);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterRequests() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredRequests = pendingRequests.where((request) {
        final fullName = '${request['prenom']} ${request['nom']}'.toLowerCase();
        return fullName.contains(query);
      }).toList();
    });
  }

  Future<void> _fetchPendingRequests() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/trips/${widget.tripId}/requests'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          pendingRequests = data.map((request) => {
            'id_participation': request['id_participation'],
            'id_voyageur': request['id_voyageur'],
            'nom': request['nom'],
            'prenom': request['prenom'],
            'photo_profil': request['photo_profil'],
            'date_inscription': request['date_inscription'],
          }).toList();
          filteredRequests = pendingRequests;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load requests: ${response.body}');
      }
    } catch (e) {
      print('Error fetching pending requests: $e');
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du chargement des demandes: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleRequest(int participationId, String action) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/api/trips/requests/$participationId/$action'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        setState(() {
          pendingRequests.removeWhere((request) => request['id_participation'] == participationId);
          filteredRequests.removeWhere((request) => request['id_participation'] == participationId);
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(action == 'accept' ? 'Demande acceptée' : 'Demande refusée'),
            backgroundColor: action == 'accept' ? Colors.green : Colors.red,
          ),
        );
      } else {
        throw Exception('Failed to $action request');
      }
    } catch (e) {
      print('Error handling request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du traitement de la demande'),
          backgroundColor: Colors.red,
    ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search here..',
                    border: InputBorder.none,
                    icon: Icon(Icons.search, color: Colors.grey),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Liste des demandes
            Expanded(
              child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredRequests.isEmpty
                  ? const Center(
                      child: Text(
                        'Aucune demande en attente',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.separated(
                      itemCount: filteredRequests.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                        final request = filteredRequests[index];
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
                              horizontal: 16,
                              vertical: 12,
                            ),
                      leading: CircleAvatar(
                        radius: 24,
                              backgroundImage: NetworkImage(
                                'http://localhost:3000${request['photo_profil']}',
                              ),
                        backgroundColor: Colors.transparent,
                      ),
                      title: Text(
                              '${request['prenom']} ${request['nom']}',
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
                                  onPressed: () => _handleRequest(
                                    request['id_participation'],
                                    'accept',
                                  ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RejectRequestScreen(
                                    userName: '${request['prenom']} ${request['nom']}',
                                    participationId: request['id_participation'],
                                    onRequestRejected: (participationId) {
                                      setState(() {
                                        pendingRequests.removeWhere((request) => request['id_participation'] == participationId);
                                        filteredRequests.removeWhere((request) => request['id_participation'] == participationId);
                                      });
                                    },
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
