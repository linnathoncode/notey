import 'package:flutter/material.dart';
import 'package:notey/utilities/colors.dart';

Widget customButton({
  required String buttonText, // Pass the button text as a parameter
  required VoidCallback onPressed, // Pass the onPressed function as a parameter
}) {
  return Container(
    decoration: BoxDecoration(
      color: kAccentColor,
      borderRadius: BorderRadius.circular(5),
      boxShadow: const [
        BoxShadow(
          color: kPrimaryColor,
          blurRadius: 7.0,
          offset: Offset(0, 3),
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF6DD5FA), // Light Blue
                    Color(0xFF2980B9), // Medium Blue
                    Color(0xFF2C3E50), // Dark Blue
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: [
                    0.0,
                    0.5,
                    1.0
                  ], // Control the gradient stops for smoother transitions
                ),
              ),
            ),
          ),
          TextButton(
            onPressed: onPressed, // Use the passed onPressed function
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
              foregroundColor: kAccentColor,
              textStyle: const TextStyle(fontSize: 15),
            ),
            child: Text(buttonText), // Use the passed buttonText
          ),
        ],
      ),
    ),
  );
}
