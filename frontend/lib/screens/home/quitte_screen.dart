import 'package:flutter/material.dart';
// TODO: Importer la page OffersPage si nécessaire
// import 'offers_page.dart';

class ExclusionVoyage extends StatefulWidget {
  final String memberName;
  final int tripId;

  const ExclusionVoyage({
    super.key,
    required this.memberName,
    required this.tripId,
  });

  @override
  State<ExclusionVoyage> createState() => _ExclusionPageState();
}

class _ExclusionPageState extends State<ExclusionVoyage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showExclusionDialog(context);
    });
  }

  void _showExclusionDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.grey.withOpacity(0.5),
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
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Ferme le dialog
                        Navigator.pop(context); // Quitte la page
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE45517),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Quitter',
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
                        Navigator.pop(context); // Ferme juste le dialog
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
      backgroundColor: Colors.white,
      body: SizedBox.expand(),
    );
  }
}
