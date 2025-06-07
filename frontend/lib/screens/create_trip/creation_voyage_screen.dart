import 'package:flutter/material.dart';
import 'package:frontend/screens/create_trip/infos_voyage_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/models/user.dart';

class CreationVoyagePage extends StatefulWidget {
  const CreationVoyagePage({super.key});

  @override
  _CreationVoyagePageState createState() => _CreationVoyagePageState();
}

class _CreationVoyagePageState extends State<CreationVoyagePage> {
  final _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> activities = [];
  List<String> selectedActivities = [];
  final TextEditingController budgetController = TextEditingController();
  final TextEditingController capacityController = TextEditingController();
  String? depart;
  String? destination;
  List<Map<String, dynamic>> cities = [];
  bool isLoading = true;
  bool isLoadingActivities = true;

  String? activityError;
  String? capacityError;

  Map<String, dynamic> formData = {};

  @override
  void initState() {
    super.initState();
    _fetchCities();
    _fetchActivities();
  }

  Future<void> _fetchActivities() async {
    try {
      print('Fetching activities...');
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/data/activities'),
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('Parsed activities data: $data');
        
        setState(() {
          activities = data.map((activity) => {
            'id': activity['id_activity'],
            'name': activity['nom_activity'],
          }).toList();
          print('Mapped activities: $activities');
          isLoadingActivities = false;
        });
      } else {
        print('Error response: ${response.body}');
        setState(() {
          isLoadingActivities = false;
        });
      }
    } catch (e) {
      print('Error fetching activities: $e');
      setState(() {
        isLoadingActivities = false;
      });
    }
  }

  Future<void> _fetchCities() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/data/villes'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          cities = data.map((city) => {
            'id': city['id_ville'],
            'name': city['nom_ville'],
          }).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching cities: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (selectedActivities.isEmpty) {
        setState(() {
          activityError = 'Veuillez sélectionner au moins une activité';
        });
        return;
      }

      formData = {
        'id_voyageur': int.parse(User.getUserId() ?? '0'),
        'activites': selectedActivities,
        'budget': budgetController.text,
        'capacite': capacityController.text,
        'ville_depart': depart,
        'ville_arrivee': destination,
      };

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => InfosVoyagePage(formData: formData),
        ),
      );
    }
  }

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
            children: [
              Expanded(
                child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                SizedBox(height: 30),
              Text('Activités', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              SizedBox(height: 16),
                      if (isLoadingActivities)
                        Center(child: CircularProgressIndicator())
                      else if (activities.isEmpty)
                        Center(child: Text('Aucune activité disponible'))
                      else
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: activities.map((activity) {
                            print('Building chip for activity: ${activity['name']}');
                            bool selected = selectedActivities.contains(activity['id'].toString());
                  return ChoiceChip(
                              label: Text(activity['name'], style: TextStyle(fontSize: 13)),
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
                                    selectedActivities.remove(activity['id'].toString());
                        } else {
                                    selectedActivities.add(activity['id'].toString());
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
                      Text('Capacité', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: capacityController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: "Nombre de participants maximum",
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Veuillez entrer une capacité';
                          }
                          final parsed = int.tryParse(value.trim());
                          if (parsed == null) {
                            return 'Veuillez entrer un nombre valide';
                          }
                          if (parsed <= 0) {
                            return 'La capacité doit être supérieure à 0';
                          }
                          if (parsed > 50) {
                            return 'La capacité ne peut pas dépasser 50';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              Text('Départ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: depart,
                        hint: Text('Sélectionner votre ville'),
                        items: isLoading 
                          ? [DropdownMenuItem(value: 'loading', child: Text('Chargement...'))]
                          : cities.map((city) => DropdownMenuItem(
                              value: city['id'].toString(),
                              child: Text(city['name']),
                            )).toList(),
                        onChanged: isLoading ? null : (value) => setState(() => depart = value),
                decoration: InputDecoration(border: OutlineInputBorder()),
                validator: (value) =>
                    value == null ? 'Veuillez choisir une ville de départ' : null,
              ),
              SizedBox(height: 24),
              Text('Destination', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: destination,
                        hint: Text('Sélectionner votre ville'),
                        items: isLoading 
                          ? [DropdownMenuItem(value: 'loading', child: Text('Chargement...'))]
                          : cities.map((city) => DropdownMenuItem(
                              value: city['id'].toString(),
                              child: Text(city['name']),
                            )).toList(),
                        onChanged: isLoading ? null : (value) => setState(() => destination = value),
                decoration: InputDecoration(border: OutlineInputBorder()),
                validator: (value) =>
                    value == null ? 'Veuillez choisir une destination' : null,
              ),
                      SizedBox(height: 24), // Add padding at the bottom of the scrollable area
                    ],
                  ),
                ),
              ),
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
                  onPressed: _submitForm,
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
