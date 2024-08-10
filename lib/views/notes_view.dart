import 'package:flutter/material.dart';
import 'package:notey/constants/routes.dart';
import 'package:notey/enums/menu_action.dart';
import 'package:notey/services/auth/auth_service.dart';
import 'package:notey/utilities/show_snack_bar.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  @override
  Widget build(BuildContext context) {
    final user = AuthService.firebase().currentUser;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        actions: [
          PopupMenuButton<MenuAction>(
            offset: const Offset(50, 40),
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout = await showLogOutDialog(context);
                  if (shouldLogout) {
                    final user = AuthService.firebase().currentUser;
                    await AuthService.firebase().reload();
                    await AuthService.firebase().logOut();
                    if (context.mounted) {
                      showInformationSnackBar(
                          context, "Logged out from ${user?.email}");
                    }
                    if (context.mounted) {
                      await Navigator.of(context).pushNamedAndRemoveUntil(
                        loginRoute,
                        (route) => false,
                      );
                    }
                  }
                  break;
                case MenuAction.devmenu:
                  await Navigator.of(context).pushNamedAndRemoveUntil(
                    devmenuRoute,
                    (route) => false,
                  );
                  break;
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem<MenuAction>(
                    value: MenuAction.logout, child: Text("Log out")),
                PopupMenuItem<MenuAction>(
                    value: MenuAction.devmenu, child: Text("Dev Menu"))
              ];
            },
          )
        ],
        title: const Text("Notey",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        backgroundColor: const Color.fromARGB(204, 36, 50, 83),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 8.0, left: 8),
            child: Center(
              child: Text(
                'Welcome back',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  overflow: TextOverflow.clip,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 0.0, left: 8),
            child: Center(
              child: Text(
                '${user?.email}',
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  overflow: TextOverflow.clip,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<bool> showLogOutDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Log out"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text("Log out"),
          )
        ],
      );
    },
  ).then((value) => value ?? false);
}
