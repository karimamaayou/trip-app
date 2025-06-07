import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/models/user.dart';
import 'package:frontend/services/api_service.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<dynamic> notifications = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    try {
      print('Fetching notifications...'); // Debug log
      final response = await http.get(
        Uri.parse('${Environment.apiHost}/api/friends/notifications/${User.getUserId()}'),
      );

      print('Fetch response status: ${response.statusCode}'); // Debug log
      
      if (response.statusCode == 200) {
        final List<dynamic> fetchedNotifications = json.decode(response.body);
        print('Fetched ${fetchedNotifications.length} notifications'); // Debug log
        
        setState(() {
          notifications = fetchedNotifications;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load notifications');
      }
    } catch (e) {
      print('Error fetching notifications: $e'); // Debug log
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _handleTripInvitation(int notificationId, String action) async {
    try {
      print('Handling trip invitation: notificationId=$notificationId, action=$action');
      
      final response = await http.post(
        Uri.parse('${Environment.apiHost}/api/trips/notifications/$notificationId/respond?userId=${User.getUserId()}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'action': action}),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        if (responseData['deleted'] == true) {
          // Remove the notification from the local list
          setState(() {
            notifications.removeWhere((n) => n['id_notification'] == notificationId);
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(action == 'accept' 
                ? 'Invitation au voyage acceptée' 
                : 'Invitation au voyage refusée'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          // If notification wasn't deleted by the backend, try to delete it directly
          await _deleteNotification(notificationId);
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to handle trip invitation');
      }
    } catch (e) {
      print('Error handling trip invitation: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteNotification(int notificationId) async {
    try {
      final response = await http.delete(
        Uri.parse('${Environment.apiHost}/api/trips/notifications/$notificationId?userId=${User.getUserId()}'),
      );

      if (response.statusCode == 200) {
        setState(() {
          notifications.removeWhere((n) => n['id_notification'] == notificationId);
        });
      } else {
        print('Failed to delete notification: ${response.body}');
      }
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }

  Future<void> _handleFriendRequest(int notificationId, String action) async {
    try {
      print('Handling friend request: notificationId=$notificationId, action=$action');
      
      final response = await http.post(
        Uri.parse('${Environment.apiHost}/api/friends/request/$notificationId/respond?currentUserId=${User.getUserId()}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'action': action}),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        // Try to delete the notification directly
        await _deleteNotification(notificationId);
        
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
        throw Exception(errorData['message'] ?? 'Failed to handle friend request');
      }
    } catch (e) {
      print('Error handling friend request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final date = DateTime.parse(notification['date_notification']);
    final formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(date);
    final bool isUnread = notification['lue'] == 0;
    final bool hasAction = notification['has_action'] == 1;
    final String type = notification['type'];

    IconData getNotificationIcon() {
      switch (type) {
        case 'inv_ami':
          return Icons.person_add;
        case 'inv_voyage':
          return Icons.card_travel;
        default:
          return Icons.info_outline;
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: isUnread ? 2 : 1,
      color: isUnread ? Colors.blue[50] : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  getNotificationIcon(),
                  color: const Color(0xFF0054A5),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    notification['contenu'],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formattedDate,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                if (type == 'inv_voyage' || (type == 'inv_ami' && hasAction))
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 32,
                        child: ElevatedButton.icon(
                          onPressed: () => type == 'inv_ami' 
                            ? _handleFriendRequest(notification['id_notification'], 'accept')
                            : _handleTripInvitation(notification['id_notification'], 'accept'),
                          icon: const Icon(Icons.check, color: Colors.white, size: 16),
                          label: const Text('Accepter', style: TextStyle(fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            minimumSize: const Size(0, 0),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      SizedBox(
                        height: 32,
                        child: ElevatedButton.icon(
                          onPressed: () => type == 'inv_ami'
                            ? _handleFriendRequest(notification['id_notification'], 'reject')
                            : _handleTripInvitation(notification['id_notification'], 'reject'),
                          icon: const Icon(Icons.close, color: Colors.white, size: 16),
                          label: const Text('Refuser', style: TextStyle(fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            minimumSize: const Size(0, 0),
                          ),
                        ),
                      ),
                    ],
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Notifications',
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
              : notifications.isEmpty
                  ? const Center(
                      child: Text(
                        'Aucune notification',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchNotifications,
                      child: ListView.builder(
                        itemCount: notifications.length,
                        itemBuilder: (context, index) {
                          return _buildNotificationCard(notifications[index]);
                        },
                      ),
                    ),
    );
  }
} 