import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend/screens/profile/pofile_screen.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nomController = TextEditingController();
  final TextEditingController prenomController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  File? _selectedImage;
  Uint8List? _webImage;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (kIsWeb) {
        _webImage = await pickedFile.readAsBytes();
      } else {
        _selectedImage = File(pickedFile.path);
      }
      setState(() {});
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      print("Nom: ${nomController.text}");
      print("Prénom: ${prenomController.text}");
      print("Email: ${emailController.text}");
      // Intégration de l'API ici
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        Navigator.push(
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
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 36, 165, 0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
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
