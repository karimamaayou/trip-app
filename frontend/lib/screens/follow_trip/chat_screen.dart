import 'package:flutter/material.dart';
import 'package:frontend/main_screen.dart';
import 'package:frontend/screens/follow_trip/suivie_screen.dart';
import 'package:frontend/screens/home/trip_details.dart';
import 'package:frontend/screens/home/trip_details_historique.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/models/user.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final int tripId;
  const ChatScreen({Key? key, required this.tripId}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  Map<String, dynamic>? tripData;
  bool isLoading = true;
  final List<Map<String, dynamic>> messages = [];
  final TextEditingController _messageController = TextEditingController();
  late IO.Socket socket;
  final currentUserId = int.parse(User.getUserId() ?? '0');
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _fetchTripDetails();
    _setupSocket();
    _fetchMessages();
  }

  @override
  void dispose() {
    _isDisposed = true;
    socket.disconnect();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _fetchTripDetails() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/trips/details/${widget.tripId}'),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        setState(() {
          tripData = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load trip details');
      }
    } catch (e) {
      print('Error fetching trip details: $e');
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du chargement des détails du voyage: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _setupSocket() {
    socket = IO.io('http://localhost:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();
    socket.onConnect((_) {
      if (_isDisposed) return;
      print('Connected to socket server');
      socket.emit('join_trip', widget.tripId);
    });

    socket.on('new_message', (data) {
      if (_isDisposed) return;
      if (!mounted) return;
      
      setState(() {
        messages.insert(0, data); // Insert at beginning since we're using reverse
      });
    });

    socket.on('error', (error) {
      if (_isDisposed) return;
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error'), backgroundColor: Colors.red),
      );
    });
  }

  Future<void> _fetchMessages() async {
    if (_isDisposed) return;
    
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/trips/${widget.tripId}/messages'),
      );

      if (_isDisposed) return;

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (!mounted) return;
        
        setState(() {
          messages.clear();
          // Add messages in reverse order since we're using reverse ListView
          messages.addAll(data.reversed.map((msg) => {
            'id': msg['id_message'],
            'message': msg['contenu'],
            'timestamp': DateTime.parse(msg['date_envoi']),
            'userId': msg['id_auteur'],
            'sender': {
              'prenom': msg['prenom'],
              'nom': msg['nom'],
              'photo_profil': msg['photo_profil'],
            },
          }).toList());
        });
      }
    } catch (e) {
      if (_isDisposed) return;
      print('Error fetching messages: $e');
    }
  }

  void _sendMessage() {
    if (_isDisposed) return;
    if (_messageController.text.trim().isEmpty) return;

    final message = _messageController.text.trim();
    _messageController.clear();

    socket.emit('send_message', {
      'tripId': widget.tripId,
      'userId': currentUserId,
      'message': message,
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || tripData == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF2B54A4)),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            "Chat",
            style: TextStyle(
              color: Color(0xFF2B54A4),
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final trip = tripData!['0'];
    final images = tripData!['images'] as List;
    String? imageUrl;
    if (images.isNotEmpty && images[0] is Map<String, dynamic>) {
      imageUrl = images[0]['chemin']?.toString();
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2B54A4)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: imageUrl != null 
                ? NetworkImage('http://localhost:3000$imageUrl')
                : const AssetImage('assets/default_trip.jpg') as ImageProvider,
              radius: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                trip['titre'],
                style: const TextStyle(
                  color: Color(0xFF2B54A4),
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.info,
                color: Color(0xFF24A500),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TripDetailsHistorique(tripId: widget.tripId),
                  ),
                );
              },
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              reverse: true, // This makes the list start from bottom
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index]; // No need to reverse index since we're using reverse
                final isMe = message['userId'] == currentUserId;
                final sender = message['sender'];
                final timestamp = message['timestamp'] is String 
                  ? DateTime.parse(message['timestamp'])
                  : message['timestamp'] as DateTime;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isMe) ...[
                        CircleAvatar(
                          radius: 16,
                          backgroundImage: sender['photo_profil'] != null
                            ? NetworkImage('http://localhost:3000${sender['photo_profil']}')
                            : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        child: Column(
                          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            if (!isMe)
                              Text(
                                '${sender['prenom']} ${sender['nom']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: isMe ? const Color(0xFF24A500) : Colors.grey[200],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                message['message'],
                                style: TextStyle(
                                  color: isMe ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('HH:mm').format(timestamp),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 8),
                        CircleAvatar(
                          radius: 16,
                          backgroundImage: sender['photo_profil'] != null
                            ? NetworkImage('http://localhost:3000${sender['photo_profil']}')
                            : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: const Color(0xFF24A500),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 