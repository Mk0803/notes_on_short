import 'package:flutter/material.dart';
import 'package:notes_on_short/features/notes/models/note.dart';
import 'package:notes_on_short/features/notes/services/notes_repository.dart';
import 'package:notes_on_short/features/notes/widgets/color_picker.dart';
import 'package:notes_on_short/utils/helpers/helper_functions.dart';
import 'package:provider/provider.dart';

class CreateNoteScreen extends StatefulWidget {
  const CreateNoteScreen({super.key});

  @override
  State<CreateNoteScreen> createState() => _CreateNoteScreenState();
}

class _CreateNoteScreenState extends State<CreateNoteScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  late NotesRepository _notesRepository;
  bool _isSaving = false;
  String selectedColorName = 'default';

  Color get _selectedColor {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return HelperFunctions.getColorFromName(selectedColorName, isDarkMode);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _notesRepository = Provider.of<NotesRepository>(context, listen: false);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  bool _hasUnsavedChanges() {
    return _titleController.text.trim().isNotEmpty ||
        _contentController.text.trim().isNotEmpty;
  }

  Future<void> _onWillPop() async {
    if (_hasUnsavedChanges()) {
      setState(() => _isSaving = true);
      try {
        await _createNote();
        if (mounted) Navigator.of(context).pop();
      } catch (e) {
        if (mounted) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Note saved in background. Error: $e')),
          );
          Navigator.of(context).pop();
        }
      }
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _createNote() async {
    String title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty && content.isNotEmpty) {
      title = content.split('\n').first;
      if (title.length > 50) {
        title = '${title.substring(0, 50)}...';
      }
    } else if (title.isEmpty) {
      title = 'Note ${DateTime.now().toString().substring(0, 16)}';
    }

    final newNote = Note()
      ..title = title
      ..content = content
      ..isSynced = false
      ..lastModified = DateTime.now()
      ..created = DateTime.now()
      ..noteColor = selectedColorName;

    await _notesRepository.addNote(newNote);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          await _onWillPop();
        }
      },
      child: Scaffold(
        backgroundColor: _selectedColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text('Create New Note'),
          actions: [
            if (_isSaving)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _titleController,
                      style: Theme.of(context).textTheme.headlineSmall,
                      decoration: const InputDecoration(
                        hintText: 'Title',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                      ),
                      autofocus: true,
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: TextField(
                        controller: _contentController,
                        style: Theme.of(context).textTheme.bodyMedium,
                        decoration: const InputDecoration(
                          hintText: 'Note content',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                        ),
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding:
              const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
              child: RepaintBoundary(
                child: ColorPicker(
                  onColorSelected: (colorName) {
                    setState(() {
                      selectedColorName = colorName;
                    });
                  },
                  selectedColorName: selectedColorName,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
