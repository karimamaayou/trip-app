import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend/screens/profile/pofile_screen.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/services/api_service.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nomController;
  late TextEditingController prenomController;
  late TextEditingController emailController;
  bool isLoading = false;

  File? _selectedImage;
  Uint8List? _webImage;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with user data
    nomController = TextEditingController(text: User.nom);
    prenomController = TextEditingController(text: User.prenom);
    emailController = TextEditingController(text: User.email);
  }

  @override
  void dispose() {
    nomController.dispose();
    prenomController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        isLoading = true;
      });

      try {
      if (kIsWeb) {
        _webImage = await pickedFile.readAsBytes();
      } else {
        _selectedImage = File(pickedFile.path);
      }

        print('Selected image: ${_selectedImage?.path ?? 'Web image'}');
        print('User ID: ${User.getUserId()}');
        print('Token: ${User.token}');

        // Create multipart request
        var request = http.MultipartRequest(
          'PUT',
          Uri.parse('${Environment.apiHost}/api/profile/${User.getUserId()}'),
        );

        // Add authorization header
        request.headers['Authorization'] = 'Bearer ${User.token}';

        // Add the image file
        if (kIsWeb && _webImage != null) {
          print('Adding web image to request');
          request.files.add(
            http.MultipartFile.fromBytes(
              'profile_image',
              _webImage!,
              filename: 'profile_picture.jpg',
              contentType: MediaType('image', 'jpeg'),
            ),
          );
        } else if (_selectedImage != null) {
          print('Adding file image to request');
          request.files.add(
            await http.MultipartFile.fromPath(
              'profile_image',
              _selectedImage!.path,
              contentType: MediaType('image', 'jpeg'),
            ),
          );
        }

        // Add other required fields
        request.fields['nom'] = nomController.text;
        request.fields['prenom'] = prenomController.text;
        request.fields['email'] = emailController.text;

        print('Request fields: ${request.fields}');
        print('Request files: ${request.files.map((f) => f.filename).toList()}');

        var response = await request.send();
        var responseData = await response.stream.bytesToString();
        print('Response status code: ${response.statusCode}');
        print('Response headers: ${response.headers}');
        print('Profile update response: $responseData');

        if (response.statusCode == 200) {
          var jsonResponse = json.decode(responseData);
          print('Parsed JSON response: $jsonResponse');
          
          // Update User class with new profile picture
          if (jsonResponse['profile'] != null && jsonResponse['profile']['photo_profil'] != null) {
            // Add the correct path prefix
            String photoPath = jsonResponse['profile']['photo_profil'];
            if (!photoPath.startsWith('/uploads/profile_pictures/')) {
              photoPath = '/uploads/profile_pictures/$photoPath';
            }
            User.profilePicture = photoPath;
            print('Updated profile picture path: ${User.profilePicture}');
            
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Photo de profil mise à jour'),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            print('No profile picture in response');
            throw Exception('No profile picture in response');
          }
        } else {
          print('Failed with status code: ${response.statusCode}');
          throw Exception('Failed to update profile picture: ${responseData}');
        }
      } catch (e, stackTrace) {
        print('Error updating profile picture: $e');
        print('Stack trace: $stackTrace');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      try {
        // Create multipart request
        var request = http.MultipartRequest(
          'PUT',
          Uri.parse('${Environment.apiHost}/api/profile/${User.getUserId()}'),
        );

        // Add authorization header
        request.headers['Authorization'] = 'Bearer ${User.token}';

        // Add form fields
        request.fields['nom'] = nomController.text;
        request.fields['prenom'] = prenomController.text;
        request.fields['email'] = emailController.text;

        // Add existing profile picture if available
        if (User.profilePicture != null) {
          request.fields['photo_profil'] = User.profilePicture!;
        }

        var response = await request.send();
        var responseData = await response.stream.bytesToString();
        print('Profile update response: $responseData');

        if (response.statusCode == 200) {
          var jsonResponse = json.decode(responseData);
          
          // Update the User class with new information
          User.nom = nomController.text;
          User.prenom = prenomController.text;
          User.email = emailController.text;
          if (jsonResponse['profile'] != null && jsonResponse['profile']['photo_profil'] != null) {
            User.profilePicture = jsonResponse['profile']['photo_profil'];
          }

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profil mis à jour avec succès'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate back to profile screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => CustomProfileScreen()),
          );
        } else {
          throw Exception('Failed to update profile');
        }
      } catch (e) {
        print('Error updating profile: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CustomProfileScreen()),
        );
        return false;
      },
      child: Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 30),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: Color(0xFF0054A5)),
                      onPressed: () {
                          Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CustomProfileScreen()),
                        );
                      },
                    ),
                    const Text(
                      "Éditer le profil",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0054A5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: _webImage != null
                          ? MemoryImage(_webImage!)
                          : _selectedImage != null
                              ? FileImage(_selectedImage!) as ImageProvider
                                : User.profilePicture != null
                                    ? NetworkImage('${Environment.apiHost}${User.profilePicture}')
                              : const AssetImage("assets/default_user.png"),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Color(0xFF0054A5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit,
                              color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                /// NOM
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Nom",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 84, 84, 84))),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: nomController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  onChanged: (value) => setState(() {}),
                  decoration: _inputDecoration(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Veuillez entrer votre nom";
                    } else if (!RegExp(r"^[a-zA-ZÀ-ÿ\s'-]+$").hasMatch(value)) {
                      return "Caractères invalides";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                /// PRENOM
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Prénom",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 84, 84, 84))),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: prenomController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  onChanged: (value) => setState(() {}),
                  decoration: _inputDecoration(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Veuillez entrer votre prénom";
                    } else if (!RegExp(r"^[a-zA-ZÀ-ÿ\s'-]+$").hasMatch(value)) {
                      return "Caractères invalides";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                /// EMAIL
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Email",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 84, 84, 84))),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: emailController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  onChanged: (value) => setState(() {}),
                  decoration: _inputDecoration(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Veuillez entrer un email";
                    } else if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                      return "Email invalide";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),

                /// BOUTON
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                      onPressed: isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 36, 165, 0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                      "Enregistrer",
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }
}
