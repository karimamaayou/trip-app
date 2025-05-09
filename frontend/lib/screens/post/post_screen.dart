import 'package:flutter/material.dart';

class PostsPage extends StatelessWidget {
  final String dummyText =
      'lorem lorem lorem lorem lorem lorem lorem lorem lorem lorem lorem lorem lorem lorem lorem lorem lorem lorem lorem lorem';

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
                    backgroundImage: AssetImage(
                        'assets/images/marakich.jpeg'), // change image path
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

      // Floating button
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () {},
        child: Icon(Icons.add),
      ),
    );
  }
}

class PostCard extends StatelessWidget {
  final String dummyText;

  const PostCard({required this.dummyText});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4, // ombre
      margin: EdgeInsets.symmetric(
          horizontal: 16, vertical: 8), // espacement autour
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
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: Image.asset(
                'assets/images/marakich.jpeg',
                fit: BoxFit.cover,
                width: double.infinity,
                height: 200,
              ),
            ),
            SizedBox(height: 10),
            // Description
            Text(dummyText, style: TextStyle(color: Colors.grey[800])),
            SizedBox(height: 10),
            // Like row
            Row(
              children: [
                Icon(Icons.favorite_border, color: Colors.red),
                SizedBox(width: 5),
                Text(
                  '300',
                  style: TextStyle(color: Color.fromARGB(255, 245, 4, 4)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
