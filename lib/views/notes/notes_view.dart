import 'package:flutter/material.dart';
import 'package:notey/constants/routes.dart';
import 'package:notey/enums/menu_action.dart';
import 'package:notey/services/auth/auth_service.dart';
import 'package:notey/services/crud/notes_service.dart';
import 'package:notey/utilities/show_dialoges.dart';
import 'package:notey/utilities/show_snack_bar.dart';
import 'dart:developer' as devtools show log;

import 'package:notey/views/notes/notes_card_view.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final NotesService _notesService;
  final user = AuthService.firebase().currentUser;
  final ValueNotifier<bool> _isDeleteMode = ValueNotifier<bool>(false);
  final List<DatabaseNote> _trashCan = [];

  String get userEmail => user!.email!;

  @override
  void initState() {
    _notesService = NotesService();
    super.initState();
  }

  Future<void> deleteNoteFromDatabase(DatabaseNote note) async {
    try {
      await _notesService.deleteNote(id: note.id);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _confirmAndDeleteNotes() async {
    final shouldDelete = await showDeleteNoteDialog(context, _trashCan.length);
    if (shouldDelete) {
      for (var note in _trashCan) {
        await deleteNoteFromDatabase(note);
      }
      _clearTrashCan();
      //you dont have to use set state
      //if you are using ValueListenerBuilders

      //set state causes the whole widget to be redrawn
      //setState(() {}); // Refresh the UI
    } else {
      _clearTrashCan();
    }
  }

  void _clearTrashCan() {
    _trashCan.clear();
    _isDeleteMode.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ValueListenableBuilder<bool>(
          valueListenable: _isDeleteMode,
          builder: (context, isDeleteMode, child) {
            return AppBar(
              centerTitle: true,
              leading: isDeleteMode
                  ? IconButton(
                      onPressed: () {
                        _clearTrashCan();
                      },
                      icon: const Icon(Icons.cancel),
                    )
                  : null,
              actions: isDeleteMode
                  ? [
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: _confirmAndDeleteNotes,
                      ),
                    ]
                  : [
                      PopupMenuButton<MenuAction>(
                        offset: const Offset(50, 40),
                        onSelected: (value) async {
                          switch (value) {
                            case MenuAction.logout:
                              final shouldLogout =
                                  await showLogOutDialog(context);
                              if (shouldLogout) {
                                final user = AuthService.firebase().currentUser;
                                await AuthService.firebase().reload();
                                await AuthService.firebase().logOut();
                                if (context.mounted) {
                                  showInformationSnackBar(context,
                                      "Logged out from ${user?.email}");
                                }
                                if (context.mounted) {
                                  await Navigator.of(context)
                                      .pushNamedAndRemoveUntil(
                                    loginRoute,
                                    (route) => false,
                                  );
                                }
                              }
                              break;
                            case MenuAction.devmenu:
                              await Navigator.of(context)
                                  .pushNamed(devmenuRoute);
                              break;
                          }
                        },
                        itemBuilder: (context) {
                          return const [
                            PopupMenuItem<MenuAction>(
                                value: MenuAction.logout,
                                child: Text("Log out")),
                            PopupMenuItem<MenuAction>(
                                value: MenuAction.devmenu,
                                child: Text("Dev Menu"))
                          ];
                        },
                      )
                    ],
              title: Text(
                isDeleteMode ? "Delete Notes" : "Notey",
                style:
                    const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              backgroundColor: isDeleteMode
                  ? const Color.fromARGB(255, 87, 87, 87)
                  : Colors.yellow.shade800,
              foregroundColor:
                  isDeleteMode ? Colors.yellow.shade800 : Colors.white,
            );
          },
        ),
      ),
      body: FutureBuilder(
        future: _notesService.getOrCreateUser(email: userEmail),
        builder: (context, snapshot) {
          final user = snapshot.data;
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return StreamBuilder(
                stream: _notesService.allNotes,
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                      return const Center(
                          child: Text("You don't have any notes!"));
                    case ConnectionState.waiting:
                    case ConnectionState.active:
                      if (snapshot.hasData) {
                        devtools.log(snapshot.data.toString());
                        late final allNotes =
                            (snapshot.data as List<DatabaseNote>)
                                .where((note) => note.userId == user?.id)
                                .toList();
                        allNotes.sort((a, b) => b.id.compareTo(a.id));
                        devtools.log(allNotes.toString());
                        return NoteCard(
                          allNotes: allNotes,
                          isDeleteMode: _isDeleteMode,
                          trashCan: _trashCan,
                        );
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    default:
                      return const Center(child: CircularProgressIndicator());
                  }
                },
              );
            default:
              return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).pushNamed(newNoteRoute);
        },
        backgroundColor: Colors.yellow[800],
        foregroundColor: Colors.white,
        child: const Icon(
          Icons.add,
          size: 35,
        ),
      ),
    );
  }
}
