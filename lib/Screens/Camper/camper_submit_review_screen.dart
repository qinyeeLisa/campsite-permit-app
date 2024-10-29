import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../services/user_provider.dart';

class CamperSubmitReviewScreen extends StatefulWidget {
  const CamperSubmitReviewScreen({super.key});

  @override
  State<CamperSubmitReviewScreen> createState() =>
      _CamperSubmitReviewScreenState();
}

class _CamperSubmitReviewScreenState extends State<CamperSubmitReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _ratingController = TextEditingController();
  int? _selectedRating;

  @override
  void dispose() {
    _descriptionController.dispose();
    _ratingController.dispose();
    super.dispose();
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

  Future<void> _submitReview() async {
    if (_formKey.currentState!.validate()) {
      final String description = _descriptionController.text;
      final int rating = _selectedRating!;
      final user = await Provider.of<UserProvider>(context, listen: false).getUser();
      int userId = user?.userId ?? 0;

      // Review data
      final Map<String, dynamic> reviewData = {
        "userId": userId, // Replace this with dynamic userId if needed
        "description": description,
        "rating": rating,
        'CreatedBy': user?.fullName,
        'UpdatedBy': user?.fullName
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


      // API URL
      const String apiUrl =
          //"https://d24mqpbjn8370i.cloudfront.net/ratingsapi/rating/AddRating/";
          'https://eqqd1j4q2j.execute-api.ap-southeast-1.amazonaws.com/dev/ratingsapi/rating/AddRating/';
      try {
        // Make the POST request
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {
            "Content-Type": "application/json",
            'x-api-key': apiKey
          },
          body: jsonEncode(reviewData),
        );

        if (response.statusCode == 200) {
          // Show a success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Review Submitted!')),
          );
          // Navigate back to the previous screen (CamperHomeScreen)
          Navigator.pushReplacementNamed(context, '/camper/home');
        } else {
          // Show an error message if submission failed
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to submit review')),
          );
        }
      } catch (error) {
        // Handle network errors
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Submit Review"),
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Description',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  hintText: 'Enter review description',
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Rating (1 - Worse, 5 - Best)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              DropdownButtonFormField<int>(
                value: _selectedRating,
                decoration: const InputDecoration(
                  hintText: 'Select a rating',
                ),
                items: List.generate(5, (index) => index + 1)
                    .map((rating) => DropdownMenuItem<int>(
                          value: rating,
                          child: Text(rating.toString()),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRating = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a rating';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: _submitReview,
                  child: const Text('Submit Review'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}





//original
// import 'package:flutter/material.dart';

// class CamperSubmitReviewScreen extends StatefulWidget {
//   const CamperSubmitReviewScreen({super.key});

//   @override
//   State<CamperSubmitReviewScreen> createState() =>
//       _CamperSubmitReviewScreenState();
// }

// class _CamperSubmitReviewScreenState extends State<CamperSubmitReviewScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _subjectController = TextEditingController();
//   final TextEditingController _contentController = TextEditingController();

//   @override
//   void dispose() {
//     _subjectController.dispose();
//     _contentController.dispose();
//     super.dispose();
//   }

//   void _submitFeedback() {
//     if (_formKey.currentState!.validate()) {
//       // Perform the feedback submission logic here
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Feedback Submitted!')),
//       );
//       // Navigate back to the previous screen (CamperHomeScreen)
//       Navigator.pop(context);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Submit Review"),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 'Subject',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               TextFormField(
//                 controller: _subjectController,
//                 decoration: const InputDecoration(
//                   hintText: 'Enter subject',
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter a subject';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),
//               const Text(
//                 'Content',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               TextFormField(
//                 controller: _contentController,
//                 decoration: const InputDecoration(
//                   hintText: 'Enter your feedback',
//                 ),
//                 maxLines: 5,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter content';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),
//               Center(
//                 child: ElevatedButton(
//                   onPressed: _submitFeedback,
//                   child: const Text('Submit Feedback'),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
