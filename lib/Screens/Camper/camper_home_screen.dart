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

  Future<String?> fetchApiKey() async {
    final url = Uri.parse('https://eqqd1j4q2j.execute-api.ap-southeast-1.amazonaws.com/dev/fetchapikey/'); // Your API Gateway URL here
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Decode the response body first
        final decodedBody = json.decode(response.body);
        // Then access the inner body
        final innerBody = json.decode(decodedBody['body']);
        return innerBody['apiKey'];  // Access the actual API key
      } else {
        throw Exception('Failed to load API key');
      }
    } catch (e) {
      print('Error fetching API key: $e');
      return null; // or handle error accordingly
    }
  }

  Future<void> fetchPermits() async {
    final user = await Provider.of<UserProvider>(context, listen: false).getUser();
    int userId = user?.userId ?? 0;

    // Get Firebase JWT token
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final idToken = await firebaseUser?.getIdToken();

    if (firebaseUser == null) {
      throw Exception('User is not authenticated');
    }

    if (idToken == null) {
      throw Exception('Unable to retrieve Firebase ID Token');
    }
/*    print("JWTToken");
    print(idToken);*/

    final rawApiKey = await fetchApiKey(); // Get the API key

    //print(rawApiKey);

    if (rawApiKey == null) {
      print('API key retrieval failed.');
      return;
    }

    // Parse the JSON to extract only the API key value
    final apiKeyData = json.decode(rawApiKey); // Decode JSON if needed
    final apiKey = apiKeyData['APIKey']; // Access the 'apiKey' value

    //print(apiKey); // Should print only the API key value as a string


    final url = Uri.parse(
        'https://eqqd1j4q2j.execute-api.ap-southeast-1.amazonaws.com/dev/permitapi/permit/GetPermit/$userId'
        //'https://d24mqpbjn8370i.cloudfront.net/permitapi/permit/GetPermit/$userId'
    );
    try {
      //final response = await http.get(url);
      final response = await http.get(
        url,
        headers: {
          'x-api-key': apiKey,
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
        title: const Text('Camper Dashboard'),
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

