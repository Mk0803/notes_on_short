import 'package:flutter/material.dart';
import 'package:notes_on_short/features/notes/models/note.dart';
import 'package:notes_on_short/features/notes/services/isar_service.dart';
import 'package:notes_on_short/features/notes/services/firestore_service.dart';
import 'package:notes_on_short/utils/logger/logger.dart';

class NotesRepository extends ChangeNotifier {
  final IsarService _isarService = IsarService();
  final FirestoreService _firestoreService = FirestoreService();

  Future<void> initialize() async {
    await IsarService.initialize();
  }

  static bool isInitialized() {
    return IsarService.isInitialized;
  }

  Future<void> addNote(Note note) async {
    note.isSynced = false;
    await _isarService.addNote(note);
    notifyListeners();
  }

  Future<void> updateNote(Note note) async {
    note.isSynced = false;
    await _isarService.updateNote(note);
    notifyListeners();
  }

  Future<void> deleteNote(int id) async {
    await _isarService.deleteNote(id);
    notifyListeners();
  }

  Future<List<Note>> getNotes() async {
    return await _isarService.getNotes();
  }

  Future<void> syncNotes({BuildContext? context,}) async {
    try {

      // Check if we can sync
      if (!await _firestoreService.canSync()) return;

      // Get local notes
      final List<Note> localNotes = await getNotes();
      final localNoteIds = localNotes.map((note) => note.id.toString()).toSet();

      // Get cloud note IDs
      final cloudNotes = await _firestoreService.getCloudNotes();
      final cloudNoteIds = cloudNotes.map((note) => note.id.toString()).toSet();

      // Upload local notes
      await _firestoreService.uploadNotes(localNotes);

      // Mark local notes as synced
      await _isarService.markNotesAsSynced(localNotes);

      // Delete cloud notes not in local DB
      final notesToDelete = cloudNoteIds.difference(localNoteIds);
      await _firestoreService.deleteCloudNotes(notesToDelete);

      AppLogger.i('Sync complete. All local notes pushed, unmatched cloud notes removed.');
      notifyListeners();
    } catch (e) {
      AppLogger.i('Unexpected sync error: $e');
    }
  }

  Future<void> pullMissingCloudNotes() async {
    try {
      if (!await _firestoreService.canSync()) return;

      final localNotes = await getNotes();
      final localIds = localNotes.map((note) => note.id.toString()).toSet();

      final cloudNotes = await _firestoreService.getCloudNotes();
      final newNotes = cloudNotes.where((note) => !localIds.contains(note.id.toString())).toList();

      if (newNotes.isNotEmpty) {
        await _isarService.saveCloudNotes(newNotes);
        notifyListeners();
        AppLogger.i('Pulled ${newNotes.length} missing notes from cloud to local DB.');
      }
    } catch (e) {
      AppLogger.i('Error pulling missing notes: $e');
    }
  }
}