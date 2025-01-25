import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes_on_short/Utils/button.dart';
import 'package:notes_on_short/Utils/google_sign_in_button.dart';
import 'package:notes_on_short/Utils/text_field.dart';
import 'package:notes_on_short/auth/auth_service.dart';

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

  void register(BuildContext context) async {
    // Check for empty email or password fields
    if (userEmailController.text.isEmpty ||
        userPasswordController.text.isEmpty ||
        userConfirmPasswordController.text.isEmpty) {
      showErrorMessage("Please enter email, password, and confirm password.");
      return;
    }

    if (userPasswordController.text != userConfirmPasswordController.text) {
      showErrorMessage("Passwords do not match.");
      return;
    }

    // Show CircularProgressIndicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      await authService.signUpWithEmailPassword(
        userEmailController.text.trim(),
        userPasswordController.text.trim(),
      );

      Navigator.pop(context); // Close CircularProgressIndicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registration Successful!")),
      );
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context); // Close CircularProgressIndicator
      if (e.code == 'email-already-in-use') {
        showErrorMessage("This email is already in use.");
      } else if (e.code == 'invalid-email') {
        showErrorMessage("Invalid email format.");
      } else if (e.code == 'weak-password') {
        showErrorMessage("Password should be at least 6 characters.");
      } else {
        showErrorMessage(e.message ?? "An unknown error occurred.");
      }
    } catch (e) {
      Navigator.pop(context); // Close CircularProgressIndicator
      showErrorMessage("An unexpected error occurred: $e");
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
          const SnackBar(content: Text("Google Sign-In Successful!")),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Close CircularProgressIndicator
      showErrorMessage("Google Sign-In Failed: $e");
    }
  }

  void showErrorMessage(String error) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(error),
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
                  Button(text: "Register", onTap: () => register(context)),
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
                  GoogleSignInButton(onTap: () => signInWithGoogle(context)),
                  
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
