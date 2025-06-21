import 'package:flutter/material.dart';
import 'package:notes_on_short/common/widgets/confirmation_dialog.dart';
import 'package:notes_on_short/common/widgets/error_message.dart';
import 'package:notes_on_short/features/notes/models/note.dart';
import 'package:notes_on_short/features/notes/services/notes_repository.dart';
import 'package:notes_on_short/features/notes/widgets/color_picker.dart';
import 'package:notes_on_short/utils/helpers/helper_functions.dart';
import 'package:provider/provider.dart';

class NoteEditingScreen extends StatefulWidget {
  final Note note;

  const NoteEditingScreen({super.key, required this.note});

  @override
  State<NoteEditingScreen> createState() => _NoteEditingScreenState();
}

class _NoteEditingScreenState extends State<NoteEditingScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late NotesRepository _notesRepository;
  bool _isSaving = false;
  late String selectedColorName;
  late String _originalTitle;
  late String _originalContent;
  late String _originalColorName;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final selectedColor =
        HelperFunctions.getColorFromName(selectedColorName, isDarkMode);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          await _onWillPop();
        }
      },
      child: Scaffold(
        backgroundColor: selectedColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Edit Note'),
          actions: [
            IconButton(
              icon: widget.note.isStarred
                  ? const Icon(Icons.star)
                  : const Icon(Icons.star_outline),
              onPressed: _isSaving
                  ? null
                  : () {
                      setState(() {
                        widget.note.isStarred = !widget.note.isStarred;
                        widget.note.lastModified = DateTime.now();
                        widget.note.isSynced = false;
                      });
                      _notesRepository.updateNote(widget.note);
                    },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _isSaving ? null : _deleteNote,
              tooltip: 'Delete Note',
            ),
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
                    ),
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
              child: ColorPicker(
                onColorSelected: (colorName) {
                  setState(() {
                    selectedColorName = colorName;
                  });
                },
                selectedColorName: selectedColorName,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content ?? '');
    selectedColorName = widget.note.noteColor;
    _originalTitle = widget.note.title;
    _originalContent = widget.note.content ?? '';
    _originalColorName = widget.note.noteColor;
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
    return _titleController.text.trim() != _originalTitle.trim() ||
        _contentController.text.trim() != _originalContent.trim() ||
        selectedColorName != _originalColorName;
  }

  Future<void> _onWillPop() async {
    if (_hasUnsavedChanges()) {
      setState(() {
        _isSaving = true;
      });
      try {
        await _saveNote();
        if (mounted) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isSaving = false;
          });
          ErrorMessage.show(context, "Note saved in background. Error: $e");
          Navigator.of(context).pop();
        }
      }
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _saveNote() async {
    String title = _titleController.text.trim();
    if (title.isEmpty) {
      if (_contentController.text.trim().isNotEmpty) {
        title = _contentController.text.trim().split('\n').first;
        if (title.length > 50) {
          title = '${title.substring(0, 50)}...';
        }
      } else {
        title = 'Untitled Note';
      }
    }

    widget.note.title = title;
    widget.note.content = _contentController.text.trim();
    widget.note.isSynced = false;
    widget.note.lastModified = DateTime.now();
    widget.note.noteColor = selectedColorName;

    await _notesRepository.updateNote(widget.note);

    _originalTitle = widget.note.title;
    _originalContent = widget.note.content ?? '';
    _originalColorName = selectedColorName;
  }

  Future<void> _deleteNote() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return const ConfirmationDialog(
          title: "Delete Note?",
          message: "Are you sure you want to delete this note?",
        );
      },
    );
    if (confirm != true) return;
    if (mounted) {
      setState(() {
        _isSaving = true;
      });
    }

    try {
      await _notesRepository.deleteNote(widget.note.id);
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ErrorMessage.show(context, "Note deleted from UI. Background error: $e");
        Navigator.pop(context);
      }
    }
  }
}
