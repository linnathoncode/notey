import 'package:flutter/material.dart';
import 'package:notey/services/auth/auth_service.dart';
import 'package:notey/services/cloud/cloud_note.dart';
import 'package:notey/services/cloud/firebase_cloud_storage.dart';
import 'package:notey/utilities/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  late final TextEditingController _titleController;
  late final bool _isUpdateMode;
  final ValueNotifier<bool> _isTextNotEmpty = ValueNotifier<bool>(false);

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    _isUpdateMode = isUpdateMode();
    _textController = TextEditingController();
    _titleController = TextEditingController();
    _titleController.addListener(_onTextChanged);
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
      _textController.text = widgetNote.text;
      _titleController.text = widgetNote.title;
      return widgetNote;
    } else {
      final existingNote = _note;
      if (existingNote != null) {
        return existingNote;
      }
      final currentUser = AuthService.firebase().currentUser!;
      final userId = currentUser.id;
      return CloudNote(
        documentId: '',
        ownerUserId: userId,
        text: '',
        title: '',
        date: Timestamp.fromDate(DateTime.now()),
      );
    }
  }

  void _onTextChanged() {
    _isTextNotEmpty.value =
        (_textController.text.isNotEmpty || _titleController.text.isNotEmpty);
  }

  Future<bool> _deleteNoteIfTextIsEmpty() async {
    final note = _note;
    if (!(_isTextNotEmpty.value) && note != null) {
      await _notesService.deleteNote(documentId: note.documentId);
    }
    return _isTextNotEmpty.value;
  }

  Future<void> _saveNoteIfTextNotEmpty() async {
    final note = _note;
    final text = _textController.text;
    final title = _titleController.text;
    if (_isTextNotEmpty.value && note != null) {
      await _notesService.updateNote(
          documentId: note.documentId, text: text, title: title);
    }
  }

  @override
  void dispose() async {
    await handleDispose();
    _textController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  Future<void> handleDispose() async {
    if (_isUpdateMode) {
      final noteShouldExist = await _deleteNoteIfTextIsEmpty();
      if (noteShouldExist) {
        await _saveNoteIfTextNotEmpty();
      }
    } else {
      if (!_isTextNotEmpty.value) {
        return;
      } else {
        createNewNote();
      }
    }
  }

  Future<void> createNewNote() async {
    final currentUser = AuthService.firebase().currentUser!;
    final userId = currentUser.id;

    final note = await _notesService.createNewNote(ownerUserId: userId);
    final text = _textController.text;
    final title = _titleController.text;
    await _notesService.updateNote(
        documentId: note.documentId, text: text, title: title);
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

              // MAKE CUSTOM TEXTFIELD
              return SingleChildScrollView(
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.start, // Aligns items at the top
                  children: [
                    const SizedBox(
                      height: 16,
                    ),
                    // Title TextField
                    Center(
                      child: Container(
                        height: MediaQuery.of(context).size.height *
                            0.1, // Make this smaller
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16.0), // Margin around the container
                        decoration: BoxDecoration(
                          color: kAccentColor,
                          borderRadius:
                              BorderRadius.circular(20), // Curvy corners
                          border: Border.all(
                            width: 4.0, // Border width
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: TextField(
                          autofocus: false,
                          showCursor: true,
                          cursorColor: kPrimaryColor,
                          controller: _titleController,
                          keyboardType: TextInputType.multiline,
                          maxLines: 1, // Single line for the title
                          style: const TextStyle(
                            fontSize: 18, // Font size for the title
                            color: kFontColor,
                            fontWeight: FontWeight.w400,
                          ),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(20), // Curvy corners
                              borderSide: BorderSide.none, // No visible border
                            ),
                            hintText: "Write a title...",
                            hintStyle: const TextStyle(
                              color: kHintColor,
                              fontSize: 16,
                            ),
                            filled: true,
                            fillColor: kAccentColor,
                          ),
                        ),
                      ),
                    ),
                    // Spacing between TextFields
                    const SizedBox(
                      height: 16,
                    ), // Adjust this for more or less spacing

                    // Text TextField
                    Center(
                      child: Container(
                        height: MediaQuery.of(context).size.height *
                            0.7, // Make this larger
                        margin: const EdgeInsets.symmetric(horizontal: 16.0),
                        decoration: BoxDecoration(
                          color: kAccentColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            width: 4.0,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: TextField(
                          autofocus: true,
                          showCursor: true,
                          expands: true,
                          cursorColor: kPrimaryColor,
                          controller: _textController,
                          keyboardType: TextInputType.multiline,
                          maxLines: null, // Multiline for body text
                          textAlignVertical: TextAlignVertical.top,
                          style: const TextStyle(
                            fontSize: 18, // Font size for body text
                            color: kFontColor,
                            fontWeight: FontWeight.w400,
                          ),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            hintText: "Write what's on your mind...",
                            hintStyle: const TextStyle(
                              color: kHintColor,
                              fontSize: 16,
                            ),
                            filled: true,
                            fillColor: kAccentColor,
                          ),
                        ),
                      ),
                    ),
                  ],
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
