import 'package:flutter/material.dart';
import 'package:frontend/screens/create_trip/creation_voyage_screen.dart';
import 'package:frontend/screens/home/filter_screen.dart';
import 'package:frontend/screens/home/trip_details.dart';
import 'package:frontend/screens/profile/pofile_screen.dart';
import 'package:frontend/screens/notification/notification_screen.dart';
import 'package:frontend/screens/search/search_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/models/user.dart';
import 'package:frontend/services/api_service.dart';
import 'dart:async';
import 'package:frontend/screens/notifications/notifications_screen.dart';

class OffersPage extends StatefulWidget {
  const OffersPage({super.key});

  @override
  _OffersPageState createState() => _OffersPageState();
}

class _OffersPageState extends State<OffersPage> {
  List<Map<String, dynamic>> offres = [];
  List<Map<String, dynamic>> filteredOffres = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  bool hasMoreData = true;
  int currentPage = 1;
  Map<String, dynamic>? currentFilters;
  final ScrollController _scrollController = ScrollController();
  DateTime? _loadingStartTime;
  int _unreadNotifications = 0;
  Timer? _notificationTimer;

  @override
  void initState() {
    super.initState();
    
    // Debug print to verify user data
    print('🏠 HomeScreen - User Status:');
    print('Is User Logged In: ${User.isLoggedIn()}');
    print('User ID: ${User.getUserId()}');
    print('User ID: ${User.profilePicture}');
    
    _fetchTrips();
    _scrollController.addListener(_onScroll);
    _fetchUnreadNotifications();
    // Check for new notifications every minute
    _notificationTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _fetchUnreadNotifications();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _notificationTimer?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8 &&
        !isLoadingMore &&
        hasMoreData &&
        currentFilters == null) {
      print('Chargement de plus de voyages...'); // Debug log
      _loadMoreTrips();
    }
  }

  Future<void> _fetchFilteredTrips(int page) async {
    try {
      final response = await http.get(
        Uri.parse('${Environment.apiHost}/api/trips/paginated?page=$page&limit=4'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final trips = (data['trips'] as List).map((trip) => {
          'titre': trip['titre'].toString(),
          'ville_depart': trip['ville_depart'].toString(),
          'ville_arrivee': trip['ville_arrivee'].toString(),
          'id': trip['id_voyage'].toString(),
          'images': trip['images'] ?? [],
          'budget': trip['budget']?.toDouble() ?? 0.0,
          'activities': (trip['activities'] as List<dynamic>?)?.map((a) => a['nom_activity'].toString()).toList() ?? [],
        }).toList();

        // Apply filters to the fetched trips
        final filteredTrips = trips.where((trip) {
          // Filter by budget
          if (currentFilters!['budget'] != null && trip['budget'] > currentFilters!['budget']) {
            return false;
          }

          // Filter by departure city
          if (currentFilters!['depart'] != null && trip['ville_depart'] != currentFilters!['depart']) {
            return false;
          }

          // Filter by destination city
          if (currentFilters!['destination'] != null && trip['ville_arrivee'] != currentFilters!['destination']) {
            return false;
          }

          // Filter by activities
          if (currentFilters!['activities'] != null && currentFilters!['activities'].isNotEmpty) {
            final tripActivities = trip['activities'] as List<String>;
            if (!currentFilters!['activities'].every((activity) => tripActivities.contains(activity))) {
              return false;
            }
          }

          return true;
        }).toList();

        setState(() {
          if (page == 1) {
            offres = filteredTrips;
            filteredOffres = filteredTrips;
          } else {
            offres.addAll(filteredTrips);
            filteredOffres = offres;
          }
          currentPage = page;
          hasMoreData = filteredTrips.length == 4; // If we got 4 trips, there might be more
          isLoading = false;
          isLoadingMore = false;
        });
      }
    } catch (e) {
      print('Erreur lors de la récupération des voyages filtrés: $e');
      setState(() {
        isLoading = false;
        isLoadingMore = false;
      });
    }
  }

  void _applyFilters(Map<String, dynamic> filters) async {
    print('Applying filters: $filters');
    setState(() {
      isLoading = true;
      currentFilters = filters;
      currentPage = 1;
    });

    // Fetch first page of filtered results
    await _fetchFilteredTrips(1);
  }

  Future<void> _loadMoreTrips() async {
    if (isLoadingMore) return;

    setState(() {
      isLoadingMore = true;
      _loadingStartTime = DateTime.now();
    });

    try {
      if (currentFilters != null) {
        // Load more filtered trips
        await _fetchFilteredTrips(currentPage + 1);
      } else {
        // Load more regular trips
        final response = await http.get(
          Uri.parse('${Environment.apiHost}/api/trips/paginated?page=${currentPage + 1}&limit=4'),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final newTrips = (data['trips'] as List).map((trip) => {
            'titre': trip['titre'].toString(),
            'ville_depart': trip['ville_depart'].toString(),
            'ville_arrivee': trip['ville_arrivee'].toString(),
            'id': trip['id_voyage'].toString(),
            'images': trip['images'] ?? [],
            'budget': trip['budget']?.toDouble() ?? 0.0,
            'activities': (trip['activities'] as List<dynamic>?)?.map((a) => a['nom_activity'].toString()).toList() ?? [],
          }).toList();

          // Calculate how long to wait to ensure minimum display time
          final elapsedTime = DateTime.now().difference(_loadingStartTime!).inMilliseconds;
          final minimumDisplayTime = 500;
          if (elapsedTime < minimumDisplayTime) {
            await Future.delayed(Duration(milliseconds: minimumDisplayTime - elapsedTime));
          }

          setState(() {
            offres.addAll(newTrips);
            filteredOffres = offres;
            currentPage++;
            hasMoreData = currentPage < data['pagination']['totalPages'];
            isLoadingMore = false;
            _loadingStartTime = null;
          });
        }
      }
    } catch (e) {
      print('Erreur lors du chargement des voyages: $e');
      final elapsedTime = DateTime.now().difference(_loadingStartTime!).inMilliseconds;
      final minimumDisplayTime = 500;
      if (elapsedTime < minimumDisplayTime) {
        await Future.delayed(Duration(milliseconds: minimumDisplayTime - elapsedTime));
      }
      
      setState(() {
        isLoadingMore = false;
        _loadingStartTime = null;
      });
    }
  }

  Future<void> _fetchTrips() async {
    try {
      setState(() {
        isLoading = true;
        currentPage = 1;
        hasMoreData = true;
        _loadingStartTime = DateTime.now();
      });

      print('Starting _fetchTrips...'); // Debug log
      final response = await http.get(
        Uri.parse('${Environment.apiHost}/api/trips/paginated?page=1&limit=4'),
      );
      
      print('_fetchTrips - Response status code: ${response.statusCode}'); // Debug log
      print('_fetchTrips - Response body (first 200 chars): ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}'); // Debug log

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Raw trip data: ${data['trips']}'); // Debug print
        final trips = (data['trips'] as List).map((trip) => {
          'titre': trip['titre'].toString(),
          'ville_depart': trip['ville_depart'].toString(),
          'ville_arrivee': trip['ville_arrivee'].toString(),
          'id': trip['id_voyage'].toString(),
          'images': trip['images'] ?? [],
          'budget': trip['budget']?.toDouble() ?? 0.0,
          'activities': (trip['activities'] as List<dynamic>?)?.map((a) => a['nom_activity'].toString()).toList() ?? [],
        }).toList();
        print('Processed trips: $trips'); // Debug print

        print('Chargement initial: ${trips.length} voyages'); // Debug log
        print('Pages totales: ${data['pagination']['totalPages']}'); // Debug log

        // Calculate how long to wait to ensure minimum display time
        final elapsedTime = DateTime.now().difference(_loadingStartTime!).inMilliseconds;
        final minimumDisplayTime = 500; // 0.5 seconds in milliseconds
        if (elapsedTime < minimumDisplayTime) {
          await Future.delayed(Duration(milliseconds: minimumDisplayTime - elapsedTime));
        }

        setState(() {
          offres = trips;
          filteredOffres = trips;
          currentPage = 1;
          hasMoreData = currentPage < data['pagination']['totalPages'];
          isLoading = false;
          _loadingStartTime = null;
        });
      }
    } catch (e) {
      print('Erreur lors de la récupération des voyages: $e');
      // Also ensure minimum display time even for errors
      final elapsedTime = DateTime.now().difference(_loadingStartTime!).inMilliseconds;
      final minimumDisplayTime = 500;
      if (elapsedTime < minimumDisplayTime) {
        await Future.delayed(Duration(milliseconds: minimumDisplayTime - elapsedTime));
      }
      
      setState(() {
        isLoading = false;
        _loadingStartTime = null;
      });
    }
  }

  Future<void> _fetchAllTrips() async {
    try {
      final response = await http.get(
        Uri.parse('${Environment.apiHost}/api/trips/paginated?page=1&limit=1000'), // Fetch all trips
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final trips = (data['trips'] as List).map((trip) => {
          'titre': trip['titre'].toString(),
          'ville_depart': trip['ville_depart'].toString(),
          'ville_arrivee': trip['ville_arrivee'].toString(),
          'id': trip['id_voyage'].toString(),
          'images': trip['images'] ?? [],
          'budget': trip['budget']?.toDouble() ?? 0.0,
          'activities': (trip['activities'] as List<dynamic>?)?.map((a) => a['nom_activity'].toString()).toList() ?? [],
        }).toList();

        setState(() {
          offres = trips;
          currentPage = 1;
          hasMoreData = false; // Disable pagination when filtered
        });
      }
    } catch (e) {
      print('Erreur lors de la récupération de tous les voyages: $e');
    }
  }

  void _clearFilters() {
    setState(() {
      currentFilters = null;
      isLoading = true;
      currentPage = 1;
    });
    print('Clearing filters, fetching trips...'); // Debug log
    _fetchTrips(); // This will reset to regular paginated view
  }

  Future<void> _fetchUnreadNotifications() async {
    try {
      final response = await http.get(
        Uri.parse('${Environment.apiHost}/api/friends/notifications/${User.getUserId()}/unread'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _unreadNotifications = data['count'];
        });
      }
    } catch (e) {
      print('Error fetching unread notifications: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF51D32D),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreationVoyagePage()),
          );
        },
        shape: CircleBorder(),
        child: Icon(Icons.add, size: 28, color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CustomProfileScreen()),
                      );
                    },
                    child: CircleAvatar(
                      radius: 25,
                      backgroundImage: User.profilePicture != null
                          ? NetworkImage('${Environment.apiHost}${User.profilePicture}')
                          : const AssetImage('assets/profile.jpg') as ImageProvider,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        text: 'Bonjour, ',
                        style: TextStyle(fontSize: 16),
                        children: [
                          TextSpan(
                            text: '${User.prenom} ${User.nom}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications, color: Color(0xFF0054A5)),
                        onPressed: () async {
                          // Mark notifications as read
                          try {
                            await http.put(
                              Uri.parse('${Environment.apiHost}/api/friends/notifications/${User.getUserId()}/mark-read'),
                            );
                            print('Notifications marked as read'); // Debug log
                          } catch (e) {
                            print('Error marking notifications as read: $e'); // Debug log
                          }

                          // Navigate to notifications screen
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NotificationsScreen(),
                            ),
                          );
                          
                          // Refresh unread count after returning from notifications screen
                          _fetchUnreadNotifications();
                        },
                      ),
                      if (_unreadNotifications > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              _unreadNotifications.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SearchScreen(),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: Colors.grey.shade300, blurRadius: 6),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.grey),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Rechercher...',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.tune, color: Colors.grey),
                        onPressed: () async {
                          final filters = await Navigator.push<Map<String, dynamic>>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SearchFilterPage(initialFilters: currentFilters),
                            ),
                          );
                          if (filters != null) {
                            _applyFilters(filters);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Les voyages",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  if (currentFilters != null)
                    TextButton.icon(
                      onPressed: _clearFilters,
                      icon: Icon(Icons.clear, size: 16, color: Colors.grey[600]),
                      label: Text(
                        'Effacer les filtres',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Grid of cards
            Expanded(
              child: isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text(
                            'Chargement des voyages...',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                  : filteredOffres.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
                              SizedBox(height: 16),
                              Text(
                                'Aucun voyage trouvé',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        )
                      : Column(
                          children: [
                            Expanded(
                              child: GridView.builder(
                                controller: _scrollController,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 0.8,
                                ),
                                itemCount: filteredOffres.length + (isLoadingMore ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index == filteredOffres.length) {
                                    return SizedBox(
                                      height: 100,
                                      child: Center(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            CircularProgressIndicator(),
                                            SizedBox(height: 8),
                                            Text(
                                              'Chargement de plus de voyages...',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }
                                  final offre = filteredOffres[index];
                                  return _buildTripCard(offre);
                                },
                              ),
                            ),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripCard(Map<String, dynamic> trip) {
    final images = trip['images'] as List<dynamic>;
    String? imageUrl;
    
    if (images.isNotEmpty && images[0] is Map<String, dynamic>) {
      imageUrl = images[0]['chemin']?.toString();
    }
    
  return GestureDetector(
    onTap: () async {
      print('Navigating to TripDetailsPage for trip ${trip['id']}'); // Debug log
      final result = await Navigator.push(
        context,
          MaterialPageRoute(
            builder: (context) => TripDetailsPage(tripId: int.parse(trip['id'])),
          ),
      );
      // If result is true, it means the trip was deleted, refresh the list
      print('Returned from TripDetailsPage with result: $result'); // Debug log
      if (result == true) {
        print('Trip deleted, fetching trips again...'); // Debug log
        _fetchTrips();
      } else {
        print('Trip not deleted or navigation cancelled.'); // Debug log
      }
    },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.55),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 7,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    imageUrl != null ? '${Environment.apiHost}$imageUrl' : '${Environment.apiHost}/assets/default_trip.jpg',
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.error, size: 50),
                      );
                    },
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      trip['titre'] ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 1),
                    Row(
                      children: [
                        Icon(Icons.location_on,
                            size: 16, color: Colors.grey.shade400),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            trip['ville_arrivee'] ?? '',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
      ),
    ),
  );
}
}
