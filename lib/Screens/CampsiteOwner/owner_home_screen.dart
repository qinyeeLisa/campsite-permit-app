import 'dart:convert'; // For JSON handling
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../services/user_provider.dart';
import 'owner_submit_feedback_screen.dart';

class OwnerHomeScreen extends StatefulWidget {
  const OwnerHomeScreen({super.key});

  @override
  State<OwnerHomeScreen> createState() => _OwnerHomeScreenState();
}

class _OwnerHomeScreenState extends State<OwnerHomeScreen> {
  List<Map<String, dynamic>> permitApplications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPermitApplications();
  }

  // Fetch permit applications from API
  Future<void> _fetchPermitApplications() async {
    final url = 'https://d24mqpbjn8370i.cloudfront.net/permitapi/permit';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        setState(() {
          permitApplications = data
              .map((application) => {
                    'permitId': application['permitId'].toString(),
                    'userId': application['userId'].toString(),
                    'startDate': application['startDate'] ?? 'N/A',
                    'endDate': application['endDate'] ?? 'N/A',
                    'location': application['location'] ?? 'Unknown',
                    'area': application['area'] ?? 'Unknown',
                    'status': application['status'] ?? 'Pending',
                    'createdBy': application['createdBy'] ?? 'Unknown',
                    'dateTimeCreated': application['dateTimeCreated'] ?? 'N/A',
                    'updatedBy': application['updatedBy'] ?? 'N/A',
                    'dateTimeUpdated': application['dateTimeUpdated'] ?? 'N/A',
                  })
              .toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load permit applications');
      }
    } catch (error) {
      print('Error fetching permit applications: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Approve permit application
  Future<void> _approveApplication(String permitId, String userId) async {
    final url = 'https://d24mqpbjn8370i.cloudfront.net/approveapi/approve/';
    final user = Provider.of<UserProvider>(context, listen: false).user;
    //int userId = user?.userId ?? 0;

    try {
      // Create the PermitInfoDto payload
      final Map<String, dynamic> permitInfo = {
        'Id': int.parse(permitId),
        'UserId': int.parse(userId),
        'UpdatedBy': user?.fullName
      };

      // Send POST request with the permitInfo as JSON
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(permitInfo),
      );

      if (response.statusCode == 200) {
        setState(() {
          permitApplications.firstWhere((application) =>
              application['permitId'] == permitId)['status'] = 'Approved';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Application $permitId approved')),
        );
      } else {
        throw Exception('Failed to approve application');
      }
    } catch (error) {
      print('Error approving application: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error approving application')),
      );
    }
  }

// Reject permit application
  Future<void> _rejectApplication(String permitId, String userId) async {
    final url =
        'https://d24mqpbjn8370i.cloudfront.net/approveapi/approve/rejectpermit';

    final user = Provider.of<UserProvider>(context, listen: false).user;

    try {
      // Create the PermitInfoDto payload
      final Map<String, dynamic> permitInfo = {
        'Id': int.parse(permitId),
        'UserId': int.parse(userId),
        'UpdatedBy': user?.fullName
      };

      // Send POST request with the permitInfo as JSON
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(permitInfo),
      );

      if (response.statusCode == 200) {
        setState(() {
          permitApplications.firstWhere((application) =>
              application['permitId'] == permitId)['status'] = 'Rejected';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Application $permitId rejected')),
        );
      } else {
        throw Exception('Failed to reject application');
      }
    } catch (error) {
      print('Error rejecting application: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error rejecting application')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Campsite Owner Home"),
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
                'Campsite Owner Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pushNamed(context, '/campsite_owner/home');
              },
            ),
            ListTile(
              leading: const Icon(Icons.feedback),
              title: const Text('Submit Feedback'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OwnerSubmitFeedbackScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  const Text(
                    'Permit Applications',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      children: permitApplications.map((application) {
                        return Card(
                          child: ListTile(
                            title: Text(
                              'Permit ID: ${application['permitId']} - Location: ${application['location']}, ${application['area']} - Status: ${application['status']}',
                            ),
                            subtitle: Text(
                              'Camper: ${application['createdBy']} - From: ${application['startDate']} to ${application['endDate']}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ElevatedButton(
                                  onPressed: application['status'] == 'Pending'
                                      ? () => _approveApplication(
                                            application['permitId']!,
                                            application['userId']!,
                                          )
                                      : null,
                                  child: const Text('Approve'),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: application['status'] == 'Pending'
                                      ? () => _rejectApplication(
                                            application['permitId']!,
                                            application['userId']!,
                                          )
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  child: const Text('Reject'),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}





//working with API

// import 'dart:convert'; // For JSON handling
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'owner_submit_feedback_screen.dart';

// class OwnerHomeScreen extends StatefulWidget {
//   const OwnerHomeScreen({super.key});

//   @override
//   State<OwnerHomeScreen> createState() => _OwnerHomeScreenState();
// }

// class _OwnerHomeScreenState extends State<OwnerHomeScreen> {
//   List<Map<String, dynamic>> permitApplications = [];
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _fetchPermitApplications();
//   }

//   // Fetch permit applications from API
//   Future<void> _fetchPermitApplications() async {
//     final url =
//         'https://eqqd1j4q2j.execute-api.ap-southeast-1.amazonaws.com/dev/permitapi/permit';
//     try {
//       final response = await http.get(Uri.parse(url));
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body) as List<dynamic>;
//         setState(() {
//           permitApplications = data
//               .map((application) => {
//                     'permitId': application['permitId'].toString(),
//                     'userId': application['userId'].toString(),
//                     'startDate': application['startDate'] ?? 'N/A',
//                     'endDate': application['endDate'] ?? 'N/A',
//                     'location': application['location'] ?? 'Unknown',
//                     'area': application['area'] ?? 'Unknown',
//                     'status': application['status'] ?? 'Pending',
//                     'createdBy': application['createdBy'] ?? 'Unknown',
//                     'dateTimeCreated': application['dateTimeCreated'] ?? 'N/A',
//                     'updatedBy': application['updatedBy'] ?? 'N/A',
//                     'dateTimeUpdated': application['dateTimeUpdated'] ?? 'N/A',
//                   })
//               .toList();
//           isLoading = false;
//         });
//       } else {
//         throw Exception('Failed to load permit applications');
//       }
//     } catch (error) {
//       print('Error fetching permit applications: $error');
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   // Approve permit application
//   Future<void> _approveApplication(String id) async {
//     final url =
//         'https://eqqd1j4q2j.execute-api.ap-southeast-1.amazonaws.com/dev/approveapi/approve/$id';
//     try {
//       final response = await http.post(Uri.parse(url));
//       if (response.statusCode == 200) {
//         setState(() {
//           permitApplications.firstWhere(
//                   (application) => application['permitId'] == id)['status'] =
//               'Approved';
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Application $id approved')),
//         );
//       } else {
//         throw Exception('Failed to approve application');
//       }
//     } catch (error) {
//       print('Error approving application: $error');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error approving application')),
//       );
//     }
//   }

//   // Reject permit application locally
//   void _rejectApplication(String id) {
//     setState(() {
//       permitApplications.firstWhere(
//               (application) => application['permitId'] == id)['status'] =
//           'Rejected';
//     });
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Application $id rejected')),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Campsite Owner Home"),
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
//                 'Campsite Owner Menu',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 24,
//                 ),
//               ),
//             ),
//             ListTile(
//               leading: const Icon(Icons.home),
//               title: const Text('Home'),
//               onTap: () {
//                 Navigator.pushNamed(context, '/campsite_owner/home');
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.feedback),
//               title: const Text('Submit Feedback'),
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => const OwnerSubmitFeedbackScreen(),
//                   ),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: isLoading
//             ? const Center(child: CircularProgressIndicator())
//             : Column(
//                 children: [
//                   const Text(
//                     'Permit Applications',
//                     style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 16),
//                   Expanded(
//                     child: ListView(
//                       children: permitApplications.map((application) {
//                         return Card(
//                           child: ListTile(
//                             title: Text(
//                               'Permit ID: ${application['permitId']} - Location: ${application['location']}, ${application['area']} - Status: ${application['status']}',
//                             ),
//                             subtitle: Text(
//                               'Camper: ${application['createdBy']} - From: ${application['startDate']} to ${application['endDate']}',
//                             ),
//                             trailing: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 ElevatedButton(
//                                   onPressed: application['status'] == 'Pending'
//                                       ? () => _approveApplication(
//                                           application['permitId']!)
//                                       : null,
//                                   child: const Text('Approve'),
//                                 ),
//                                 const SizedBox(width: 8),
//                                 ElevatedButton(
//                                   onPressed: application['status'] == 'Pending'
//                                       ? () => _rejectApplication(
//                                           application['permitId']!)
//                                       : null,
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: Colors.red,
//                                   ),
//                                   child: const Text('Reject'),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         );
//                       }).toList(),
//                     ),
//                   ),
//                 ],
//               ),
//       ),
//     );
//   }
// }





//working with drawers

// import 'package:camplified/Screens/CampsiteOwner/owner_submit_feedback_screen.dart';
// import 'package:flutter/material.dart';

// class OwnerHomeScreen extends StatefulWidget {
//   const OwnerHomeScreen({super.key});

//   @override
//   State<OwnerHomeScreen> createState() => _CampsiteOwnerHomeScreenState();
// }

// class _CampsiteOwnerHomeScreenState extends State<OwnerHomeScreen> {
//   // Sample permit applications data
//   final List<Map<String, String>> permitApplications = [
//     {'id': '1', 'camper': 'John Doe', 'status': 'Pending'},
//     {'id': '2', 'camper': 'Jane Smith', 'status': 'Pending'},
//     {'id': '3', 'camper': 'Bob Johnson', 'status': 'Pending'},
//   ];

//   void _approveApplication(String id) {
//     setState(() {
//       permitApplications.firstWhere(
//           (application) => application['id'] == id)['status'] = 'Approved';
//     });
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Application $id approved')),
//     );
//   }

//   void _rejectApplication(String id) {
//     setState(() {
//       permitApplications.firstWhere(
//           (application) => application['id'] == id)['status'] = 'Rejected';
//     });
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Application $id rejected')),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Campsite Owner Home"),
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
//                 'Campsite Owner Menu',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 24,
//                 ),
//               ),
//             ),
//             ListTile(
//               leading: const Icon(Icons.home),
//               title: const Text('Home'),
//               onTap: () {
//                 Navigator.pushNamed(context, '/campsite_owner/home');
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.feedback),
//               title: const Text('Submit Feedback'),
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => const OwnerSubmitFeedbackScreen(),
//                   ),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             const Text(
//               'Permit Applications',
//               style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 16),
//             Expanded(
//               child: ListView(
//                 children: permitApplications.map((application) {
//                   return Card(
//                     child: ListTile(
//                       title: Text(
//                           'Camper: ${application['camper']} - Status: ${application['status']}'),
//                       trailing: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           ElevatedButton(
//                             onPressed: () =>
//                                 _approveApplication(application['id']!),
//                             child: const Text('Approve'),
//                           ),
//                           const SizedBox(width: 8),
//                           ElevatedButton(
//                             onPressed: () =>
//                                 _rejectApplication(application['id']!),
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.red,
//                             ),
//                             child: const Text('Reject'),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 }).toList(),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }




//original no drawers

// import 'package:camplified/Screens/CampsiteOwner/owner_submit_feedback_screen.dart';
// import 'package:flutter/material.dart';

// class OwnerHomeScreen extends StatefulWidget {
//   const OwnerHomeScreen({super.key});

//   @override
//   State<OwnerHomeScreen> createState() => _CampsiteOwnerHomeScreenState();
// }

// class _CampsiteOwnerHomeScreenState extends State<OwnerHomeScreen> {
//   // Sample permit applications data
//   final List<Map<String, String>> permitApplications = [
//     {'id': '1', 'camper': 'John Doe', 'status': 'Pending'},
//     {'id': '2', 'camper': 'Jane Smith', 'status': 'Pending'},
//     {'id': '3', 'camper': 'Bob Johnson', 'status': 'Pending'},
//   ];

//   void _approveApplication(String id) {
//     setState(() {
//       permitApplications.firstWhere(
//           (application) => application['id'] == id)['status'] = 'Approved';
//     });
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Application $id approved')),
//     );
//   }

//   void _rejectApplication(String id) {
//     setState(() {
//       permitApplications.firstWhere(
//           (application) => application['id'] == id)['status'] = 'Rejected';
//     });
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Application $id rejected')),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Campsite Owner Home"),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             const Text(
//               'Permit Applications',
//               style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 16),
//             Expanded(
//               child: ListView(
//                 children: permitApplications.map((application) {
//                   return Card(
//                     child: ListTile(
//                       title: Text(
//                           'Camper: ${application['camper']} - Status: ${application['status']}'),
//                       trailing: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           ElevatedButton(
//                             onPressed: () =>
//                                 _approveApplication(application['id']!),
//                             child: const Text('Approve'),
//                           ),
//                           const SizedBox(width: 8),
//                           ElevatedButton(
//                             onPressed: () =>
//                                 _rejectApplication(application['id']!),
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.red,
//                             ),
//                             child: const Text('Reject'),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 }).toList(),
//               ),
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () {
//                 // Navigate to the OwnerSubmitReviewScreen
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) => const OwnerSubmitFeedbackScreen()),
//                 );
//               },
//               child: const Text('Submit Feedback'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
