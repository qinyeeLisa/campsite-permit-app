// Suggested code may be subject to a license. Learn more: ~LicenseLog:2390663160.
import 'package:camplified/Screens/Camper/camper_home_screen.dart';
import 'package:camplified/Screens/Login/login_screen.dart';
import 'package:camplified/Screens/Register/register_screen.dart';
import 'package:camplified/Screens/login_signup.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '/constants.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: kBackgroundColor,
        body: SizedBox(
          width: double.infinity,
          height: size.height,
          child: Stack(
            alignment: Alignment.topCenter,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SvgPicture.asset(
                    'assets/images/main1.svg',
                    width: size.width,
                    height: size.height * 0.60,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    width: size.width,
                    padding: const EdgeInsets.only(top: 40, bottom: 10),
                    child: const Text(
                      'Camplified',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                      ),
                    ),
                  ),
                  Container(
                    width: size.width,
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: const Text(
                      'Connect with people and plan your next escape to explore this beautiful World!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.05),
                  _buildElevatedButton(context, "LOGIN", kPrimaryColor, Colors.white, () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()), // Navigate to Login screen
                  ),),
                  SizedBox(height: size.height * 0.03),
                  _buildElevatedButton(context, "SIGN UP", kPrimaryColor2, Colors.black, () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegisterScreen()), // Navigate to Sign Up screen
                  ),), // Use a different text color here
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildElevatedButton(BuildContext context, String text, Color buttonColor, Color textColor, VoidCallback onPressed) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.5,
      height: 60.0,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: textColor,
          backgroundColor: buttonColor, // Use the passed color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(80.0),
          ),
          padding: EdgeInsets.zero, // Removes padding around the button
          shadowColor: buttonColor.withOpacity(0.30), // Shadow color
          elevation: 20, // Adjusts shadow blur
        ),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(80.0),
            color: buttonColor, // Use the passed color
            boxShadow: [
              BoxShadow(
                color: buttonColor.withOpacity(0.30),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(0),
            child: Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: textColor, // Use the passed text color
              ),
            ),
          ),
        ),
      ),
    );
  }
}
