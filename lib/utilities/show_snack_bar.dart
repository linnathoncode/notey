import 'package:flutter/material.dart';
import 'package:notey/utilities/colors.dart';

void showErrorSnackBar(BuildContext context, String errorMessage) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Center(
        child: Text(
          "Error: $errorMessage",
          style: const TextStyle(
            color: kAccentColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      duration: const Duration(seconds: 2),
      backgroundColor: kErrorColor,
    ),
  );
}

void showInformationSnackBar(BuildContext context, String infoMessage) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Center(
        child: Text(
          infoMessage,
          style: const TextStyle(
            color: kAccentColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      duration: const Duration(seconds: 2),
      backgroundColor: kPrimaryColor,
    ),
  );
}
