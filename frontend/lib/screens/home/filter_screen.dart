import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SearchFilterPage extends StatefulWidget {
  final Map<String, dynamic>? initialFilters;

  const SearchFilterPage({Key? key, this.initialFilters}) : super(key: key);

  @override
  _SearchFilterPageState createState() => _SearchFilterPageState();
}

class _SearchFilterPageState extends State<SearchFilterPage> {
  late double _budget;
  late String? _depart;
  late String? _destination;
  late List<String> selectedActivities;
  
  List<Map<String, dynamic>> _cities = [];
  List<Map<String, dynamic>> _activities = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Initialize with initial filters if provided
    _budget = widget.initialFilters?['budget']?.toDouble() ?? 100.0;
    _depart = widget.initialFilters?['depart'];
    _destination = widget.initialFilters?['destination'];
    selectedActivities = List<String>.from(widget.initialFilters?['activities'] ?? []);
    
    // Fetch cities and activities
    _fetchCities();
    _fetchActivities();
  }

  Future<void> _fetchCities() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/data/villes'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _cities = List<Map<String, dynamic>>.from(data);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load cities';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error connecting to server';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchActivities() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/data/activities'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _activities = List<Map<String, dynamic>>.from(data);
        });
      }
    } catch (e) {
      print('Error fetching activities: $e');
    }
  }

  Map<String, dynamic> _getFilters() {
    return {
      'budget': _budget.round(),
      'depart': _depart,
      'destination': _destination,
      'activities': selectedActivities,
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: BackButton(color: const Color.fromARGB(255, 13, 84, 142)),
          title: Text('Search Filter', style: TextStyle(color: const Color.fromARGB(255, 13, 84, 142))),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: BackButton(color: const Color.fromARGB(255, 13, 84, 142)),
          title: Text('Search Filter', style: TextStyle(color: const Color.fromARGB(255, 13, 84, 142))),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 48),
              SizedBox(height: 16),
              Text(_error!, style: TextStyle(color: Colors.red)),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _error = null;
                  });
                  _fetchCities();
                  _fetchActivities();
                },
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: BackButton(color: const Color.fromARGB(255, 13, 84, 142)),
        title: Text('Search Filter', style: TextStyle(color: const Color.fromARGB(255, 13, 84, 142))),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _budget = 100.0;
                _depart = null;
                _destination = null;
                selectedActivities = [];
              });
            },
            child: Text(
              'Clear All',
              style: TextStyle(
                color: const Color.fromARGB(255, 13, 84, 142),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Budget', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('10dh'),
                Text('500dh'),
              ],
            ),
            Slider(
              value: _budget,
              min: 10,
              max: 500,
              divisions: 49,
              label: '${_budget.round()}dh',
              onChanged: (value) {
                setState(() {
                  _budget = value;
                });
              },
              activeColor: Colors.blue,
              inactiveColor: Colors.grey,
            ),
            SizedBox(height: 16),
            Text('Activites', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            SizedBox(height: 16),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: _activities.map((activity) {
                final isSelected = selectedActivities.contains(activity['nom_activity']);
                return ChoiceChip(
                  label: Text(activity['nom_activity']),
                  selected: isSelected,
                  selectedColor: Colors.blue.shade100,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        selectedActivities.add(activity['nom_activity']);
                      } else {
                        selectedActivities.remove(activity['nom_activity']);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            Text('Depart', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _depart,
              items: _cities.map((city) => DropdownMenuItem<String>(
                value: city['nom_ville'] as String,
                child: Text(city['nom_ville'] as String),
              )).toList(),
              onChanged: (value) {
                setState(() {
                  _depart = value;
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Select departure city',
              ),
            ),
            SizedBox(height: 16),
            Text('Destination', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _destination,
              items: _cities.map((city) => DropdownMenuItem<String>(
                value: city['nom_ville'] as String,
                child: Text(city['nom_ville'] as String),
              )).toList(),
              onChanged: (value) {
                setState(() {
                  _destination = value;
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Select destination city',
              ),
            ),
            SizedBox(height: 24),
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
                  Navigator.pop(context, _getFilters());
                },
                child: const Text(
                  'Apply Filters',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
