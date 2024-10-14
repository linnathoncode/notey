import 'package:flutter/material.dart';
import 'package:notey/utilities/colors.dart';

Widget customTextField({
  required BuildContext context,
  required TextEditingController textController,
  required String hintText,
  bool autoFocus = false,
  FocusNode? focusNode,
}) {
  return Center(
    child: Container(
      decoration: BoxDecoration(
        color: kAccentColor,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          width: 3.0,
          color: kSecondaryColor,
        ),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        autofocus: autoFocus,
        focusNode: focusNode,
        showCursor: true,
        expands: true,
        cursorColor: kPrimaryColor,
        controller: textController,
        keyboardType: TextInputType.multiline,
        maxLines: null, // Multiline for body text
        textAlignVertical: TextAlignVertical.top,
        style: const TextStyle(
          fontSize: 18, // Font size for body text
          color: kFontColor,
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            hintText: hintText,
            hintStyle: const TextStyle(
              color: kHintColor,
              fontSize: 16,
            ),
            filled: true,
            fillColor: Colors.white),
      ),
    ),
  );
}
