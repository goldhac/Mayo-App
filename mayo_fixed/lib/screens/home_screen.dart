import 'package:flutter/material.dart';
import 'package:mayo_fixed/services/auth_service.dart';
import 'package:mayo_fixed/screens/authentication/sign_in_screen.dart';

/// HomeScreen - The main screen users see after successful authentication
/// This screen displays a welcome message and provides logout functionality
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService(); // Instance of our authentication service
  bool _isLoading = false; // Loading state for logout process

  /// Handle user logout process
  /// This method calls the authentication service to sign out the user
  /// and navigates back to the sign-in screen
  Future<void> _handleLogout() async {
    // Show confirmation dialog before logging out
    final bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            'Logout',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    // If user confirmed logout, proceed with the logout process
    if (shouldLogout == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Call the authentication service to sign out the user
        final result = await _authService.signOut();

        if (mounted) {
          if (result.success) {
            // Logout successful - show success message and navigate to sign-in
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result.message),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );

            // Navigate to sign-in screen and clear the navigation stack
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const SignInScreen(),
              ),
              (route) => false, // Remove all previous routes
            );
          } else {
            // Logout failed - show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result.message),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      } catch (e) {
        // Handle any unexpected errors
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('An unexpected error occurred during logout.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } finally {
        // Hide loading state
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get current user information
    final user = _authService.currentUser;
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Mayo App',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Logout button in the app bar
          IconButton(
            onPressed: _isLoading ? null : _handleLogout,
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(
                    Icons.logout,
                    color: Colors.white,
                  ),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome message
            Text(
              'Welcome back!',
              style: TextStyle(
                fontSize: 32.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16.0),
            
            // User information card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(
                  color: Colors.deepPurple.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Account Information',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  
                  // Display user's name
                  Row(
                    children: [
                      const Icon(
                        Icons.person,
                        color: Colors.deepPurple,
                        size: 20,
                      ),
                      const SizedBox(width: 8.0),
                      Text(
                        'Name: ${user?.displayName ?? 'Not provided'}',
                        style: const TextStyle(
                          fontSize: 16.0,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  
                  // Display user's email
                  Row(
                    children: [
                      const Icon(
                        Icons.email,
                        color: Colors.deepPurple,
                        size: 20,
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Text(
                          'Email: ${user?.email ?? 'Not available'}',
                          style: const TextStyle(
                            fontSize: 16.0,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  
                  // Display email verification status
                  Row(
                    children: [
                      Icon(
                        user?.emailVerified == true
                            ? Icons.verified
                            : Icons.warning,
                        color: user?.emailVerified == true
                            ? Colors.green
                            : Colors.orange,
                        size: 20,
                      ),
                      const SizedBox(width: 8.0),
                      Text(
                        'Email: ${user?.emailVerified == true ? 'Verified' : 'Not verified'}',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: user?.emailVerified == true
                              ? Colors.green
                              : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32.0),
            
            // App features section (placeholder for future development)
            const Text(
              'App Features',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16.0),
            
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(
                    color: Colors.deepPurple.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.construction,
                        color: Colors.deepPurple,
                        size: 64,
                      ),
                      SizedBox(height: 16.0),
                      Text(
                        'Coming Soon!',
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        'App features will be added here.\nStay tuned for updates!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}