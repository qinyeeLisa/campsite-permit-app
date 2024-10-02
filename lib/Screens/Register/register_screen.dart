import 'package:camplified/Screens/Register/Components/social_sign_up.dart';
import 'package:camplified/model/user_model.dart';
import 'package:camplified/services/auth_service.dart';
import 'package:camplified/services/db_service.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _dbService = DatabaseService();

  final _formKey = GlobalKey<FormState>();
  final _auth = AuthService();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  String _email = '';
  String _password = '';
  String _confirmPassword = '';
  
  //To control password visibility
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  int _selectedRoleIndex = 0; // Initialize with the index of the default role

  List<String> _roles = ['Camper', 'Campsite Owner'];


  void _register() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      bool userExist = await _dbService.checkUserExist(_email);

      if (userExist) {
        _showSignUpErrorDialog('Account exists. Please login with your credentials!');
      }
      else{
        // Create user with email and password
        final user =
            await _auth.createUserWithEmailAndPassword(_email, _password);

        UserModel userModel = UserModel(
          fullName: _nameController.text,
          email: _email,
          role: _selectedRoleIndex
          // dateTimeCreated: DateTime.now(),
          // dateTimeUpdated: DateTime.now(),
        );

        // Create user in database
        dynamic result = await _dbService.createUser(userModel);

        if (user != null && result == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registered $_email successfully!')),
          );

          // Navigate to login or home screen
          Navigator.pushNamed(context, '/login');
        }else{
          _showSignUpErrorDialog('Error on signing up. Please try again!');
        }
      }
    }
  }

  void _showSignUpErrorDialog(String errorText) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: new Text("Error"),
            content: new SingleChildScrollView(
              child: new ListBody(
                children: [
                  new Text(errorText),
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

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _email = value!;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
                onSaved: (value) {
                  _email = value!;
                },
              ),
              TextFormField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a valid password';
                  } else if (value.length < 6) {
                    return 'Password must be at least 6 characters long';
                  }
                  return null;
                },
                onSaved: (value) {
                  _password = value!;
                },
              ),
              TextFormField(
                obscureText: !_isConfirmPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isConfirmPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  } else if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
                onSaved: (value) {
                  _confirmPassword = value!;
                },
              ),
              SizedBox(height: size.height * 0.01),
              Row(
                children: [
                  const Text('Select Role: '),
                  DropdownButton(
                    value: _selectedRoleIndex,
                    items: _roles.asMap().entries.map((entry) {
                      return DropdownMenuItem<int>(
                        value: entry.key,
                        child: Text(entry.value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedRoleIndex = value!;
                      });
                    },
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: _register,
                child: const Text('Register'),
              ),
              SizedBox(height: size.height * 0.01),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    style: const TextStyle(fontSize: 16),
                    'Already have an account?',         
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    child: const Text('Login here'),
                  ),
                ],
              ),
              SocialSignUp(),
            ],
          ),
        ),
      ),
    );
  }
}
