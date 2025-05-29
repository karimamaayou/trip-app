import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Import dart:convert for json handling
import 'package:frontend/services/api_service.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/screens/auth/login_screen.dart';
import 'package:frontend/main_screen.dart'; // Import MainScreen

class DeleteTripConfirmationScreen extends StatefulWidget {
  final int tripId;
  final String tripTitle;

  const DeleteTripConfirmationScreen({super.key, required this.tripId, required this.tripTitle});

  @override
  State<DeleteTripConfirmationScreen> createState() => _DeleteTripConfirmationScreenState();
}

class _DeleteTripConfirmationScreenState extends State<DeleteTripConfirmationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showDeleteConfirmationDialog(context);
    });
  }

  Future<void> _deleteTrip() async {
    try {
      final response = await http.delete(
        Uri.parse('${Environment.apiHost}/api/trips/${widget.tripId}'),
        headers: {
           'Authorization': 'Bearer ${User.token}',
        } // Assuming trip deletion requires authentication
      );

      if (response.statusCode == 200) {
        // Trip deleted successfully
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Voyage supprimé avec succès.'), backgroundColor: Colors.green),
        );
        
        // First pop the dialog
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop(); // Close dialog
        }
        
        // Then pop the confirmation screen
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop(); // Pop DeleteTripConfirmationScreen
        }
        
        // Finally navigate to MainScreen
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => MainScreen(initialIndex: 3)),
            (route) => false, // Remove all previous routes
          );
        });
      } else {
        // Failed to delete trip
        final errorBody = json.decode(response.body);
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Échec de la suppression du voyage: ${errorBody['message'] ?? 'Erreur inconnue'}'), backgroundColor: Colors.red),
        );
        Navigator.of(context).pop(); // Close dialog on error
      }
    } catch (e) {
      print('Error deleting trip: $e');
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Une erreur est survenue lors de la suppression: $e'), backgroundColor: Colors.red),
      );
      Navigator.of(context).pop(); // Close dialog on exception
    }
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.grey.withOpacity(0.5),
      builder: (context) {
        return Center(
          child: Material(
            type: MaterialType.transparency,
            child: Container(
              width: 320, // Matching width
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Vous voulez supprimer le voyage \"${widget.tripTitle}\" ?", // Confirmation text with trip title
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20), // Spacing
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _deleteTrip, // Call the delete trip method
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE45517), // Matching delete/exclude color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Supprimer', // Delete button text
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10), // Spacing
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        // Close dialog and return to previous screen (TripDetailsHistorique)
                        Navigator.of(context).pop(); // Close dialog
                         Navigator.of(context).pop(); // Pop the confirmation screen
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFBFB5B5), // Matching cancel color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Annuler', // Cancel button text
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
    ).then((value) { // Ensure we pop the confirmation screen even if dialog is dismissed
       Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    // This screen is primarily for showing the dialog,
    // so return an empty container or similar.
    return const Scaffold(
       backgroundColor: Colors.transparent,
       body: SizedBox.shrink(),
    );
  }
} 