import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService{
  final _auth = FirebaseAuth.instance;

  Future<User?> createUserWithEmailAndPassword(String email, String password) async{
    try{
      final results = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return results.user;
    }
    catch(e){
      log("Something went wrong. $e");
    }
    return null;
  }

  Future<User?> loginUserWithEmailAndPassword(String email, String password) async{
    try{
      final results = await _auth.signInWithEmailAndPassword(email: email, password: password);
      ////////////below code is for jwt token
      final user = results.user;
      if (user != null) {
        // Get the JWT token
        final idToken = await user.getIdToken();
        // Print the JWT token to the console
        log("JWT Token: $idToken");
        //return idToken; // Return the JWT token
      }
      ////////////

      return results.user;
    }
    catch(e){
      log("Something went wrong. $e");
    }
    return null;
  }

  Future<void> signOut() async{
    try{
      await _auth.signOut();
    }
    catch(e){
      log("Something went wrong. $e");
    }
  }

  //Google Auth
  Future<UserCredential?> signInWithGoogle() async {
    try {
      GoogleSignIn _googleSignIn = GoogleSignIn(
      clientId: '708697230446-ovbqtvr4m9pi0hos0bm5q2lnp2c1g7b8.apps.googleusercontent.com', // Client ID from Firebase console
      scopes: <String>[
        'email',
      ],
    );

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      //below for jwt token
     /* final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        // Get the JWT token
        final idToken = await user.getIdToken();
        return idToken; // Return the JWT token
      }*/
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      log("Something went wrong. $e");
    }
    return null;

  } 
}