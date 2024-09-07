import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:camplified/amplify_configuration.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const LoginSignupScreen());
}

class LoginSignupScreen extends StatefulWidget {
  const LoginSignupScreen({super.key});

  @override
  State<LoginSignupScreen> createState() => _LoginSignupScreenState();
}

class _LoginSignupScreenState extends State<LoginSignupScreen> {
  bool isSignIn = false;
  bool isLoading = true; // Add a loading state

  @override
  void initState() {
    super.initState();
    _configureAmplify();
  }

  Future<void> _configureAmplify() async {
    try {
      final auth = AmplifyAuthCognito();
      await Amplify.addPlugin(auth);
      await Amplify.configure(amplifyconfig);
      fetchAuthSession();
      safePrint('Successfully configured');
    } on Exception catch (e) {
      safePrint('An error occurred configuring Amplify: $e');
    }
  }

  Future<void> fetchAuthSession() async {
    try {
      final result = await Amplify.Auth.fetchAuthSession();
      setState(() {
        isSignIn = result.isSignedIn;
        isLoading = false; // Stop loading once the session is fetched
      });
      safePrint('User is signed in: ${result.isSignedIn}');
    } on AuthException catch (e) {
      safePrint('Error retrieving auth session: ${e.message}');
      setState(() {
        isLoading = false; // Stop loading even on error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Authenticator(
      child: MaterialApp(
        builder: Authenticator.builder(),
        home: Scaffold(
          body: Center(
            child: isLoading
                ? const CircularProgressIndicator() // Show a loading spinner while waiting
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      isSignIn
                          ? const Text('User is signed in')
                          : const Text('User is not signed in'),
                      const SignOutButton(),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
