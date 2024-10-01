import 'package:flutter/material.dart';
import 'package:notey/utilities/colors.dart';

Widget customTextField({
  required BuildContext context,
  required TextEditingController textController,
  required double size,
  required String hintText,
  required bool autoFocus,
}) {
  return Center(
    child: Container(
      height: MediaQuery.of(context).size.height * size,
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: kAccentColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          width: 4.0,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        autofocus: autoFocus,
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
          fillColor: kAccentColor,
        ),
      ),
    ),
  );
}
