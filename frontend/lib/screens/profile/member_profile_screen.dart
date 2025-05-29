import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/models/user.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/screens/follow_trip/exclusion_screen.dart';
import 'package:frontend/screens/home/quitte_screen.dart';

class MemberProfileScreen extends StatefulWidget {
  final int memberId;
  final String memberName;
  final String memberPhoto;
  final String? currentUserRole;
  final int tripId;

  const MemberProfileScreen({
    Key? key,
    required this.memberId,
    required this.memberName,
    required this.memberPhoto,
    this.currentUserRole,
    required this.tripId,
  }) : super(key: key);

  @override
  _MemberProfileScreenState createState() => _MemberProfileScreenState();
}

class _MemberProfileScreenState extends State<MemberProfileScreen> {
  bool isLoading = true;
  String friendshipStatus = 'not_friend'; // 'not_friend', 'friend', 'pending', 'invitation_sent'
  Map<String, dynamic>? memberInfo;
  DateTime? _loadingStartTime;

  @override
  void initState() {
    super.initState();
    // Immediately return if trying to view own profile
    if (widget.memberId == User.getUserId()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vous ne pouvez pas voir votre propre profil ici'),
            backgroundColor: Colors.red,
          ),
        );
      });
      return;
    }
    _fetchMemberInfo();
  }

  Future<void> _checkFriendshipStatus() async {
    try {
      final response = await http.get(
        Uri.parse('${Environment.apiHost}/api/friends/status/${User.getUserId()}/${widget.memberId}'),
        headers: {
          'Authorization': 'Bearer ${User.token}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          friendshipStatus = data['status'];
        });
      }
    } catch (e) {
      print('Error checking friendship status: $e');
    }
  }

  Future<void> _sendFriendRequest() async {
    try {
      final currentUserId = User.getUserId();
      if (currentUserId == null) {
        throw Exception('User ID not found');
      }

      final response = await http.post(
        Uri.parse('${Environment.apiHost}/api/friends/request/${widget.memberId}?currentUserId=$currentUserId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          friendshipStatus = 'invitation_sent';
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Demande d\'ami envoyée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to send friend request');
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

  Future<void> _fetchMemberInfo() async {
    setState(() {
      isLoading = true;
      _loadingStartTime = DateTime.now();
    });

    try {
      // Get member's detailed info
      final response = await http.get(
        Uri.parse('${Environment.apiHost}/api/users/${widget.memberId}'),
        headers: {
          'Authorization': 'Bearer ${User.token}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Check friendship status
        await _checkFriendshipStatus();

        // Calculate how long to wait to ensure minimum display time
        final elapsedTime = DateTime.now().difference(_loadingStartTime!).inMilliseconds;
        final minimumDisplayTime = 500;
        if (elapsedTime < minimumDisplayTime) {
          await Future.delayed(Duration(milliseconds: minimumDisplayTime - elapsedTime));
        }

        setState(() {
          memberInfo = data;
          isLoading = false;
          _loadingStartTime = null;
        });
      } else {
        throw Exception('Failed to load member info');
      }
    } catch (e) {
      print('Error fetching member info: $e');
      final elapsedTime = DateTime.now().difference(_loadingStartTime!).inMilliseconds;
      final minimumDisplayTime = 500;
      if (elapsedTime < minimumDisplayTime) {
        await Future.delayed(Duration(milliseconds: minimumDisplayTime - elapsedTime));
      }
      
      setState(() {
        isLoading = false;
        _loadingStartTime = null;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du chargement du profil: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildFriendButton() {
    switch (friendshipStatus) {
      case 'friend':
        return ElevatedButton(
          onPressed: null, // Disabled button
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Amis',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
      );
      case 'invitation_sent':
        return ElevatedButton(
          onPressed: null, // Disabled button
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Invitation envoyée',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
      case 'pending':
        return ElevatedButton(
          onPressed: null, // Disabled button
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
          ),
          ),
          child: const Text(
            'En attente',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
      default: // not_friend
        return ElevatedButton(
          onPressed: _sendFriendRequest,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0054A5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Ajouter comme ami',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Prevent building if it's the user's own profile
    if (widget.memberId == User.getUserId()) {
      return const SizedBox.shrink();
    }

    // Debug prints to check conditions
    print('MemberProfileScreen: Member ID = ${widget.memberId}');
    print('MemberProfileScreen: Current User ID = ${User.getUserId()}');
    print('MemberProfileScreen: Current User Role = ${widget.currentUserRole}');
    print('MemberProfileScreen: isOrganizer = ${widget.currentUserRole == 'organisateur'}');
    print('MemberProfileScreen: isNotCurrentUser = ${widget.memberId.toString() != User.getUserId()}');
    print('MemberProfileScreen: Show Exclure button = ${widget.currentUserRole == 'organisateur' && widget.memberId.toString() != User.getUserId()}');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0054A5)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Profil",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0054A5),
          ),
        ),
      ),
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Chargement du profil...',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Profile Picture
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: widget.memberPhoto.isNotEmpty
                        ? NetworkImage('${Environment.apiHost}${widget.memberPhoto}')
                        : const AssetImage('assets/default_user.png') as ImageProvider,
                  ),
                  const SizedBox(height: 16),
                  // Name
                  Text(
                    widget.memberName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2B54A4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Email
                  if (memberInfo?['email'] != null)
                    Text(
                      memberInfo!['email'],
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  const SizedBox(height: 24),
                  // Friend Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: _buildFriendButton(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Add Exclure button if current user is organizer and not viewing their own profile
                  if (widget.currentUserRole == 'organisateur' && widget.memberId.toString() != User.getUserId())
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: () async {
                            // TODO: Implement exclusion logic
                            print('Exclure memberId: ${widget.memberId}, tripId: ${widget.tripId}');
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ExclusionPage(
                                  memberId: widget.memberId,
                                  tripId: widget.tripId,
                                  memberName: widget.memberName,
                                ),
                              ),
                            );
                            // If result is true from ExclusionPage, pop MemberProfileScreen with true
                            if (result == true) {
                              print('ExclusionPage returned true. Popping MemberProfileScreen with true.');
                              // Use addPostFrameCallback to ensure the pop happens after the current frame
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                Navigator.pop(context, true);
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            'Exclure',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  // Additional Info Section
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Informations',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2B54A4),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Member since
                        if (memberInfo?['date_inscription'] != null)
                          _buildInfoRow(
                            Icons.calendar_today,
                            'Membre depuis',
                            DateTime.parse(memberInfo!['date_inscription']).year.toString(),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF2B54A4),
          ),
        ),
      ],
    );
  }
} 