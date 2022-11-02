import 'dart:convert';

import 'package:contacts/widgets/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:contacts/utils/httpException.dart';
import 'package:http/http.dart' as http;
import 'package:contacts/widgets/conatctList.dart';
import 'package:contacts/providers/authentication.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  bool _isLoading = false;
  final GlobalKey<FormState> _formKey = GlobalKey();

  Map<String, String> _authData = {'email': '', 'password': ''};

  Future submit() async {
    if (!_formKey.currentState!.validate()) {
      //invalid
      return;
    }
    _formKey.currentState!.save();
    try {
      await Provider.of<Auth>(context, listen: false)
          .signUp(_authData['email'] as String, _authData['password'] as String)
          .then((_) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (ctx) => const ContactList()));
        Navigator.of(context).pop();
      });
    } on HttpException catch (e) {
      var errorMessage = 'Authentication Failed';
      if (e.toString().contains('EMAIL_EXISTS')) {
        errorMessage = 'This email is alredy exsist';
        _showerrorDialog(errorMessage);
      } else if (e.toString().contains('WEAK_PASSWORD')) {
        errorMessage = 'Weak password';
        _showerrorDialog(errorMessage);
      }
    } catch (e) {
      var errorMessage = 'Please Try again later';
      _showerrorDialog(errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light
        .copyWith(statusBarColor: Colors.transparent));
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.green, Colors.green[700] as Color],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter),
        ),
        child: ListView(
          children: <Widget>[
            headerSection(),
            formSection(),
            signupSection(),
          ],
        ),
      ),
    );
  }

  final TextEditingController passwordController = TextEditingController();

  Container formSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              cursorColor: Colors.white,
              style: const TextStyle(color: Colors.white70),
              decoration: const InputDecoration(
                icon: Icon(Icons.email, color: Colors.white70),
                hintText: "Email",
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white70)),
                hintStyle: TextStyle(color: Colors.white70),
              ),
              validator: (value) {
                bool emailValid =
                    RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+"
                            r"@[a-zA-Z0-9]+\.[a-zA-Z]+")
                        .hasMatch(value as String);
                if (!emailValid || value.isEmpty) {
                  return 'Invalid email';
                }
              },
              onSaved: (newValue) {
                _authData['email'] = newValue!;
              },
            ),
            const SizedBox(height: 30.0),
            TextFormField(
              controller: passwordController,
              cursorColor: Colors.white,
              obscureText: true,
              style: const TextStyle(color: Colors.white70),
              decoration: const InputDecoration(
                icon: Icon(Icons.lock, color: Colors.white70),
                hintText: "Password",
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white70)),
                hintStyle: TextStyle(color: Colors.white70),
              ),
              validator: (value) {
                if (value!.isEmpty || value.length < 5) {
                  return 'Password is to Short';
                }
              },
              onSaved: (newValue) {
                _authData['password'] = newValue!;
              },
            ),
            const SizedBox(height: 30.0),
            TextFormField(
                cursorColor: Colors.white,
                obscureText: true,
                style: const TextStyle(color: Colors.white70),
                decoration: const InputDecoration(
                  icon: Icon(Icons.lock, color: Colors.white70),
                  hintText: "Confirm Password",
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white70)),
                  hintStyle: TextStyle(color: Colors.white70),
                ),
                validator: (value) {
                  if (value != passwordController.text) {
                    return 'Password doesnot match';
                  }
                }),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 40.0,
              //padding: EdgeInsets.only(left: 30.0),
              margin: const EdgeInsets.only(top: 25.0),
              child: ElevatedButton(
                onPressed: () {
                  submit();
                },
                style: ButtonStyle(
                    elevation: const MaterialStatePropertyAll<double>(0.0),
                    overlayColor:
                        MaterialStatePropertyAll<Color>(Colors.teal[200]!)),
                child: const Text("Register",
                    style: TextStyle(color: Colors.white70)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Container headerSection() {
    return Container(
      margin: const EdgeInsets.only(top: 40.0),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
      child: const Center(
        child: Text("Sign Up",
            style: TextStyle(
                color: Colors.white70,
                fontSize: 24.0,
                fontWeight: FontWeight.bold)),
      ),
    );
  }

  Container signupSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      margin: const EdgeInsets.only(top: 15.0),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        const Text("Already have an account? "),
        TextButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: ((context) {
                return const LoginPage();
              })));
            },
            child: const Text(
              'Sign In',
              style: TextStyle(
                  color: Colors.black87,
                  decoration: TextDecoration.underline,
                  fontSize: 14),
            ))
      ]),
    );
  }

  void _showerrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'An Error Occurred',
          style: TextStyle(color: Colors.red),
        ),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('Okay'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
        ],
      ),
    );
  }
}
