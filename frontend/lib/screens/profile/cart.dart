import 'package:flutter/material.dart';



class FifaCardApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      
      ),
      
      body: Center(
        child: SizedBox(
          width: 300,
          height: 450,
          child: FifaPlayerCard(),
        ),
      ),
    );
  }
}

class FifaPlayerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const goldLight = Color.fromARGB(255, 36, 167, 0);
    const goldDark = Color.fromARGB(255, 14, 63, 0);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [goldLight, goldDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white.withOpacity(0.8), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 15,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 70, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Note + image
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '88',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [Shadow(blurRadius: 4, color: Colors.black38)],
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    'images/home2.png',
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),

            // Nom
            Text(
              'RONALDO',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: Colors.white,
                shadows: [Shadow(blurRadius: 3, color: Colors.black38)],
              ),
            ),

            SizedBox(height: 4),

            // Sous-titre
            Text(
              "Légende du terrain",
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Colors.white70,
              ),
            ),

            Divider(color: Colors.white38, height: 30),

            // Statistiques
            StatLine(label: "Voyage en groupe", value: 87),
            StatLine(label: "Adaptabilité", value: 90),
            StatLine(label: "Orientation", value: 78),
            StatLine(label: "Aventure", value: 92),
          ],
        ),
      ),
    );
  }
}

class StatLine extends StatelessWidget {
  final String label;
  final int value;

  const StatLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
          Text(
            "$value",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}