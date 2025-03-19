import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../common/widgets/error_message.dart';
import 'auth_service.dart';

class GoogleAuth {
  final FirebaseAuth _auth = AuthService().instance;

  Future<UserCredential?> signInWithGoogle(BuildContext context) async {
    try {
      await GoogleSignIn().signOut();

      _showLoading(context);

      final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();
      if (gUser == null) {
        Navigator.pop(context);
        return null;
      }

      final GoogleSignInAuthentication gAuth = await gUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      Navigator.pop(context);
      return userCredential;
    } catch (e) {
      Navigator.pop(context);
      ErrorMessage.errorMessage("Google Sign-In Failed: $e", context);
      return null;
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
