import 'package:flutter/material.dart';
import 'package:notey/constants/routes.dart';
import 'package:notey/enums/menu_action.dart';
import 'package:notey/services/auth/auth_service.dart';
import 'package:notey/services/crud/notes_service.dart';
import 'package:notey/utilities/show_snack_bar.dart';
import 'dart:developer' as devtools show log;

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final NotesService _notesService;
  final user = AuthService.firebase().currentUser;

  String get userEmail => user!.email!;

  Future<void> deleteNoteFromDatabase(DatabaseNote note) async {
    try {
      await _notesService.deleteNote(id: note.id);
    } catch (e) {
      rethrow;
    }
  }

  @override
  void initState() {
    _notesService = NotesService();
    super.initState();
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
                  await Navigator.of(context).pushNamed(devmenuRoute);
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
        backgroundColor: Colors.yellow.shade800,
        foregroundColor: Colors.white,
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
                          child: Text("You dont have any notes!"));
                    case ConnectionState.waiting:
                    case ConnectionState.active:
                      if (snapshot.hasData) {
                        devtools.log(snapshot.data.toString());
                        //sort the notes from newest to oldest
                        //get only current user's notes
                        late final allNotes =
                            (snapshot.data as List<DatabaseNote>)
                                .where((note) => note.userId == user?.id)
                                .toList();
                        allNotes.sort((a, b) => b.id.compareTo(a.id));
                        devtools.log(allNotes.toString());
                        return NoteCard(allNotes: allNotes);
                      } else {
                        return const CircularProgressIndicator();
                      }
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

Future<bool> showDeleteNoteDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Delete note"),
        content: const Text("This note will be deleted forever, are you sure?"),
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
            child: const Text("Yes, delete"),
          )
        ],
      );
    },
  ).then((value) => value ?? false);
}

class NoteCard extends StatefulWidget {
  final List<DatabaseNote> allNotes;

  const NoteCard({super.key, required this.allNotes});

  @override
  State<NoteCard> createState() => _NoteCardState();
}

class _NoteCardState extends State<NoteCard> {
  List<DatabaseNote> trashCan = [];

  bool existsInTrashCan(DatabaseNote note) => trashCan.contains(note);

  void onDelete(DatabaseNote note) {
    if (trashCan.contains(note)) {
      trashCan.remove(note);
    } else {
      trashCan.add(note);
    }
    setState(() {});
  }

  void onTap() {
    devtools.log("single tap");
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        separatorBuilder: (context, index) => const SizedBox(height: 0),
        itemCount:
            widget.allNotes.length, // Access allNotes from the widget instance
        itemBuilder: (context, index) {
          final note =
              widget.allNotes[index]; // Access the specific note by index
          final isSelected = existsInTrashCan(note);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            child: ListTile(
              onLongPress: () => onDelete(note),
              onTap: trashCan.isNotEmpty ? () => onDelete(note) : onTap,
              selected: isSelected,
              tileColor: Colors.white,
              selectedColor: Colors.white,
              selectedTileColor: Colors.yellow.shade800,
              title: Text(
                note.text,
                maxLines: 1,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: Colors.black,
                  width: 3,
                  style: isSelected ? BorderStyle.solid : BorderStyle.none,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
