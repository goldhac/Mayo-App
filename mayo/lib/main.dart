import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'screens/onboarding _screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mayo',
      debugShowCheckedModeBanner:
          false, // Set to false to remove the debug banner
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        useMaterial3: true,
      ),
      home: const OnboardingScreen(),
    );
  }
}
