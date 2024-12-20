import 'dart:convert';
import 'package:camplified/services/user_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class OwnerSubmitFeedbackScreen extends StatefulWidget {
  const OwnerSubmitFeedbackScreen({super.key});

  @override
  State<OwnerSubmitFeedbackScreen> createState() =>
      _OwnerSubmitFeedbackScreenState();
}

class _OwnerSubmitFeedbackScreenState extends State<OwnerSubmitFeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
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

  Future<void> _submitFeedback() async {
    if (_formKey.currentState!.validate()) {
      final String title = _titleController.text;
      final String description = _descriptionController.text;

      final user = await Provider.of<UserProvider>(context, listen: false).getUser();
      int userId = user?.userId ?? 0;

      // Feedback data
      final Map<String, dynamic> feedbackData = {
        "userId": userId, // Replace this with dynamic userId if needed
        "title": title,
        "description": description,
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
          //"https://d24mqpbjn8370i.cloudfront.net/feedbackapi/feedback/AddFeedback/";
           'https://eqqd1j4q2j.execute-api.ap-southeast-1.amazonaws.com/dev/feedbackapi/feedback/AddFeedback/';
      try {
        // Make the POST request
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {
            "Content-Type": "application/json",
            'x-api-key': apiKey
          },
          body: jsonEncode(feedbackData),
        );

        if (response.statusCode == 200) {
          // Show a success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Feedback Submitted!')),
          );
          // Navigate back to the previous screen (CampsiteOwnerHomeScreen)
          Navigator.pushReplacementNamed(context, '/campsite_owner/home');
        } else {
          // Show an error message if submission failed
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to submit feedback')),
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
        title: const Text("Submit Feedback"),
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
                'Title',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'Enter feedback title',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Description',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  hintText: 'Enter your feedback description',
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
              Center(
                child: ElevatedButton(
                  onPressed: _submitFeedback,
                  child: const Text('Submit Feedback'),
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

// class OwnerSubmitFeedbackScreen extends StatefulWidget {
//   const OwnerSubmitFeedbackScreen({super.key});

//   @override
//   State<OwnerSubmitFeedbackScreen> createState() =>
//       _OwnerSubmitReviewScreenState();
// }

// class _OwnerSubmitReviewScreenState extends State<OwnerSubmitFeedbackScreen> {
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
//       // Perform feedback submission logic here

//       // Show a success message
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Feedback Submitted!')),
//       );

//       // Navigate back to the previous screen (CampsiteOwnerHomeScreen)
//       Navigator.pop(context);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Submit Feedback"),
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
