import 'package:flutter/material.dart';

Widget customTextFormField({
  required String hintText,
  required String validatorErrorMessage,
  required TextInputType keyboardType,
  required TextEditingController controller,
  required bool obscureText,
  required BuildContext context,
  FocusNode? focusNodeOne,
  FocusNode? focusNodeTwo,
}) {
  return Container(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.tertiary,
      borderRadius: BorderRadius.circular(5),
      boxShadow: [
        BoxShadow(
          color: Theme.of(context).colorScheme.primary,
          blurRadius: 5.0,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: TextFormField(
      onFieldSubmitted: (value) {
        if (context.mounted) {
          FocusScope.of(context).requestFocus(focusNodeTwo);
        }
      },
      focusNode: focusNodeOne,
      obscureText: obscureText,
      obscuringCharacter: "*",
      enableSuggestions: false,
      autofocus: true,
      autocorrect: false,
      keyboardType: keyboardType,
      controller: controller,
      decoration: InputDecoration(
        errorStyle: TextStyle(color: Theme.of(context).colorScheme.error),
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
