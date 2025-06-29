import 'package:flutter/material.dart';
import 'package:mayo_fixed/widgets/full_width_button.dart';
import 'package:mayo_fixed/screens/authentication/sign_up_screen.dart';
import 'package:mayo_fixed/screens/authentication/sign_in_screen.dart';

class OnboardingScreen5 extends StatelessWidget {
  const OnboardingScreen5({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Text(
              'Ready to Begin?',
              style: TextStyle(
                fontSize: 32.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16.0),
            Text(
              'Create your free account and start your first session.',
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            FullWidthButton(
              text: 'Sign Up',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignUpScreen()),
                );
              },
              color: Colors.deepPurple.shade400,
            ),
            const SizedBox(height: 16.0),
            FullWidthButton(
              text: 'Log In',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignInScreen()),
                );
              },
              color: Colors.grey.shade800,
              textColor: Colors.white,
            ),
            const SizedBox(height: 16.0),
            TextButton(
              onPressed: () {
                // Handle Skip for now
              },
              child: Text(
                'Skip for now',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 16.0,
                ),
              ),
            ),
            const SizedBox(height: 24.0),
          ],
        ),
      ),
    );
  }
}