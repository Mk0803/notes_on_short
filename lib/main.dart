import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:notes_on_short/Pages/auth_page.dart';
import 'package:notes_on_short/models/notes_repository.dart';
import 'package:notes_on_short/themes/theme_provider.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:isar/isar.dart';
import 'models/note.dart'; // Import the Note model
import 'package:path_provider/path_provider.dart';


late final Isar isar;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotesRepository.initialize();

  // Firebase initialization
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Isar initialization
  

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: Provider.of<ThemeProvider>(context).themeData,
      home: AuthPage(), // Initial page
    );
  }
}
