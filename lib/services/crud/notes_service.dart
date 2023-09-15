import 'dart:async';
import 'package:flutter/material.dart';
import 'package:noted/services/crud/crud_exception.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart'
    show MissingPlatformDirectoryException, getApplicationDocumentsDirectory;
import 'package:sqflite/sqflite.dart';

class NotesServices {
  Database? _db;
  List<DataBaseNotes> _notes = [];

  static final NotesServices _shared = NotesServices._sharedInstance();
  NotesServices._sharedInstance() {
    _notesStreamController = StreamController<List<DataBaseNotes>>.broadcast(
      onListen: () {
        _notesStreamController.sink.add(_notes);
      },
    );
  }
  factory NotesServices() => _shared;

  late final StreamController<List<DataBaseNotes>> _notesStreamController;

  Stream<List<DataBaseNotes>> get allNotes => _notesStreamController.stream;

  Future<DataBaseUser> getOrCreateUser({required String email}) async {
    try {
      final user = await getUser(email: email);
      return user;
    } on CouldNotFindUser {
      final createdUser = createUser(email: email);
      return createdUser;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _cacheNotes() async {
    final allNotes = await getAllNotes();
    _notes = allNotes.toList();
    _notesStreamController.add(_notes);
  }

  Future<DataBaseNotes> updateNotes(
      {required DataBaseNotes note, required String text}) async {
    await _ensureDBIsOpen();
    final db = _getDatabaseOrThrow();
    await getNote(id: note.id);

    final updatesCount = await db.update(noteTable, {
      textColumn: text,
      isSyncedWithCloudColumn: 0,
    });
    if (updatesCount == 0) {
      throw CouldNotUpdateNote();
    } else {
      final updatedNote = await getNote(id: note.id);
      _notes.removeWhere((note) => note.id == updatedNote.id);
      _notes.add(updatedNote);
      _notesStreamController.add(_notes);
      return updatedNote;
    }
  }

  Future<Iterable<DataBaseNotes>> getAllNotes() async {
    await _ensureDBIsOpen();
    final db = _getDatabaseOrThrow();
    final notes = await db.query(noteTable);
    return notes.map((noteRow) => DataBaseNotes.fromRow(noteRow));
  }

  Future<DataBaseNotes> getNote({required int id}) async {
    await _ensureDBIsOpen();
    final db = _getDatabaseOrThrow();
    final notes = await db.query(
      noteTable,
      limit: 1,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (notes.isEmpty) {
      throw CouldNotFindNotes();
    } else {
      final note = DataBaseNotes.fromRow(notes.first);
      _notes.removeWhere((note) => note.id == id);
      _notesStreamController.add(_notes);
      return note;
    }
  }

  Future<int> deleteAllNote() async {
    await _ensureDBIsOpen();
    final db = _getDatabaseOrThrow();
    final numberofDeletion = await db.delete(noteTable);
    _notes = [];
    _notesStreamController.add(_notes);
    return numberofDeletion;
  }

  Future<void> deleteNote({required int id}) async {
    await _ensureDBIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      noteTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (deletedCount == 0) {
      throw CouldNotDeleteNote();
    } else {
      _notes.removeWhere((note) => note.id == id);
      _notesStreamController.add(_notes);
    }
  }

  Future<DataBaseNotes> createNote({required DataBaseUser owner}) async {
    await _ensureDBIsOpen();
    final db = _getDatabaseOrThrow();
    // make sure user exists with the correct id in the database
    final dbUser = await getUser(email: owner.email);
    if (dbUser != owner) {
      throw CouldNotFindUser();
    }

    // create note
    final noteId = await db.insert(userTable,
        {userIdColumn: owner.id, textColumn: text, isSyncedWithCloudColumn: 1});

    final note = DataBaseNotes(
      id: noteId,
      userId: owner.id,
      text: text,
      isSyncedWithCloud: true,
    );

    _notes.add(note);
    _notesStreamController.add(_notes);

    return note;
  }

  Future<DataBaseUser> getUser({required String email}) async {
    await _ensureDBIsOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (results.isEmpty) {
      throw CouldNotFindUser();
    } else {
      return DataBaseUser.fromRow(results.first);
    }
  }

  Future<DataBaseUser> createUser({required String email}) async {
    await _ensureDBIsOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (results.isNotEmpty) {
      throw UserAlreadyExists();
    }
    final userId = await db.insert(
      userTable,
      {emailColumn: email.toLowerCase()},
    );

    return DataBaseUser(id: userId, email: email);
  }

  Future<void> deleteUser({required String email}) async {
    await _ensureDBIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      userTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase],
    );
    if (deletedCount != 1) {
      throw CouldNotDeleteUser();
    }
  }

  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      return db;
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      db.close();
      db.close();
    }
  }

  Future<void> _ensureDBIsOpen() async {
    try {
      await open();
    } on DatabaseAlreadyOpenException {
      // empty
    }
  }

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;
      // Create User Table
      await _db!.execute(createUserTable);
      // Create notes table
      await _db!.execute(createNotesTable);
      await _cacheNotes();
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectory();
    }
  }
}

@immutable
class DataBaseUser {
  final int id;
  final String email;

  const DataBaseUser({
    required this.id,
    required this.email,
  });

  DataBaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() => 'Person, ID = $id, email = $email';

  @override
  bool operator ==(covariant DataBaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

@immutable
class DataBaseNotes {
  final int id;
  final int userId;
  final String text;
  final bool isSyncedWithCloud;

  const DataBaseNotes({
    required this.id,
    required this.userId,
    required this.text,
    required this.isSyncedWithCloud,
  });

  DataBaseNotes.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        text = map[textColumn] as String,
        isSyncedWithCloud =
            (map[isSyncedWithCloudColumn] as int) == 1 ? true : false;

  @override
  String toString() =>
      'Note, ID = $id, user_id = $userId, isSyncedWithCloud = $isSyncedWithCloud text = $text';

  @override
  bool operator ==(covariant DataBaseNotes other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const text = '';
const dbName = 'notes.db';
const userTable = 'user';
const noteTable = 'note';
const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'user_id';
const textColumn = 'text';
const isSyncedWithCloudColumn = 'is_synced_with_cloud';

const createUserTable = '''CREATE TABLE IF NOT EXISTS "user"(
        "id" INTEGER NOT NULL,
        "email" TEXT NOT NULL UNIQUE,
        PRIMARY KEY("id" AUTOINCREMENT)
      );''';

const createNotesTable = '''
      CREATE TABLE IF NOT EXISTS "notes"(
        "id" INTEGER NOT NULL,
        "user_id" INTEGER NOT NULL,
        "note" TEXT NOT NULL,
        "is_synced_to_cloud" INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY("user_id") REFERENCES "user"("id"),
        PRIMARY KEY("id" AUTOINCREMENT), 
      );''';
