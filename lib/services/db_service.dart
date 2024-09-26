import 'dart:developer';

import 'package:camplified/model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService{
  final _firebase = FirebaseFirestore.instance;

  createUser(UserModel user){
    try{
      _firebase.collection('users').add({
        'name': 'John',
        'age': 30
      });
    }catch(e){
      log(e.toString());
    }
  }

  retrieveUsers(String email, String password) async{
    try{
      final user = await _firebase.collection('users')
        .where('email', isEqualTo: email)
        .where('password', isEqualTo: password)
        .get();
    }catch(e){
      log(e.toString());
    }
  }
}