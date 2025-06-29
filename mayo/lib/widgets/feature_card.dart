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
                  color: Colors.deepPurple.shade400,
                  size: 30.0,
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                    softWrap: true,
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
