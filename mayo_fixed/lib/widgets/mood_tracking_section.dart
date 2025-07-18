import 'package:flutter/material.dart';

/// Reusable mood tracking section widget
class MoodTrackingSection extends StatelessWidget {
  final String monthTitle;
  final String weekTitle;
  final int moodPercentage;
  final String weeklyChange;
  final List<double> weeklyData;
  final VoidCallback? onTap;

  const MoodTrackingSection({
    super.key,
    required this.monthTitle,
    required this.weekTitle,
    required this.moodPercentage,
    required this.weeklyChange,
    required this.weeklyData,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0x1A6B46C1), // 0.1 opacity purple
        border: Border.all(color: const Color(0xFF6B46C1)),
      ),
      child: Material(
        color: Colors.transparent,
        elevation: 0,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Month title
                Text(
                  monthTitle,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6B46C1),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Week title
                Text(
                  weekTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B46C1),
                  ),
                ),
                const SizedBox(height: 8),
                
                // Mood chart title
                const Text(
                  'Mood Chart',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xBF6B46C1), // 0.7 opacity purple
                  ),
                ),
                const SizedBox(height: 16),
                
                // Mood percentage
                Row(
                  children: [
                    Text(
                      '$moodPercentage%',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6B46C1),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0x33FFFFFF), // 0.2 opacity white
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        weeklyChange,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF6B46C1),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Weekly chart
                _buildWeeklyChart(),
                const SizedBox(height: 12),
                
                // Days of week
                _buildDaysOfWeek(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyChart() {
    return SizedBox(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: weeklyData.map((value) {
          return Container(
            width: 24,
            height: value * 60, // Scale to fit the height
            decoration: BoxDecoration(
              color: const Color(0xB3FFFFFF), // 0.7 opacity white
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDaysOfWeek() {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: days.map((day) {
        return Text(
          day,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xCC6B46C1), // 0.8 opacity purple
          ),
        );
      }).toList(),
    );
  }
}