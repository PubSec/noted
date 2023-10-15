// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show ReadContext;
import 'package:noted/constants/mycolors.dart';
import 'package:noted/constants/routes.dart';
import 'package:noted/constants/text_style.dart';
import 'package:noted/enums/menu_action.dart';
import 'package:noted/services/auth/auth_service.dart';
import 'package:noted/services/auth/bloc/auth_bloc.dart';
import 'package:noted/services/auth/bloc/auth_event.dart';
import 'package:noted/services/cloud/cloud_note.dart';
import 'package:noted/services/cloud/firebase_cloud_storage.dart';
import 'package:noted/utilities/dialogs/generic_dialogs.dart';
import 'package:noted/utilities/dialogs/logout_dialog.dart';
import 'package:noted/views/notes/notes_list_view.dart';

class NotedView extends StatefulWidget {
  const NotedView({super.key});

  @override
  State<NotedView> createState() => _NotedViewState();
}

class _NotedViewState extends State<NotedView> {
  late final FirebaseCloudStorage _notesServices;
  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    _notesServices = FirebaseCloudStorage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: containercolor,
      appBar: AppBar(
        toolbarHeight: 50,
        leading: const Icon(
          Icons.snowing,
          size: 30,
          color: whiteColor,
        ),
        title: Text(
          'My Notes',
          style: textStyle(
            family: akira,
            size: 23,
          ),
        ),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              showGenericDialog(
                context: context,
                title: 'Buy Me Coffee',
                content:
                    'Please buy me a coffee here https://www.buymeacoffee.com/notedapp',
                optionBuilder: () => {
                  'OK': null,
                },
              );
            },
            icon: const Icon(
              Icons.info_outline_rounded,
              color: whiteColor,
            ),
          ),
          PopupMenuButton<MenuAction>(
            color: whiteColor,
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogOut = await showLogOutDialog(context);
                  if (shouldLogOut == true) {
                    context.read<AuthBloc>().add(
                          const AuthEventLogOut(),
                        );
                  }
              }
            },
            itemBuilder: (context) {
              return [
                PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text(
                    'Logout',
                    style: textStyle(color: Colors.blue),
                  ),
                )
              ];
            },
          )
        ],
      ),
      body: Container(
        color: whiteColor,
        child: StreamBuilder(
          stream: _notesServices.allNotes(ownerUserId: userId),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
              case ConnectionState.active:
                if (snapshot.hasData) {
                  final allNotes = snapshot.data as Iterable<CloudNote>;
                  return NotesListView(
                    notes: allNotes,
                    onDeleteNote: (note) async {
                      await _notesServices.deleteNote(
                          documentId: note.documentId);
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
        ),
      ),
      floatingActionButton: IconButton(
        onPressed: () {
          Navigator.of(context).pushNamed(createOrUpdateNoteRoute);
        },
        icon: const CircleAvatar(
          minRadius: 30,
          maxRadius: 30,
          backgroundColor: containercolor,
          child: Icon(
            Icons.add_rounded,
            color: whiteColor,
            size: 60,
          ),
        ),
      ),
    );
  }
}
