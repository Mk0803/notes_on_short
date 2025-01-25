import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserCredential> signInWithEmailPassword(String email, password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  Future<UserCredential> signUpWithEmailPassword(String email, password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  Future<UserCredential?> signInWithGoogle(BuildContext context) async {
  try {
    // Sign out the previous Google session
    await GoogleSignIn().signOut();

    // Show CircularProgressIndicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // Begin Google Sign-In process
    final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();
    if (gUser == null) {
      Navigator.pop(context); // Close CircularProgressIndicator
      return null; // User canceled the sign-in process
    }

    final GoogleSignInAuthentication gAuth = await gUser.authentication;

    // Create a credential for Firebase Authentication
    final credential = GoogleAuthProvider.credential(
      accessToken: gAuth.accessToken,
      idToken: gAuth.idToken,
    );

    // Use the credential to sign in to Firebase
    final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

    Navigator.pop(context); // Close CircularProgressIndicator
    return userCredential;
  } catch (e) {
    Navigator.pop(context); // Close CircularProgressIndicator
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Google Sign-In Failed: $e")),
    );
    return null;
  }
}

}
