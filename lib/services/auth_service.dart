import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';

class AuthService{
  final _auth = FirebaseAuth.instance;

  Future<User?> createUserWithEmailAndPassword(String email, String password) async{
    try{
      final results = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      //await DatabaseServices(uid: user.uid).updateUserData(user.uid,name, email);
      return results.user;
    }
    catch(e){
      log("Something went wrong.");
    }
    return null;
  }

  Future<User?> loginUserWithEmailAndPassword(String email, String password) async{
    try{
      final results = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return results.user;
    }
    catch(e){
      log("Something went wrong.");
    }
    return null;
  }

  Future<void> signOut() async{
    try{
      await _auth.signOut();
    }
    catch(e){
      log("Something went wrong.");
    }
  }
}