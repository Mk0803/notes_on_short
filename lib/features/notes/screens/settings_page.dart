import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes_on_short/common/widgets/error_message.dart';
import 'package:notes_on_short/features/notes/controllers/home_controller.dart';
import 'package:notes_on_short/features/notes/services/isar_service.dart';
import 'package:notes_on_short/features/authentication/screens/auth_page.dart';
import 'package:provider/provider.dart';

import '../../../common/widgets/button.dart';
import '../../authentication/controllers/auth_service.dart';
import '../services/notes_repository.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final fireBaseAuth = AuthService().instance;

  late NotesRepository notesRepository;
  late HomeController homeController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    notesRepository = Provider.of<NotesRepository>(context, listen: false);
    homeController = Provider.of<HomeController>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Logged In as:"),
            SizedBox(height: 8),
            Text(fireBaseAuth.currentUser?.email ?? ""),
            SizedBox(height: 10),
            Button(
              text: "Sign Out",
              onTap: () async {
                try {
                  await IsarService.clearDatabase();
                  notesRepository.clearAllData();
                  homeController.reset();
                  FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const AuthPage()),
                      (route) => false,
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ErrorMessage.show(context, "Error Signing Out!");
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
