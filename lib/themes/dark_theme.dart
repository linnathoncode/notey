import 'package:flutter/material.dart';

ThemeData darkTheme = ThemeData(
  disabledColor: const Color(0xFFBDBDBD), // Lighter gray for disabled items
  hintColor: const Color(0xFF757575), // Darker hint color for input fields
  brightness: Brightness.dark, // Set the brightness to dark
  colorScheme: const ColorScheme.dark(
    surface: Color(0xFF121212), // Dark background surface
    primary: Color(0xFFDBA506), // Keep primary the same or adjust slightly
    secondary: Color(0xFFE0E0E0), // Light gray secondary color for contrast
    tertiary: Color(0xFF2E2E2E), // Dark tertiary for subtle contrast
    error: Color(0xFFCF6679), // Slightly lighter red for error on dark surfaces
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      fontSize: 18,
      color: Color(0xFFE0E0E0), // Light color for text on dark background
      fontWeight: FontWeight.w400,
    ),
  ),
);
