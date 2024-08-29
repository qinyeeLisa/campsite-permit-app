import 'package:flutter/material.dart';

class CamperHomeScreen extends StatefulWidget {
  @override
  _CamperHomeScreenState createState() => _CamperHomeScreenState();
}

class _CamperHomeScreenState extends State<CamperHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> campsites = [
    {'name': 'Campsite A', 'location': 'Mountain'},
    {'name': 'Campsite B', 'location': 'Lake'},
    {'name': 'Campsite C', 'location': 'Forest'},
    // Add more campsites as needed
  ];
  List<Map<String, String>> filteredCampsites = [];

  @override
  void initState() {
    super.initState();
    filteredCampsites = campsites;
  }

  void _filterCampsites(String query) {
    final filtered = campsites.where((campsite) {
      final nameLower = campsite['name']!.toLowerCase();
      final searchLower = query.toLowerCase();

      return nameLower.contains(searchLower);
    }).toList();

    setState(() {
      filteredCampsites = filtered;
    });
  }

  // void _applyForPermit(String campsiteName) {
  //   // TODO: Implement application for permit logic
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(content: Text('Applied for permit at $campsiteName')),
  //   );
  // }

  // void _submitFeedback() {
  //   // TODO: Implement submit feedback logic
  //   Navigator.pushNamed(context, '/camper/submit_feedback');
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Camper Dashboard'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Campsites',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _filterCampsites,
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: FittedBox(
                        fit: BoxFit.fitWidth,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Campsite Name')),
                            DataColumn(label: Text('Location')),
                          ],
                          rows: filteredCampsites.map((campsite) {
                            return DataRow(cells: [
                              DataCell(Text(campsite['name']!)),
                              DataCell(Text(campsite['location']!)),
                            ]);
                          }).toList(),
                        ),
                      )),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to the apply permit screen
                      Navigator.pushNamed(context, '/camper/apply_permit');
                    },
                    child: Text('Apply for Campsite Permit'),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to the permit status enquiry screen
                      Navigator.pushNamed(context, '/camper/enquire_status');
                    },
                    child: Text('Enquire Permit Status'),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to the apply permit screen
                      Navigator.pushNamed(context, '/camper/submit_review');
                    },
                    child: Text('Submit Review'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
