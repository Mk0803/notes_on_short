import 'package:flutter/material.dart';
import 'package:notes_on_short/common/widgets/button.dart';
import 'package:notes_on_short/common/widgets/google_sign_in_button.dart';
import 'package:notes_on_short/common/widgets/text_field.dart';
import 'package:notes_on_short/features/authentication/controllers/auth_service.dart';

import '../controllers/email_auth.dart';
import '../controllers/google_auth.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;

  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController userEmailController = TextEditingController();
  final TextEditingController userPasswordController = TextEditingController();
  final TextEditingController userConfirmPasswordController =
      TextEditingController();

  final authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
      ),
      bottomNavigationBar: BottomAppBar(
        color: colorScheme.surface,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipOval(
                    child: Image.asset(
                      'assets/icons/icon.png',
                      width: 150,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Text(
                    "Notes",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    "Create an Account",
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  MyTextField(
                    controller: userEmailController,
                    hintText: "Email",
                    isPassword: false,
                  ),
                  const SizedBox(height: 10),
                  MyTextField(
                    controller: userPasswordController,
                    hintText: "Password",
                    isPassword: true,
                  ),
                  const SizedBox(height: 10),
                  MyTextField(
                    controller: userConfirmPasswordController,
                    hintText: "Confirm Password",
                    isPassword: true,
                  ),
                  const SizedBox(height: 20),
                  Button(
                      text: "Register",
                      onTap: () => EmailAuth().register(
                          context,
                          userEmailController,
                          userPasswordController,
                          userConfirmPasswordController)),
                  const SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(child: Divider(thickness: 0.8)),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          child: Text("Or Continue with"),
                        ),
                        const Expanded(child: Divider(thickness: 0.8)),
                      ],
                    ),
                  ),
                  GoogleSignInButton(
                      onTap: () => GoogleAuth().signInWithGoogle(context)),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text("Already a Member? "),
                        GestureDetector(
                          onTap: widget.onTap,
                          child: const Text(
                            "Login",
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
