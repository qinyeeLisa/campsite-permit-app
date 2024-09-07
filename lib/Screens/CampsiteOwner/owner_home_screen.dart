import 'package:camplified/Screens/CampsiteOwner/owner_submit_feedback_screen.dart';
import 'package:flutter/material.dart';

class OwnerHomeScreen extends StatefulWidget {
  const OwnerHomeScreen({super.key});

  @override
  State<OwnerHomeScreen> createState() => _CampsiteOwnerHomeScreenState();
}

class _CampsiteOwnerHomeScreenState extends State<OwnerHomeScreen> {
  // Sample permit applications data
  final List<Map<String, String>> permitApplications = [
    {'id': '1', 'camper': 'John Doe', 'status': 'Pending'},
    {'id': '2', 'camper': 'Jane Smith', 'status': 'Pending'},
    {'id': '3', 'camper': 'Bob Johnson', 'status': 'Pending'},
  ];

  void _approveApplication(String id) {
    setState(() {
      permitApplications.firstWhere(
          (application) => application['id'] == id)['status'] = 'Approved';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Application $id approved')),
    );
  }

  void _rejectApplication(String id) {
    setState(() {
      permitApplications.firstWhere(
          (application) => application['id'] == id)['status'] = 'Rejected';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Application $id rejected')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Campsite Owner Home"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Permit Applications',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: permitApplications.map((application) {
                  return Card(
                    child: ListTile(
                      title: Text(
                          'Camper: ${application['camper']} - Status: ${application['status']}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton(
                            onPressed: () =>
                                _approveApplication(application['id']!),
                            child: const Text('Approve'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () =>
                                _rejectApplication(application['id']!),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: const Text('Reject'),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Navigate to the OwnerSubmitReviewScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const OwnerSubmitFeedbackScreen()),
                );
              },
              child: const Text('Submit Feedback'),
            ),
          ],
        ),
      ),
    );
  }
}





// import 'package:flutter/material.dart';

// class OwnerHomeScreen extends StatelessWidget {
//   const OwnerHomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Campsite Owner Home'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             ElevatedButton(
//               onPressed: () {
//                 // Navigate to the screen where the owner can submit feedback
//                 Navigator.pushNamed(context, '/campsite_owner/submit_feedback');
//               },
//               child: const Text('Submit Feedback'),
//             ),
//             const SizedBox(height: 20), // Add some spacing between buttons
//             ElevatedButton(
//               onPressed: () {
//                 // Navigate to the screen where the owner can approve permit applications
//                 Navigator.pushNamed(context, '/campsite_owner/approve_permit');
//               },
//               child: const Text('Approve Permit Applications'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
