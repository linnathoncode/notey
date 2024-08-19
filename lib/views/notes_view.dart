import 'package:flutter/material.dart';
import 'package:notey/constants/routes.dart';
import 'package:notey/enums/menu_action.dart';
import 'package:notey/services/auth/auth_service.dart';
import 'package:notey/services/crud/notes_service.dart';
import 'package:notey/utilities/show_snack_bar.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final NotesService _notesService;
  final user = AuthService.firebase().currentUser;
  String get userEmail => user!.email!;

  @override
  void initState() {
    _notesService = NotesService();
    super.initState();
  }

  @override
  void dispose() {
    _notesService.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      body: FutureBuilder(
        future: _notesService.getOrCreateUser(email: userEmail),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return StreamBuilder(
                stream: _notesService.allNotes,
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return const Text('Waiting for all notes');
                    default:
                      return const CircularProgressIndicator();
                  }
                },
              );
            default:
              return const CircularProgressIndicator();
          }
        },
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
