import 'package:flutter/material.dart';


class SearchFilterPage extends StatefulWidget {
  @override
  _SearchFilterPageState createState() => _SearchFilterPageState();
}

class _SearchFilterPageState extends State<SearchFilterPage> {
  double _budget = 100;
  String? _depart;
  String? _destination;
  List<String> activities = ['Nager', 'Montagne', 'Tour', 'Quad', 'Festival'];
  List<String> selectedActivities = [];

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor:  Colors.white,
      appBar: AppBar(
        leading: BackButton(color: const Color.fromARGB(255, 13, 84, 142)),
        title: Text('Search Filter', style: TextStyle(color: const Color.fromARGB(255, 13, 84, 142))),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              
            Text('Budget', style: TextStyle(fontWeight: FontWeight.bold , fontSize: 14) ),
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
            Text('Activites', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14) ),
            SizedBox(height: 16),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: activities.map((activity) {
                final isSelected = selectedActivities.contains(activity);
                return ChoiceChip(
                  label: Text(activity),
                  selected: isSelected,
                  selectedColor: Colors.blue.shade100,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        selectedActivities.add(activity);
                      } else {
                        selectedActivities.remove(activity);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            Text('depart', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14) ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _depart,
              items: ['ville A', 'ville B']
                  .map((city) => DropdownMenuItem(
                        value: city,
                        child: Text(city),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _depart = value;
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            Text('Destination', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14) ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _destination,
              items: ['ville A', 'ville B']
                  .map((city) => DropdownMenuItem(
                        value: city,
                        child: Text(city),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _destination = value;
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            Spacer(),
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
                    
                        
                      
                    },
                    child: const Text(
                      'Recherche',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
