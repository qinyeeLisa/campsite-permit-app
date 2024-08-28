import 'package:flutter/material.dart';

class CamperApplyPermitScreen extends StatefulWidget {
  const CamperApplyPermitScreen({super.key});

  @override
  State<CamperApplyPermitScreen> createState() =>
      _CamperApplyPermitScreenState();
}

class _CamperApplyPermitScreenState extends State<CamperApplyPermitScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("CamperApplyPermitScreen"),
      ),
    );
  }
}
