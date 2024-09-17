import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CamperHomeScreen extends StatefulWidget {
  const CamperHomeScreen({super.key});

  @override
  _CamperHomeScreenState createState() => _CamperHomeScreenState();
}

class _CamperHomeScreenState extends State<CamperHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> permits = [];
  List<Map<String, dynamic>> filteredPermits = [];

  @override
  void initState() {
    super.initState();
    fetchPermits();
  }

  Future<void> fetchPermits() async {
    final url = Uri.parse(
        'https://eqqd1j4q2j.execute-api.ap-southeast-1.amazonaws.com/dev/permitapi/permit');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> permitData = json.decode(response.body);

        setState(() {
          permits = permitData
              .map((data) => {
                    'permitId': data['permitId'],
                    'location': data['location'],
                    'area': data['area'],
                    'status': data['status'],
                    'startDate': data['startDate'],
                    'endDate': data['endDate'],
                  })
              .toList();

          filteredPermits = permits;
        });
      } else {
        throw Exception('Failed to load permits');
      }
    } catch (e) {
      print('Error fetching permits: $e');
    }
  }

  void _filterPermits(String query) {
    final filtered = permits.where((permit) {
      final locationLower = permit['location'].toLowerCase();
      final searchLower = query.toLowerCase();

      return locationLower.contains(searchLower);
    }).toList();

    setState(() {
      filteredPermits = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camper Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search Campsites',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _filterPermits,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: permits.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: FittedBox(
                        fit: BoxFit.fitWidth,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Permit ID')),
                            DataColumn(label: Text('Location')),
                            DataColumn(label: Text('Area')),
                            DataColumn(label: Text('Status')),
                            DataColumn(label: Text('Start Date')),
                            DataColumn(label: Text('End Date')),
                          ],
                          rows: filteredPermits.map((permit) {
                            return DataRow(cells: [
                              DataCell(Text(permit['permitId'].toString())),
                              DataCell(Text(permit['location'])),
                              DataCell(Text(permit['area'])),
                              DataCell(Text(permit['status'])),
                              DataCell(Text(permit['startDate'])),
                              DataCell(Text(permit['endDate'])),
                            ]);
                          }).toList(),
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Navigate to the apply permit screen and wait for a result
                final result =
                    await Navigator.pushNamed(context, '/camper/apply_permit');
                if (result == 'refresh') {
                  // Refresh the permits table after a new permit is created
                  fetchPermits();
                }
              },
              child: const Text('Apply for Campsite Permit'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to the permit status enquiry screen
                Navigator.pushNamed(context, '/camper/enquire_status');
              },
              child: const Text('Enquire Permit Status'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to the apply permit screen
                Navigator.pushNamed(context, '/camper/submit_review');
              },
              child: const Text('Submit Review'),
            ),
          ],
        ),
      ),
    );
  }
}



// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// class CamperHomeScreen extends StatefulWidget {
//   const CamperHomeScreen({super.key});

//   @override
//   _CamperHomeScreenState createState() => _CamperHomeScreenState();
// }

// class _CamperHomeScreenState extends State<CamperHomeScreen> {
//   final TextEditingController _searchController = TextEditingController();
//   List<Map<String, dynamic>> permits = [];
//   List<Map<String, dynamic>> filteredPermits = [];

//   @override
//   void initState() {
//     super.initState();
//     fetchPermits();
//   }

//   Future<void> fetchPermits() async {
//     final url = Uri.parse(
//         'https://eqqd1j4q2j.execute-api.ap-southeast-1.amazonaws.com/dev/permitapi/permit');
//     try {
//       final response = await http.get(url);

//       if (response.statusCode == 200) {
//         final List<dynamic> permitData = json.decode(response.body);

//         setState(() {
//           permits = permitData
//               .map((data) => {
//                     'permitId': data['permitId'],
//                     'location': data['location'],
//                     'area': data['area'],
//                     'status': data['status'],
//                     'startDate': data['startDate'],
//                     'endDate': data['endDate'],
//                   })
//               .toList();

//           filteredPermits = permits;
//         });
//       } else {
//         throw Exception('Failed to load permits');
//       }
//     } catch (e) {
//       print('Error fetching permits: $e');
//     }
//   }

//   void _filterPermits(String query) {
//     final filtered = permits.where((permit) {
//       final locationLower = permit['location'].toLowerCase();
//       final searchLower = query.toLowerCase();

//       return locationLower.contains(searchLower);
//     }).toList();

