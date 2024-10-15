import 'package:flutter/material.dart';

typedef DialogOptionBuilder<T> = Map<String, T> Function();

Future<T?> showGenericDialog<T>({
  required BuildContext context,
  required String title,
  required String content,
  required DialogOptionBuilder optionsBuilder,
}) {
  final options = optionsBuilder();
  return showDialog<T>(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0), // Rounded corners
        ),
        backgroundColor: Theme.of(context)
            .colorScheme
            .surface, // Background color for the dialog
        title: Text(
          title,
          style: TextStyle(
            color: Theme.of(context)
                .textTheme
                .displayLarge
                ?.color, // Custom title color
            fontWeight: FontWeight.bold, // Bold title
            fontSize: 18, // Larger font size for title
          ),
        ),
        content: Text(
          content,
          style: TextStyle(
            color: Theme.of(context)
                .textTheme
                .displayLarge
                ?.color, // Custom content text color
            fontSize: 16, // Custom font size for content
          ),
        ),
        actions: options.keys.map((optionTitle) {
          final value = options[optionTitle];
          return TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context)
                  .colorScheme
                  .primary, // Text color for button
              backgroundColor: Theme.of(context)
                  .colorScheme
                  .surface, // Button background color
              padding: const EdgeInsets.symmetric(
                  horizontal: 16.0, vertical: 8.0), // Padding for button
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(8.0), // Rounded button corners
              ),
            ),
            onPressed: () {
              if (value != null) {
                Navigator.of(context).pop(value);
              } else {
                Navigator.of(context).pop();
              }
            },
            child: Text(optionTitle),
          );
        }).toList(),
      );
    },
  );
}
