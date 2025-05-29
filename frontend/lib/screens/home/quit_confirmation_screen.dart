import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/models/user.dart';
import 'package:frontend/main_screen.dart';

class QuitConfirmationScreen extends StatefulWidget {
  final int tripId;

  const QuitConfirmationScreen({super.key, required this.tripId});

  @override
  State<QuitConfirmationScreen> createState() => _QuitConfirmationScreenState();
}

class _QuitConfirmationScreenState extends State<QuitConfirmationScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showQuitDialog(context);
    });
  }

  Future<void> _quitTrip() async {
    setState(() {
      _isLoading = true;
    });

    final userId = int.parse(User.getUserId() ?? '0');
    final url = 'http://localhost:3000/api/trips/${widget.tripId}/leave';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'userId': userId}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vous avez quitté le voyage avec succès!'),
            backgroundColor: Colors.green,
          ),
        );
        // Navigate to MainScreen with suivie tab (index 3)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainScreen(initialIndex: 3)),
        );
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Échec de quitter le voyage.');
      }
    } catch (e) {
      print('Error quitting trip: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showQuitDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) {
        return Center(
          child: Material(
            type: MaterialType.transparency,
            child: Container(
              width: 320,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Voulez-vous quitter ce voyage ?",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _quitTrip,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE45517),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Quitter',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : () {
                        Navigator.pop(context); // Close the dialog
                        Navigator.pop(context); // Pop the QuitConfirmationScreen
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFBFB5B5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Annuler',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
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
    return const Scaffold(
      backgroundColor: Colors.transparent,
      body: SizedBox.shrink(),
    );
  }
} 