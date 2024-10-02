import 'dart:developer';

import 'package:camplified/model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService{
  final _firebase = FirebaseFirestore.instance;

  createUser(UserModel user){
    try{
      _firebase.collection('users').add({
        'fullName': user.fullName,
        'email': user.email,
        //'password': user.password,
        'role': user.role,
        'DateTimeCreated': user.dateTimeCreated,
        'DateTimeUpdated': user.dateTimeUpdated,
      });

      return true;
    }catch(e){
      log(e.toString());
    }
  }

  retrieveUsers(String email) async{
    try{
      final userDoc = await _firebase.collection('users')
        .where('email', isEqualTo: email)
        .get();

      return userDoc.docs.first.data() as Map<String, dynamic>;
    }catch(e){
      log(e.toString());
    }
  }

  Future<bool> checkUserExist(String email) async{
    try{
      final userDoc = await _firebase.collection('users')
        .where('email', isEqualTo: email)
        .get();

        if (userDoc.size > 0) {
          return true;
        } else {
          return false;
        }
      } catch(e){
      log(e.toString());
      return false;
    }
  }
}