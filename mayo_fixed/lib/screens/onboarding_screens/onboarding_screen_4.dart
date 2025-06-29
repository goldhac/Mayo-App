import 'package:flutter/material.dart';
import 'package:mayo_fixed/widgets/feature_card.dart';
import 'package:mayo_fixed/widgets/onboarding_navigation_buttons.dart';
import 'onboarding_screen_5.dart';

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
            // Placeholder for an image or illustration specific to this screen
            // You can add an Image.asset widget here, similar to previous screens.
            // Example: Image.asset('assets/your_image_4.png', height: 200),
            const SizedBox(height: 48.0),
            Text(
              'Your Privacy Matters', // Title for the screen
              style: TextStyle(
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 9, 3, 22),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16.0),
            const Text(
              'All your chats are encrypted end-to-end. Stored only on your device.', // Description
              style: TextStyle(
                fontSize: 16.0,
                color: Color.fromARGB(255, 9, 3, 22),
              ),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 32.0),
            // Example of two feature cards
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: FeatureCard(
                    icon: Icons.lock_outline,
                    title: 'Secure Encryption',
                  ),
                ),
                Expanded(
                  child: FeatureCard(
                    icon: Icons.masks_outlined,
                    title: 'Anonymous Profiles',
                  ),
                ),
              ],
            ),
            const Spacer(),
            const Text(
              '4 / 5', // Page indicator
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 24.0),
            OnboardingNavigationButtons(
              onBack: () {
                Navigator.pop(context);
              },
              onNext: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OnboardingScreen5(),
                    ));
              },
            )
          ],
        ),
      ),
    );
  }
}