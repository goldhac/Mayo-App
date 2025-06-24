import 'package:flutter/material.dart';

/// A reusable widget to display a feature card with an icon and a title.
class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white, // Set background color to white
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade300), // Light gray border
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start, // Align top for multi-line text
          children: [
            Icon(
              icon,
              size: 40.0,
              color: Colors.deepPurple.shade400,
            ),
            const SizedBox(width: 12.0),
            Expanded(
              // Ensures the text wraps within available space
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16.0, // Increased font size
                  fontWeight: FontWeight.w600, // Slightly bolder than bold
                  color: Colors.black,
                ),
                softWrap: true,
                overflow: TextOverflow.visible,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
