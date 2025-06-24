import 'package:flutter/material.dart';

/// A reusable widget for onboarding screen navigation buttons.
/// It includes a 'Back' button and a 'Next' button.
class OnboardingNavigationButtons extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onNext;

  const OnboardingNavigationButtons({
    super.key,
    this.onBack,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed:
                onBack ?? () => Navigator.pop(context), // Default back behavior
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Colors.purple),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Back',
              style: TextStyle(fontSize: 16, color: Colors.purple),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: onNext, // Next button action
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 96, 5, 161),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Next',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}
