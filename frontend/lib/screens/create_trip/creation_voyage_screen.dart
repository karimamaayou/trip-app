import 'package:flutter/material.dart';
import 'package:frontend/screens/create_trip/infos_voyage_screen.dart';

class CreationVoyagePage extends StatefulWidget {
  @override
  _CreationVoyagePageState createState() => _CreationVoyagePageState();
}

class _CreationVoyagePageState extends State<CreationVoyagePage> {
  final _formKey = GlobalKey<FormState>();
  List<String> activities = [
    'Nager', 'Montagne', 'Tour', 'Quad', 'Jouer',
    'Nager', 'Montagne1', 'Tour1', 'Quad1', 'Jouer1'
  ];
  List<String> selectedActivities = [];
  final TextEditingController budgetController = TextEditingController();
  String? depart;
  String? destination;

  String? activityError;

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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                SizedBox(height: 30),
              Text('Activités', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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
                        activityError = null;
                      });
                    },
                  );
                }).toList(),
              ),
              if (activityError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    activityError!,
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              SizedBox(height: 24),
              Text('Budget', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              SizedBox(height: 16),
              TextFormField(
                controller: budgetController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "Budget en dh",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez entrer un budget';
                  }
                  final parsed = num.tryParse(value.trim());
                  if (parsed == null) {
                    return 'Veuillez entrer un nombre valide';
                  }
                  if (parsed <= 0) {
                    return 'Le budget doit être supérieur à 0';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              Text('Départ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: depart,
                items: ['ville A', 'ville B']
                    .map((city) => DropdownMenuItem(value: city, child: Text(city)))
                    .toList(),
                onChanged: (value) => setState(() => depart = value),
                decoration: InputDecoration(border: OutlineInputBorder()),
                validator: (value) =>
                    value == null ? 'Veuillez choisir une ville de départ' : null,
              ),
              SizedBox(height: 24),
              Text('Destination', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: destination,
                items: ['ville A', 'ville B']
                    .map((city) => DropdownMenuItem(value: city, child: Text(city)))
                    .toList(),
                onChanged: (value) => setState(() => destination = value),
                decoration: InputDecoration(border: OutlineInputBorder()),
                validator: (value) =>
                    value == null ? 'Veuillez choisir une destination' : null,
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
                    bool isValid = _formKey.currentState!.validate();

                    if (selectedActivities.isEmpty) {
                      setState(() {
                        activityError = "Veuillez sélectionner au moins une activité";
                      });
                      isValid = false;
                    }

                    if (isValid) {
                      formData = {
                        'activites': selectedActivities,
                        'budget': budgetController.text.trim(),
                        'depart': depart,
                        'destination': destination,
                      };

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InfosVoyagePage(formData: formData),
                        ),
                      );
                    }
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
      ),
    );
  }
}
