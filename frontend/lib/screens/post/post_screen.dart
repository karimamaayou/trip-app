import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/screens/post/ImagePost_screen.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;

void main() => runApp(MaterialApp(home: PostsPage()));

class PostsPage extends StatelessWidget {
  final String dummyText =
      'Lorem ipsum dolor sit amet, lisis anteen  Sed non ex non enim gravida ullamcorper. Integer at arcu justo. Morbi placerat dolor a libero feugiat, eu feugiat nunc tincidunt. Sed ut nisi ut lorem placerat dignissim. Fusce sollicitudin est non dui lobortis, in interdum velit bibendum';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: AssetImage('assets/images/marakich.jpeg'),
                    radius: 25,
                  ),
                  SizedBox(width: 10),
                  RichText(
                    text: TextSpan(
                      text: 'Bonjour, ',
                      style: TextStyle(color: Colors.grey[700], fontSize: 16),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Karim amaayou',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Spacer(),
                  Icon(Icons.notifications_none, size: 35),
                ],
              ),
            ),

            // Posts List
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: 2,
                itemBuilder: (context, index) => PostCard(dummyText: dummyText),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ImageScreen(
                formData: [],
              ),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class PostCard extends StatefulWidget {
  final String dummyText;

  const PostCard({required this.dummyText});

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isLiked = false; // Gère l'état du like

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                ImageDetailPage(imagePath: 'assets/images/marakich.jpeg'),
          ),
        );
      },
      child: Card(
        elevation: 4,
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User info
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: AssetImage('assets/images/marakich.jpeg'),
                    radius: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Karim amaayou',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 10),
              // Image
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ImageDetailPage(
                          imagePath: 'assets/images/marakich.jpeg'),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: Image.asset(
                    'assets/images/marakich.jpeg',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 200,
                  ),
                ),
              ),
              SizedBox(height: 10),
              // Description
              Text(widget.dummyText, style: TextStyle(color: Colors.grey[800])),
              SizedBox(height: 10),
              // Like row
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? Colors.red : Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        isLiked = !isLiked; // Change l'état de "liked"
                      });
                    },
                  ),
                  SizedBox(width: 5),
                  Text(
                    '300',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ImageDetailPage extends StatelessWidget {
  final String imagePath;

  const ImageDetailPage({required this.imagePath});

  Future<void> _saveImage(BuildContext context) async {
    if (kIsWeb) {
      // 📦 Web : téléchargement via AnchorElement

      final byteData = await rootBundle.load(imagePath);
      final blob = html.Blob([byteData.buffer.asUint8List()]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", "downloaded_image.jpg")
        ..click();
      html.Url.revokeObjectUrl(url);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Image téléchargée !")),
      );
    } else {
      // 📱 Android / iOS
      final status = await Permission.storage.request();
      if (status.isGranted) {
        final byteData = await rootBundle.load(imagePath);
        final result = await ImageGallerySaver.saveImage(
          Uint8List.view(byteData.buffer),
          quality: 100,
          name: "downloaded_image",
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("✅ Image sauvegardée dans la galerie !")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Permission refusée.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Color.fromARGB(255, 2, 2, 117)),
        centerTitle: false,
        toolbarHeight: 70, // augmente la hauteur totale de l'AppBar
        titleSpacing: 0, // aligne le titre avec l'icône
        title: Padding(
          padding:
              const EdgeInsets.only(top: 12.0), // déplace le texte vers le bas
          child: Text(
            'Aperçu de l\'image',
            style: TextStyle(
              color: Color.fromARGB(255, 2, 2, 117),
            ),
          ),
        ),
        leading: Padding(
          padding:
              const EdgeInsets.only(top: 12.0), // déplace l'icône vers le bas
          child: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Image.asset(imagePath, fit: BoxFit.contain),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ElevatedButton.icon(
              icon: Icon(Icons.download),
              label: Text("Télécharger l'image"),
              onPressed: () => _saveImage(context),
            ),
          ),
        ],
      ),
    );
  }
}
