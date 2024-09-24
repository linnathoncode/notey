import 'package:flutter/material.dart';
import 'package:notey/services/crud/notes_service.dart';
import 'package:notey/utilities/colors.dart';
// import 'dart:developer' as devtools show log;
import 'package:notey/views/notes/create_or_update_note_view.dart';

class NoteCard extends StatefulWidget {
  final List<DatabaseNote> allNotes;
  final ValueNotifier<bool> isDeleteMode;
  final List<DatabaseNote> trashCan;

  const NoteCard({
    super.key,
    required this.allNotes,
    required this.isDeleteMode,
    required this.trashCan,
  });

  @override
  State<NoteCard> createState() => _NoteCardState();
}

class _NoteCardState extends State<NoteCard> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  late List<DatabaseNote> _displayedNotes;

  @override
  void initState() {
    super.initState();
    _displayedNotes = List.from(widget.allNotes);
  }

  //Called by flutter whenever the widget configuration changes.
  @override
  void didUpdateWidget(covariant NoteCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle new notes being added
    if (widget.allNotes.length > oldWidget.allNotes.length) {
      final newNote = widget.allNotes.firstWhere(
        (note) => !oldWidget.allNotes.contains(note),
      );
      _displayedNotes.insert(0, newNote);
      _listKey.currentState?.insertItem(0);
    }

    // Handle notes being deleted
    if (widget.allNotes.length < oldWidget.allNotes.length) {
      for (var oldNote in oldWidget.allNotes) {
        if (!widget.allNotes.contains(oldNote)) {
          final index = _displayedNotes.indexOf(oldNote);
          final removedNote = _displayedNotes.removeAt(index);
          _listKey.currentState?.removeItem(
            index,
            (context, animation) => SizeTransition(
              sizeFactor: animation,
              axis: Axis.vertical,
              child: _buildListTile(removedNote,
                  isSelected: false, animation: animation),
            ),
          );
        }
      }
    }
// Handle notes being updated

    for (var note in widget.allNotes) {
      final oldNoteIndex = oldWidget.allNotes.indexOf(note);
      if (oldNoteIndex != -1) {
        final oldNote = oldWidget.allNotes[oldNoteIndex];
        if (note.text != oldNote.text) {
          final index = _displayedNotes.indexOf(oldNote);
          _displayedNotes[index] = note;
          // Optionally trigger a visual update here
          setState(
            () {
              // This will cause the AnimatedSwitcher to trigger an animation
            },
          );
          break; // Add break statement to exit the loop after updating the note
        }
      }
    }
  }

  void onDelete(DatabaseNote note) {
    if (widget.trashCan.contains(note)) {
      widget.trashCan.remove(note);
    } else {
      widget.trashCan.add(note);
    }
    setState(() {});
    widget.isDeleteMode.value = widget.trashCan.isNotEmpty;
  }

  Widget _buildListTile(DatabaseNote note,
      {required bool isSelected, required Animation<double> animation}) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 10, vertical: 6), // Increased padding for shadow
      child: FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: animation.drive(
            Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).chain(CurveTween(curve: Curves.linear)),
          ),
          child: Material(
            shadowColor: kPrimaryColor,
            elevation:
                isSelected ? 8.0 : 2.0, // Adjust elevation based on selection
            color: kAccentColor, // Background color
            borderRadius: BorderRadius.circular(8),
            child: ListTile(
              onLongPress: () => onDelete(note),
              onTap: widget.trashCan.isNotEmpty
                  ? () => onDelete(note)
                  : () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => CreateOrUpdateNoteView(
                            currentNote: note,
                          ),
                        ),
                      ),
              selected: isSelected,
              selectedColor: kAccentColor,
              selectedTileColor: kPrimaryColor,
              title: Text(
                note.text,
                maxLines: 1,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: kSecondaryColor,
                  width: 3,
                  style: isSelected ? BorderStyle.solid : BorderStyle.none,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: widget.isDeleteMode,
      builder: (context, isDeleteMode, child) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: AnimatedList(
            key: _listKey,
            initialItemCount: _displayedNotes.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index, animation) {
              final note = _displayedNotes[index];
              final isSelected = widget.trashCan.contains(note);

              return SizeTransition(
                sizeFactor: animation,
                axis: Axis.vertical,
                child: _buildListTile(note,
                    isSelected: isSelected, animation: animation),
              );
            },
          ),
        );
      },
    );
  }
}
