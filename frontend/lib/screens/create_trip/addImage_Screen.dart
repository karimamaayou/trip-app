import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend/screens/create_trip/conformation_screen.dart';
import 'package:frontend/models/user.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';

class AddImageScreen extends StatefulWidget {
  final List<Map<String, dynamic>> formData;

  const AddImageScreen({Key? key, required this.formData}) : super(key: key);

  @override
  State<AddImageScreen> createState() => _AddImageScreenState();
}

class _AddImageScreenState extends State<AddImageScreen> {
  final List<dynamic> _images = [];
  bool _isLoading = false;

  String getMediaType(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'bmp':
        return 'image/bmp';
      case 'webp':
        return 'image/webp';
      default:
        return 'application/octet-stream';
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _images.add(Uint8List.fromList(bytes));
          widget.formData.add({
            "image": Uint8List.fromList(bytes),
            "type": getMediaType(pickedFile.name),
            "name": pickedFile.name,
          });
        });
      } else {
        setState(() {
          _images.add(pickedFile);
          widget.formData.add({
            "image": File(pickedFile.path),
            "type": getMediaType(pickedFile.path),
            "name": pickedFile.path.split('/').last,
          });
        });
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
      widget.formData.removeAt(index);
    });
  }

  Future<void> _createTrip() async {
    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez ajouter au moins une image')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://localhost:3000/api/trips/create'),
      );

      // Add trip data
      final tripData = widget.formData[0];
      
      // Debug print to check form data
      print('Form data: $tripData');
      
      request.fields.addAll({
        'titre': tripData['titre'],
        'description': tripData['description'],
        'date_depart': tripData['date_depart'].toString(),
        'date_retour': tripData['date_fin'].toString(),
        'capacite_max': tripData['capacite'].toString(),
        'id_ville_depart': tripData['ville_depart'].toString(),
        'id_ville_destination': tripData['ville_arrivee'].toString(),
        'budget': tripData['budget'].toString(),
        'userId': User.getUserId() ?? '1',
      });

      // Add activities
      if (tripData['activites'] != null) {
      final activities = tripData['activites'] as List;
        if (activities.isNotEmpty) {
          request.fields['activites'] = activities.join(',');
        }
      }

      // Debug print request fields
      print('Request fields: ${request.fields}');

      // Add images
      for (var i = 1; i < widget.formData.length; i++) {
        final imageData = widget.formData[i];
        if (kIsWeb) {
          request.files.add(
            http.MultipartFile.fromBytes(
              'images',
              imageData['image'] as Uint8List,
              filename: imageData['name'],
              contentType: MediaType.parse(imageData['type']),
            ),
          );
        } else {
          request.files.add(
            await http.MultipartFile.fromPath(
              'images',
              (imageData['image'] as File).path,
              contentType: MediaType.parse(imageData['type']),
            ),
          );
        }
      }

      // Send request
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      print('Response status: ${response.statusCode}');
      print('Response data: $responseData');

      if (response.statusCode == 201) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Conformation(formData: widget.formData),
          ),
        );
      } else {
        throw Exception('Failed to create trip: $responseData');
      }
    } catch (e) {
      print('Error creating trip: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating trip: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ajouter les images',
          style: TextStyle(
            color: Color(0xFF0054A5),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0054A5)),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    // Display selected images
                    ..._images.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final img = entry.value;
                      return Stack(
                        children: [
                          Container(
                            height: 200,
                            margin: const EdgeInsets.only(bottom: 10),
                            child: kIsWeb
                                ? Image.memory(img as Uint8List,
                                    fit: BoxFit.cover, width: double.infinity)
                                : Image.file(File((img as XFile).path),
                                    fit: BoxFit.cover,
                                    width: double.infinity),
                          ),
                          Positioned(
                            top: 5,
                            right: 6,
                            child: GestureDetector(
                              onTap: () => _removeImage(idx),
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(2),
                                child: const Icon(Icons.delete,
                                    color: Colors.red, size: 26),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                    // Add-image button (up to 6)
                    if (_images.length < 6)
                      GestureDetector(
                        onTap: () => _pickImage(ImageSource.gallery),
                        child: CustomPaint(
                          painter: DashedBorderPainter(),
                          child: Container(
                            height: 204,
                            alignment: Alignment.center,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                border: Border.all(
                                  color: const Color(0xFF04557F),
                                  width: 2,
                                ),
                              ),
                              child: const Icon(Icons.add,
                                  color: Color(0xFF04557F), size: 30),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Next button with loading state
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
                  onPressed: _isLoading ? null : _createTrip,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
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

class DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF06477C)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const dashWidth = 10.0, dashSpace = 5.0;
    double x = 0, y = 0;

    // Top border
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dashWidth, 0), paint);
      x += dashWidth + dashSpace;
    }
    // Right border
    while (y < size.height) {
      canvas.drawLine(
          Offset(size.width, y), Offset(size.width, y + dashWidth), paint);
      y += dashWidth + dashSpace;
    }
    // Bottom border
    x = size.width;
    while (x > 0) {
      canvas.drawLine(
          Offset(x, size.height), Offset(x - dashWidth, size.height), paint);
      x -= dashWidth + dashSpace;
    }
    // Left border
    y = size.height;
    while (y > 0) {
      canvas.drawLine(Offset(0, y), Offset(0, y - dashWidth), paint);
      y -= dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
