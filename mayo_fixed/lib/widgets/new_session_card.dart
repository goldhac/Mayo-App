import 'package:flutter/material.dart';

/// Reusable new session card widget
class NewSessionCard extends StatelessWidget {
  // Title text (e.g., "Start solo or couples chat")
  final String title;
  // Subtitle/action text (e.g., "Begin")
  final String subtitle;
  // Top label text (e.g., "New Session")
  final String toptext;
  // Callback function when card is tapped
  final VoidCallback onTap;
  // Card background color
  final Color backgroundColor;
  // Text color for content
  final Color textColor;
  // Optional icon widget on the right side
  final Widget? icon;

  const NewSessionCard({
    super.key,
    required this.title,
    required this.toptext,
    required this.subtitle,
    required this.onTap,
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black87,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      // Card container with no elevation, just border
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        elevation: 0, // Remove elevation for flat design
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          // Inner container with padding
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16),
              // Add subtle border
              border: Border.all(color: Colors.grey.shade200),
            ),
            // Main content row
            child: Row(
              children: [
                // Left side content (text)
                Expanded(
                  flex: 3, // Give more space to text content
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top label text ("New Session")
                      Text(
                        toptext,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF6B46C1), // Purple color for top text
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Main title text
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 18),
                      // Action button (pill-shaped)
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF6B46C1).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16), // Consistent with mood tracker
                          border: Border.all(color: const Color(0xFF6B46C1)),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 10),
                        child: Row(
                          mainAxisSize:
                              MainAxisSize.min, // Only take needed width
                          children: [
                            // Button text
                            Text(
                              subtitle,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6B46C1),
                              ),
                            ),
                            const SizedBox(width: 4),
                            // Arrow icon
                            const Icon(
                              Icons.arrow_forward,
                              size: 14,
                              color: Color(0xFF6B46C1),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Right side image/icon (expanded)
                if (icon != null) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2, // Give more space to the image
                    child: Container(
                      alignment: Alignment.centerRight,
                      child: icon!,
                    ),
                  )
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
