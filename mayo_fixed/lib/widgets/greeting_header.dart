import 'package:flutter/material.dart';

/// Reusable greeting header widget for the home screen
class GreetingHeader extends StatelessWidget {
  final String userName;
  final String greeting;
  final VoidCallback? onNotificationTap;

  const GreetingHeader({
    super.key,
    required this.userName,
    required this.greeting,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min, // Set to min to avoid unbounded height
          children: [
            Text(
              '$greeting, $userName',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            // Remove Spacer() as it requires a bounded constraint
          ],
        ),
        const Spacer(), // Add spacer here in the Row instead
        IconButton(
          icon: const Icon(
            Icons.notifications_none_rounded,
            color: Colors.black54,
            size: 28,
          ),
          onPressed: onNotificationTap,
        ),
      ],
    );
  }
}
