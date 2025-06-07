
import 'package:flutter/material.dart';
import 'package:frontend/screens/auth/login_screen.dart';


class InfpConfirmationScreen extends StatelessWidget {
  const InfpConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[700], // Fond gris comme dans l'image
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.symmetric(horizontal: 30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                spreadRadius: 2,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                 backgroundColor:  Color(0xFF24A500),
                radius: 30,
                child: Icon(Icons.check, color: Colors.white, size: 30),
              ),
              const SizedBox(height: 16),
              const Text(
                "Demande reçue",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.normal,
                   color: Color(0xFF565656),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Vote de demande de rejoindre ete envoye",
              
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 400,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                     backgroundColor:  Color(0xFF24A500),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                      Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => LoginScreen(),
    ),
  );
                  },
                  child: const Text(
                    "Revenir",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
