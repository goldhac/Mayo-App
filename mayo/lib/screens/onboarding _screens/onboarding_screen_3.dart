import 'package:flutter/material.dart';
import 'package:mayo/widgets/mood_bar.dart'; // Import the new MoodBar widget
import 'onboarding_screen_4.dart';
import 'package:mayo/widgets/onboarding_navigation_buttons.dart';

class OnboardingScreen3 extends StatelessWidget {
  const OnboardingScreen3({super.key});

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
              // Title and description
              const Text(
                'Track Your Mood & Progress',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Log how you feel each day and see your\njourney over time.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Mood Tracker section
              const Text(
                'Mood Tracker',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              const SizedBox(height: 24),
              const Text(
                'Last 7 Days',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  MoodBar(day: 'Mon'), // Use the new MoodBar widget
                  MoodBar(day: 'Tue'),
                  MoodBar(day: 'Wed'),
                  MoodBar(day: 'Thu'),
                  MoodBar(day: 'Fri'),
                  MoodBar(day: 'Sat'),
                  MoodBar(day: 'Sun'),
                ],
              ),

              const Spacer(),

              // Page indicator
              const Text(
                '3 / 5',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),

              // Navigation buttons
              OnboardingNavigationButtons(
                onBack: () {
                  Navigator.pop(context);
                },
                onNext: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OnboardingScreen4(),
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
