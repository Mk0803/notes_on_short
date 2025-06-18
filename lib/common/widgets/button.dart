import 'package:flutter/material.dart';
import 'package:notes_on_short/utils/helpers/helper_functions.dart';

class Button extends StatefulWidget {
  final String text;
  final void Function()? onTap;

  const Button({super.key, required this.text, required this.onTap});

  @override
  State<Button> createState() => _ButtonState();
}

class _ButtonState extends State<Button> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _isPressed = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          _isPressed = false;
        });
        if (widget.onTap != null) {
          widget.onTap!();
        }
      },
      onTapCancel: () {
        setState(() {
          _isPressed = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: _isPressed
              ? colorScheme.primary.withOpacity(0.8)
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
            style: TextStyle(
                fontSize: 20,
                color: HelperFunctions.isDarkMode(context)
                    ? Colors.black
                    : Colors.white),
          ),
        ),
      ),
    );
  }
}
