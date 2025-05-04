import 'package:flutter/material.dart';
import 'package:frontend/screens/create_trip/addImage_Screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class InfosVoyagePage extends StatefulWidget {
  final Map<String, dynamic> formData;

  InfosVoyagePage({required this.formData});
  @override
  _InfosVoyagePageState createState() => _InfosVoyagePageState();
}

class _InfosVoyagePageState extends State<InfosVoyagePage> {
  File? _image;
  final TextEditingController descriptionController = TextEditingController();
  DateTime? _dateDepart; 
  DateTime? _dateFin;

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
        } else {
          _dateFin = picked;
        }
      });
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 20),
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
            SizedBox(height: 380),
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
  // Ajoute les nouvelles infos dans formData
  widget.formData['description'] = descriptionController.text;
  widget.formData['date_depart'] = _dateDepart;
  widget.formData['date_fin'] = _dateFin;

  //print("FORMDATA FINAL : ${widget.formData}");

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => AddImageScreen(formData: [widget.formData]),

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

  String _moisFr(int month) {
    const mois = [
      "janv", "févr", "mars", "avr", "mai", "juin",
      "juil", "août", "sept", "oct", "nov", "déc"
    ];
    return mois[month - 1];
  }
}
