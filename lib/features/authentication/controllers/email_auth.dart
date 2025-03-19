import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../common/widgets/error_message.dart';
import 'auth_service.dart';

class EmailAuth {
  final FirebaseAuth _auth = AuthService().instance;

  Future<UserCredential> signInWithEmailPassword(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  Future<UserCredential> signUpWithEmailPassword(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  void register(BuildContext context, TextEditingController emailController, TextEditingController passwordController, TextEditingController confirmPasswordController) async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty || confirmPasswordController.text.isEmpty) {
      ErrorMessage.errorMessage("Please fill in all fields.", context);
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      ErrorMessage.errorMessage("Passwords do not match.", context);
      return;
    }

    _showLoading(context);

    try {
      await signUpWithEmailPassword(emailController.text.trim(), passwordController.text.trim());
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Registration Successful!")));
    } catch (e) {
      Navigator.pop(context);
      ErrorMessage.errorMessage("Error: ${e.toString()}", context);
    }
  }

  void login(BuildContext context, TextEditingController emailController, TextEditingController passwordController) async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ErrorMessage.errorMessage("Please enter email and password.", context);
      return;
    }

    _showLoading(context);

    try {
      await signInWithEmailPassword(emailController.text.trim(), passwordController.text.trim());
      Navigator.pop(context);
    } catch (e) {
      Navigator.pop(context);
      ErrorMessage.errorMessage("Error: ${e.toString()}", context);
    }
  }

  void _showLoading(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
  }
}
