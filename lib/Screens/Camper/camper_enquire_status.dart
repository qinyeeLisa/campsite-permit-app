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
        title: Text("CamperEnquireStatusScreen"),
      ),
    );
  }
}
