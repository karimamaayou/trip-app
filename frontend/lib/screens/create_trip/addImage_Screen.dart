import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend/screens/create_trip/conformation_screen.dart';

import 'package:image_picker/image_picker.dart';

// Remplace ceci par ton vrai écran de destination


class AddImageScreen extends StatefulWidget {
 final List<Map<String, dynamic>> formData;

  const AddImageScreen({Key? key, required this.formData}) : super(key: key);

  @override
  State<AddImageScreen> createState() => _AddImageScreenState();
}

class _AddImageScreenState extends State<AddImageScreen> {
  final List<dynamic> _images = [];

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
                      print("FORMDATA FINAL : ${widget.formData}");
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            Conformation(formData: widget.formData),
                      ),
                    );
                  },
                  child: const Text(
                    'Suivant',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              )
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

    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dashWidth, 0), paint);
      x += dashWidth + dashSpace;
    }

    while (y < size.height) {
      canvas.drawLine(
          Offset(size.width, y), Offset(size.width, y + dashWidth), paint);
      y += dashWidth + dashSpace;
    }

    x = size.width;
    while (x > 0) {
      canvas.drawLine(
          Offset(x, size.height), Offset(x - dashWidth, size.height), paint);
      x -= dashWidth + dashSpace;
    }

    y = size.height;
    while (y > 0) {
      canvas.drawLine(Offset(0, y), Offset(0, y - dashWidth), paint);
      y -= dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
