import 'package:contacts/providers/authentication.dart';
import 'package:contacts/widgets/conatctList.dart';
import 'package:contacts/widgets/login.dart';
import 'package:flutter/material.dart';
import 'package:contacts/settings/theme.dart';
import 'package:provider/provider.dart';

void main(List<String> args) {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ignore: prefer_const_constructors
    return ChangeNotifierProvider.value(
      value: Auth(),
      child: Consumer<Auth>(
          builder: ((context, auth, child) => MaterialApp(
                title: 'Flutter Contact Book App',
                debugShowCheckedModeBanner: false,
                theme: lightTheme,
                home: auth.isAuth
                    ? const ContactList()
                    : FutureBuilder(
                        future: auth.tryautoLogin(),
                        builder: ((context, snapshot) =>
                            snapshot.connectionState == ConnectionState.waiting
                                ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : const LoginPage())),
              ))),
    );
  }
}
