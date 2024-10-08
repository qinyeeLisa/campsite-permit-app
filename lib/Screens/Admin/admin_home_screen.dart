import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Home'),
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                // Navigate to the screen where the admin can manage users
                Navigator.pushNamed(context, '/admin/manage_users');
              },
              child: const Text('Manage Users'),
            ),
            const SizedBox(height: 20), // Add some spacing between buttons
            ElevatedButton(
              onPressed: () {
                // Navigate to the screen where the admin can oversee permit applications
                Navigator.pushNamed(context, '/admin/oversee_permits');
              },
              child: const Text('Oversee Permit Applications'),
            ),
          ],
        ),
      ),
    );
  }
}
