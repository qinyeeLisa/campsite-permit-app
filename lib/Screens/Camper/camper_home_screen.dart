import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:camplified/services/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../services/user_provider.dart';

class CamperHomeScreen extends StatefulWidget {
  const CamperHomeScreen({super.key});

  @override
  _CamperHomeScreenState createState() => _CamperHomeScreenState();
}

class _CamperHomeScreenState extends State<CamperHomeScreen> {
  List<Map<String, dynamic>> permits = [];
  bool isLoading = true; // New flag to handle loading state
  bool noPermits = false; // Flag to check if no permits exist

  @override
  void initState() {
    super.initState();
    fetchPermits();
  }

  Future<void> fetchPermits() async {
    final user = await Provider.of<UserProvider>(context, listen: false).getUser();
    int userId = user?.userId ?? 0;

    // Get Firebase JWT token
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final idToken = await firebaseUser?.getIdToken();
    print("JWTToken");
    print(idToken);

    final url = Uri.parse(
        //'https://eqqd1j4q2j.execute-api.ap-southeast-1.amazonaws.com/dev/permitapi/permit/GetPermit/$userId'
        'https://d24mqpbjn8370i.cloudfront.net/permitapi/permit/GetPermit/$userId'
    );
    try {
      //final response = await http.get(url);
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $idToken',  // Add JWT token to Authorization header
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> permitData = json.decode(response.body);

        setState(() {
          isLoading = false;
          if (permitData.isEmpty) {
            noPermits = true; // Set flag if no permits are returned
          } else {
            permits = permitData
                .map((data) => {
                      'permitId': data['permitId'],
                      'userId': data['userId'],
                      'location': data['location'],
                      'area': data['area'],
                      'status': data['status'],
                      'startDate': data['startDate'],
                      'endDate': data['endDate'],
                    })
                .toList();
          }
        });
      } else {
        throw Exception('Failed to load permits');
      }
    } catch (e) {
      print('Error fetching permits: $e');
      setState(() {
        isLoading = false;
        noPermits = true; // Display no permits if an error occurs
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camper Dashboard Test'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushNamed(context, '/login');
            },
          )
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Camper Dashboard'),
              onTap: () {
                // Close the drawer and navigate to the Camper Dashboard
                Navigator.pop(context);
                Navigator.pushNamed(context, '/camper/home');
              },
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Apply for Campsite Permit'),
              onTap: () async {
                Navigator.pop(context);
                final result =
                    await Navigator.pushNamed(context, '/camper/apply_permit');
                if (result == 'refresh') {
                  fetchPermits();
                }
              },
            ),
      /*      ListTile(
              leading: const Icon(Icons.search),
              title: const Text('Enquire Permit Status'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/camper/enquire_status');
              },
            ),*/
            ListTile(
              leading: const Icon(Icons.rate_review),
              title: const Text('Submit Review'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/camper/submit_review');
              },
            ),
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text('Search Campsites'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/camper/search_campsites');
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Expanded(
              child: isLoading
                  ? const Center(
                      child:
                          CircularProgressIndicator()) // Show loading spinner
                  : noPermits
                      ? const Center(
                          child: Text(
                            'There are no permits. Please create a permit.',
                            style: TextStyle(fontSize: 16),
                          ),
                        ) // Show "no permits" message
                      : SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minWidth: MediaQuery.of(context).size.width,
                              ),
                              child: DataTable(
                                columnSpacing: 10.0,
                                dataRowMinHeight: 20,
                                columns: const [
                                  DataColumn(
                                      label: Text('Permit ID',
                                          style: TextStyle(fontSize: 10))),
                                  DataColumn(
                                      label: Text('User ID',
                                          style: TextStyle(fontSize: 10))),
                                  DataColumn(
                                      label: Text('Location',
                                          style: TextStyle(fontSize: 10))),
                                  DataColumn(
                                      label: Text('Area',
                                          style: TextStyle(fontSize: 10))),
                                  DataColumn(
                                      label: Text('Status',
                                          style: TextStyle(fontSize: 10))),
                                  DataColumn(
                                      label: Text('Start',
                                          style: TextStyle(fontSize: 10))),
                                  DataColumn(
                                      label: Text('End',
                                          style: TextStyle(fontSize: 10))),
                                ],
                                rows: permits.map((permit) {
                                  return DataRow(cells: [
                                    DataCell(Text(permit['permitId'].toString(),
                                        style: const TextStyle(fontSize: 8))),
                                    DataCell(Text(permit['userId'].toString(),
                                        style: const TextStyle(fontSize: 8))),
                                    DataCell(Text(permit['location'],
                                        style: const TextStyle(fontSize: 8))),
                                    DataCell(Text(permit['area'],
                                        style: const TextStyle(fontSize: 8))),
                                    DataCell(Text(permit['status'],
                                        style: const TextStyle(fontSize: 8))),
                                    DataCell(Text(permit['startDate'],
                                        style: const TextStyle(fontSize: 8))),
                                    DataCell(Text(permit['endDate'],
                                        style: const TextStyle(fontSize: 8))),
                                  ]);
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}


//old working
// import 'dart:convert';
// import 'package:camplified/services/user_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:provider/provider.dart';

// class CamperHomeScreen extends StatefulWidget {
//   const CamperHomeScreen({super.key});

//   @override
//   _CamperHomeScreenState createState() => _CamperHomeScreenState();
// }

// class _CamperHomeScreenState extends State<CamperHomeScreen> {
//   List<Map<String, dynamic>> permits = [];

//   @override
//   void initState() {
//     super.initState();
//     fetchPermits();
//   }

//   Future<void> fetchPermits() async {
//     final user = Provider.of<UserProvider>(context, listen: false).user;
//     int userId = user?.userId ?? 0;

//     final url = Uri.parse(
//         'https://d24mqpbjn8370i.cloudfront.net/permitapi/permit/GetPermit/$userId'
//         // 'https://eqqd1j4q2j.execute-api.ap-southeast-1.amazonaws.com/dev/permitapi/permit'
//         );
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
//         });
//       } else {
//         throw Exception('Failed to load permits');
//       }
//     } catch (e) {
//       print('Error fetching permits: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Camper Dashboard'),
//       ),
//       drawer: Drawer(
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: <Widget>[
//             const DrawerHeader(
//               decoration: BoxDecoration(
//                 color: Colors.blue,
//               ),
//               child: Text(
//                 'Menu',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 24,
//                 ),
//               ),
//             ),
//             ListTile(
//               leading: const Icon(Icons.dashboard),
//               title: const Text('Camper Dashboard'),
//               onTap: () {
//                 // Close the drawer and navigate to the Camper Dashboard
//                 Navigator.pop(context);
//                 Navigator.pushNamed(context, '/camper/home');
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.add),
//               title: const Text('Apply for Campsite Permit'),
//               onTap: () async {
//                 Navigator.pop(context);
//                 final result =
//                     await Navigator.pushNamed(context, '/camper/apply_permit');
//                 if (result == 'refresh') {
//                   fetchPermits();
//                 }
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.search),
//               title: const Text('Enquire Permit Status'),
//               onTap: () {
//                 Navigator.pop(context);
//                 Navigator.pushNamed(context, '/camper/enquire_status');
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.rate_review),
//               title: const Text('Submit Review'),
//               onTap: () {
//                 Navigator.pop(context);
//                 Navigator.pushNamed(context, '/camper/submit_review');
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.search),
//               title: const Text('Search Campsites'),
//               onTap: () {
//                 Navigator.pop(context);
//                 Navigator.pushNamed(context, '/camper/search_campsites');
//               },
//             ),
//           ],
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Column(
//           children: <Widget>[
//             Expanded(
//               child: permits.isEmpty
//                   ? const Center(child: CircularProgressIndicator())
//                   : SingleChildScrollView(
//                       scrollDirection: Axis.horizontal,
//                       child: FittedBox(
//                         fit: BoxFit.fitWidth,
//                         child: DataTable(
//                           columnSpacing:
//                               10.0, // Adjust the space between columns
//                           dataRowMinHeight: 20, // Adjust row height
//                           columns: const [
//                             DataColumn(
//                                 label: Text('Permit ID',
//                                     style: TextStyle(fontSize: 10))),
//                             DataColumn(
//                                 label: Text('Location',
//                                     style: TextStyle(fontSize: 10))),
//                             DataColumn(
//                                 label: Text('Area',
//                                     style: TextStyle(fontSize: 10))),
//                             DataColumn(
//                                 label: Text('Status',
//                                     style: TextStyle(fontSize: 10))),
//                             DataColumn(
//                                 label: Text('Start',
//                                     style: TextStyle(fontSize: 10))),
//                             DataColumn(
//                                 label: Text('End',
//                                     style: TextStyle(fontSize: 10))),
//                           ],
//                           rows: permits.map((permit) {
//                             return DataRow(cells: [
//                               DataCell(Text(permit['permitId'].toString(),
//                                   style: const TextStyle(fontSize: 8))),
//                               DataCell(Text(permit['location'],
//                                   style: const TextStyle(fontSize: 8))),
//                               DataCell(Text(permit['area'],
//                                   style: const TextStyle(fontSize: 8))),
//                               DataCell(Text(permit['status'],
//                                   style: const TextStyle(fontSize: 8))),
//                               DataCell(Text(permit['startDate'],
//                                   style: const TextStyle(fontSize: 8))),
//                               DataCell(Text(permit['endDate'],
//                                   style: const TextStyle(fontSize: 8))),
//                             ]);
//                           }).toList(),
//                         ),
//                       ),
//                     ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }






//original
// class CamperHomeScreen extends StatefulWidget {
//   const CamperHomeScreen({super.key});

//   @override
//   _CamperHomeScreenState createState() => _CamperHomeScreenState();
// }

// class _CamperHomeScreenState extends State<CamperHomeScreen> {
//   final TextEditingController _searchController = TextEditingController();
//   List<Map<String, dynamic>> permits = [];

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
//         });
//       } else {
//         throw Exception('Failed to load permits');
//       }
//     } catch (e) {
//       print('Error fetching permits: $e');
//     }
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
//                           rows: permits.map((permit) {
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
//               onPressed: () async {
//                 // Navigate to the apply permit screen and wait for a result
//                 final result =
//                     await Navigator.pushNamed(context, '/camper/apply_permit');
//                 if (result == 'refresh') {
//                   // Refresh the permits table after a new permit is created
//                   fetchPermits();
//                 }
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
//                 // Navigate to the submit review screen
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
