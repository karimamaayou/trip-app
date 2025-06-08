import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/screens/post/ImagePost_screen.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;
import 'package:frontend/models/user.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/screens/notification/notification_screen.dart';
import 'package:frontend/screens/profile/pofile_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PostsPage extends StatefulWidget {
  const PostsPage({super.key});

  @override
  _PostsPageState createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  List<Map<String, dynamic>> posts = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  int currentPage = 1;
  final int postsPerPage = 4;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchPosts();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMorePosts();
    }
  }

  Future<void> _loadMorePosts() async {
    if (isLoadingMore) return;

    setState(() {
      isLoadingMore = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
          '${Environment.apiHost}/api/posts?page=${currentPage + 1}&limit=$postsPerPage&userId=${User.id}',
        ),
        headers: {'Authorization': 'Bearer ${User.token}'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> newPosts = json.decode(response.body);
        if (newPosts.isNotEmpty) {
          setState(() {
            posts.addAll(List<Map<String, dynamic>>.from(newPosts));
            currentPage++;
          });
        }
      }
    } catch (e) {
      print('Error loading more posts: $e');
    } finally {
      setState(() {
        isLoadingMore = false;
      });
    }
  }

  Future<void> _fetchPosts() async {
    try {
      print('Fetching posts...'); // Debug log
      final url = Uri.parse(
        '${Environment.apiHost}/api/posts?page=1&limit=$postsPerPage&userId=${User.id}',
      );
      print('Request URL: $url'); // Debug log
      print('User token: ${User.token}'); // Debug log

      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer ${User.token}'},
      );

      print('Response status code: ${response.statusCode}'); // Debug log
      print('Response body: ${response.body}'); // Debug log

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          posts = List<Map<String, dynamic>>.from(data);
          isLoading = false;
          currentPage = 1;
        });
        print('Posts loaded successfully: ${posts.length} posts'); // Debug log
      } else {
        print('Error response: ${response.body}'); // Debug log
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching posts: $e'); // Debug log
      setState(() {
        isLoading = false;
      });
    }
  }

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
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CustomProfileScreen(),
                        ),
                      );
                    },
                    child: CircleAvatar(
                      radius: 25,
                      backgroundImage:
                          User.profilePicture != null
                              ? NetworkImage(
                                '${Environment.apiHost}${User.profilePicture}',
                              )
                              : const AssetImage('assets/profile.jpg')
                                  as ImageProvider,
                    ),
                  ),
                  SizedBox(width: 10),
                  RichText(
                    text: TextSpan(
                      text: 'Bonjour, ',
                      style: TextStyle(color: Colors.grey[700], fontSize: 16),
                      children: <TextSpan>[
                        TextSpan(
                          text: '${User.prenom} ${User.nom}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    icon: const Icon(Icons.notifications_none),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Posts List
            Expanded(
              child:
                  isLoading
                      ? Center(child: CircularProgressIndicator())
                      : RefreshIndicator(
                        onRefresh: _fetchPosts,
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.zero,
                          itemCount: posts.length + (isLoadingMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == posts.length) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            return PostCard(
                              post: posts[index],
                              onReactionChanged: () {
                                // Refresh the post data after reaction
                                _fetchPosts();
                              },
                            );
                          },
                        ),
                      ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF51D32D),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ImageScreen(formData: [])),
          );
        },
        shape: CircleBorder(),
        child: Icon(Icons.add, size: 28, color: Colors.white),
      ),
    );
  }
}

class PostCard extends StatefulWidget {
  final Map<String, dynamic> post;
  final VoidCallback onReactionChanged;

