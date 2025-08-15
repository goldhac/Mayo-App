import 'package:flutter/material.dart';
import 'package:mayo_fixed/widgets/full_width_button.dart';
import 'package:mayo_fixed/widgets/form_widgets.dart';
import 'package:mayo_fixed/services/auth_service.dart'; // Import our authentication service
import 'package:mayo_fixed/utilities/auth_theme.dart'; // Import authentication theme
import 'package:mayo_fixed/main.dart'; // Import for AuthWrapper
import 'sign_up_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _isPasswordVisible = false; // Password visibility flag
  bool _isLoading = false; // Loading state for sign-in process

  final _formKey = GlobalKey<FormState>(); // Form key for validation
  final AuthService _authService = AuthService(); // Instance of our authentication service

  // Controllers for text fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Validate email format
  String? _validateEmail(String value) {
    String pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  // Validate password length
  String? _validatePassword(String value) {
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  // Function to toggle the password visibility
  void togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  /// Handle user sign-in process
  /// This method validates the form, calls the authentication service,
  /// and handles the response (success or error)
  Future<void> _handleSignIn() async {
    // Clear any previous errors
    setState(() {
      _emailError = _validateEmail(_emailController.text);
      _passwordError = _validatePassword(_passwordController.text);
    });

    // Check if form is valid before proceeding
    if (_emailError != null || _passwordError != null) {
      return;
    }

    // Show loading state
    setState(() {
      _isLoading = true;
    });

    try {
      // Call the authentication service to sign in the user
      final result = await _authService.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (mounted) {
        if (result.success) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );

          // Add manual navigation to force a rebuild of the widget tree
          // This will trigger the AuthWrapper to check authentication state
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const AuthWrapper()),
            (route) => false,
          );
          
        } else {
          // Sign-in failed - show error message
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
            content: Text('An unexpected error occurred. Please try again.'),
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

  /// Handle forgot password functionality
  /// This method shows a dialog to get the user's email and sends a password reset email
  Future<void> _handleForgotPassword() async {
    final TextEditingController emailController = TextEditingController();
    
    // Show dialog to get user's email for password reset
    final String? email = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            'Reset Password',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Enter your email address to receive a password reset link.',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Email address',
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.grey[800],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(emailController.text);
              },
              child: const Text(
                'Send Reset Email',
                style: TextStyle(color: Colors.deepPurple),
              ),
            ),
          ],
        );
      },
    );

    // If user provided an email, send the password reset email
    if (email != null && email.isNotEmpty) {
      final result = await _authService.sendPasswordResetEmail(email);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: result.success ? Colors.green : Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AuthTheme.getAuthTheme(context),
      child: Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey, // Attach form key to the form widget
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome Back',
                  style: AuthTheme.getAuthTextStyle(
                    fontSize: 32.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32.0),
                buildTextField('Email Address', 'you@example.com',
                    _emailController, _emailError),
                const SizedBox(height: 16.0),
                buildPasswordField(
                    'Password',
                    _passwordController,
                    _isPasswordVisible,
                    togglePasswordVisibility,
                    _passwordError),
                const SizedBox(height: 16.0),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _handleForgotPassword, // Call our forgot password handler
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
                const SizedBox(height: 24.0),
                FullWidthButton(
                  text: _isLoading ? 'Signing In...' : 'Log In', // Show loading text when processing
                  onPressed: _isLoading ? null : () => _handleSignIn(), // Wrap async function in sync callback
                  color: Colors.deepPurple.shade400,
                ),
                
                // Show loading indicator when signing in
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 16.0),
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                      ),
                    ),
                  ),
                const SizedBox(height: 24.0),
                Center(
                  child: Text(
                    'Or log in with',
                    style: AuthTheme.getAuthTextStyle(color: Colors.white54),
                  ),
                ),
                const SizedBox(height: 24.0),
                Row(
                  children: [
                    Expanded(
                      child: FullWidthButton(
                        text: 'Google',
                        onPressed: () {
                          // Handle Google Log In
                        },
                        color: Colors.grey.shade800,
                        textColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: FullWidthButton(
                        text: 'Apple',
                        onPressed: () {
                          // Handle Apple Log In
                        },
                        color: Colors.grey.shade800,
                        textColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24.0),
                Center(
                  child: TextButton(
                    onPressed: () {
                      // Navigate to Sign Up screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignUpScreen(),
                        ),
                      );
                    },
                    child: Text(
                      "Don't have an account? Sign Up",
                      style: AuthTheme.getAuthTextStyle(color: Colors.white70),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}
