import 'package:flutter/material.dart';
import 'package:notey/constants/routes.dart';
import 'package:notey/enums/menu_action.dart';
import 'package:notey/services/auth/auth_service.dart';
import 'package:notey/services/cloud/cloud_note.dart';
import 'package:notey/services/cloud/firebase_cloud_storage.dart';
import 'package:notey/services/theme/theme_provider.dart';
import 'package:notey/utilities/show_dialog.dart';
import 'package:notey/utilities/show_snack_bar.dart';
// import 'dart:developer' as devtools show log;

import 'package:notey/views/notes/create_or_update_note_view.dart';
import 'package:provider/provider.dart';

// import 'package:notey/views/notes/notes_card_view.dart';

extension Count<T extends Iterable> on Stream<T> {
  Stream<int> get getLength => map((event) => event.length);
}

class NotesView extends StatefulWidget {
  const NotesView({
    super.key,
  });

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final List<CloudNote> _list = [];

  late final FirebaseCloudStorage _notesService;
  final userId = AuthService.firebase().currentUser!.id;
  final ValueNotifier<bool> _isDeleteMode = ValueNotifier<bool>(false);
  final List<String> _trashCan = [];
  final FocusNode _searchFocus = FocusNode();

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    super.initState();
  }

  Future<void> deleteNoteFromDatabase(String id) async {
    try {
      await _notesService.deleteNote(documentId: id);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _confirmAndDeleteNotes() async {
    final numberOfNotes = _trashCan.length;
    final String dialogContent =
        "$numberOfNotes ${numberOfNotes == 1 ? "note" : "notes"} will be deleted forever, are you sure?";
    if (!mounted) return;
    final shouldDelete = await showDeleteNoteDialog(context, dialogContent);
    if (shouldDelete) {
      for (var (id) in _trashCan) {
        await deleteNoteFromDatabase(id);
      }
      _clearTrashCan();
    } else {
      _clearTrashCan();
    }
  }

  void _clearTrashCan() {
    _trashCan.clear();
    _isDeleteMode.value = false;
    setState(() {});
  }

  void _addOrRemoveToTrashCan(String noteId) {
    if (_trashCan.contains(noteId)) {
      _trashCan.remove(noteId);
    } else {
      _trashCan.add(noteId);
    }
    _isDeleteMode.value = _trashCan.isNotEmpty;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    ThemeProvider themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                  : IconButton(
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                      icon: const Icon(Icons.menu)),
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
                        color: Theme.of(context)
                            .colorScheme
                            .secondary, // Background color for the menu
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
                            PopupMenuItem<MenuAction>(
                              value: MenuAction.logout,
                              child: Text(
                                "Log out",
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .tertiary, // Text color for the menu item
                                ),
                              ),
                            ),
                            PopupMenuItem<MenuAction>(
                              value: MenuAction.devmenu,
                              child: Text(
                                "Dev Menu",
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .tertiary, // Text color for the menu item
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
              backgroundColor: isDeleteMode
                  ? Theme.of(context).colorScheme.secondary
                  : Theme.of(context).colorScheme.primary,
              foregroundColor: isDeleteMode
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.tertiary,
            );
          },
        ),
      ),
      drawer: Drawer(
          child: IconButton(
        onPressed: () {
          bool isCurrentlyDark = themeProvider.themeMode == ThemeMode.dark;
          themeProvider.toggleTheme(!isCurrentlyDark);
        },
        icon: Icon(
          themeProvider.themeMode == ThemeMode.dark
              ? Icons.light_mode
              : Icons.dark_mode,
        ),
      )),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        autofocus: false,
                        decoration: const InputDecoration(
                          hintText: 'Search notes',
                          border: InputBorder.none,
                        ),
                        onTap: () {
                          _searchFocus.unfocus();
                          FocusScope.of(context).requestFocus(FocusNode());
                          Navigator.of(context).pushNamed(searchRoute);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 20,
              child: StreamBuilder(
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
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).pushNamed(createOrUpdateNoteRoute);
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.tertiary,
        child: const Icon(
          Icons.add,
          size: 35,
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
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
    final isSelected = _trashCan.contains(note.documentId);
    final textColor = isSelected
        ? Theme.of(context).colorScheme.tertiary
        : Theme.of(context).colorScheme.secondary;

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
          shadowColor: Theme.of(context).colorScheme.primary,
          elevation: isSelected ? 4.0 : 2.0,
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.tertiary, // Background color
          borderRadius: BorderRadius.circular(8),
          child: ListTile(
            selected: isSelected,
            onTap: !_isDeleteMode.value
                ? () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CreateOrUpdateNoteView(
                          currentNote: note,
                        ),
                      ),
                    );
                  }
                : () => _addOrRemoveToTrashCan(note.documentId),
            onLongPress: () {
              _addOrRemoveToTrashCan(note.documentId);
            },
            title: note.title.isNotEmpty
                ? Text(
                    note.title, // Display the title if it exists
                    maxLines: 1,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : Text(
                    note.text, // Display the subtitle text in the title's place if title is empty
                    maxLines: 1,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: textColor,
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
                    style: TextStyle(
                      color: textColor,
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                    ),
                  )
                : null,
            shape: isSelected
                ? RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.secondary,
                      width: 4,
                      style: BorderStyle.solid,
                    ),
                  )
                : RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.secondary,
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
