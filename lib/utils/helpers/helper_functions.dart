import 'package:flutter/material.dart';

import '../constants/colors.dart';

class HelperFunctions{
  static String formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0 && date.day == now.day) {
      // Today - 12-hour format
      final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
      final minute = date.minute.toString().padLeft(2, '0');
      final period = date.hour >= 12 ? 'PM' : 'AM';
      return '$hour:$minute $period';
    } else if (difference.inDays <= 1 &&
        DateTime(now.year, now.month, now.day - 1) == DateTime(date.year, date.month, date.day)) {
      // Yesterday
      return 'Yesterday';
    } else if (date.year == now.year) {
      // Same year
      final month = _monthName(date.month);
      return '$month ${date.day}';
    } else {
      // Previous years
      final month = _monthName(date.month);
      return '$month ${date.day}, ${date.year}';
    }
  }

  static String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  static void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  static void showAlert(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static Size screenSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static Color getColorFromName(String colorName, bool isDarkMode) {
    switch (colorName.toLowerCase()) {
      case 'default':
        return isDarkMode ? NotesColorsDark.notesDefault : NotesColorsLight.notesDefault;
      case 'coral':
        return isDarkMode ? NotesColorsDark.notesCoral : NotesColorsLight.notesCoral;
      case 'peach':
        return isDarkMode ? NotesColorsDark.notesPeach : NotesColorsLight.notesPeach;
      case 'sand':
        return isDarkMode ? NotesColorsDark.notesSand : NotesColorsLight.notesSand;
      case 'mint':
        return isDarkMode ? NotesColorsDark.notesMint : NotesColorsLight.notesMint;
      case 'sage':
        return isDarkMode ? NotesColorsDark.notesSage : NotesColorsLight.notesSage;
      case 'fog':
        return isDarkMode ? NotesColorsDark.notesFog : NotesColorsLight.notesFog;
      case 'storm':
        return isDarkMode ? NotesColorsDark.notesStorm : NotesColorsLight.notesStorm;
      case 'dusk':
        return isDarkMode ? NotesColorsDark.notesDusk : NotesColorsLight.notesDusk;
      case 'blossom':
        return isDarkMode ? NotesColorsDark.notesBlossom : NotesColorsLight.notesBlossom;
      case 'clay':
        return isDarkMode ? NotesColorsDark.notesClay : NotesColorsLight.notesClay;
      case 'chalk':
        return isDarkMode ? NotesColorsDark.notesChalk : NotesColorsLight.notesChalk;
      default:
        return isDarkMode ? NotesColorsDark.notesChalk : NotesColorsLight.notesWhite;
    }
  }
}