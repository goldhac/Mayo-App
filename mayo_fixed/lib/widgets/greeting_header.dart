import 'package:flutter/material.dart';

/// Reusable greeting header widget for the home screen
class GreetingHeader extends StatelessWidget {
  final String userName;
  final VoidCallback? onNotificationTap;

  const GreetingHeader({
    super.key,
    required this.userName,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good afternoon, $userName',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        Spacer(),
        IconButton(
          onPressed: onNotificationTap,
          icon: const Icon(
            Icons.notifications_outlined,
            color: Colors.black87,
            size: 24,
          ),
        ),
      ],
    );
  }
}
