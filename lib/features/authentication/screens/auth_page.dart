import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:notes_on_short/features/notes/services/notes_repository.dart';
import 'package:notes_on_short/features/notes/screens/home/home_page.dart';
import 'package:notes_on_short/features/authentication/controllers/login_or_register_page.dart';

import '../controllers/auth_service.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    final fireBaseAuth = AuthService().instance;
    return StreamBuilder<User?>(
        stream: fireBaseAuth.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final notesRepository =
                Provider.of<NotesRepository>(context, listen: false);
            return ChangeNotifierProvider.value(
              value: notesRepository,
              child: const HomePage(),
            );
          } else {
            return const LoginOrRegisterPage();
          }
        });
  }
}
