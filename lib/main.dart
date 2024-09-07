import 'package:camplified/Screens/Admin/admin_home_screen.dart';
import 'package:camplified/Screens/Camper/camper_apply_permit_screen.dart';
import 'package:camplified/Screens/Camper/camper_home_screen.dart';
import 'package:camplified/Screens/Camper/camper_enquire_status.dart';
import 'package:camplified/Screens/Camper/camper_submit_review.dart';
import 'package:camplified/Screens/CampsiteOwner/owner_home_screen.dart';
import 'package:camplified/Screens/Welcome/welcome.dart';
import 'package:camplified/Screens/login_signup.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Campsite Permit Application',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: kPrimaryColor,
          textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
          scaffoldBackgroundColor: Colors.white,
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const LoginSignupScreen(),
        routes: {
          '/auth': (context) => const LoginSignupScreen(),
          '/camper/home': (context) => const CamperHomeScreen(),
          '/camper/apply_permit': (context) => const CamperApplyPermitScreen(),
          '/camper/enquire_status': (context) =>
              const CamperEnquireStatusScreen(),
          '/camper/submit_review': (context) =>
              const CamperSubmitReviewScreen(),
          '/campsite_owner/home': (context) => const OwnerHomeScreen(),
          '/admin/home': (context) => const AdminHomeScreen(),
        });
  }
}
