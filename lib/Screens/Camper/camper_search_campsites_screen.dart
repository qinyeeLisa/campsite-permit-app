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

  Future<void> fetchCampsites() async {

    final apiKey = await fetchApiKey(); // Get the API key
    print(apiKey);

    if (apiKey == null) {
      print('API key retrieval failed.');
      return;
    }

    final url = Uri.parse(
        //'https://00xjqmjhij.execute-api.ap-southeast-1.amazonaws.com/dev2/campsitesapi/campsites/'
        'https://d24mqpbjn8370i.cloudfront.net/campsitesapi/campsites/'
         //'https://eqqd1j4q2j.execute-api.ap-southeast-1.amazonaws.com/dev/campsitesapi/campsites/'
        );
    try {
      //final response = await http.get(url);
      final response = await http.get(
        url,
        headers: {
          'x-api-key': apiKey, // Include the API key in the headers
          //'Access-Control-Allow-Origin': '*'

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
