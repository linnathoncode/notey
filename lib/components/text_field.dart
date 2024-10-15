import 'package:flutter/material.dart';

Widget customTextField({
  required BuildContext context,
  required TextEditingController textController,
  required String hintText,
  bool autoFocus = false,
  FocusNode? focusNode,
}) {
  final theme = Theme.of(context);

  return Center(
    child: Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface, // Use theme color for surface
        borderRadius: BorderRadius.circular(12), // Smoother corner radius
        border: Border.all(
          width: 2.0, // Thinner border for a sleek look
          color: theme.colorScheme.onSurface
              .withOpacity(0.1), // Softer border color
        ),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 8), // Add padding
      child: TextField(
        autofocus: autoFocus,
        focusNode: focusNode,
        showCursor: true,
        expands: true,
        cursorColor: theme.colorScheme.primary,
        controller: textController,
        keyboardType: TextInputType.multiline,
        maxLines: null, // Allows multiline input
        textAlignVertical: TextAlignVertical.top,
        style: TextStyle(
          fontSize: 18,
          color: theme.textTheme.bodyLarge?.color, // Use adaptive text color
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(16), // Internal padding
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none, // Remove default borders
          ),
          hintText: hintText,
          hintStyle: TextStyle(
            color: theme.hintColor, // Adaptive hint text color
            fontSize: 16,
          ),
          filled: true,
          fillColor:
              theme.colorScheme.surface.withOpacity(0.05), // Subtle fill color
        ),
      ),
    ),
  );
}
