import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/screens/post/post_screen.dart';
import 'package:frontend/main_screen.dart';
import 'package:frontend/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';

class SharePage extends StatefulWidget {
  final List<Map<String, dynamic>> formData;

  const SharePage(this.formData, {super.key});

  @override
  State<SharePage> createState() => _SharePageState();
}

class _SharePageState extends State<SharePage> {
  final TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = false;

  Future<void> _createPost() async {
    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez ajouter une description')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // First create the post
      final postResponse = await http.post(
        Uri.parse('http://localhost:3000/api/posts'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'content': _descriptionController.text.trim(),
          'userId': int.parse(User.getUserId() ?? '0'),
        }),
      );

      if (postResponse.statusCode != 201) {
        throw Exception('Failed to create post: ${postResponse.body}');
      }

      final postData = json.decode(postResponse.body);
      final postId = postData['id_post'];

      // Then upload images if any
      if (widget.formData.isNotEmpty) {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('http://localhost:3000/api/posts/$postId/images'),
        );

        for (var imageData in widget.formData) {
          if (imageData['image'] is List<int>) {
            request.files.add(
              http.MultipartFile.fromBytes(
                'images',
                imageData['image'] as List<int>,
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

        final uploadResponse = await request.send();
        if (uploadResponse.statusCode != 200) {
          throw Exception('Failed to upload images');
        }
      }

      // Navigate to posts tab
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScreen(initialIndex: 1)),
      );
    } catch (e) {
      print('Error creating post: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating post: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0054A5)),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MainScreen(initialIndex: 0)),
            );
          },
        ),
        title: const Text(
          'Partager',
          style: TextStyle(
            color: Color(0xFF0054A5),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Description',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF565656),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TextField(
                  controller: _descriptionController,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(12),
                    border: InputBorder.none,
                    hintText: 'Écris quelque chose...',
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createPost,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF24A500),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Partager',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
