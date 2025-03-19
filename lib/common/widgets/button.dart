import 'package:flutter/material.dart';

class Button extends StatefulWidget {
  final String text;
  final void Function()? onTap;
  const Button({super.key, required this.text, required this.onTap});

  @override
  State<Button> createState() => _ButtonState();
}


class _ButtonState extends State<Button> {
  bool _isPressed = false; // Track the button press state

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTapDown: (_) {
        // On button press, set the pressed state
        setState(() {
          _isPressed = true;
        });
      },
      onTapUp: (_) {
        // Reset the pressed state and execute the onTap callback
        setState(() {
          _isPressed = false;
        });
        if (widget.onTap != null) {
          widget.onTap!();
        }
      },
      onTapCancel: () {
        // Reset the pressed state if the gesture is canceled
        setState(() {
          _isPressed = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: _isPressed
              ? colorScheme.primary.withOpacity(0.8) // Darker shade on press
              : colorScheme.primary,
          borderRadius: BorderRadius.circular(10),
          boxShadow: _isPressed
              ? []
              : [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.5),
                    offset: const Offset(0, 4),
                    blurRadius: 8,
                  ),
                ],
        ),
        width: 300,
        height: 50,
        child: Center(
          child: Text(
            widget.text,
            style: const TextStyle(fontSize: 20, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
