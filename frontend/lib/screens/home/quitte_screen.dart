import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/models/user.dart';
import 'package:frontend/screens/home/home_screen.dart';
import 'package:frontend/main_screen.dart';
// TODO: Importer la page OffersPage si nécessaire
// import 'offers_page.dart';

class ExclusionVoyage extends StatefulWidget {
  final String? memberName;
  final int? memberId;
  final int tripId;

  const ExclusionVoyage({
    Key? key,
    this.memberName,
    this.memberId,
    required this.tripId,
  }) : super(key: key);

  @override
  State<ExclusionVoyage> createState() => _ExclusionVoyageState();
}

class _ExclusionVoyageState extends State<ExclusionVoyage> {
  bool _isLoading = false;

  Future<void> _performExclusion() async {
    setState(() {
      _isLoading = true;
    });

    final url = widget.memberId != null
        ? 'http://localhost:3000/api/trips/${widget.tripId}/remove-member/${widget.memberId}'
        : 'http://localhost:3000/api/trips/${widget.tripId}/leave';

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'userId': int.parse(User.getUserId() ?? '0')}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.memberId != null ? 'Membre exclu avec succès!' : 'Voyage quitté avec succès!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        if (widget.memberId != null) {
          Navigator.pop(context, true);
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => MainScreen(initialIndex: 3)),
            (Route<dynamic> route) => false,
          );
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Échec de l\'opération.');
      }
    } catch (e) {
      print('Error performing exclusion/leaving: $e');
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

  @override
  Widget build(BuildContext context) {
    final bool isExcludingMember = widget.memberId != null;
    final String confirmationText = isExcludingMember
        ? 'Vous voulez exclure ${widget.memberName} du voyage ?'
        : 'Vous voulez vous déconnecter ?';

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.5),
      body: Center(
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            'Confirmation',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(confirmationText),
          actions: [
            TextButton(
              onPressed: _isLoading ? null : () {
                Navigator.of(context).pop();
              },
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: _isLoading ? null : _performExclusion,
              style: ElevatedButton.styleFrom(
                backgroundColor: isExcludingMember ? Colors.red : null,
              ),
              child: _isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text(isExcludingMember ? 'Exclure' : 'Déconnexion'),
            ),
          ],
        ),
      ),
    );
  }
}
