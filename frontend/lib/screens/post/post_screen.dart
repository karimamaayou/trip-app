import 'package:flutter/material.dart';
import 'package:frontend/screens/post/ImagePost_screen.dart';

void main() => runApp(MaterialApp(home: PostsPage()));

class PostsPage extends StatelessWidget {
  final List<Map<String, dynamic>> posts = [
    {
      'username': 'Karim amaayou',
      'avatar': 'assets/images/image.png',
      'image': 'assets/images/image1.png',
      'description': 'Découverte des souks de Marrakech...',
      'likes': 124,
      'isLiked': false,
    },
    {
      'username': 'Omar amaayou',
      'avatar': 'assets/images/image.png',
      'image': 'assets/images/image2.png',
      'description': 'Soirée inoubliable à la place Jemaa el-Fna...',
      'likes': 89,
      'isLiked': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            // Header (inchangé)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: AssetImage('assets/images/image.png'),
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
                itemCount: posts.length,
                itemBuilder: (context, index) => PostCard(
                  username: posts[index]['username'],
                  avatar: posts[index]['avatar'],
                  imagePath: posts[index]['image'],
                  description: posts[index]['description'],
                  initialLikes: posts[index]['likes'],
                  isInitiallyLiked: posts[index]['isLiked'],
                ),
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
          ); // Navigation vers l'écran de création de post
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class PostCard extends StatefulWidget {
  final String username;
  final String avatar;
  final String imagePath;
  final String description;
  final int initialLikes;
  final bool isInitiallyLiked;

  const PostCard({
    required this.username,
    required this.avatar,
    required this.imagePath,
    required this.description,
    required this.initialLikes,
    required this.isInitiallyLiked,
  });

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late bool isLiked;
  late int likes;

  @override
  void initState() {
    super.initState();
    isLiked = widget.isInitiallyLiked;
    likes = widget.initialLikes;
  }

  void _toggleLike() {
    setState(() {
      isLiked = !isLiked;
      likes += isLiked ? 1 : -1;
    });
  }

  void _showImageDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ImageDetailPage(imagePath: widget.imagePath),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
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
                  backgroundImage: AssetImage(widget.avatar),
                  radius: 20,
                ),
                SizedBox(width: 8),
                Text(
                  widget.username,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 10),

            // Image (maintenant cliquable)
            GestureDetector(
              onTap: () => _showImageDetail(context),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: Image.asset(
                  widget.imagePath,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 200,
                ),
              ),
            ),
            SizedBox(height: 10),

            // Description
            Text(
              widget.description,
              style: TextStyle(color: Colors.grey[800]),
            ),
            SizedBox(height: 10),

            // Like row
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.red : Colors.grey,
                  ),
                  onPressed: _toggleLike,
                ),
                SizedBox(width: 5),
                Text(
                  likes.toString(),
                  style: TextStyle(color: isLiked ? Colors.red : Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ImageDetailPage extends StatelessWidget {
  final String imagePath;

  const ImageDetailPage({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Aperçu',
            style: TextStyle(color: const Color.fromARGB(255, 10, 7, 169))),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true, // Autorise le déplacement
          boundaryMargin: EdgeInsets.all(20),
          minScale: 0.5, // Zoom minimum
          maxScale: 3.0, // Zoom maximum
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Image.asset(
              imagePath,
              fit: BoxFit
                  .contain, // Ajuste l'image à l'écran en gardant les proportions
            ),
          ),
        ),
      ),
    );
  }
}
