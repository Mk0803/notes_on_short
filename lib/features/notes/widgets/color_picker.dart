import 'package:flutter/material.dart';
import 'package:notes_on_short/utils/helpers/helper_functions.dart';
import '../../../utils/constants/colors.dart';

class ColorPicker extends StatelessWidget {
  final String? selectedColorName;
  final Function(String) onColorSelected;
  final double circleSize;

  const ColorPicker({
    super.key,
    this.selectedColorName,
    required this.onColorSelected,
    this.circleSize = 36.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = HelperFunctions.isDarkMode(context);

    final colorData = isDark
        ? [
            {'name': 'default', 'color': NotesColorsDark.notesDefault},
            {'name': 'coral', 'color': NotesColorsDark.notesCoral},
            {'name': 'peach', 'color': NotesColorsDark.notesPeach},
            {'name': 'sand', 'color': NotesColorsDark.notesSand},
            {'name': 'mint', 'color': NotesColorsDark.notesMint},
            {'name': 'sage', 'color': NotesColorsDark.notesSage},
            {'name': 'fog', 'color': NotesColorsDark.notesFog},
            {'name': 'storm', 'color': NotesColorsDark.notesStorm},
            {'name': 'dusk', 'color': NotesColorsDark.notesDusk},
            {'name': 'blossom', 'color': NotesColorsDark.notesBlossom},
            {'name': 'clay', 'color': NotesColorsDark.notesClay},
            {'name': 'chalk', 'color': NotesColorsDark.notesChalk},
          ]
        : [
            {'name': 'default', 'color': NotesColorsLight.notesDefault},
            {'name': 'white', 'color': NotesColorsLight.notesWhite},
            {'name': 'coral', 'color': NotesColorsLight.notesCoral},
            {'name': 'peach', 'color': NotesColorsLight.notesPeach},
            {'name': 'sand', 'color': NotesColorsLight.notesSand},
            {'name': 'mint', 'color': NotesColorsLight.notesMint},
            {'name': 'sage', 'color': NotesColorsLight.notesSage},
            {'name': 'fog', 'color': NotesColorsLight.notesFog},
            {'name': 'storm', 'color': NotesColorsLight.notesStorm},
            {'name': 'dusk', 'color': NotesColorsLight.notesDusk},
            {'name': 'blossom', 'color': NotesColorsLight.notesBlossom},
            {'name': 'clay', 'color': NotesColorsLight.notesClay},
            {'name': 'chalk', 'color': NotesColorsLight.notesChalk},
          ];

    return Container(
      clipBehavior: Clip.hardEdge,
      height: circleSize + 24,
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      decoration: BoxDecoration(
        color: _getBackgroundColor(context, colorData),
        borderRadius: BorderRadius.circular(28),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: colorData.length,
        itemBuilder: (context, index) {
          final colorName = colorData[index]['name'] as String;
          final color = colorData[index]['color'] as Color?;
          final isSelected =
              selectedColorName?.toLowerCase() == colorName.toLowerCase();
          final isDefault = colorName == 'default';

          return Padding(
            padding: EdgeInsets.only(
              right: index < colorData.length - 1 ? 12.0 : 0,
            ),
            child: GestureDetector(
              onTap: () => onColorSelected(colorName),
              child: Container(
                width: circleSize,
                height: circleSize,
                decoration: BoxDecoration(
                  color: isDefault
                      ? (isDark ? Colors.grey.shade700 : Colors.grey.shade200)
                      : color,
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2.5,
                        )
                      : Border.all(
                          color: _getBorderColor(context, color, isDefault),
                          width: 1.0,
                        ),
                ),
                child: isDefault
                    ? Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            Icons.format_color_reset,
                            color: isDark
                                ? Colors.grey.shade300
                                : Colors.grey.shade600,
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check,
                              color: HelperFunctions.isDarkMode(context)
                                  ? Colors.white
                                  : Colors.black,
                              size: circleSize * 0.3,
                            ),
                        ],
                      )
                    : isSelected
                        ? Icon(
                            Icons.check,
                            color: _getContrastColor(color!),
                            size: circleSize * 0.4,
                          )
                        : null,
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getBackgroundColor(
      BuildContext context, List<Map<String, dynamic>> colorData) {
    final isDark = HelperFunctions.isDarkMode(context);

    Color? selectedColor;
    for (final data in colorData) {
      if (selectedColorName?.toLowerCase() ==
          (data['name'] as String).toLowerCase()) {
        selectedColor = data['color'] as Color?;
        break;
      }
    }

    if (selectedColor == null ||
        selectedColorName?.toLowerCase() == 'default') {
      return isDark
          ? Colors.grey.shade800.withOpacity(0.5)
          : const Color(0xffc8c8c8);
    }

    if (isDark) {
      final hsl = HSLColor.fromColor(selectedColor);
      return hsl
          .withLightness((hsl.lightness + 0.15).clamp(0.0, 1.0))
          .toColor()
          .withOpacity(0.3);
    } else {
      final hsl = HSLColor.fromColor(selectedColor);
      return hsl
          .withLightness((hsl.lightness - 0.15).clamp(0.0, 1.0))
          .toColor()
          .withOpacity(0.4);
    }
  }

  Color _getBorderColor(BuildContext context, Color? color, bool isDefault) {
    final isDark = HelperFunctions.isDarkMode(context);

    if (isDefault) {
      return isDark ? Colors.grey.shade600 : Colors.grey.shade400;
    }
    if (color == null) return Colors.grey.withOpacity(0.3);
    final hsl = HSLColor.fromColor(color);
    if (isDark) {
      return hsl.withLightness((hsl.lightness + 0.2).clamp(0.0, 1.0)).toColor();
    } else {
      return hsl.withLightness((hsl.lightness - 0.2).clamp(0.0, 1.0)).toColor();
    }
  }

  Color _getContrastColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
