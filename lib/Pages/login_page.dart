import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes_on_short/Utils/button.dart';
import 'package:notes_on_short/Utils/text_field.dart';
import 'package:notes_on_short/auth/auth_service.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;

  const LoginPage({super.key,
  required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController userEmailController = TextEditingController();

  final TextEditingController userPasswordController = TextEditingController();

  final authService = AuthService();

  void login(BuildContext context) async {
    // Check for empty email or password fields
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
      return; // Exit the function
    }

    // Show CircularProgressIndicator
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      // Attempt sign-in
      await authService.signInWithEmailPassword(
        userEmailController.text.trim(),
        userPasswordController.text.trim(),
      );
      Navigator.pop(context); // Close CircularProgressIndicator
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context); // Close CircularProgressIndicator
      // Handle specific Firebase exceptions
      if (e.code == 'user-not-found') {
        wrongEmailMessage();
      } else if (e.code == 'wrong-password') {
        wrongPasswordMessage();
      }
    } catch (e) {
      Navigator.pop(context); // Close CircularProgressIndicator
      // Handle any other errors
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

  void wrongEmailMessage() {
    showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            title: Text("Wrong Email"),
          );
        });
  }

  void wrongPasswordMessage() {
    showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            title: Text("Wrong Password"),
          );
        });
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
                  SizedBox(
                    height: 30,
                  ),
                  Text(
                    "Login",
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  MyTextField(
                      controller: userEmailController,
                      hintText: "Email",
                      isPassword: false),
                  SizedBox(
                    height: 10,
                  ),
                  MyTextField(
                    controller: userPasswordController,
                    hintText: "Password",
                    isPassword: true,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [Text("Forgot Password")],
                    ),
                  ),
                  Button(text: "Login", onTap: () => login(context)),
                  SizedBox(
                    height: 5,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            child: Divider(
                          thickness: 0.8,
                        )),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Text("Or Continue with"),
                        ),
                        Expanded(
                            child: Divider(
                          thickness: 0.8,
                        ))
                      ],
                    ),
                  ),
                  Button(text: "Google", onTap: () {}),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text("Not a Member? "),
                        GestureDetector(
                          onTap: widget.onTap,
                          child: Text(
                            "Register Now",
                            style: TextStyle(
                                color: Colors.blue, fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
