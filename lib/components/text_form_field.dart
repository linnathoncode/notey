import 'package:flutter/material.dart';
import 'package:notey/utilities/colors.dart';

Widget customTextField({
  required String hintText,
  required String validatorErrorMessage,
  required TextInputType keyboardType,
  required TextEditingController controller,
  required bool obscureText,
}) {
  return Container(
    decoration: BoxDecoration(
      color: kAccentColor,
      borderRadius: BorderRadius.circular(5),
      boxShadow: const [
        BoxShadow(
          color: kPrimaryColor,
          blurRadius: 5.0,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: TextFormField(
      obscureText: obscureText,
      obscuringCharacter: "*",
      enableSuggestions: false,
      autofocus: true,
      autocorrect: false,
      keyboardType: keyboardType,
      controller: controller,
      decoration: InputDecoration(
        errorStyle: const TextStyle(color: kErrorColor),
        hintText: hintText,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return validatorErrorMessage;
        }
        return null;
      },
    ),
  );
}
