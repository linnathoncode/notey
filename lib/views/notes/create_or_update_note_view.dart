import 'package:flutter/material.dart';
import 'package:notey/services/auth/auth_service.dart';
import 'package:notey/services/crud/notes_service.dart';
import 'dart:developer' as devtools show log;

class CreateOrUpdateNoteView extends StatefulWidget {
  final DatabaseNote? currentNote;

  const CreateOrUpdateNoteView({super.key, this.currentNote});

  @override
  State<CreateOrUpdateNoteView> createState() => _CreateOrUpdateNoteViewState();
}

class _CreateOrUpdateNoteViewState extends State<CreateOrUpdateNoteView> {
  DatabaseNote? _note;
  late final NotesService _notesService;
  late final TextEditingController _textController;
  late final bool _isUpdateMode;
  final ValueNotifier<bool> _isTextNotEmpty = ValueNotifier<bool>(false);

  @override
  void initState() {
    _notesService = NotesService();
    _isUpdateMode = isUpdateMode();
    _textController = TextEditingController();
    _textController.addListener(_onTextChanged);
    super.initState();
  }

  bool isUpdateMode() {
    return (widget.currentNote != null) ? true : false;
  }

  Future<DatabaseNote> createNewNote() async {
    final existingNote = _note;
    if (existingNote != null) {
      return existingNote;
    }
    final currentUser = AuthService.firebase().currentUser!;
    final email = currentUser.email!;
    final owner = await _notesService.getUser(email: email);
    return await _notesService.createNote(owner: owner);
  }

  Future<DatabaseNote> getCurrentNote() async {
    final existingNote =
        await _notesService.getNote(id: widget.currentNote!.id);
    devtools.log(existingNote.text);
    _note = existingNote;
    _textController.text = _note!.text;
    return existingNote;
  }

  void _onTextChanged() {
    _isTextNotEmpty.value = _textController.text.isNotEmpty;
  }

  void _textControllerListener() async {
    final note = _note;
    if (note == null) {
      return;
    }
    final text = _textController.text;
    await _notesService.updateNote(
      note: note,
      text: text,
    );
  }

  void _setupTextControllerListener() {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

  Future<bool> _deleteNoteIfTextIsEmpty() async {
    final note = _note;
    if (_textController.text.isEmpty && note != null) {
      await _notesService.deleteNote(id: note.id);
    }
    return _textController.text.isNotEmpty;
  }

  Future<void> _saveNoteIfTextNotEmpty() async {
    final note = _note;
    final text = _textController.text;
    if (text.isNotEmpty && note != null) {
      await _notesService.updateNote(
        note: note,
        text: text,
      );
      _notesService.addNoteToStream();
    }
  }

  @override
  void dispose() async {
    final bool noteShouldExist = await _deleteNoteIfTextIsEmpty();
    // devtools.log(noteShouldExist.toString());
    if (noteShouldExist) await _saveNoteIfTextNotEmpty();
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    super.dispose();
  }

  // void _onCheckIconPressed() {
  //   dispose();
  //   Navigator.of(context).pop();
  // }

  @override
  Widget build(BuildContext context) {
    devtools.log(_isUpdateMode.toString());

    return Scaffold(
      appBar: AppBar(
        title:
            _isUpdateMode ? const Text("Update Note") : const Text("New Note"),
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: _isTextNotEmpty,
            builder: (context, isTextNotEmpty, child) {
              // add functionality
              return const IconButton(
                icon: Icon(Icons.check),
                onPressed: null,
              );
            },
          ),
        ],
      ),
      body: _isUpdateMode
          ? FutureBuilder(
              future: getCurrentNote(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.done:
                    _note = snapshot.data as DatabaseNote;
                    devtools.log(_note.toString());
                    _setupTextControllerListener();
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: _textController,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        decoration: const InputDecoration(
                            hintText: "Write what's on your mind..."),
                      ),
                    );
                  default:
                    return const Center(child: CircularProgressIndicator());
                }
              },
            )
          : FutureBuilder(
              future: createNewNote(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.done:
                    _note = snapshot.data as DatabaseNote;
                    _setupTextControllerListener();
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: _textController,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        decoration: const InputDecoration(
                            hintText: "Write what's on your mind..."),
                      ),
                    );
                  default:
                    return const Center(child: CircularProgressIndicator());
                }
              },
            ),
    );
  }
}
