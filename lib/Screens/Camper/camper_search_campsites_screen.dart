import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CamperSearchCampsitesScreen extends StatefulWidget {
  const CamperSearchCampsitesScreen({super.key});

  @override
  _CamperSearchCampsitesScreenState createState() =>
      _CamperSearchCampsitesScreenState();
}

class _CamperSearchCampsitesScreenState
    extends State<CamperSearchCampsitesScreen> {
  List<Map<String, dynamic>> campsites = [];
  List<Map<String, dynamic>> filteredCampsites = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchCampsites();
  }

  Future<void> fetchCampsites() async {

    // Get Firebase JWT token
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final idToken = await firebaseUser?.getIdToken();

    if (firebaseUser == null) {
      throw Exception('User is not authenticated');
    }

    if (idToken == null) {
      throw Exception('Unable to retrieve Firebase ID Token');
    }

    final url = Uri.parse(
        'https://00xjqmjhij.execute-api.ap-southeast-1.amazonaws.com/dev2/campsitesapi/campsites/'
        //'https://d24mqpbjn8370i.cloudfront.net/campsitesapi/campsites/'
        // 'https://eqqd1j4q2j.execute-api.ap-southeast-1.amazonaws.com/dev/campsitesapi/campsites/'
        );
    try {
      //final response = await http.get(url);
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $idToken',  // Add JWT token to Authorization header
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': "*", // Required for CORS support to work
          'Access-Control-Allow-Credentials': "true", // Required for cookies, authorization headers with HTTPS
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> campsiteData = json.decode(response.body);

        setState(() {
          campsites = campsiteData
              .map((data) => {
                    'campsiteId': data['campsiteId'],
                    'userId': data['userId'],
                    'address': data['address'],
                    'campsiteName': data['campsiteName'],
                    'size': data['size'],
                    'remarks': data['remarks'],
                    'createdBy': data['createdBy'],
                    'dateTimeCreated': data['dateTimeCreated'],
                    'updatedBy': data['updatedBy'],
                    'dateTimeUpdated': data['dateTimeUpdated'],
                  })
              .toList();
          filteredCampsites = List.from(campsites);
        });
      } else {
        throw Exception('Failed to load campsites');
      }
    } catch (e) {
      print('Error fetching campsites: $e');
    }
  }

  void filterCampsites(String query) {
    setState(() {
      filteredCampsites = campsites
          .where((campsite) =>
              campsite['campsiteName']
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              campsite['address'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Campsites'),
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
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: 'Search by Campsite Name or Address',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (query) {
                filterCampsites(query);
              },
            ),
            const SizedBox(height: 10),
            Expanded(
              child: filteredCampsites.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: filteredCampsites.length,
                      itemBuilder: (context, index) {
                        final campsite = filteredCampsites[index];
                        return Card(
                          child: ListTile(
                            title: Text(campsite['campsiteName']),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Address: ${campsite['address']}'),
                                Text('Size: ${campsite['size']}'),
                                Text('Remarks: ${campsite['remarks']}'),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
