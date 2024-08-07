import 'package:flutter/material.dart';

void showErrorSnackBar(BuildContext context, String errorMessage) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Center(
        child: Text(
          "Error: $errorMessage",
          style: const TextStyle(color: Colors.white),
        ),
      ),
      duration: const Duration(seconds: 2),
      backgroundColor: Colors.red,
    ),
  );
}
