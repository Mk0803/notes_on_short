import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../models/note.dart';
import '../../widgets/note_card.dart';

class HomeView extends StatelessWidget {
  final List<Note> notes;
  final bool isLoading;
  final Future<void> Function() onRefresh;
  final ScrollController scrollController;
  final Widget? showEmptyState;
  final bool isSelectionMode;
  final Set<int> selectedNoteIds;
  final Function(int)? onNoteLongPress;
  final Function(int)? onNoteSelectionToggle;

  const HomeView({
    super.key,
    required this.notes,
    required this.isLoading,
    required this.onRefresh,
    required this.scrollController,
    this.showEmptyState,
    this.isSelectionMode = false,
    this.selectedNoteIds = const <int>{},
    this.onNoteLongPress,
    this.onNoteSelectionToggle,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && notes.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (notes.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: Center(
              child: showEmptyState ?? _buildDefaultEmptyState(),
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: MasonryGridView.count(
        controller: scrollController,
        padding: const EdgeInsets.all(8),
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        itemCount: notes.length,
        addAutomaticKeepAlives: false,
        addRepaintBoundaries: false,
        cacheExtent: 100,
        itemBuilder: (context, index) {
          return RepaintBoundary(
            child: NoteCard(
              note: notes[index],
              onUpdate: onRefresh,
              isSelectionMode: isSelectionMode,
              isSelected: selectedNoteIds.contains(notes[index].id),
              onLongPress: onNoteLongPress,
              onSelectionToggle: onNoteSelectionToggle,
            ),
          );
        },
      ),
    );
  }

  Widget _buildDefaultEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.note_alt_outlined,
          size: 64,
          color: Colors.grey[400],
        ),
        const SizedBox(height: 16),
        Text(
          'No notes yet',
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey[400],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tap the + button to create one',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
