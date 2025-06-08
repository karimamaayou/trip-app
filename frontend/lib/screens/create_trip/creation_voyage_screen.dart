import 'package:flutter/material.dart';
import 'package:frontend/screens/create_trip/infos_voyage_screen.dart';
import 'package:frontend/screens/create_trip/point_depart.dart';
import 'package:frontend/services/api_service.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/models/user.dart';

// Importer l'écran de sélection de position (LocationPickerScreen est dans pion_depart.dart)

import 'package:latlong2/latlong.dart';
// LatLng n'est pas utilisé directement ici, mais l'import de pion_depart.dart le nécessite

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

  // Utiliser 'depart' pour stocker l'ID de la ville de départ sélectionnée dans la liste
  String? depart;
  String? destination; // La destination reste l'ID de la ville sélectionnée dans la liste


  List<Map<String, dynamic>> cities = [];
  bool isLoading = true; // Pour le chargement des villes
  bool isLoadingActivities = true; // Pour le chargement des activités

  String? activityError;
  // capacityError n'est plus nécessaire car la validation est dans le TextFormField

  // formData sera construit dans _submitForm et passé à LocationPickerScreen

  @override
  void initState() {
    super.initState();
    _fetchCities();
    _fetchActivities();
  }

  @override
  void dispose() {
    budgetController.dispose();
    capacityController.dispose();
    super.dispose();
  }

  Future<void> _fetchActivities() async {
    try {
      print('Fetching activities...');
      final response = await http.get(
        Uri.parse('${Environment.apiHost}/api/data/activities'),
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('Parsed activities data: $data');

        setState(() {
          activities =
              data
                  .map(
                    (activity) => {
                      'id': activity['id_activity'],
                      'name': activity['nom_activity'],
                    },
                  )
                  .toList();
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
        Uri.parse('${Environment.apiHost}/api/data/villes'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          cities =
              data
                  .map(
                    (city) => {
                      'id': city['id_ville'],
                      'name': city['nom_ville'],
                    },
                  )
                  .toList();
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


  // Modifier la fonction _submitForm pour valider le formulaire et construire formData et naviguer vers LocationPickerScreen
  void _submitForm() {
    // Valider les champs du formulaire (y compris maintenant le champ 'depart' de type Dropdown)
    if (_formKey.currentState!.validate()) {
       // Valider la sélection d'activité
       if (selectedActivities.isEmpty) {
          setState(() {
             activityError = 'Veuillez sélectionner au moins une activité';
          });
          return; // Arrêter si aucune activité sélectionnée
       }

       // Si le formulaire est valide et qu'au moins une activité est sélectionnée,
       // construire les données du formulaire collectées jusqu'à présent
       final formData = {
          'id_voyageur': int.parse(User.getUserId() ?? '0'),
          'activites': selectedActivities,
          'budget': budgetController.text,
          'capacite': capacityController.text,
          // Inclure l'ID de la ville de départ sélectionnée dans la liste
          'ville_depart': depart, // Utilise l'ID sélectionné dans le Dropdown
          'ville_arrivee': destination, // La destination reste l'ID de la ville de la liste
          // Les coordonnées lat/lng du départ seront ajoutées dans LocationPickerScreen
       };

       // Naviguer vers LocationPickerScreen, en passant les données actuelles du formulaire
       // La position initiale de la carte pourrait être basée sur la ville de départ sélectionnée,
       // ou juste une position par défaut (centre du Maroc).
       // Pour baser la position initiale sur la ville sélectionnée, on chercherait les coordonnées de cette ville.
       // Pour l'instant, utilisons une position par défaut pour simplifier le flux de navigation.
       Navigator.push(
         context,
         MaterialPageRoute(
           builder: (context) => LocationPickerScreen(
             initialPosition: const LatLng(31.7917, -7.0926), // Position par défaut de la carte
             // Le callback onLocationSelected n'est plus utilisé pour la navigation vers InfosVoyagePage
             // car LocationPickerScreen s'en charge maintenant.
             // Cependant, la classe LocationPickerScreen l'attend toujours si nous ne modifions pas sa signature.
             // Si on garde le callback, on peut le laisser vide ou le supprimer de LocationPickerScreen.
             // Si on supprime le callback de LocationPickerScreen, il faut l'enlever d'ici aussi.
             // Gardons-le pour l'instant pour minimiser les changements dans LocationPickerScreen.
             onLocationSelected: (position) {
                // Cette fonction n'aura plus pour rôle de naviguer vers InfosVoyagePage
                // La navigation se fait maintenant DANS LocationPickerScreen après avoir ajouté la position
                // au formData reçu.
             },
             formData: formData, // Passer les données actuelles du formulaire à LocationPickerScreen
           ),
         ),
       );

    } else {
       // Si la validation du formulaire échoue, les messages d'erreur seront affichés par les champs.
       // Vérifier quand même l'erreur d'activité si le bouton est cliqué sans sélection
        if (selectedActivities.isEmpty) {
          setState(() {
            activityError = 'Veuillez sélectionner au moins une activité';
          });
        }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: BackButton(color: Colors.blue),
        title: Text('Création de voyage', style: TextStyle(color: Colors.blue)),
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
                      Text(
                        'Activités',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 16),
                      if (isLoadingActivities)
                        Center(child: CircularProgressIndicator())
                      else if (activities.isEmpty)
                        Center(child: Text('Aucune activité disponible'))
                      else
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children:
                              activities.map((activity) {
                                print(
                                  'Building chip for activity: ${activity['name']}',
                                );
                                bool selected = selectedActivities.contains(
                                  activity['id'].toString(),
                                );
                                return ChoiceChip(
                                  label: Text(
                                    activity['name'],
                                    style: TextStyle(fontSize: 13),
                                  ),
                                  selected: selected,
                                  selectedColor: Colors.blue,
                                  labelStyle: TextStyle(
                                    color:
                                        selected ? Colors.white : Colors.blue,
                                  ),
                                  backgroundColor: Colors.white,
                                  side: BorderSide(color: Colors.blue),
                                  onSelected: (_) {
                                    setState(() {
                                      if (selected) {
                                        selectedActivities.remove(
                                          activity['id'].toString(),
                                        );
                                      } else {
                                        selectedActivities.add(
                                          activity['id'].toString(),
                                        );
                                      }
                                      activityError =
                                          null; // Clear error when selecting
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
                      Text(
                        'Budget',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
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
                      Text(
                        'Capacité',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
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
                      // Le champ de départ est une liste déroulante de villes, comme Destination
                      Text(
                        'Départ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: depart, // Utilise la variable 'depart'
                        hint: Text('Sélectionner votre ville de départ'), // Texte indicatif
                        items:
                            isLoading
                                ? [ // Afficher "Chargement..." si les villes ne sont pas encore chargées
                                  DropdownMenuItem(
                                    value: 'loading',
                                    child: Text('Chargement...'),
                                  ),
                                ]
                                : cities
                                    .map( // Mapper la liste des villes en DropdownMenuItems
                                      (city) => DropdownMenuItem(
                                        value: city['id'].toString(), // Utilise l'ID de la ville comme valeur
                                        child: Text(city['name']), // Affiche le nom de la ville
                                      ),
                                    )
                                    .toList(),
                        // Désactiver le Dropdown si les villes chargent, sinon permettre la sélection
                        onChanged:
                            isLoading
                                ? null
                                : (value) =>
                                    setState(() => depart = value), // Met à jour 'depart' avec l'ID sélectionné
                        decoration: InputDecoration(
                          border: OutlineInputBorder(), // Style de bordure
                        ),
                        validator: // Validation pour s'assurer qu'une ville est sélectionnée
                            (value) =>
                                value == null || value == 'loading' // Vérifie null ou la valeur "Chargement..."
                                    ? 'Veuillez choisir une ville de départ'
                                    : null,
                      ),


                      SizedBox(height: 24),
                      Text(
                        'Destination',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: destination, // Utilise la variable 'destination'
                        hint: Text('Sélectionner votre ville'), // Texte indicatif
                        items:
                            isLoading
                                ? [ // Afficher "Chargement..." si les villes ne sont pas encore chargées
                                  DropdownMenuItem(
                                    value: 'loading',
                                    child: Text('Chargement...'),
                                  ),
                                ]
                                : cities
                                    .map( // Mapper la liste des villes en DropdownMenuItems
                                      (city) => DropdownMenuItem(
                                        value: city['id'].toString(), // Utilise l'ID de la ville comme valeur
                                        child: Text(city['name']), // Affiche le nom de la ville
                                      ),
                                    )
                                    .toList(),
                        // Désactiver le Dropdown si les villes chargent, sinon permettre la sélection
                        onChanged:
                            isLoading
                                ? null
                                : (value) =>
                                    setState(() => destination = value), // Met à jour 'destination' avec l'ID sélectionné
                        decoration: InputDecoration(
                          border: OutlineInputBorder(), // Style de bordure
                        ),
                        validator: // Validation pour s'assurer qu'une ville est sélectionnée
                            (value) =>
                                value == null || value == 'loading' // Vérifie null ou la valeur "Chargement..."
                                    ? 'Veuillez choisir une destination'
                                    : null,
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
                   // Le bouton "Suivant" appelle _submitForm qui valide et navigue vers LocationPickerScreen
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

  // Cette fonction n'est pas utilisée dans ce code, mais était présente dans le code précédent
  // String _moisFr(int month) {
  //   const mois = [
  //     "janv", "févr", "mars", "avr", "mai", "juin",
  //     "juil", "août", "sept", "oct", "nov", "déc"
  //   ];
  //   return mois[month - 1];
  // }
}