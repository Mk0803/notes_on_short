import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes_on_short/Utils/button.dart';
import 'package:notes_on_short/Utils/google_sign_in_button.dart';
import 'package:notes_on_short/Utils/text_field.dart';
import 'package:notes_on_short/auth/auth_service.dart';

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

  void login(BuildContext context) async {
    if (userEmailController.text.isEmpty ||
        userPasswordController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            title: Text("Missing Information"),
            content: Text("Please enter both email and password."),
          );
        },
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      await authService.signInWithEmailPassword(
        userEmailController.text.trim(),
        userPasswordController.text.trim(),
      );
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      if (e.code == 'user-not-found') {
        wrongEmailMessage();
      } else if (e.code == 'wrong-password') {
        wrongPasswordMessage();
      }
    } catch (e) {
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Error"),
            content: Text(e.toString()),
          );
        },
      );
    }
  }

  void signInWithGoogle(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      final userCredential = await authService.signInWithGoogle(context);
      Navigator.pop(context); // Close CircularProgressIndicator
      if (userCredential != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Google Sign-In Successful")),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Google Sign-In Failed: $e")),
      );
    }
  }

  void wrongEmailMessage() {
    showDialog(
      context: context,
      builder: (context) {
        return const AlertDialog(
          title: Text("Wrong Email"),
        );
      },
    );
  }

  void wrongPasswordMessage() {
    showDialog(
      context: context,
      builder: (context) {
        return const AlertDialog(
          title: Text("Wrong Password"),
        );
      },
    );
  }

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
                  Text(
                    "Notes On Short",
                    style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    "Login",
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
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: const [Text("Forgot Password")],
                    ),
                  ),
                  Button(text: "Login", onTap: () => login(context)),
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
                  GoogleSignInButton(onTap: () => signInWithGoogle(context)),
                  
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
                                color: Colors.blue, fontWeight: FontWeight.bold),
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
