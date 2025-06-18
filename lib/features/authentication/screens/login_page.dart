import 'package:flutter/material.dart';
import 'package:notes_on_short/common/widgets/button.dart';
import 'package:notes_on_short/common/widgets/google_sign_in_button.dart';
import 'package:notes_on_short/common/widgets/text_field.dart';
import 'package:notes_on_short/features/authentication/controllers/auth_service.dart';
import 'package:notes_on_short/features/authentication/controllers/email_auth.dart';
import 'package:notes_on_short/features/authentication/controllers/google_auth.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;

  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController userEmailController = TextEditingController();
  final TextEditingController userPasswordController = TextEditingController();

  final AuthService authService = AuthService();

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
                  const SizedBox(height: 20),
                  Text(
                    "Notes",
                    style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary),
                  ),
                  const SizedBox(height: 30),
                  const Text("Login", style: TextStyle(fontSize: 25)),
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
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: const [Text("Forgot Password")],
                    ),
                  ),
                  Button(
                      text: "Login",
                      onTap: () => EmailAuth().login(context,
                          userEmailController, userPasswordController)),
                  const SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Expanded(
                          child: Divider(thickness: 0.8),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          child: Text("Or Continue with"),
                        ),
                        Expanded(
                          child: Divider(thickness: 0.8),
                        ),
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
                        const Text("Not a Member? "),
                        GestureDetector(
                          onTap: widget.onTap,
                          child: const Text(
                            "Register Now",
                            style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold),
                          ),
                        )
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
