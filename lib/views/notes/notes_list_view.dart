import 'package:flutter/material.dart';
import 'package:noted/services/crud/notes_service.dart';
import 'package:noted/utilities/dialogs/delete_dialog.dart';

typedef NoteCallBack = void Function(DataBaseNotes notes);

class NotesListView extends StatelessWidget {
  final List<DataBaseNotes> notes;
  final NoteCallBack onTap;
  final NoteCallBack onDeleteNote;

  const NotesListView({
    super.key,
    required this.notes,
    required this.onDeleteNote,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return ListTile(
          onTap: () {
            onTap(note);
          },
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
            icon: const Icon(Icons.delete_forever_sharp),
          ),
        );
      },
    );
  }
}
