import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/screens/home/trip_details.dart';
import 'package:frontend/screens/home/filter_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> offres = [];
  List<Map<String, dynamic>> filteredOffres = [];
  List<Map<String, dynamic>> displayedTrips = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  int currentDisplayCount = 6;
  Map<String, dynamic>? currentFilters;
  DateTime? _loadingStartTime;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScroll);
    _fetchAllTrips();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8 &&
        !isLoadingMore &&
        displayedTrips.length < filteredOffres.length) {
      _loadMoreTrips();
    }
  }

  Future<void> _fetchAllTrips() async {
    try {
      setState(() {
        isLoading = true;
        _loadingStartTime = DateTime.now();
      });

      // Fetch all trips at once
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/trips/paginated?page=1&limit=1000'),
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

        // Calculate how long to wait to ensure minimum display time
        final elapsedTime = DateTime.now().difference(_loadingStartTime!).inMilliseconds;
        final minimumDisplayTime = 500;
        if (elapsedTime < minimumDisplayTime) {
          await Future.delayed(Duration(milliseconds: minimumDisplayTime - elapsedTime));
        }

        setState(() {
          offres = trips;
          _applyFilters();
          displayedTrips = filteredOffres.take(currentDisplayCount).toList();
          isLoading = false;
          _loadingStartTime = null;
        });
      }
    } catch (e) {
      print('Erreur lors de la récupération des voyages: $e');
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

  Future<void> _loadMoreTrips() async {
    if (isLoadingMore) return;

    setState(() {
      isLoadingMore = true;
      _loadingStartTime = DateTime.now();
    });

    // Simulate loading delay
    await Future.delayed(Duration(milliseconds: 500));

    setState(() {
      final nextBatch = filteredOffres.skip(displayedTrips.length).take(6).toList();
      displayedTrips.addAll(nextBatch);
      isLoadingMore = false;
      _loadingStartTime = null;
    });
  }

  void _applyFilters() {
    String searchQuery = _searchController.text.toLowerCase();
    
    setState(() {
      filteredOffres = offres.where((trip) {
        // Apply search query filter
        if (searchQuery.isNotEmpty) {
          final title = trip['titre']?.toString().toLowerCase() ?? '';
          final depart = trip['ville_depart']?.toString().toLowerCase() ?? '';
          final arrivee = trip['ville_arrivee']?.toString().toLowerCase() ?? '';

          if (!title.contains(searchQuery) &&
              !depart.contains(searchQuery) &&
              !arrivee.contains(searchQuery)) {
            return false;
          }
        }

        // Apply budget filter
        if (currentFilters?['budget'] != null) {
          final tripBudget = trip['budget']?.toDouble() ?? 0.0;
          if (tripBudget > currentFilters!['budget']) {
            return false;
          }
        }

        // Apply departure city filter
        if (currentFilters?['depart'] != null) {
          if (trip['ville_depart']?.toString() != currentFilters!['depart']) {
            return false;
          }
        }

        // Apply destination city filter
        if (currentFilters?['destination'] != null) {
          if (trip['ville_arrivee']?.toString() != currentFilters!['destination']) {
            return false;
          }
        }

        // Apply activities filter
        if (currentFilters?['activities'] != null && (currentFilters!['activities'] as List).isNotEmpty) {
          final tripActivities = trip['activities'] as List<String>;
          if (!(currentFilters!['activities'] as List).every((activity) => tripActivities.contains(activity))) {
            return false;
          }
        }

        return true;
      }).toList();

      // Reset displayed trips when filters change
      displayedTrips = filteredOffres.take(currentDisplayCount).toList();
    });
  }

  void _onSearchChanged() {
    _applyFilters();
  }

  bool _hasActiveFilters() {
    return currentFilters != null || _searchController.text.isNotEmpty;
  }

  void _clearFilters() {
    setState(() {
      currentFilters = null;
      _searchController.clear();
    });
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          height: 45,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 12),
              const Icon(Icons.search, color: Colors.grey, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Rechercher des voyages...',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  style: TextStyle(fontSize: 16),
                ),
              ),
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.tune, color: Colors.grey, size: 20),
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SearchFilterPage(
                            initialFilters: currentFilters,
                          ),
                        ),
                      );
                      if (result != null) {
                        setState(() {
                          currentFilters = Map<String, dynamic>.from(result);
                        });
                        _applyFilters();
                      }
                    },
                  ),
                  if (_hasActiveFilters())
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.circle, color: Colors.red, size: 8),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: isLoading
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
                    if (_hasActiveFilters())
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
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
                    Expanded(
                      child: GridView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: displayedTrips.length + (isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == displayedTrips.length) {
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
                          final trip = displayedTrips[index];
                          return _buildTripCard(trip);
                        },
                      ),
                    ),
                  ],
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
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TripDetailsPage(tripId: int.parse(trip['id'])),
          ),
        );
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
                    imageUrl != null ? 'http://localhost:3000$imageUrl' : 'http://localhost:3000/assets/default_trip.jpg',
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
                        Icon(Icons.location_on, size: 16, color: Colors.grey.shade400),
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