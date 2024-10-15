import 'package:flutter/material.dart';

Widget customButton({
  required String buttonText, // Pass the button text as a parameter
  required VoidCallback onPressed,
  required BuildContext context, // Pass the onPressed function as a parameter
}) {
  return Container(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.tertiary,
      borderRadius: BorderRadius.circular(5),
      boxShadow: [
        BoxShadow(
          color: Theme.of(context).colorScheme.tertiary,
          blurRadius: 5.0,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          TextButton(
            onPressed: onPressed, // Use the passed onPressed function
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
              foregroundColor: Theme.of(context).colorScheme.tertiary,
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
