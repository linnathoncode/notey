import 'package:flutter/material.dart';
import 'package:notey/services/auth/auth_service.dart';
import 'package:notey/services/cloud/cloud_note.dart';
import 'package:notey/services/cloud/firebase_cloud_storage.dart';
import 'package:notey/utilities/colors.dart';
import 'dart:developer' as devtools show log;

class CreateOrUpdateNoteView extends StatefulWidget {
  final CloudNote? currentNote;

  const CreateOrUpdateNoteView({super.key, this.currentNote});

  @override
  State<CreateOrUpdateNoteView> createState() => _CreateOrUpdateNoteViewState();
}

class _CreateOrUpdateNoteViewState extends State<CreateOrUpdateNoteView> {
  CloudNote? _note;
  late final FirebaseCloudStorage _notesService;
  late final TextEditingController _textController;
  late final bool _isUpdateMode;
  final ValueNotifier<bool> _isTextNotEmpty = ValueNotifier<bool>(false);

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    _isUpdateMode = isUpdateMode();
    _textController = TextEditingController();
    _textController.addListener(_onTextChanged);
    super.initState();
  }

  bool isUpdateMode() {
    return (widget.currentNote != null) ? true : false;
  }

  Future<CloudNote> createOrGetExistingNote(BuildContext context) async {
    final widgetNote = widget.currentNote;

    if (widgetNote != null) {
      _note = widgetNote;
      devtools.log(_note!.text);
      _textController.text = widgetNote.text;
      return widgetNote;
    }

    final existingNote = _note;
    if (existingNote != null) {
      return existingNote;
    }
    final currentUser = AuthService.firebase().currentUser!;
    final userId = currentUser.id;
    final newNote = await _notesService.createNewNote(ownerUserId: userId);
    _note = newNote;
    if (mounted) {
      setState(() {});
    }
    return newNote;
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
    await _notesService.updateNote(documentId: note.documentId, text: text);
  }

  void _setupTextControllerListener() {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

  Future<bool> _deleteNoteIfTextIsEmpty() async {
    final note = _note;
    if (_textController.text.isEmpty && note != null) {
      await _notesService.deleteNote(documentId: note.documentId);
    }
    if (mounted) {
      setState(() {});
    }
    return _textController.text.isNotEmpty;
  }

  Future<void> _saveNoteIfTextNotEmpty() async {
    final note = _note;
    final text = _textController.text;
    if (text.isNotEmpty && note != null) {
      await _notesService.updateNote(documentId: note.documentId, text: text);
    }
  }

  @override
  void dispose() {
    if (mounted) {
      _textController.removeListener(_onTextChanged);
      _textController.dispose();
      _handleNoteOnDispose();
    }
    super.dispose();
  }

  Future<void> _handleNoteOnDispose() async {
    final noteShouldExist = await _deleteNoteIfTextIsEmpty();
    if (noteShouldExist) {
      await _saveNoteIfTextNotEmpty();
    }
  }

  void _saveAndExit() {
    if (mounted) {
      Navigator.of(context).pop();
    }
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
        backgroundColor: kPrimaryColor,
        foregroundColor: kAccentColor,
        title: _isUpdateMode
            ? const Text(
                "Update Note",
                style: TextStyle(fontWeight: FontWeight.bold),
              )
            : const Text(
                "New Note",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: _isTextNotEmpty,
            builder: (context, isTextNotEmpty, child) {
              // add functionality
              return IconButton(
                icon: const Icon(Icons.check),
                color: Colors.white,
                disabledColor: kDisabledColor,
                onPressed: isTextNotEmpty
                    ? () {
                        _saveAndExit();
                      }
                    : null,
              );
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: createOrGetExistingNote(context),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              _note = snapshot.data as CloudNote;
              // devtools.log(_note.toString());
              _setupTextControllerListener();
              return Container(
                color: kPrimaryColor, // Background color of the entire view
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.all(
                        16.0), // Add margin to make shadows visible
                    decoration: BoxDecoration(
                      color: kAccentColor,
                      borderRadius: BorderRadius.circular(20), // Curvy corners
                      // boxShadow: const [
                      //   BoxShadow(
                      //     color: kPrimaryColor,
                      //     blurRadius: 8.0,
                      //     offset: Offset(0, 2),
                      //   ),
                      // ],
                      border: Border.all(
                        color: kSecondaryColor, // Border color
                        width: 4.0, // Border width
                      ),
                    ),
                    padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 8,
                        bottom: 8), // Inner padding for the TextField
                    child: TextField(
                      autofocus: true,
                      showCursor: true,
                      expands: true,
                      cursorColor: kPrimaryColor, // Cursor color
                      controller: _textController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      textAlignVertical: TextAlignVertical.top,
                      style: const TextStyle(
                        fontSize:
                            18, // Adjust to suit the Redmi note app font size
                        color: kFontColor,
                        fontWeight:
                            FontWeight.w400, // Adjust for note-like feel
                      ),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              20), // Curvy corners for TextField
                          borderSide: BorderSide.none, // No visible border
                        ),
                        hintText: "Write what's on your mind...",
                        hintStyle: const TextStyle(
                          color: kHintColor, // Softer hint text color
                          fontSize: 16,
                        ),
                        filled: true,
                        fillColor:
                            kAccentColor, // Background color for TextField
                        contentPadding: const EdgeInsets.only(
                          top: 10.0,
                          left: 15.0, // Padding for top-left alignment
                        ),
                      ),
                      cursorHeight:
                          22, // Adjust cursor height to match text size
                      cursorRadius: const Radius.circular(
                          2.0), // Rounded cursor (droplet-like)
                      cursorWidth: 2.0, // Thin cursor
                    ),
                  ),
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
