import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Import our screens and services
import 'screens/onboarding_screens/onboarding_screen.dart';
import 'screens/home_screen.dart';
import 'screens/authentication/profile_setup_screen.dart';
import 'services/auth_service.dart';
import 'services/database_service.dart';

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
        // Set Lexend as the default font family for all screens
        fontFamily: 'Lexend',
        // Configure text themes to use Lexend
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontFamily: 'Lexend'),
          displayMedium: TextStyle(fontFamily: 'Lexend'),
          displaySmall: TextStyle(fontFamily: 'Lexend'),
          headlineLarge: TextStyle(fontFamily: 'Lexend'),
          headlineMedium: TextStyle(fontFamily: 'Lexend'),
          headlineSmall: TextStyle(fontFamily: 'Lexend'),
          titleLarge: TextStyle(fontFamily: 'Lexend'),
          titleMedium: TextStyle(fontFamily: 'Lexend'),
          titleSmall: TextStyle(fontFamily: 'Lexend'),
          bodyLarge: TextStyle(fontFamily: 'Lexend'),
          bodyMedium: TextStyle(fontFamily: 'Lexend'),
          bodySmall: TextStyle(fontFamily: 'Lexend'),
          labelLarge: TextStyle(fontFamily: 'Lexend'),
          labelMedium: TextStyle(fontFamily: 'Lexend'),
          labelSmall: TextStyle(fontFamily: 'Lexend'),
        ),
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
          // User is signed in - check if profile setup is complete
          return ProfileSetupChecker(user: snapshot.data!);
        } else {
          // User is not signed in - show onboarding screens
          return const OnboardingScreen();
        }
      },
    );
  }
}

/// ProfileSetupChecker determines if user needs to complete profile setup
class ProfileSetupChecker extends StatelessWidget {
  final User user;

  const ProfileSetupChecker({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final DatabaseService databaseService = DatabaseService();

    return FutureBuilder<bool>(
      future: _checkProfileSetupComplete(),
      builder: (context, snapshot) {
        // Show loading while checking profile setup status
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

        // Check if profile setup is complete
        final isProfileComplete = snapshot.data ?? false;

        if (isProfileComplete) {
          // Profile is complete - show home screen
          return const HomeScreen();
        } else {
          // Profile setup needed - show profile picture screen
          return const ProfileSetupScreen();
        }
      },
    );
  }

  /// Check if user has completed profile setup
  /// Returns false if user needs to set up profile picture
  Future<bool> _checkProfileSetupComplete() async {
    try {
      final DatabaseService databaseService = DatabaseService();
      final userDoc = await databaseService.getUserData(user.uid);

      if (!userDoc.success || userDoc.data == null) {
        // If user document doesn't exist or failed to fetch, assume setup needed
        return false;
      }

      final userData = userDoc.data as Map<String, dynamic>;

      // Check if user has completed profile setup
      // We consider profile complete if they have explicitly set a profile picture
      // or if they have the 'profileSetupComplete' flag set to true
      final hasProfilePicture = userData['profilePicture'] != null &&
          userData['profilePicture'].toString().isNotEmpty;
      final profileSetupComplete = userData['profileSetupComplete'] == true;

      return hasProfilePicture || profileSetupComplete;
    } catch (e) {
      // If there's an error, assume profile setup is needed
      return false;
    }
  }
}
