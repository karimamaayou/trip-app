import 'package:flutter/material.dart';
import 'package:frontend/main_screen.dart';
import 'package:frontend/screens/auth/login_screen.dart';
import 'package:frontend/screens/profile/TripsEffectues.dart';
import 'package:frontend/screens/profile/amie_screen.dart';
import 'package:frontend/screens/profile/editerProfil_screen.dart';
import 'package:frontend/screens/home/home_screen.dart';
import 'package:frontend/screens/profile/cart.dart';

const Color primaryColor = Color(0xFF0054A5);

class ProfileVoyageurScreen extends StatefulWidget {
  @override
  _CustomProfileScreenState createState() => _CustomProfileScreenState();
}

class _CustomProfileScreenState extends State<ProfileVoyageurScreen> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainScreen(initialIndex: 0)),
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 8),

              // Header
              Padding(
                padding: const EdgeInsets.only(top: 24, left: 12, right: 12, bottom: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: primaryColor),
                      onPressed: () {
                      
                      },
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      "Profil Voyageur",
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

              // Avatar + nom centré (statique)
              Column(
                children: [
                  const CircleAvatar(
                    radius: 45,
                    backgroundImage: AssetImage('assets/profile.jpg'),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Nom Prénom',
                    style: TextStyle(
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
                      icon: Icons.group, // Icône changée
                      title: "Amis",
                      textColor: const Color.fromARGB(255, 86, 86, 86),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AmiePage()),
                        );
                      },
                    ),
                    const SizedBox(height: 18),
                    ProfileTile(
  icon: Icons.star_border, // Icône modifiée
  title: "Évaluations",
  textColor: const Color.fromARGB(255, 86, 86, 86),
  onTap: () {
  
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FifaCardApp()),
    );
  },
),

                    const SizedBox(height: 18),
                    ProfileTile(
                      icon: Icons.history, // Icône changée
                      title: "Trips effectués",
                      textColor: const Color.fromARGB(255, 86, 86, 86),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => TripsEffectuesPage()),
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
