import 'package:flutter/material.dart';
import 'package:frontend/screens/auth/login_screen.dart'; // Import LoginScreen for navigation

class LogoutConfirmationScreen extends StatefulWidget {
  const LogoutConfirmationScreen({super.key});

  @override
  State<LogoutConfirmationScreen> createState() => _LogoutConfirmationScreenState();
}

class _LogoutConfirmationScreenState extends State<LogoutConfirmationScreen> {
  @override
  void initState() {
    super.initState();
    // Show the dialog immediately after the screen is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showLogoutConfirmationDialog(context);
    });
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true, // Allow dismissing by tapping outside
      barrierColor: Colors.grey.withOpacity(0.5),
      builder: (context) {
        return Center(
          child: Material(
            type: MaterialType.transparency,
            child: Container(
              width: 300, // Adjust width as needed
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                   const Text(
                    "Vous voulez vous déconnecter ?",
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        // Perform logout action
                        Navigator.of(context).pop(); // Close the dialog
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                          (Route<dynamic> route) => false, // Clear navigation stack
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 228, 85, 23), // Using a distinct color for logout, similar to exclude
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Déconnexion', // Logout button text in French
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        // Close the dialog and navigate back to the previous screen (ProfileScreen)
                        Navigator.of(context).pop(); // Close the dialog
                        Navigator.of(context).pop(); // Navigate back to ProfileScreen
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFBFB5B5), // Annuler button color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Annuler', // Cancel button text in French
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // This screen is primarily for showing the dialog,
    // so the build method can return an empty container or similar.
    return const Scaffold(
      backgroundColor: Colors.transparent, // Make scaffold background transparent
      body: SizedBox.shrink(), // Use a shrinked SizedBox
    );
  }
} 