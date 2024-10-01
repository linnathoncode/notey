import 'package:flutter/material.dart';
import 'package:notey/constants/routes.dart';
import 'package:notey/enums/menu_action.dart';
import 'package:notey/services/auth/auth_service.dart';
import 'package:notey/services/cloud/cloud_note.dart';
import 'package:notey/services/cloud/firebase_cloud_storage.dart';
import 'package:notey/utilities/colors.dart';
import 'package:notey/utilities/show_dialog.dart';
import 'package:notey/utilities/show_snack_bar.dart';
// import 'dart:developer' as devtools show log;

import 'package:notey/views/notes/create_or_update_note_view.dart';

// import 'package:notey/views/notes/notes_card_view.dart';

extension Count<T extends Iterable> on Stream<T> {
  Stream<int> get getLength => map((event) => event.length);
}

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final List<CloudNote> _list = [];

  late final FirebaseCloudStorage _notesService;
  final userId = AuthService.firebase().currentUser!.id;
  final ValueNotifier<bool> _isDeleteMode = ValueNotifier<bool>(false);
  final List<CloudNote> _trashCan = [];

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    super.initState();
  }

  Future<void> deleteNoteFromDatabase(CloudNote note) async {
    try {
      await _notesService.deleteNote(documentId: note.documentId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _confirmAndDeleteNotes() async {
    const String dialogContent = "Note will be deleted forever, are you sure?";
    if (!mounted) return;
    final shouldDelete = await showDeleteNoteDialog(context, dialogContent);
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
                        color: kSecondaryColor, // Background color for the menu
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
                          return [
                            const PopupMenuItem<MenuAction>(
                              value: MenuAction.logout,
                              child: Text(
                                "Log out",
                                style: TextStyle(
                                  color:
                                      kAccentColor, // Text color for the menu item
                                ),
                              ),
                            ),
                            const PopupMenuItem<MenuAction>(
                              value: MenuAction.devmenu,
                              child: Text(
                                "Dev Menu",
                                style: TextStyle(
                                  color:
                                      kAccentColor, // Text color for the menu item
                                ),
                              ),
                            ),
                          ];
                        },
                      )
                    ],
              title: Text(
                isDeleteMode ? "Delete Notes" : "Notey",
                style:
                    const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              backgroundColor: isDeleteMode ? kSecondaryColor : kPrimaryColor,
              foregroundColor: isDeleteMode ? kPrimaryColor : kAccentColor,
            );
          },
        ),
      ),
      body: StreamBuilder(
        stream: _notesService.allNotes(ownerUserId: userId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          final allNotesIterable = snapshot.data as Iterable<CloudNote>;
          // Coverting the iterable to a list to work easier with it
          // then sorting the list by date (recent to least recent)
          final allNotesInOrder = allNotesIterable.toList()
            ..sort((a, b) => b.date.compareTo(a.date));

          // Handle changes made to the stream
          _updateList(allNotesInOrder);

          // Return AnimatedList
          return AnimatedList(
            key: _listKey,
            initialItemCount: _list.length,
            itemBuilder: (context, index, animation) {
              return _buildListItem(
                _list[index],
                animation,
                index,
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).pushNamed(createOrUpdateNoteRoute);
        },
        backgroundColor: kPrimaryColor,
        foregroundColor: kAccentColor,
        child: const Icon(
          Icons.add,
          size: 35,
        ),
      ),
      backgroundColor: kBackgroundColor,
    );
  }

  void _updateList(List<CloudNote> allNotesInOrder) async {
    // Convert list to maps based on documentId for easier lookup
    final Map<String, CloudNote> newMap = {
      for (var note in allNotesInOrder) note.documentId: note
    };

    // An item is removed
    if (allNotesInOrder.length < _list.length) {
      // Remove notes that are no longer in the new list
      for (int i = _list.length - 1; i >= 0; i--) {
        final note = _list[i];
        if (!newMap.containsKey(note.documentId)) {
          // Remove the item from the AnimatedList
          _listKey.currentState?.removeItem(
            i,
            (context, animation) {
              // Makes the removed item not interactable
              return FadeTransition(
                opacity: animation,
                child: IgnorePointer(
                  child: _buildListItem(
                      note, animation, i), // Use the note being removed
                ),
              );
            },
            duration: const Duration(milliseconds: 300),
          );
          _list.removeAt(
              i); // Move this line after removeItem to avoid accessing an empty list
        }
      }
    }

    // An item is added or updated
    for (int i = 0; i < allNotesInOrder.length; i++) {
      final newNote = allNotesInOrder[i];

      if (i >= _list.length) {
        // Case 1: Adding new notes at the end
        _list.add(newNote);
        _listKey.currentState?.insertItem(
          i,
          duration: const Duration(milliseconds: 400),
        );
      } else if (_list[i].documentId != newNote.documentId) {
        // Case 2: The note doesn't match the current one, insert at the right position
        _list.insert(i, newNote);
        _listKey.currentState?.insertItem(
          i,
          duration: const Duration(milliseconds: 400),
        );
      } else {
        // Case 3: The note is already present but may need an update
        _list[i] = newNote;
      }
    }

    // Handle removal of the last item to prevent accessing an empty list
    if (_list.isEmpty) {
      // Optionally handle the empty list case if needed
    }
  }

  Widget _buildListItem(
      CloudNote note, Animation<double> animation, int index) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.5, 0), // Swipes the right of the screen
        end: Offset.zero, // End at its final position
      ).animate(animation),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 6,
        ), // Increased padding for shadow
        child: Material(
          shadowColor: kPrimaryColor,
          elevation: 2.0,
          color: kAccentColor, // Background color
          borderRadius: BorderRadius.circular(8),
          child: ListTile(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => CreateOrUpdateNoteView(
                  currentNote: note,
                ),
              ),
            ),
            trailing: IconButton(
              color: kSecondaryColor,
              icon: const Icon(Icons.delete),
              onPressed: () {
                if (context.mounted) {
                  deleteNoteFromDatabase(note);
                }
              },
            ),
            title: note.title.isNotEmpty
                ? Text(
                    note.title, // Display the title if it exists
                    maxLines: 1,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : Text(
                    note.text, // Display the subtitle text in the title's place if title is empty
                    maxLines: 1,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
            subtitle: note.title.isNotEmpty
                ? Text(
                    note.text, // Show subtitle only if title is not empty
                    maxLines: 1,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                    ),
                  )
                : null,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(
                color: kSecondaryColor,
                width: 3,
                style: BorderStyle.none,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
