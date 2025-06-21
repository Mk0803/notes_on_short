import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes_on_short/common/widgets/error_message.dart';
import 'package:notes_on_short/features/notes/services/isar_service.dart';
import 'package:notes_on_short/features/authentication/screens/auth_page.dart';

import '../../../common/widgets/button.dart';
import '../../authentication/controllers/auth_service.dart';

class SettingsPage extends StatelessWidget {
  SettingsPage({super.key});

  final fireBaseAuth = AuthService().instance;

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
                  await FirebaseAuth.instance.signOut();
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
