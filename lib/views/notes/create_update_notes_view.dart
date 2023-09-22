import 'package:flutter/material.dart';
import 'package:noted/services/auth/auth_service.dart';
import 'package:noted/utilities/dialogs/cannot_share_empty_note_dialog.dart';
import 'package:noted/utilities/generics/get_arguments.dart';
import 'package:noted/services/cloud/cloud_note.dart';
// import 'package:noted/services/cloud/cloud_storage_exceptions.dart';
import 'package:noted/services/cloud/firebase_cloud_storage.dart';
import 'package:share_plus/share_plus.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({super.key});

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
  CloudNote? _note;
  late final FirebaseCloudStorage _notesServices;
  late final TextEditingController _textControllor;

  @override
  void initState() {
    _notesServices = FirebaseCloudStorage();
    _textControllor = TextEditingController();
    super.initState();
  }

  void _textControllorListener() async {
    final note = _note;
    if (note == null) {
      return;
    }
    final text = _textControllor.text;
    await _notesServices.updateNote(
      documentId: note.documentId,
      text: text,
    );
  }

  void _setupTextControllerListener() {
    _textControllor.removeListener(_textControllorListener);
    _textControllor.addListener(_textControllorListener);
  }

  Future<CloudNote> createOrGetExistingNote(BuildContext context) async {
    final widgetNote = context.getArgument<CloudNote>();

    if (widgetNote != null) {
      _note = widgetNote;
      _textControllor.text = widgetNote.text;
      return widgetNote;
    }

    final existingNote = _note;
    if (existingNote != null) {
      return existingNote;
    }
    final currentUser = AuthService.firebase().currentUser!;
    final userId = currentUser.id;
    final newNote = await _notesServices.createNewNote(ownerUserId: userId);
    _note = newNote;
    return newNote;
  }

  void _deleteNoteIfTextIsEmpty() {
    final note = _note;
    if (_textControllor.text.isEmpty && note != null) {
      _notesServices.deleteNote(documentId: note.documentId);
    }
  }

  void _saveNoteIfTextNotEmpty() async {
    final note = _note;
    final text = _textControllor.text;
    if (note != null && text.isNotEmpty) {
      await _notesServices.updateNote(documentId: note.documentId, text: text);
    }
  }

  @override
  void dispose() {
    _deleteNoteIfTextIsEmpty();
    _saveNoteIfTextNotEmpty();
    _textControllor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Notes'),
        actions: [
          IconButton(
              onPressed: () async {
                final text = _textControllor.text;
                if (_note == null || text.isEmpty) {
                  await showCannotShareEmptyNoteDialog(context);
                } else {
                  Share.share(text);
                }
              },
              icon: const Icon(Icons.share_rounded))
        ],
      ),
      body: FutureBuilder(
          future: createOrGetExistingNote(context),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                _note = snapshot.data;
                _setupTextControllerListener();
                return TextField(
                  controller: _textControllor,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: const InputDecoration(
                    hintText: 'Input your note here...',
                  ),
                );
              default:
                return const Center(child: CircularProgressIndicator());
            }
          }),
    );
  }
}
