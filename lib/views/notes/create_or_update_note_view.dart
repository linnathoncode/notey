import 'package:flutter/material.dart';
import 'package:notey/components/text_field.dart';
import 'package:notey/services/auth/auth_service.dart';
import 'package:notey/services/cloud/cloud_note.dart';
import 'package:notey/services/cloud/firebase_cloud_storage.dart';
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

  @override
  void dispose() {
    handleDispose(); //fire and forget
    _textController.dispose();
    _titleController.dispose();
    super.dispose();
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
      documentId: note.documentId,
      text: text,
      title: title,
    );
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
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.tertiary,
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
                color: Theme.of(context).colorScheme.tertiary,
                disabledColor: Theme.of(context).disabledColor,
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
                  mainAxisSize:
                      MainAxisSize.min, // Adjusts to the height of its children
                  children: [
                    const SizedBox(height: 16),

                    // Title TextField
                    SizedBox(
                      height: MediaQuery.of(context).size.height *
                          0.1, // 10% of screen height
                      child: customTextField(
                        context: context,
                        textController: _titleController,
                        hintText: "Write a title...",
                        autoFocus: false,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Text TextField
                    SizedBox(
                      height: MediaQuery.of(context).size.height *
                          0.7, // 70% of screen height
                      child: customTextField(
                        context: context,
                        textController: _textController,
                        hintText: "Write a note...",
                        autoFocus: true,
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