  const PostCard({super.key, required this.post, required this.onReactionChanged});

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isLiked = false;
  int reactionCount = 0;
  int currentImageIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _updateReactionState();
  }

  @override
  void didUpdateWidget(PostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.post != widget.post) {
      _updateReactionState();
    }
  }

  void _updateReactionState() {
    setState(() {
      isLiked = widget.post['has_reacted'] ?? false;
      reactionCount = widget.post['reaction_count'] ?? 0;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _toggleReaction() async {
    try {
      final response = await http.post(
        Uri.parse(
          '${Environment.apiHost}/api/posts/${widget.post['id_post']}/reactions',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id_utilisateur': User.id}),
      );

      if (response.statusCode == 200) {
        // Instead of managing state locally, trigger a refresh
        widget.onReactionChanged();
      } else {
        print('Error toggling reaction: ${response.body}');
      }
    } catch (e) {
      print('Error toggling reaction: $e');
    }
  }

  String _formatDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m';
      }
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}j';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> images = List<String>.from(widget.post['images'] ?? []);
    final String profilePicture = widget.post['photo_profil'] ?? '';

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
                  backgroundImage:
                      profilePicture.isNotEmpty
                          ? NetworkImage('${Environment.apiHost}$profilePicture')
                          : const AssetImage('assets/profile.jpg')
                              as ImageProvider,
                  radius: 20,
                ),
                SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.post['prenom']} ${widget.post['nom']}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _formatDate(widget.post['date_publication']),
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),

            // Images carousel
            if (images.isNotEmpty)
              SizedBox(
                height: 200,
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          currentImageIndex = index;
                        });
                      },
                      itemCount: images.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => ImageDetailPage(
                                      imagePath:
                                          '${Environment.apiHost}${images[index]}',
                                    ),
                              ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: Image.network(
                              '${Environment.apiHost}${images[index]}',
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                        );
                      },
                    ),
                    if (images.length > 1)
                      Positioned(
                        bottom: 8,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            images.length,
                            (index) => Container(
                              width: 8,
                              height: 8,
                              margin: EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    currentImageIndex == index
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.5),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

            SizedBox(height: 10),
            // Post content
            Text(
              widget.post['contenu'],
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
                  onPressed: _toggleReaction,
                ),
                SizedBox(width: 5),
                Text(
                  reactionCount.toString(),
                  style: TextStyle(color: Colors.red),
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

  const ImageDetailPage({super.key, required this.imagePath});

  Future<void> _saveImage(BuildContext context) async {
    try {
      if (kIsWeb) {
        // Pour le web
        final response = await http.get(Uri.parse(imagePath));
        final blob = html.Blob([response.bodyBytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor =
            html.AnchorElement(href: url)
              ..setAttribute("download", "image.jpg")
              ..click();
        html.Url.revokeObjectUrl(url);

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("✅ Image téléchargée !")));
      } else {
        // Pour mobile
        final status = await Permission.storage.request();
        if (status.isGranted) {
          final response = await http.get(Uri.parse(imagePath));
          final result = await ImageGallerySaver.saveImage(
            response.bodyBytes,
            quality: 100,
            name: "image_${DateTime.now().millisecondsSinceEpoch}",
          );

          if (result['isSuccess']) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("✅ Image sauvegardée dans la galerie !"),
              ),
            );
          } else {
            throw Exception('Échec de la sauvegarde');
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("❌ Permission refusée.")),
          );
        }
      }
    } catch (e) {
      print('Erreur lors de la sauvegarde: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Erreur: ${e.toString()}")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color.fromARGB(255, 2, 2, 117)),
        centerTitle: false,
        toolbarHeight: 70,
        titleSpacing: 0,
        title: const Padding(
          padding: EdgeInsets.only(top: 12.0),
          child: Text(
            'Aperçu de l\'image',
            style: TextStyle(color: Color.fromARGB(255, 2, 2, 117)),
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: Column(
        
        children: [
          Expanded(
            child: InteractiveViewer(
              // Permet de zoomer sur l'image
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.network(
                imagePath,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value:
                          loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  print('Erreur de chargement de l\'image: $error');
                  return const Center(
                    child: Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 50,
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(padding: const EdgeInsets.all(12.0)),
        ],
      ),
    );
  }
}