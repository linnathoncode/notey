import 'package:flutter/material.dart';
import 'package:notey/services/crud/notes_service.dart';
import 'dart:developer' as devtools show log;

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

  void onTap() {
    devtools.log("single tap");
  }

  Widget _buildListTile(DatabaseNote note,
      {required bool isSelected, required Animation<double> animation}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      child: FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: animation.drive(
            Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).chain(CurveTween(curve: Curves.linear)),
          ),
          child: ListTile(
            onLongPress: () => onDelete(note),
            onTap: widget.trashCan.isNotEmpty ? () => onDelete(note) : onTap,
            selected: isSelected,
            tileColor: Colors.white,
            selectedColor: Colors.white,
            selectedTileColor: Colors.yellow.shade800,
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
                color: Colors.black,
                width: 3,
                style: isSelected ? BorderStyle.solid : BorderStyle.none,
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
