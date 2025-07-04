import 'package:flutter/cupertino.dart';
import '../models/note.dart';
import '../services/notes_repository.dart';

class HomeController extends ChangeNotifier {
  final NotesRepository notesRepository;

  HomeController({required this.notesRepository});

  bool _isLoading = false;
  int _selectedIndex = 0;
  bool _isSearchActive = false;
  bool _isSyncing = false;
  bool _isSelectionMode = false;
  Set<int> _selectedNoteIds = <int>{};

  bool get isLoading => _isLoading;
  bool get isSyncing => notesRepository.isSyncing;
  bool get isSelectionMode => _isSelectionMode;
  Set<int> get selectedNoteIds => _selectedNoteIds;
  int get selectedCount => _selectedNoteIds.length;
  List<Note> get notes => notesRepository.notes;
  List<Note> get allNotes => notesRepository.allNotes;
  List<Note> get starredNotes => notesRepository.starredNotes;
  int get selectedIndex => _selectedIndex;
  bool get isSearchActive => _isSearchActive;
  String get searchQuery => notesRepository.searchQuery;

  Future<void> loadNotes() async {
    _isLoading = true;
    notifyListeners();
    try {
      await notesRepository.loadNotes();
    } catch (e) {
      debugPrint('Error loading notes: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  void reset() {
    _isLoading = true;
    _selectedIndex = 0;
    _isSearchActive = false;
    _isSelectionMode = false;
    _selectedNoteIds.clear();
    notifyListeners();
    debugPrint("HomeController reset");
  }

  Future<void> syncNotes() async {
    try {
      await notesRepository.syncNotes();
    } catch (e) {
      debugPrint('Error syncing notes: $e');
    }
  }

  void toggleSearch() {
    _isSearchActive = !_isSearchActive;
    if (!_isSearchActive) {
      notesRepository.clearSearch();
    }
    notifyListeners();
  }

  void searchNotes(String query) {
    notesRepository.searchNotes(query);
  }

  void clearSearch() {
    notesRepository.clearSearch();
  }

  void setSelectedIndex(int index) {
    if (_selectedIndex == index && !_isSearchActive) return;
    _selectedIndex = index;
    if (_selectedIndex == 2 && _isSearchActive) {
      _isSearchActive = false;
      notesRepository.clearSearch();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isSyncing) {
        notifyListeners();
      }
    });
  }

  void updateSelectedIndex(int index) {
    if (_selectedIndex != index) {
      _isSyncing = true;
      _selectedIndex = index;
      if (_selectedIndex == 2 && _isSearchActive) {
        _isSearchActive = false;
        notesRepository.clearSearch();
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _isSyncing = false;
        notifyListeners();
      });
    }
  }

  void _setSelectedIndexSilent(int index) {
    _selectedIndex = index;
    if (_selectedIndex == 2 && _isSearchActive) {
      _isSearchActive = false;
      notesRepository.clearSearch();
    }
  }

  Future<void> refreshNotes() async {
    await notesRepository.refreshNotes();
  }

  void sortNotesByDate({bool ascending = false}) {
    notesRepository.sortNotesByDate(ascending: ascending);
  }

  void sortNotesByTitle({bool ascending = true}) {
    notesRepository.sortNotesByTitle(ascending: ascending);
  }

  void clearFilters() {
    notesRepository.clearFilters();
  }

  void enterSelectionMode(int noteId) {
    _isSelectionMode = true;
    _selectedNoteIds.add(noteId);
    notifyListeners();
  }

  void exitSelectionMode() {
    _isSelectionMode = false;
    _selectedNoteIds.clear();
    notifyListeners();
  }

  void toggleNoteSelection(int noteId) {
    if (_selectedNoteIds.contains(noteId)) {
      _selectedNoteIds.remove(noteId);
    } else {
      _selectedNoteIds.add(noteId);
    }

    if (_selectedNoteIds.isEmpty) {
      _isSelectionMode = false;
    }

    notifyListeners();
  }

  void selectAllNotes(List<Note> notes) {
    _selectedNoteIds.addAll(notes.map((note) => note.id));
    notifyListeners();
  }

  bool isNoteSelected(int noteId) {
    return _selectedNoteIds.contains(noteId);
  }

  bool areAllNotesSelected() {
    return _selectedNoteIds.length == notes.length;
  }

  bool areAllSelectedStarred() {
    return _selectedNoteIds.every((noteId) {
      final note = notesRepository.getNoteById(noteId);
      return note != null && note.isStarred;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
}
