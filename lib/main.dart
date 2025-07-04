import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:notes_on_short/features/authentication/screens/auth_page.dart';
import 'package:notes_on_short/features/notes/services/notes_repository.dart';
import 'package:notes_on_short/utils/themes/theme_provider.dart';
import 'package:provider/provider.dart';
import 'Utils/themes/dark_mode.dart';
import 'Utils/themes/light_mode.dart';
import 'data/services/firebase_options.dart';
import 'features/notes/controllers/home_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final notesRepository = NotesRepository();
  await notesRepository.initialize();
  await notesRepository.pullMissingCloudNotes();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider.value(value: notesRepository),
        ChangeNotifierProvider<HomeController>(
          create: (context) => HomeController(
            notesRepository:
                Provider.of<NotesRepository>(context, listen: false),
          ),
        ),
      ],
      child: const NotesApp(),
    ),
  );
}

class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightMode,
      darkTheme: darkMode,
      themeMode: themeProvider.themeMode,
      home: const AuthPage(),
    );
  }
}
