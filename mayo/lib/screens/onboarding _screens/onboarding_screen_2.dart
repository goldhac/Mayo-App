import 'package:flutter/material.dart';
import 'onboarding_screen_3.dart';
import 'package:mayo/widgets/onboarding_navigation_buttons.dart';

class OnboardingScreen2 extends StatelessWidget {
  const OnboardingScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              // Placeholder for the new illustration
              Image.asset(
                'assets/interactive_ai_sessions.png', // You'll need to add this image to your assets folder
                height: 200,
              ),
              const SizedBox(height: 48),
              const Text(
                'Interactive AI Sessions',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                "Chat naturally with Mayo's AI therapist\nand explore your relationship.",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              Text(
                '2/5',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              OnboardingNavigationButtons(
                onBack: () {
                  Navigator.pop(context);
                },
                onNext: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OnboardingScreen3(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
