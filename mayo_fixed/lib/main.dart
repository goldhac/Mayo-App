import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Import our screens and services
import 'screens/onboarding_screens/onboarding_screen.dart';
import 'screens/home_screen.dart';
import 'services/auth_service.dart';

/// Main entry point of the application
/// Initializes Firebase and starts the app
void main() async {
  // Ensure Flutter binding is initialized before Firebase
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase for authentication and other services
  await Firebase.initializeApp();
  
  // Start the app
  runApp(const MyApp());
}

/// Main application widget
/// Sets up the app theme and routing
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mayo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        useMaterial3: true,
      ),
      // Use AuthWrapper to manage authentication state
      home: const AuthWrapper(),
    );
  }
}

/// AuthWrapper manages the authentication state of the app
/// It listens to authentication changes and routes users to appropriate screens
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    
    // Listen to authentication state changes
    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        // Show loading indicator while checking authentication state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
              ),
            ),
          );
        }
        
        // Check if user is authenticated
        if (snapshot.hasData && snapshot.data != null) {
          // User is signed in - show the main app (HomeScreen)
          return const HomeScreen();
        } else {
          // User is not signed in - show onboarding screens
          return const OnboardingScreen();
        }
      },
    );
  }
}
