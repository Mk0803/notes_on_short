import 'package:flutter/material.dart';
import 'package:notes_on_short/features/notes/models/note.dart';
import 'package:notes_on_short/features/notes/services/isar_service.dart';
import 'package:notes_on_short/features/notes/services/firestore_service.dart';
import '../../../common/widgets/error_message.dart';

class NotesRepository extends ChangeNotifier {
  final IsarService _isarService = IsarService();
  final FirestoreService _firestoreService = FirestoreService();

  List<Note> _notes = [];
  List<Note> _filteredNotes = [];
  List<Note> _starredNotes = [];

  bool _isSyncing = false;
  String _searchQuery = '';
  String _colorFilter = '';
  bool _isDataLoaded = false;

  List<Note> get notes =>
      _filteredNotes.isEmpty && _searchQuery.isEmpty && _colorFilter.isEmpty ? _notes : _filteredNotes;
  List<Note> get allNotes => _notes;
  List<Note> get starredNotes => _starredNotes;
  bool get isSyncing => _isSyncing;
  String get searchQuery => _searchQuery;
  String get colorFilter => _colorFilter; // Add getter for color filter
  bool get hasSearchResults => _filteredNotes.isNotEmpty;
  bool get hasActiveFilters => _searchQuery.isNotEmpty || _colorFilter.isNotEmpty; // Add getter for active filters
  bool get isDataLoaded => _isDataLoaded;

  set isDataLoaded(bool value) {
    _isDataLoaded = value;
    notifyListeners();
    debugPrint("isDataLoaded: $_isDataLoaded");
  }

  Future<void> initialize() async {
    await IsarService.initialize();
  }

  static bool isInitialized() {
    return IsarService.isInitialized;
  }

  int _findNoteIndex(int noteId) {
    for(int i = 0; i< _notes.length; i++){
      if(_notes[i].id == noteId){
        return i;
      }
    }
    return -1;
  }

  Future<void> loadNotesFromDatabase({BuildContext? context}) async {
    try {
      _notes = await _isarService.getNotes();
      _isDataLoaded = true;
      updateStarredNotes();

      if (_searchQuery.isNotEmpty || _colorFilter.isNotEmpty) {
        _performFiltering();
      }

      notifyListeners();
    } catch (e) {
      if (context != null) {
        ErrorMessage.show(context, 'Error loading notes: $e');
      }
    }
  }

  Future<void> loadNotes({BuildContext? context}) async {
    if (!_isDataLoaded) {
      await loadNotesFromDatabase(context: context);
    }
  }

  Future<void> addNote(Note note) async {
    note.isSynced = false;
    _notes.insert(0, note);
    updateStarredNotes();
    if (_searchQuery.isNotEmpty || _colorFilter.isNotEmpty) {
      _performFiltering();
    }
    notifyListeners();
    _saveNoteToDatabase(note);
  }

  Future<void> updateNote(Note updatedNote) async {
    final index = _findNoteIndex(updatedNote.id);
    if (index != -1) {
      final note = _notes[index];
      note.title = updatedNote.title;
      note.content = updatedNote.content;
      note.lastModified = updatedNote.lastModified;
      note.noteColor = updatedNote.noteColor;
      note.isStarred = updatedNote.isStarred; // Make sure this is included
      note.isSynced = false;

      // Update starred notes after the main note is updated
      updateStarredNotes();

      if (_searchQuery.isNotEmpty || _colorFilter.isNotEmpty) {
        _performFiltering();
      }

      notifyListeners();
    }
    _updateNoteInDatabase(updatedNote);
  }

  Future<void> deleteNote(int noteId) async {
    final index = _findNoteIndex(noteId);

    if (index != -1) {
      _notes.removeAt(index);
      updateStarredNotes();
      if (_searchQuery.isNotEmpty || _colorFilter.isNotEmpty) {
        _performFiltering();
      }
      notifyListeners();
    }
    _deleteNoteFromDatabase(noteId);
  }

  Future<void> deleteNoteByObject(Note note) async {
    await deleteNote(note.id);
  }

  Future<void> _saveNoteToDatabase(Note note, {BuildContext? context}) async {
    try {
      await _isarService.addNote(note);
    } catch (e) {
      if (context != null) {
        ErrorMessage.show(context, 'Error saving note: $e');
      }
    }
  }

  Future<void> _updateNoteInDatabase(Note note, {BuildContext? context}) async {
    try {
      await _isarService.updateNote(note);
    } catch (e) {
      if (context != null) {
        ErrorMessage.show(context, 'Error updating note: $e');
      }
    }
  }

  Future<void> _deleteNoteFromDatabase(int id, {BuildContext? context}) async {
    try {
      await _isarService.deleteNote(id);
    } catch (e) {
      if (context != null) {
        ErrorMessage.show(context, 'Error deleting note: $e');
      }
    }
  }

  Future<List<Note>> getNotes() async {
    if (_isDataLoaded) {
      return _notes;
    } else {
      await loadNotes();
      return _notes;
    }
  }

  Note? getNoteById(int noteId) {
    final index = _findNoteIndex(noteId);
    return index != -1 ? _notes[index] : null;
  }

  void searchNotes(String query) {
    _searchQuery = query;
    _performFiltering();
    notifyListeners();
  }

