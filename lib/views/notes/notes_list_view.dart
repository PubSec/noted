import 'package:flutter/material.dart';
import 'package:noted/services/crud/notes_service.dart';
import 'package:noted/utilities/dialogs/delete_dialog.dart';

typedef DeleteNoteCallBack = void Function(DataBaseNotes notes);

class NotesListView extends StatelessWidget {
  final List<DataBaseNotes> notes;

  final DeleteNoteCallBack onDeleteNote;

  const NotesListView({
    super.key,
    required this.notes,
    required this.onDeleteNote,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return ListTile(
          title: Text(
            note.text,
            maxLines: 1,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: IconButton(
            onPressed: () async {
              final shouldDelete = await showDeleteDialog(context);
              if (shouldDelete) {
                onDeleteNote(note);
              }
            },
            icon: const Icon(Icons.delete),
          ),
        );
      },
    );
  }
}