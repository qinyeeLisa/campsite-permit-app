import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CamperEnquireStatusScreen extends StatefulWidget {
  const CamperEnquireStatusScreen({super.key});

  @override
  State<CamperEnquireStatusScreen> createState() =>
      _CamperEnquireStatusScreenState();
}

class _CamperEnquireStatusScreenState extends State<CamperEnquireStatusScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Enquiry Status"),
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
    );
  }
}
