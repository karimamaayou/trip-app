import 'package:flutter/material.dart';
import 'package:frontend/main_screen.dart';
import 'package:frontend/screens/follow_trip/suivie_screen.dart';
import 'package:frontend/screens/home/trip_details.dart';
import 'package:frontend/screens/home/trip_details_historique.dart';
import 'package:frontend/services/api_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/models/user.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final int tripId;
  const ChatScreen({super.key, required this.tripId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  Map<String, dynamic>? tripData;
  bool isLoading = true;
  final List<Map<String, dynamic>> messages = [];
  final TextEditingController _messageController = TextEditingController();
  IO.Socket? socket;
  final currentUserId = int.parse(User.getUserId() ?? '0');
  final scrollController = ScrollController();
  bool _isDisposed = false;
  bool _isScrolling = false;
  bool _isSocketConnected = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fetchTripDetails();
    _setupSocket();
    _fetchMessages();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _reconnectSocket();
    } else if (state == AppLifecycleState.paused) {
      _disconnectSocket();
    }
  }

  void _reconnectSocket() {
    if (_isDisposed || !mounted) return;
    if (socket != null && !_isSocketConnected) {
      _setupSocket();
    }
  }

  void _disconnectSocket() {
    if (socket != null) {
      socket!.disconnect();
      _isSocketConnected = false;
    }
  }

  void _scrollToBottom() {
    if (_isDisposed || _isScrolling) return;
    
    // Use Future.microtask to ensure we're not in the middle of a build
    Future.microtask(() {
      if (!_isDisposed && mounted && scrollController.hasClients) {
        try {
          _isScrolling = true;
          scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          ).then((_) {
            _isScrolling = false;
          }).catchError((error) {
            print('Error scrolling: $error');
            _isScrolling = false;
          });
        } catch (e) {
          print('Error in scrollToBottom: $e');
          _isScrolling = false;
        }
      }
    });
  }

  void _setupSocket() {
    if (_isDisposed || !mounted) return;

    try {
      socket?.disconnect();
      socket = IO.io(Environment.apiHost, <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
        'reconnection': true,
        'reconnectionAttempts': 5,
        'reconnectionDelay': 1000,
      });

      socket!.connect();
      
      socket!.onConnect((_) {
        if (_isDisposed || !mounted) return;
        print('Connected to socket server');
        _isSocketConnected = true;
        socket!.emit('join_trip', widget.tripId);
      });

      socket!.onDisconnect((_) {
        if (_isDisposed || !mounted) return;
        print('Disconnected from socket server');
        _isSocketConnected = false;
      });

      socket!.on('new_message', (data) {
        if (_isDisposed || !mounted) return;
        
        setState(() {
          messages.insert(0, data);
        });
        
        Future.delayed(const Duration(milliseconds: 100), () {
          if (!_isDisposed && mounted) {
            _scrollToBottom();
          }
        });
      });

      socket!.on('error', (error) {
        if (_isDisposed || !mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error'), backgroundColor: Colors.red),
        );
      });
    } catch (e) {
      print('Error setting up socket: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error connecting to chat server'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _sendMessage() {
    if (_isDisposed || !mounted || socket == null || !_isSocketConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot send message: Not connected to chat server'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_messageController.text.trim().isEmpty) return;

    final message = _messageController.text.trim();
    _messageController.clear();

    try {
      socket!.emit('send_message', {
        'tripId': widget.tripId,
        'userId': currentUserId,
        'message': message,
      });
      
      Future.delayed(const Duration(milliseconds: 100), () {
        if (!_isDisposed && mounted) {
          _scrollToBottom();
        }
      });
    } catch (e) {
      print('Error sending message: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error sending message'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _fetchMessages() async {
    if (_isDisposed) return;
    
    try {
      final response = await http.get(
        Uri.parse('${Environment.apiHost}/api/trips/${widget.tripId}/messages'),
      );

      if (_isDisposed) return;

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (!mounted) return;
        
        setState(() {
          messages.clear();
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
        
        // Add a small delay to ensure messages are rendered before scrolling
        Future.delayed(const Duration(milliseconds: 100), () {
          if (!_isDisposed && mounted) {
            _scrollToBottom();
          }
        });
      }
    } catch (e) {
      if (_isDisposed) return;
      print('Error fetching messages: $e');
    }
  }

  Future<void> _fetchTripDetails() async {
    try {
      final response = await http.get(
        Uri.parse('${Environment.apiHost}/api/trips/details/${widget.tripId}'),
      );

      if (response.statusCode == 200) {
        setState(() {
          tripData = json.decode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching trip details: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _disconnectSocket();
    socket?.dispose();
    socket = null;
    _messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || tripData == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF2B54A4)),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => MainScreen(initialIndex: 3),
                ),
                (Route<dynamic> route) => false,
              );
            },
          ),
          title: const Text("Chat"),
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
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => MainScreen(initialIndex: 3),
              ),
              (Route<dynamic> route) => false,
            );
          },
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: imageUrl != null 
                ? NetworkImage('${Environment.apiHost}$imageUrl')
                : const AssetImage('assets/default_trip.jpg') as ImageProvider,
              radius: 16,
            ),
            const SizedBox(width: 8),
            Text(trip['titre']),
            const Spacer(),
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
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              reverse: true, // This makes the list start from bottom
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
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
                            ? NetworkImage('${Environment.apiHost}${sender['photo_profil']}')
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
                            ? NetworkImage('${Environment.apiHost}${sender['photo_profil']}')
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
