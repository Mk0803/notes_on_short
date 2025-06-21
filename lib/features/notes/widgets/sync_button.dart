import 'package:flutter/material.dart';

class SyncButton extends StatelessWidget {
  final bool isSyncing;
  final VoidCallback onSyncPressed;
  final AnimationController controller;

  const SyncButton({
    super.key,
    required this.isSyncing,
    required this.onSyncPressed,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: isSyncing
          ? AnimatedBuilder(
              animation: controller,
              builder: (context, child) {
                return Transform.rotate(
                  angle: controller.value * 6.3,
                  child: child,
                );
              },
              child: const Icon(
                Icons.sync,
              ),
            )
          : const Icon(Icons.sync),
      onPressed: isSyncing ? null : onSyncPressed,
      tooltip: 'Sync Notes',
    );
  }
}
