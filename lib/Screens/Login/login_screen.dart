import 'package:camplified/model/user_model.dart';
import 'package:camplified/services/db_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';
import '../../services/user_provider.dart';

String? validateEmail(String value) {
  RegExp regex =
      RegExp(r"^[a-z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]"
          r"{0,253}[a-z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]"
          r"{0,253}[a-z0-9])?)*$");
  if (!regex.hasMatch(value) || value == null)
    return "Please enter a valid email address";
  else
    return null;
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPasswordVisible = false;
  String _email = '';
  String _password = '';

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  //Initialize services
  final databaseService = DatabaseService();
  final _auth = AuthService();

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
                controller: _emailController,
                validator: (value) => validateEmail(value!),
                onSaved: (value) {
                  _email = value!;
                },
              ),
              TextFormField(
                obscureText: !_isPasswordVisible,
                controller: _passwordController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a valid password';
                  } else if (value.length < 6) {
                    return 'Password must be at least 6 characters long';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
                onSaved: (value) {
                  _password = value!;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  login();
                },
                child: const Text('Login'),
              ),
              SizedBox(height: size.height * 0.01),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    style: const TextStyle(fontSize: 16),
                    'Don\'t have an account?',
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    child: const Text('Sign Up'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void login() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      dynamic result =
          await _auth.loginUserWithEmailAndPassword(_email, _password);

      if (result == null) {
        _showErrorDialog();
      } else {
        dynamic userData = await databaseService.retrieveUsers(_email);

        int role = userData['role'];

        UserModel user = UserModel(
            email: userData['email'],
            fullName: userData['fullName'],
            role: userData['role'],
            dateTimeCreated: userData['dateTimeCreated'],
            dateTimeUpdated: userData['dateTimeUpdated']);

        Provider.of<UserProvider>(context, listen: false).setUser(user);

        if (role == 2) {
          Navigator.pushNamed(context, '/admin/home');
        } else if (role == 1) {
          Navigator.pushNamed(context, '/campsite_owner/home');
        } else {
          Navigator.pushNamed(context, '/camper/home');
        }
      }
    }
  }

  void _showErrorDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: new Text("Error"),
            content: new SingleChildScrollView(
              child: new ListBody(
                children: [
                  new Text("Invalid email/password! Please try again!"),
                ],
              ),
            ),
            actions: [
              new TextButton(
                child: new Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }
}
