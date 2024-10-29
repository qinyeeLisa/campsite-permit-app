import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../services/user_provider.dart';

class CamperApplyPermitScreen extends StatefulWidget {
  const CamperApplyPermitScreen({super.key});

  @override
  State<CamperApplyPermitScreen> createState() =>
      _CamperApplyPermitScreenState();
}

class _CamperApplyPermitScreenState extends State<CamperApplyPermitScreen> {
  // Dropdown options
  final List<String> _locations = [
    'No Selection',
    'East Coast Park',
    'Pasir Ris Park',
    'West Coast Park',
    'Changi Beach Park'
  ];

  final List<String> _areas = [
    'No Selection',
    'North',
    'South',
    'East',
    'West'
  ];

  // Selected values
  String _selectedLocation = 'No Selection';
  String _selectedArea = 'No Selection';

  // Date fields
  DateTime? _startDate;
  DateTime? _endDate;
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  // Function to pick a date
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          _startDate = pickedDate;
        } else {
          _endDate = pickedDate;
        }
      });
    }
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

  // Function to submit permit application
  Future<void> _submitPermitApplication() async {
    if (_selectedLocation == 'No Selection' ||
        _selectedArea == 'No Selection') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a location and an area.')),
      );
      return;
    }

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select both start and end dates.')),
      );
      return;
    }

    final user = await Provider.of<UserProvider>(context, listen: false).getUser();
    int userId = user?.userId ?? 0;

    // Prepare data for submission
    final permitData = {
      'UserId': userId, // Replace with actual user ID
      'StartDate': _dateFormat.format(_startDate!),
      'EndDate': _dateFormat.format(_endDate!),
      'Location': _selectedLocation,
      'Area': _selectedArea,
      'CreatedBy': user?.fullName,
      'UpdatedBy': user?.fullName
      // Add other necessary fields based on the API
    };

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

    const url =
        //'https://d24mqpbjn8370i.cloudfront.net/permitapi/permit/createpermit';
        'https://eqqd1j4q2j.execute-api.ap-southeast-1.amazonaws.com/dev/permitapi/permit/createpermit';
    try {
      // Send the POST request
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': apiKey
        },
        body: jsonEncode(permitData),
      );

      if (response.statusCode == 200) {
        // If the server returns a successful response
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Permit application submitted successfully!')),
        );
        Navigator.pop(context, 'refresh'); // Pass true to indicate a refresh
      } else {
        // If the server did not return a 200 OK response
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Failed to submit permit. Error: ${response.body}')),
        );
      }
    } catch (e) {
      // Handle connection errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Permit Application"),
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Location Dropdown
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(),
              ),
              value: _selectedLocation,
              items: _locations.map((location) {
                return DropdownMenuItem(
                  value: location,
                  child: Text(location),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedLocation = newValue!;
                });
              },
            ),
            const SizedBox(height: 20),

            // Area Dropdown
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Campsite Area',
                border: OutlineInputBorder(),
              ),
              value: _selectedArea,
              items: _areas.map((area) {
                return DropdownMenuItem(
                  value: area,
                  child: Text(area),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedArea = newValue!;
                });
              },
            ),
            const SizedBox(height: 20),

            // Start Date Picker
            TextFormField(
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Start Date',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context, true),
                ),
              ),
              controller: TextEditingController(
                text: _startDate != null ? _dateFormat.format(_startDate!) : '',
              ),
            ),
            const SizedBox(height: 20),

            // End Date Picker
            TextFormField(
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'End Date',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context, false),
                ),
              ),
              controller: TextEditingController(
                text: _endDate != null ? _dateFormat.format(_endDate!) : '',
              ),
            ),
            const SizedBox(height: 20),

            // Submit Button
            Center(
              child: ElevatedButton(
                onPressed: _submitPermitApplication,
                child: const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}




//original without api
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart'; // For date formatting

// class CamperApplyPermitScreen extends StatefulWidget {
//   const CamperApplyPermitScreen({super.key});

//   @override
//   State<CamperApplyPermitScreen> createState() =>
//       _CamperApplyPermitScreenState();
// }

// class _CamperApplyPermitScreenState extends State<CamperApplyPermitScreen> {
//   // Dropdown options
//   final List<String> _locations = [
//     'No Selection',
//     'East Coast Park',
//     'Pasir Ris Park',
//     'West Coast Park',
//     'Changi Beach Park'
//   ];

//   final List<String> _areas = [
//     'No Selection',
//     'North',
//     'South',
//     'East',
//     'West'
//   ];

//   // Selected values
//   String _selectedLocation = 'No Selection';
//   String _selectedArea = 'No Selection';

//   // Date fields
//   DateTime? _startDate;
//   DateTime? _endDate;

//   final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

//   // Function to pick a date
//   Future<void> _selectDate(BuildContext context, bool isStartDate) async {
//     DateTime? pickedDate = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2101),
//     );

//     if (pickedDate != null) {
//       setState(() {
//         if (isStartDate) {
//           _startDate = pickedDate;
//         } else {
//           _endDate = pickedDate;
//         }
//       });
//     }
//   }

//   void _submitPermitApplication() {
//     // Handle submission logic
//     if (_selectedLocation == 'No Selection' ||
//         _selectedArea == 'No Selection') {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please select a location and an area.')),
//       );
//       return;
//     }

//     if (_startDate == null || _endDate == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//             content: Text('Please select both start and end dates.')),
//       );
//       return;
//     }

//     // Example submission logic
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//           content: Text('Permit application submitted successfully!')),
//     );

//     // Navigate back to the previous screen (CamperHomeScreen)
//     Navigator.pop(context);

//     // Implement further submission logic such as sending data to a server
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Permit Application"),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: <Widget>[
//             // Location Dropdown
//             DropdownButtonFormField<String>(
//               decoration: const InputDecoration(
//                 labelText: 'Location',
//                 border: OutlineInputBorder(),
//               ),
//               value: _selectedLocation,
//               items: _locations.map((location) {
//                 return DropdownMenuItem(
//                   value: location,
//                   child: Text(location),
//                 );
//               }).toList(),
//               onChanged: (newValue) {
//                 setState(() {
//                   _selectedLocation = newValue!;
//                 });
//               },
//             ),
//             const SizedBox(height: 20),

//             // Area Dropdown
//             DropdownButtonFormField<String>(
//               decoration: const InputDecoration(
//                 labelText: 'Campsite Area',
//                 border: OutlineInputBorder(),
//               ),
//               value: _selectedArea,
//               items: _areas.map((area) {
//                 return DropdownMenuItem(
//                   value: area,
//                   child: Text(area),
//                 );
//               }).toList(),
//               onChanged: (newValue) {
//                 setState(() {
//                   _selectedArea = newValue!;
//                 });
//               },
//             ),
//             const SizedBox(height: 20),

//             // Start Date Picker
//             TextFormField(
//               readOnly: true,
//               decoration: InputDecoration(
//                 labelText: 'Start Date',
//                 border: const OutlineInputBorder(),
//                 suffixIcon: IconButton(
//                   icon: const Icon(Icons.calendar_today),
//                   onPressed: () => _selectDate(context, true),
//                 ),
//               ),
//               controller: TextEditingController(
//                 text: _startDate != null ? _dateFormat.format(_startDate!) : '',
//               ),
//             ),
//             const SizedBox(height: 20),

//             // End Date Picker
//             TextFormField(
//               readOnly: true,
//               decoration: InputDecoration(
//                 labelText: 'End Date',
//                 border: const OutlineInputBorder(),
//                 suffixIcon: IconButton(
//                   icon: const Icon(Icons.calendar_today),
//                   onPressed: () => _selectDate(context, false),
//                 ),
//               ),
//               controller: TextEditingController(
//                 text: _endDate != null ? _dateFormat.format(_endDate!) : '',
//               ),
//             ),
//             const SizedBox(height: 20),

//             // Submit Button
//             Center(
//               child: ElevatedButton(
//                 onPressed: _submitPermitApplication,
//                 child: const Text('Submit'),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
