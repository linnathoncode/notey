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
          color: kAccentColor,
          blurRadius: 5.0,
          offset: Offset(0, 2),
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
                color: kPrimaryColor,
              ),
            ),
          ),
          TextButton(
            onPressed: onPressed, // Use the passed onPressed function
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
              foregroundColor: kAccentColor,
              textStyle:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            child: Text(buttonText), // Use the passed buttonText
          ),
        ],
      ),
    ),
  );
}
