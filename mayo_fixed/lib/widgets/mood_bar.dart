import 'package:flutter/material.dart';

/// A widget that displays a single mood bar for the mood tracker.
/// It shows the day of the week below the bar.
class MoodBar extends StatelessWidget {
  final String day;

  const MoodBar({
    super.key,
    required this.day,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 30,
          height: 100, // Placeholder height for the bar
          decoration: BoxDecoration(
            color: Colors.purple.shade100, // Light purple color for the bar
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.purple.shade300, width: 1),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          day,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}