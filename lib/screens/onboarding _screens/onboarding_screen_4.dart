import 'package:flutter/material.dart';
import 'package:mayo/widgets/onboarding_navigation_buttons.dart';
import 'package:mayo/widgets/feature_card.dart'; // Import the new FeatureCard widget

class OnboardingScreen4 extends StatelessWidget {
  const OnboardingScreen4({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set background color to white
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ... existing code ...
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded( // Wrap FeatureCard in Expanded
                  child: FeatureCard(
                    icon: Icons.lock_outline,
                    title: 'Secure Encryption',
                  ),
                ),
                const SizedBox(width: 16.0), // Add some spacing between cards
                Expanded( // Wrap FeatureCard in Expanded
                  child: FeatureCard(
                    icon: Icons.masks_outlined,
                    title: 'Anonymous Profiles',
                  ),
                ),
              ],
            ),
            // ... existing code ...
          ],
        ),
      ),
    );
  }

  // The _buildFeatureCard helper method is no longer needed here and will be removed.
}