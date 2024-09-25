import 'package:camplified/Screens/Admin/admin_home_screen.dart';
import 'package:camplified/Screens/Camper/camper_apply_permit_screen.dart';
import 'package:camplified/Screens/Camper/camper_home_screen.dart';
import 'package:camplified/Screens/Camper/camper_enquire_status_screen.dart';
import 'package:camplified/Screens/Camper/camper_search_campsites_screen.dart';
import 'package:camplified/Screens/Camper/camper_submit_review_screen.dart';
import 'package:camplified/Screens/CampsiteOwner/owner_home_screen.dart';
import 'package:camplified/Screens/Register/register_screen.dart';
import 'package:camplified/Screens/Welcome/welcome.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'Screens/Login/login_screen.dart';
import 'constants.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  //Initialize Firebase for Web
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions
      (   
        apiKey: "AIzaSyCppfz3AOTw3EsVoh3DZhOZGWDjI0G0Z8E",
        authDomain: "cpas-auth.firebaseapp.com",
        projectId: "cpas-auth",
        storageBucket: "cpas-auth.appspot.com",
        messagingSenderId: "708697230446",
        appId: "1:708697230446:web:4584fde96ce49094bcea7f",
        measurementId: "G-GEW9QCR6TR"
      )
    );
  }
  else {
    await Firebase.initializeApp();
  }

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
        home: const LoginScreen(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/welcome': (context) => const WelcomeScreen(),
          '/camper/home': (context) => const CamperHomeScreen(),
          '/camper/apply_permit': (context) => const CamperApplyPermitScreen(),
          '/camper/enquire_status': (context) =>
              const CamperEnquireStatusScreen(),
          '/camper/submit_review': (context) =>
              const CamperSubmitReviewScreen(),
          '/camper/search_campsites': (context) =>
              const CamperSearchCampsitesScreen(),
          '/campsite_owner/home': (context) => const OwnerHomeScreen(),
          '/admin/home': (context) => const AdminHomeScreen(),
        });
  }
}
