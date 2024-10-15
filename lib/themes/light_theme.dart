import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
  disabledColor: const Color(0xFF757575),
  hintColor: const Color(0xFFB4A7A7),
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light(
    surface: Color(0xFFF0ECE2),
    primary: Color(0xFFDBA506),
    secondary: Color(0xFF1C1C1C),
    tertiary: Color(0xFFEFEFEF),
    error: Color(0xFFB22222),
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      fontSize: 18, // Font size for body text
      color: Color(0xFF202020),
      fontWeight: FontWeight.w400,
    ),
  ),
);
