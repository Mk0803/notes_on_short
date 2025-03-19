import 'package:flutter/material.dart';

ThemeData darkMode = ThemeData(
  colorScheme: ColorScheme.dark(
    surface: Color(0xff2A2A2A), // A dark surface color for the background
    primary: Color(0xff2D6A6A), // Darker shade of green complementing the light mode primary
    secondary: Color(0xffA95E3B), // Rich brownish-orange for contrast
    tertiary: Color(0xff7B444B), // Muted deep red for accents
    inversePrimary: Color(0xff4C3C74), // A darker purple to match the light mode inversePrimary
  ),
);
