import 'package:flutter/material.dart';

Widget customTextField({
  required BuildContext context,
  required TextEditingController textController,
  required String hintText,
  required double? textSize,
  required FocusNode? focusNode,
  dynamic maxLines,
  bool autoFocus = false,
}) {
  final theme = Theme.of(context);

  return Center(
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      padding:
          const EdgeInsets.symmetric(horizontal: 4, vertical: 0), // Add padding
      child: TextField(
        autofocus: autoFocus,
        focusNode: focusNode,
        showCursor: true,
        expands: (maxLines == null) ? true : false,
        cursorColor: theme.colorScheme.primary,
        controller: textController,
        keyboardType: TextInputType.multiline,
        maxLines: maxLines, // Allows multiline input
        textAlignVertical: TextAlignVertical.top,
        style: TextStyle(
          fontSize: textSize,
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
            fontSize: textSize,
          ),
          filled: true,
          fillColor:
              theme.colorScheme.surface.withOpacity(0.05), // Subtle fill color
        ),
      ),
    ),
  );
}
