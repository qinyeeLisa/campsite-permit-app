import 'package:flutter/material.dart';

class OwnerHomeScreen extends StatelessWidget {
  const OwnerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campsite Owner Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                // Navigate to the screen where the owner can submit feedback
                Navigator.pushNamed(context, '/campsite_owner/submit_feedback');
              },
              child: const Text('Submit Feedback'),
            ),
            const SizedBox(height: 20), // Add some spacing between buttons
            ElevatedButton(
              onPressed: () {
                // Navigate to the screen where the owner can approve permit applications
                Navigator.pushNamed(context, '/campsite_owner/approve_permit');
              },
              child: const Text('Approve Permit Applications'),
            ),
          ],
        ),
      ),
    );
  }
}
