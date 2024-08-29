import 'package:flutter/material.dart';
import 'package:notey/utilities/generic_dialog.dart';

Future<bool> showLogOutDialog(BuildContext context) {
  return showGenericDialog<bool>(
    context: context,
    title: "Log Out",
    content: "Are you sure you want to log out?",
    optionsBuilder: () => {
      "CANCEL": false,
      "LOG OUT": true,
    },
  ).then(
    (value) => value ?? false,
  );
}

Future<bool> showDeleteNoteDialog(BuildContext context, String content) {
  return showGenericDialog<bool>(
    context: context,
    title: "Delete Note",
    content: content,
    optionsBuilder: () => {
      "CANCEL": false,
      "YES": true,
    },
  ).then(
    (value) => value ?? false,
  );
}
