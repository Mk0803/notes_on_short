import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:notes_on_short/features/authentication/controllers/auth_page.dart';
import 'package:notes_on_short/features/notes/controllers/notes_repository.dart';
import 'package:notes_on_short/utils/themes/theme_provider.dart';
import 'package:notes_on_short/utils/logger/logger.dart';
import 'package:provider/provider.dart';
import 'data/services/firebase_options.dart';
import 'package:isar/isar.dart';



late final Isar isar;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotesRepository.initialize();

  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  AppLogger.i("Initialized Apk");

  
  

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
      home: AuthPage(), 
    );
  }
}
