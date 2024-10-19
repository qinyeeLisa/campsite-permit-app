// providers/user_provider.dart
import 'package:camplified/model/user_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider with ChangeNotifier {
  UserModel? _user;
  SharedPreferences? _prefs;

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  UserProvider() {
    _initPrefs();
  }

  UserModel? get user => _user;

  Future<void> setUser(UserModel user) async {
    _user = user;
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setInt('userId', user.userId!);
    await prefs.setString('email', user.email);
    await prefs.setString('fullName', user.fullName);
    await prefs.setInt('role', user.role);
    notifyListeners();
  }

  Future<UserModel?> getUser() async {
    print('Getting user data...');
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    final email = prefs.getString('email');
    final fullName = prefs.getString('fullName');
    final role = prefs.getInt('role');
    print('User data: $userId, $email, $fullName, $role');
    if (userId != null && email != null && fullName != null && role != null) {
      _user = UserModel(
        userId: userId,
        email: email,
        fullName: fullName,
        role: role,
      );
    } else {
      print('User data is null!');
    }
    return _user;
  }
}