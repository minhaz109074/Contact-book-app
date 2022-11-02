import 'dart:convert';

import 'package:contacts/widgets/signup.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:contacts/widgets/conatctList.dart';
import 'package:contacts/providers/authentication.dart';
import 'package:contacts/utils/httpException.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
          .login(_authData['email'] as String, _authData['password'] as String);
    } on HttpException catch (e) {
      var errorMessage = 'Authentication Failed';
      if (e.toString().contains('INVALID_EMAIL')) {
        errorMessage = 'Invalid email';
        _showerrorDialog(errorMessage);
      } else if (e.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage = 'This email not found';
        _showerrorDialog(errorMessage);
      } else if (e.toString().contains('INVALID_PASSWORD')) {
        errorMessage = 'Invalid Password';
        _showerrorDialog(errorMessage);
      }
    } catch (error) {
      var errorMessage = 'Plaese try again later';
      _showerrorDialog(errorMessage);
      print(error.toString());
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
                border: UnderlineInputBorder(
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
              cursorColor: Colors.white,
              obscureText: true,
              style: const TextStyle(color: Colors.white70),
              decoration: const InputDecoration(
                icon: Icon(Icons.lock, color: Colors.white70),
                hintText: "Password",
                border: UnderlineInputBorder(
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
            Container(
              width: MediaQuery.of(context).size.width,
              height: 40.0,
              //padding:
              //const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
              margin: const EdgeInsets.only(top: 25.0),
              child: ElevatedButton(
                onPressed: () {
                  submit();
                },
                style: ButtonStyle(
                    elevation: const MaterialStatePropertyAll<double>(0.0),
                    overlayColor:
                        MaterialStatePropertyAll<Color>(Colors.teal[200]!)),
                //elevation: 0.0,
                //color: Colors.purple,
                //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                child: const Text("Sign In",
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
      margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.15),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
      child: const Text("Welcome to Contact Book App",
          style: TextStyle(
              color: Colors.white70,
              fontSize: 24.0,
              fontWeight: FontWeight.bold)),
    );
  }

  Container signupSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      margin: const EdgeInsets.only(top: 5.0),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        const Text("Don't have an account? "),
        TextButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: ((context) {
                return const SignUp();
              })));
            },
            child: const Text(
              'Sign Up',
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
