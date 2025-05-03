import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

ThemeData darkMode = ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Color(0xff121212),
    colorScheme: ColorScheme.dark(
        surface: Color(0xff121212),
        primary: Color(0xff4B96D6),
        secondary: Color(0xff5B94C9),
        tertiary: Color(0xffD6739F),
        inversePrimary: Color(0xff9173AB)
    ),
    appBarTheme: AppBarTheme(

        systemOverlayStyle: SystemUiOverlayStyle(
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarIconBrightness: Brightness.light,
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
        ),
    ),
);