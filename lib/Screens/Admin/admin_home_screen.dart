import 'package:flutter/material.dart';

class AdminHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                // Navigate to the screen where the admin can manage users
                Navigator.pushNamed(context, '/admin/manage_users');
              },
              child: Text('Manage Users'),
            ),
            SizedBox(height: 20), // Add some spacing between buttons
            ElevatedButton(
              onPressed: () {
                // Navigate to the screen where the admin can oversee permit applications
                Navigator.pushNamed(context, '/admin/oversee_permits');
              },
              child: Text('Oversee Permit Applications'),
            ),
          ],
        ),
      ),
    );
  }
}
