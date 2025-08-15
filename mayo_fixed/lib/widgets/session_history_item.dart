import 'package:flutter/material.dart';

/// Reusable session history item widget
class SessionHistoryItem extends StatelessWidget {
  final String date;
  final String type;
  final bool isSolo;
  final VoidCallback? onTap;
  final VoidCallback? onMoreTap;
  // Mood rating from 1-3 (1=sad, 2=neutral, 3=happy)
  final int? moodRating;

  const SessionHistoryItem({
    super.key,
    required this.date,
    required this.type,
    required this.isSolo,
    this.onTap,
    this.onMoreTap,
    this.moodRating,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar - displays different images based on session type
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(
                        color: const Color(0xFF6B46C1).withAlpha(76), width: 2),
                  ),
                  child: ClipOval(
                    child: isSolo == true
                        ? Image.asset(
                            // Solo session avatar image
                            'assets/solo_session_image.png',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              // Fallback to default avatar if solo image fails to load
                              return _buildDefaultAvatar();
                            },
                          )
                        : Image.asset(
                            // Couples session avatar image
                            'assets/couples_image.png',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              // Fallback to default avatar if couples image fails to load
                              return _buildDefaultAvatar();
                            },
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                // Session info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        date,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        type,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                // Mood emojis - three emojis representing session mood
                Container(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: _buildMoodEmojis(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF6B46C1).withOpacity(0.1),
        border: Border.all(color: const Color(0xFF6B46C1)),
      ),
      child: const Icon(
        Icons.person,
        color: Color(0xFF6B46C1),
        size: 24,
      ),
    );
  }

  // Build single mood emoji based on session mood rating
  List<Widget> _buildMoodEmojis() {
    // Default mood emoji (neutral if no rating provided)
    String emoji = '😐';
    Color moodColor = Colors.grey;

    // Update emoji based on mood rating
    if (moodRating != null) {
      switch (moodRating!) {
        case 1: // Sad mood
          emoji = '😢';
          moodColor = Colors.red.shade400;
          break;
        case 2: // Neutral mood
          emoji = '😐';
          moodColor = Colors.amber.shade400;
          break;
        case 3: // Happy mood
          emoji = '😊';
          moodColor = Colors.green.shade400;
          break;
        default:
          emoji = '😐';
          moodColor = Colors.amber.shade400;
      }
    }

    return [
      Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: moodColor.withOpacity(0.1),
          border: Border.all(color: moodColor),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Text(
          emoji,
          style: TextStyle(
            fontSize: 20,
          ),
        ),
      )
    ];
  }
}
