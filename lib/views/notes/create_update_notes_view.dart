import 'package:flutter/material.dart';
import 'package:noted/services/auth/auth_service.dart';
import 'package:noted/services/crud/notes_service.dart';
import 'package:noted/utilities/generics/get_arguments.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({super.key});

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
  DataBaseNotes? _note;
  late final NotesServices _notesServices;
  late final TextEditingController _textControllor;

  @override
  void initState() {
    _notesServices = NotesServices();
    _textControllor = TextEditingController();
    super.initState();
  }

  void _textControllorListener() async {
    final note = _note;
    if (note == null) {
      return;
    }
    final text = _textControllor.text;
    await _notesServices.updateNotes(
      note: note,
      text: text,
    );
  }

  void _setupTextControllerListener() {
    _textControllor.removeListener(_textControllorListener);
    _textControllor.addListener(_textControllorListener);
  }

  Future<DataBaseNotes> createOrGetExistingNote(BuildContext context) async {
    final widgetNote = context.getArgument<DataBaseNotes>();

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
    final email = currentUser.email!;
    final owner = await _notesServices.getUser(email: email);
    final newNote = await _notesServices.createNote(owner: owner);
    _note = newNote;
    return newNote;
  }

  void _deleteNoteIfTextIsEmpty() {
    final note = _note;
    if (_textControllor.text.isEmpty && note != null) {
      _notesServices.deleteNote(id: note.id);
    }
  }

  void _saveNoteIfTextNotEmpty() async {
    final note = _note;
    final text = _textControllor.text;
    if (note != null && text.isNotEmpty) {
      await _notesServices.updateNotes(note: note, text: text);
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
