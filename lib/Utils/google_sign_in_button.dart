import 'package:flutter/material.dart';

class GoogleSignInButton extends StatelessWidget {
  final Function()? onTap;

  const GoogleSignInButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme; // Access Theme's color scheme
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80, // Square dimensions
        width: 80,
        decoration: BoxDecoration(
          color: colorScheme.surface, // Background color from colorScheme
          borderRadius: BorderRadius.circular(8), // Rounded corners
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2), // Shadow color
              blurRadius: 8, // Slightly increased blur
              offset: const Offset(0, 4), // Shadow offset
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0), // Adjust padding for better spacing
          child: Image.asset(
            'lib/images/google_login.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
