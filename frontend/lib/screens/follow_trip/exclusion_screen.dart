import 'package:flutter/material.dart';
import 'package:frontend/services/api_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/models/user.dart'; // Import User model for getUserId
import 'package:frontend/screens/home/trip_details_historique.dart'; // Import TripDetailsHistorique

class ExclusionPage extends StatefulWidget {
  final String memberName;
  final int memberId; // Add memberId
  final int tripId; // Add tripId

  const ExclusionPage({super.key, required this.memberName, required this.memberId, required this.tripId}); // Update constructor

  @override
  State<ExclusionPage> createState() => _ExclusionPageState();
}

class _ExclusionPageState extends State<ExclusionPage> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showExclusionDialog(context);
    });
  }

  Future<void> _excludeMember() async {
    setState(() {
      _isLoading = true;
    });

    final url = '${Environment.apiHost}/api/trips/${widget.tripId}/remove-member/${widget.memberId}';

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'userId': int.parse(User.getUserId() ?? '0')}), // Send current user ID for auth
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Membre exclu avec succès!'),
            backgroundColor: Colors.green,
          ),
        );
        // Navigate back to TripDetailsHistorique after successful exclusion
        // Use pushAndRemoveUntil to clear the stack up to TripDetailsHistorique
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => TripDetailsHistorique(tripId: widget.tripId)),
          (Route<dynamic> route) => route.settings.name == '/tripDetailsHistorique' || route.isFirst, // Keep only TripDetailsHistorique and root
        );

      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Échec de l\'exclusion du membre.');
      }
    } catch (e) {
      print('Error excluding member: $e');
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

  void _showExclusionDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Make it non-dismissible when loading
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
                  Text(
                    "Vous voulez exclure ${widget.memberName} ?",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _excludeMember, // Call _excludeMember
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE45517),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text(
                              'Exclure',
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
                      onPressed: _isLoading ? null : () {
                        // Close the dialog and pop the ExclusionPage screen to return
                        Navigator.pop(context); // Close the dialog
                        Navigator.pop(context); // Pop the ExclusionPage screen
                      }, // Pop the dialog and the screen on Annuler
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
    // This screen is primarily a transparent overlay for the dialog
    return const Scaffold(
      backgroundColor: Colors.transparent, // Make background transparent
      body: SizedBox.shrink(), // Use SizedBox.shrink instead of expand
    );
  }
}
