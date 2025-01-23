import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes_on_short/Utils/button.dart';
class HomePage extends StatelessWidget {
   HomePage({super.key});

  void signUserOut(){
    FirebaseAuth.instance.signOut();
  }
  final user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Logged In as "+ user.email!),
              SizedBox(height: 10,),
              Button(text: "Sign Out", onTap: signUserOut)
            ],
          ),
      )
      ),
    );
  }
}