import 'package:flutter/material.dart';

class CamperSubmitReviewScreen extends StatefulWidget {
  const CamperSubmitReviewScreen({super.key});

  @override
  State<CamperSubmitReviewScreen> createState() =>
      _CamperSubmitReviewScreenState();
}

class _CamperSubmitReviewScreenState extends State<CamperSubmitReviewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Submit Review"),
      ),
    );
  }
}
