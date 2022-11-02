import 'package:flutter/material.dart';

const Color bodyBackgroundColor = Color(0xfff4f9f4); //0xfff4f9f4
const primaryColor = Colors.teal;

final ThemeData lightTheme = ThemeData(
    primarySwatch: primaryColor,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    scaffoldBackgroundColor: bodyBackgroundColor,
    appBarTheme: AppBarTheme(backgroundColor: Colors.teal[700]));

///Light theme
// final ThemeData lightTheme = ThemeData.light().copyWith(
//   visualDensity: VisualDensity.adaptivePlatformDensity,
//   scaffoldBackgroundColor: lightThemeBkgdColor,
//   appBarTheme: const AppBarTheme(color: lightThemeButtonColor),
//   iconTheme: const IconThemeData(color: lightThemeButtonColor),
//   textTheme: const TextTheme(
//     headline5:
//         TextStyle(color: lightThemeWordsColor, fontWeight: FontWeight.w400),
//     headline6:
//         TextStyle(color: lightThemeWordsColor, fontWeight: FontWeight.w400),

//     subtitle1: TextStyle(
//         color: lightThemeWordsColor,
//         fontWeight: FontWeight.w400,
//         fontSize: 18.0),

//     subtitle2: TextStyle(
//         fontWeight: FontWeight.w400,
//         color: lightThemeWordsColor,
//         fontStyle: FontStyle.italic,
//         fontSize: 17),

//     bodyText1: TextStyle(fontSize: 16, color: lightThemeWordsColor), //16

//     bodyText2: TextStyle(
//         fontSize: 15,
//         color: lightThemeWordsColor,
//         fontStyle: FontStyle.italic), //14
//   ),
// );
