import 'package:isar/isar.dart';
import 'package:notes_on_short/features/notes/models/note.dart';
import 'package:notes_on_short/utils/logger/logger.dart';
import 'package:path_provider/path_provider.dart';

class IsarService {
  static Isar? _db;

  static Isar get db {
    if (_db == null) {
      throw StateError(
          'Database not initialized. Call IsarService.initialize() first.');
    }
    return _db!;
  }

  static bool get isInitialized => _db != null;

  static Future<void> initialize() async {
    if (isInitialized) return;

    final appDir = await getApplicationDocumentsDirectory();
    _db = await Isar.open([NoteSchema], directory: appDir.path);
  }

  Future<void> addNote(Note note) async {
    try {
      note.lastModified = DateTime.now();
      await db.writeTxn(() async {
        await db.notes.put(note);
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateNote(Note note) async {
    try {
      note.lastModified = DateTime.now();
      await db.writeTxn(() async {
        await db.notes.put(note);
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteNote(int id) async {
    try {
      await db.writeTxn(() async {
        await db.notes.delete(id);
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Note>> getNotes() async {
    try {
      if (!isInitialized) {
        await initialize();
      }
      return await db.notes.where().findAll();
    } catch (e) {
      return [];
    }
  }

  Future<void> markNotesAsSynced(List<Note> notes) async {
    try {
      await db.writeTxn(() async {
        for (final note in notes) {
          note.isSynced = true;
          await db.notes.put(note);
        }
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> saveCloudNotes(List<Note> notes) async {
    try {
      await db.writeTxn(() async {
        await db.notes.putAll(notes);
      });
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> clearDatabase() async {
    try {
      if (!isInitialized) {
        return;
      }
      await db.writeTxn(() async {
        await db.notes.clear();
      });
    } catch (e) {
      rethrow;
    }
  }
}
