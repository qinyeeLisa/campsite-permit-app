import 'package:flutter/material.dart';

class OwnerHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Campsite Owner Home'),
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
              child: Text('Submit Feedback'),
            ),
            SizedBox(height: 20), // Add some spacing between buttons
            ElevatedButton(
              onPressed: () {
                // Navigate to the screen where the owner can approve permit applications
                Navigator.pushNamed(context, '/campsite_owner/approve_permit');
              },
              child: Text('Approve Permit Applications'),
            ),
          ],
        ),
      ),
    );
  }
}
