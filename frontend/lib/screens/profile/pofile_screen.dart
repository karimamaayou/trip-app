import 'package:flutter/material.dart';
import 'package:frontend/main_screen.dart';
import 'package:frontend/screens/auth/login_screen.dart';
import 'package:frontend/screens/profile/editerProfil_screen.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/screens/home/home_screen.dart';
import 'package:frontend/screens/profile/friends_list_screen.dart';
import 'package:frontend/screens/profile/friend_invitations_screen.dart';
import 'package:frontend/screens/profile/change_password_screen.dart';
import 'package:frontend/screens/profile/logout_confirmation_screen.dart';

const Color primaryColor = Color(0xFF0054A5);

class CustomProfileScreen extends StatefulWidget {
  @override
  _CustomProfileScreenState createState() => _CustomProfileScreenState();
}

class _CustomProfileScreenState extends State<CustomProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MainScreen(initialIndex: 0)),
            );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 8),

              // Header
              Padding(
                padding: const EdgeInsets.only(
                    top: 24, left: 12, right: 12, bottom: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: primaryColor),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => MainScreen(initialIndex: 0)),
                        );
                      },
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      "Mon profile",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 43, 84, 164),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Avatar + nom centré (non cliquable)
              Column(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundImage: User.profilePicture != null && User.profilePicture!.isNotEmpty
                        ? NetworkImage('${Environment.apiHost}${User.profilePicture}')
                        : const AssetImage('assets/profile.jpg') as ImageProvider,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${User.prenom} ${User.nom}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 86, 86, 86),
                      fontSize: 18,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Options
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    ProfileTile(
                      icon: Icons.edit,
                      title: "Edit Profile",
                      textColor: const Color.fromARGB(255, 86, 86, 86),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProfileScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 18),
                    ProfileTile(
                      icon: Icons.lock_outline,
                      title: "Changer mot de passe",
                      textColor: const Color.fromARGB(255, 86, 86, 86),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ChangePasswordScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 18),
                    ProfileTile(
                      icon: Icons.people,
                      title: "Amis",
                      textColor: const Color.fromARGB(255, 86, 86, 86),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FriendsListScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 18),
                    ProfileTile(
                      icon: Icons.person_add,
                      title: "Demandes d'ami",
                      textColor: const Color.fromARGB(255, 86, 86, 86),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FriendInvitationsScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 18),
                    ProfileTile(
                      icon: Icons.logout,
                      title: "Logout",
                      textColor: const Color.fromARGB(255, 86, 86, 86),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LogoutConfirmationScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? textColor;

  const ProfileTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: primaryColor),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: textColor ?? Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