//     setState(() {
//       filteredPermits = filtered;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Camper Dashboard'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: <Widget>[
//             TextField(
//               controller: _searchController,
//               decoration: const InputDecoration(
//                 labelText: 'Search Campsites',
//                 prefixIcon: Icon(Icons.search),
//                 border: OutlineInputBorder(),
//               ),
//               onChanged: _filterPermits,
//             ),
//             const SizedBox(height: 20),
//             Expanded(
//               child: permits.isEmpty
//                   ? const Center(child: CircularProgressIndicator())
//                   : SingleChildScrollView(
//                       scrollDirection: Axis.horizontal,
//                       child: FittedBox(
//                         fit: BoxFit.fitWidth,
//                         child: DataTable(
//                           columns: const [
//                             DataColumn(label: Text('Permit ID')),
//                             DataColumn(label: Text('Location')),
//                             DataColumn(label: Text('Area')),
//                             DataColumn(label: Text('Status')),
//                             DataColumn(label: Text('Start Date')),
//                             DataColumn(label: Text('End Date')),
//                           ],
//                           rows: filteredPermits.map((permit) {
//                             return DataRow(cells: [
//                               DataCell(Text(permit['permitId'].toString())),
//                               DataCell(Text(permit['location'])),
//                               DataCell(Text(permit['area'])),
//                               DataCell(Text(permit['status'])),
//                               DataCell(Text(permit['startDate'])),
//                               DataCell(Text(permit['endDate'])),
//                             ]);
//                           }).toList(),
//                         ),
//                       ),
//                     ),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 // Navigate to the apply permit screen
//                 Navigator.pushNamed(context, '/camper/apply_permit');
//               },
//               child: const Text('Apply for Campsite Permit'),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 // Navigate to the permit status enquiry screen
//                 Navigator.pushNamed(context, '/camper/enquire_status');
//               },
//               child: const Text('Enquire Permit Status'),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 // Navigate to the apply permit screen
//                 Navigator.pushNamed(context, '/camper/submit_review');
//               },
//               child: const Text('Submit Review'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }



















//without using api
// import 'package:flutter/material.dart';

// class CamperHomeScreen extends StatefulWidget {
//   const CamperHomeScreen({super.key});

//   @override
//   _CamperHomeScreenState createState() => _CamperHomeScreenState();
// }

// class _CamperHomeScreenState extends State<CamperHomeScreen> {
//   final TextEditingController _searchController = TextEditingController();
//   List<Map<String, String>> campsites = [
//     {'name': 'Campsite A', 'location': 'Hill Side'},
//     {'name': 'Campsite B', 'location': 'Lake'},
//     {'name': 'Campsite C', 'location': 'Forest'},
//     // Add more campsites as needed
//   ];
//   List<Map<String, String>> filteredCampsites = [];

//   @override
//   void initState() {
//     super.initState();
//     filteredCampsites = campsites;
//   }

//   void _filterCampsites(String query) {
//     final filtered = campsites.where((campsite) {
//       final nameLower = campsite['name']!.toLowerCase();
//       final searchLower = query.toLowerCase();

//       return nameLower.contains(searchLower);
//     }).toList();

//     setState(() {
//       filteredCampsites = filtered;
//     });
//   }

//   // void _applyForPermit(String campsiteName) {
//   //   // TODO: Implement application for permit logic
//   //   ScaffoldMessenger.of(context).showSnackBar(
//   //     SnackBar(content: Text('Applied for permit at $campsiteName')),
//   //   );
//   // }

//   // void _submitFeedback() {
//   //   // TODO: Implement submit feedback logic
//   //   Navigator.pushNamed(context, '/camper/submit_feedback');
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Camper Dashboard'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: <Widget>[
//             TextField(
//               controller: _searchController,
//               decoration: const InputDecoration(
//                 labelText: 'Search Campsites',
//                 prefixIcon: Icon(Icons.search),
//                 border: OutlineInputBorder(),
//               ),
//               onChanged: _filterCampsites,
//             ),
//             const SizedBox(height: 20),
//             Expanded(
//               child: ListView(
//                 children: [
//                   SingleChildScrollView(
//                       scrollDirection: Axis.horizontal,
//                       child: FittedBox(
//                         fit: BoxFit.fitWidth,
//                         child: DataTable(
//                           columns: const [
//                             DataColumn(label: Text('Campsite Name')),
//                             DataColumn(label: Text('Location')),
//                           ],
//                           rows: filteredCampsites.map((campsite) {
//                             return DataRow(cells: [
//                               DataCell(Text(campsite['name']!)),
//                               DataCell(Text(campsite['location']!)),
//                             ]);
//                           }).toList(),
//                         ),
//                       )),
//                   const SizedBox(height: 20),
//                   ElevatedButton(
//                     onPressed: () {
//                       // Navigate to the apply permit screen
//                       Navigator.pushNamed(context, '/camper/apply_permit');
//                     },
//                     child: const Text('Apply for Campsite Permit'),
//                   ),
//                   const SizedBox(height: 20),
//                   ElevatedButton(
//                     onPressed: () {
//                       // Navigate to the permit status enquiry screen
//                       Navigator.pushNamed(context, '/camper/enquire_status');
//                     },
//                     child: const Text('Enquire Permit Status'),
//                   ),
//                   const SizedBox(height: 20),
//                   ElevatedButton(
//                     onPressed: () {
//                       // Navigate to the apply permit screen
//                       Navigator.pushNamed(context, '/camper/submit_review');
//                     },
//                     child: const Text('Submit Review'),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
