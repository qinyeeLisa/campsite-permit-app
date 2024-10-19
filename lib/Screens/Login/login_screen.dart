import 'package:camplified/Screens/Shared/full_screen_loader.dart';
import 'package:camplified/model/user_model.dart';
import 'package:camplified/services/db_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';
import '../../services/user_provider.dart';
import 'Components/social_sign_in.dart';

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

  void login() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      dynamic result =
          await _auth.loginUserWithEmailAndPassword(_email, _password);

      if (result == null) {
        _showErrorDialog("Invalid email/password! Please try again!");
      } else {
        

        await existingUserRedirection(_email);
      }
    }
  }

  Future<void> googleSignIn() async{
    try {
      //FullScreenLoader.openLoadingDialog(context, "Logging you in...");

      final userCredentials = await _auth.signInWithGoogle();
      
      if (userCredentials != null) {
        String uIdForFirestore = userCredentials.user!.uid;
        String emailAddress = userCredentials.user!.email ?? "";

        if (!await databaseService.checkUserExist(emailAddress)) {
          int selectedRoleIndex = await _showRoleSelectionDialog();

          UserModel user = UserModel(
              userId: int.tryParse(uIdForFirestore),
              email: emailAddress,
              fullName: userCredentials.user!.displayName ?? "",
              role: selectedRoleIndex,
              dateTimeCreated: DateTime.now(),
              dateTimeUpdated: DateTime.now()
              );
          
          await databaseService.createUser(user);

          await databaseService.retrieveUsers(user.email).then((value) {
            user.userId = value['userId'];
          });

          Provider.of<UserProvider>(context, listen: false).setUser(user);

          if (selectedRoleIndex == 1) {
            Navigator.pushNamed(context, '/campsite_owner/home');
          } else {
            Navigator.pushNamed(context, '/camper/home');
          }
        }
        else{
          await existingUserRedirection(emailAddress);
        }
        
      }
    } catch(e){
      _showErrorDialog("Error signing in with Google! Please try again!");
    }
  }

  existingUserRedirection(String emailAdd) async{
    dynamic userData = await databaseService.retrieveUsers(emailAdd);

    int role = userData['role'];
    
    UserModel user = UserModel(
        userId: userData['userId'],
        email: userData['email'],
        fullName: userData['fullName'],
        role: userData['role'],
        );

    await Provider.of<UserProvider>(context, listen: false).setUser(user);
    
    if (role == 2) {
      Navigator.pushNamed(context, '/admin/home');
    } else if (role == 1) {
      Navigator.pushNamed(context, '/campsite_owner/home');
    } else {
      Navigator.pushNamed(context, '/camper/home');
    }
  }

  Future<int> _showRoleSelectionDialog() async {
  int selectedRoleIndex = 3;

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Select Role'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Camper'),
              onTap: () {
                selectedRoleIndex = 3;
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: Text('Campsite Owner'),
              onTap: () {
                selectedRoleIndex = 1;
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    },
  );

  return selectedRoleIndex;
}

  void _showErrorDialog(String errorText) {
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
              SocialSignIn(googleSignInCallback: () => googleSignIn(),),
            ],
          ),
        ),
      ),
    );
  }
}
