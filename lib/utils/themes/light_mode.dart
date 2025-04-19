import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  useMaterial3: true,
  fontFamily: 'Poppins',
  brightness: Brightness.light,
  scaffoldBackgroundColor: Colors.white,
  colorScheme: ColorScheme.light(
    surface: Color(0xffFFFFFF),
    primary: Color(0xffA2D2FF),
    secondary: Color(0xffBDE0FE),
    tertiary: Color(0xffFFC8DD),
    inversePrimary: Color(0xffCDB4DB)
  )
);