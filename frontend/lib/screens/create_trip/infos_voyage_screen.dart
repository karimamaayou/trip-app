import 'package:flutter/material.dart';
import 'package:frontend/screens/create_trip/addImage_Screen.dart';
import 'dart:io';

class InfosVoyagePage extends StatefulWidget {
  final Map<String, dynamic> formData;

  const InfosVoyagePage({super.key, required this.formData});
  @override
  _InfosVoyagePageState createState() => _InfosVoyagePageState();
}

class _InfosVoyagePageState extends State<InfosVoyagePage> {
  File? _image;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  DateTime? _dateDepart; 
  DateTime? _dateFin;

  // Variables pour afficher les erreurs
  String? titleError;
  String? descriptionError;
  String? dateDepartError;
  String? dateFinError;

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2025, 6, 25),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _dateDepart = picked;
          dateDepartError = null;  // Clear error on valid date selection
        } else {
          _dateFin = picked;
          dateFinError = null;  // Clear error on valid date selection
        }
      });
    }
  }

  // Fonction pour valider les champs
  void validateFields() {
    setState(() {
      titleError = titleController.text.isEmpty
          ? 'Le titre ne peut pas être vide'
          : null;
      descriptionError = descriptionController.text.isEmpty
          ? 'La description ne peut pas être vide'
          : null;
      dateDepartError = _dateDepart == null
          ? 'La date de départ est requise'
          : null;
      dateFinError = _dateFin == null
          ? 'La date de fin est requise'
          : null;

      if (titleError == null && descriptionError == null && dateDepartError == null && dateFinError == null) {
        // Si tout est valide, on passe à la page suivante
        widget.formData['titre'] = titleController.text;
        widget.formData['description'] = descriptionController.text;
        widget.formData['date_depart'] = _dateDepart;
        widget.formData['date_fin'] = _dateFin;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddImageScreen(formData: [widget.formData]),
          ),
        );
      }
    });
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 30),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Titre',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: titleController,
              decoration: InputDecoration(
                hintText: 'Titre du voyage',
                border: OutlineInputBorder(),
              ),
            ),
            if (titleError != null)
              Text(
                titleError!,
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Description',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            if (descriptionError != null)
              Text(
                descriptionError!,
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Date de départ',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              readOnly: true,
              onTap: () => _selectDate(context, true),
              controller: TextEditingController(
                text: _dateDepart != null
                    ? '${_dateDepart!.day} ${_moisFr(_dateDepart!.month)} ${_dateDepart!.year}'
                    : '',
              ),
              decoration: InputDecoration(
                hintText: 'Date de départ',
                border: OutlineInputBorder(),
              ),
            ),
            if (dateDepartError != null)
              Text(
                dateDepartError!,
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Date de fin',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              readOnly: true,
              onTap: () => _selectDate(context, false),
              controller: TextEditingController(
                text: _dateFin != null
                    ? '${_dateFin!.day} ${_moisFr(_dateFin!.month)} ${_dateFin!.year}'
                    : '',
              ),
              decoration: InputDecoration(
                hintText: 'Date de fin',
                border: OutlineInputBorder(),
              ),
            ),
            if (dateFinError != null)
              Text(
                dateFinError!,
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            Expanded(child: Container()), // Remplir l'espace restant
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF24A500),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: validateFields,
            child: const Text(
              'Suivant',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  String _moisFr(int month) {
    const mois = [
      "janv", "févr", "mars", "avr", "mai", "juin",
      "juil", "août", "sept", "oct", "nov", "déc"
    ];
    return mois[month - 1];
  }
}
