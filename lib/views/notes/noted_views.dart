// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:noted/constants/routes.dart';
import 'package:noted/enums/menu_action.dart';
import 'package:noted/services/auth/auth_service.dart';
import 'package:noted/services/crud/notes_service.dart';
import 'package:noted/utilities/dialogs/logout_dialog.dart';
import 'package:noted/views/notes/notes_list_view.dart';

class NotedView extends StatefulWidget {
  const NotedView({super.key});

  @override
  State<NotedView> createState() => _NotedViewState();
}

class _NotedViewState extends State<NotedView> {
  late final NotesServices _notesServices;
  String get userEmail => AuthService.firebase().currentUser!.email!;

  @override
  void initState() {
    _notesServices = NotesServices();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notes'),
        backgroundColor: Colors.amber,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(createOrUpdateNoteRoute);
            },
            icon: const Icon(Icons.add),
          ),
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogOut = await showLogOutDialog(context);
                  if (shouldLogOut == true) {
                    await AuthService.firebase().logOut();
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      loginRoute,
                      (_) => false,
                    );
                  }
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text('Logout'),
                )
              ];
            },
          )
        ],
      ),
      body: FutureBuilder(
        future: _notesServices.getOrCreateUser(email: userEmail),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return StreamBuilder(
                stream: _notesServices.allNotes,
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.active:
                      if (snapshot.hasData) {
                        final allNotes = snapshot.data as List<DataBaseNotes>;
                        return NotesListView(
                          notes: allNotes,
                          onDeleteNote: (note) async {
                            await _notesServices.deleteNote(
                              id: note.id,
                            );
                          },
                          onTap: (notes) {
                            Navigator.of(context).pushNamed(
                              createOrUpdateNoteRoute,
                              arguments: notes,
                            );
                          },
                        );
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    default:
                      return const Center(child: CircularProgressIndicator());
                  }
                },
              );
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
