import 'package:flutter/material.dart';
import 'package:frontend/screens/create_trip/infos_voyage_screen.dart';


// Page de création du voyage
class CreationVoyagePage extends StatefulWidget {
  @override
  _CreationVoyagePageState createState() => _CreationVoyagePageState();
}

class _CreationVoyagePageState extends State<CreationVoyagePage> {
  List<String> activities = ['Nager', 'Montagne', 'Tour', 'Quad', 'Jouer','Nager', 'Montagne1', 'Tour1', 'Quad1', 'Jouer1'];
  List<String> selectedActivities = [];
  final TextEditingController budgetController = TextEditingController(text: "3800dh");
  String? depart;
  String? destination;

  // Map pour stocker les données
  Map<String, dynamic> formData = {};
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: BackButton(color: Colors.blue),
        title: Text(
          'Création de voyage',
          style: TextStyle(color: Colors.blue),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16),
            Text('Activités', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14) ),
            SizedBox(height: 16),
        
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: activities.map((activity) {
                bool selected = selectedActivities.contains(activity);
                return ChoiceChip(
                  label: Text(activity, style: TextStyle(fontSize: 13)),
                  selected: selected,
                  selectedColor: Colors.blue,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : Colors.blue,
                  ),
                  backgroundColor: Colors.white,
                  side: BorderSide(color: Colors.blue),
                  onSelected: (_) {
                    setState(() {
                      if (selected) {
                        selectedActivities.remove(activity);
                      } else {
                        selectedActivities.add(activity);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            Text('Budget', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14) ),
            SizedBox(height: 16),
            TextFormField(
              controller: budgetController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Budget en dh",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            Text('Départ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: depart,
              items: ['ville A', 'ville B']
                  .map((city) => DropdownMenuItem(value: city, child: Text(city)))
                  .toList(),
              onChanged: (value) => setState(() => depart = value),
              decoration: InputDecoration(border: OutlineInputBorder()),
            ),
            SizedBox(height: 16),
            Text('Destination', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: destination,
              items: ['ville A', 'ville B']
                  .map((city) => DropdownMenuItem(value: city, child: Text(city)))
                  .toList(),
              onChanged: (value) => setState(() => destination = value),
              decoration: InputDecoration(border: OutlineInputBorder()),
            ),
            Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF24A500),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  // Stocker les données dans la Map
                  formData = {
                    'activites': selectedActivities,
                    'budget': budgetController.text,
                    'depart': depart,
                    'destination': destination,
                  };

  Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => InfosVoyagePage(formData: formData),
  ),
);

                
                
                },
                child: const Text(
                  'Suivant',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    
  }
  
}
