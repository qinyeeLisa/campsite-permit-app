import 'package:flutter/material.dart';

class CamperSubmitReviewScreen extends StatefulWidget {
  const CamperSubmitReviewScreen({super.key});

  @override
  State<CamperSubmitReviewScreen> createState() =>
      _CamperSubmitReviewScreenState();
}

class _CamperSubmitReviewScreenState extends State<CamperSubmitReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  @override
  void dispose() {
    _subjectController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _submitFeedback() {
    if (_formKey.currentState!.validate()) {
      // Perform the feedback submission logic here
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Feedback Submitted!')),
      );
      // Navigate back to the previous screen (CamperHomeScreen)
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Submit Review"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Subject',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(
                  hintText: 'Enter subject',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a subject';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Content',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  hintText: 'Enter your feedback',
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter content';
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