  void filterByColor(String color) {
    _colorFilter = color;
    _performFiltering();
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    if (_colorFilter.isEmpty) {
      _filteredNotes = [];
    } else {
      _performFiltering();
    }
    notifyListeners();
  }

  void clearColorFilter() {
    _colorFilter = '';
    if (_searchQuery.isEmpty) {
      _filteredNotes = [];
    } else {
      _performFiltering();
    }
    notifyListeners();
  }

  void clearAllFilters() {
    _searchQuery = '';
    _colorFilter = '';
    _filteredNotes = [];
    notifyListeners();
  }

  void _performFiltering() {
    List<Note> results = _notes;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final lowerQuery = _searchQuery.toLowerCase();
      results = results.where((note) {
        return note.title.toLowerCase().contains(lowerQuery) ||
            (note.content?.toLowerCase().contains(lowerQuery) ?? false);
      }).toList();
    }

    // Apply color filter
    if (_colorFilter.isNotEmpty) {
      results = results.where((note) {
        return note.noteColor.toLowerCase() == _colorFilter.toLowerCase();
      }).toList();
    }

    _filteredNotes = results;
  }

  void sortNotesByDate({bool ascending = false}) {
    _notes.sort((a, b) => ascending
        ? a.created.compareTo(b.created)
        : b.created.compareTo(a.created));
    if (_filteredNotes.isNotEmpty) {
      _filteredNotes.sort((a, b) => ascending
          ? a.created.compareTo(b.created)
          : b.created.compareTo(a.created));
    }
    updateStarredNotes();
    notifyListeners();
  }

  void sortNotesByTitle({bool ascending = true}) {
    _notes.sort((a, b) =>
    ascending ? a.title.compareTo(b.title) : b.title.compareTo(a.title));
    if (_filteredNotes.isNotEmpty) {
      _filteredNotes.sort((a, b) =>
      ascending ? a.title.compareTo(b.title) : b.title.compareTo(a.title));
    }
    updateStarredNotes();
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _colorFilter = '';
    _filteredNotes = [];
    notifyListeners();
  }

  void updateStarredNotes() {
    _starredNotes = _notes.where((note) => note.isStarred).toList();
    notifyListeners();
  }

  Future<void> refreshNotes({BuildContext? context}) async {
    await loadNotesFromDatabase(context: context);
  }

  Future<void> forceReloadFromDatabase({BuildContext? context}) async {
    await loadNotesFromDatabase(context: context);
  }

  Future<void> syncNotes({BuildContext? context}) async {
    _isSyncing = true;
    notifyListeners();

    try {
      if (!await _firestoreService.canSync()) return;
      final List<Note> localNotes =
      _isDataLoaded ? _notes : await _isarService.getNotes();
      final localNoteIds = localNotes.map((note) => note.id.toString()).toSet();
      final cloudNotes = await _firestoreService.getCloudNotes();
      final cloudNoteIds = cloudNotes.map((note) => note.id.toString()).toSet();
      await _firestoreService.uploadNotes(localNotes);
      await _isarService.markNotesAsSynced(localNotes);
      for (var note in _notes) {
        note.isSynced = true;
      }
      final notesToDelete = cloudNoteIds.difference(localNoteIds);
      await _firestoreService.deleteCloudNotes(notesToDelete);
      notifyListeners();
    } catch (e) {
      if (context != null) {
        ErrorMessage.show(context, 'Unexpected sync error: $e');
      }
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  Future<void> pullMissingCloudNotes({BuildContext? context}) async {
    try {
      if (!await _firestoreService.canSync()) return;
      final localNotes = _isDataLoaded ? _notes : await _isarService.getNotes();
      final localIds = localNotes.map((note) => note.id.toString()).toSet();
      final cloudNotes = await _firestoreService.getCloudNotes();
      final newNotes = cloudNotes
          .where((note) => !localIds.contains(note.id.toString()))
          .toList();
      if (newNotes.isNotEmpty) {
        _notes.addAll(newNotes);
        updateStarredNotes();
        if (_searchQuery.isNotEmpty || _colorFilter.isNotEmpty) {
          _performFiltering();
        }
        notifyListeners();
        await _isarService.saveCloudNotes(newNotes);
      }
    } catch (e) {
      if (context != null) {
        ErrorMessage.show(context, 'Error pulling missing notes: $e');
      }
    }
  }

  Future<void> ensureDataLoaded({BuildContext? context}) async {
    if (!_isDataLoaded) {
      await loadNotesFromDatabase(context: context);
      notifyListeners();
    }
  }

  // Get unique colors from notes for filter display
  List<String> getUniqueColors() {
    final colors = _notes.map((note) => note.noteColor).toSet().toList();
    colors.sort();
    return colors;
  }

  void clearAllData() {
    _notes.clear();
    _filteredNotes.clear();
    _starredNotes.clear();
    _searchQuery = '';
    _colorFilter = '';
    _isDataLoaded = false;
    _isSyncing = false;
    notifyListeners();
    debugPrint("All data cleared - Repository reset");
  }

  Future<void> forceLoadNotes({BuildContext? context}) async {
    debugPrint("Force loading notes...");
    await loadNotesFromDatabase(context: context);
  }
}