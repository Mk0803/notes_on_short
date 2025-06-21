import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../models/note.dart';
import '../screens/note_editing_screen.dart';
class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback? onUpdate;
  final bool isSelectionMode;
  final bool isSelected;
  final Function(int)? onLongPress;
  final Function(int)? onSelectionToggle;

  final double maxContentHeight = 250.0;

  const NoteCard({
    super.key,
    required this.note,
    this.onUpdate,
    this.isSelectionMode = false,
    this.isSelected = false,
    this.onLongPress,
    this.onSelectionToggle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDarkMode = HelperFunctions.isDarkMode(context);
    final noteColor = HelperFunctions.getColorFromName(note.noteColor, isDarkMode);

    return GestureDetector(
      onTap: () async {
        if (isSelectionMode) {
          // In selection mode, toggle selection
          onSelectionToggle?.call(note.id);
        } else {
          // Normal mode, navigate to edit
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NoteEditingScreen(note: note),
            ),
          );
          if (result == true && onUpdate != null) {
            onUpdate!();
          }
        }
      },
      onLongPress: () {
        if (!isSelectionMode) {
          // Enter selection mode on long press
          onLongPress?.call(note.id);
          // Provide haptic feedback
          HapticFeedback.lightImpact();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: colorScheme.primary, width: 2)
              : null,
        ),
        child: Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: noteColor,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      note.title,
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 8),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: maxContentHeight,
                      ),
                      child: Text(
                        note.content ?? '',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: HelperFunctions.isDarkMode(context)
                              ? Colors.grey[500]
                              : const Color(0xff202124),
                          fontWeight: FontWeight.w300,
                        ),
                        overflow: TextOverflow.fade,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(width: 4),
                        Text(
                          HelperFunctions.formatDate(note.created),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: HelperFunctions.isDarkMode(context)
                                ? Colors.grey[400]
                                : const Color(0xff202124),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Selection indicator
              if (isSelectionMode)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? colorScheme.primary
                          : Colors.grey.withOpacity(0.3),
                      border: Border.all(
                        color: isSelected
                            ? colorScheme.primary
                            : Colors.grey,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? Icon(
                      Icons.check,
                      size: 16,
                      color: colorScheme.onPrimary,
                    )
                        : null,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}