import 'package:flutter/material.dart';
import 'package:mayo_fixed/widgets/full_width_button.dart';
import 'package:mayo_fixed/widgets/form_widgets.dart';
import 'package:mayo_fixed/services/auth_service.dart'; // Import our authentication service
import 'sign_in_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _isPasswordVisible = false; // Password visibility flag
  bool _isConfirmPasswordVisible = false; // Confirm password visibility flag
  bool _acceptTerms = false; // Terms acceptance flag
  bool _isLoading = false; // Loading state for sign-up process

  final _formKey = GlobalKey<FormState>(); // Form key for validation
  final AuthService _authService = AuthService(); // Instance of our authentication service

  // Controllers for text fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _inviteCodeController = TextEditingController();

  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _termsError;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _inviteCodeController.dispose();
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

  // Validate confirm password matches password
  String? _validateConfirmPassword(String value) {
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  // Function to toggle the password visibility
  void togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  // Function to toggle the confirm password visibility
  void toggleConfirmPasswordVisibility() {
    setState(() {
      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
    });
  }

  /// Handle user sign-up process
  /// This method validates the form, calls the authentication service,
  /// and handles the response (success or error)
  Future<void> _handleSignUp() async {
    // Validate all form fields
    setState(() {
      _nameError = _nameController.text.isEmpty ? 'Name is required' : null;
      _emailError = _validateEmail(_emailController.text);
      _passwordError = _validatePassword(_passwordController.text);
      _confirmPasswordError = _validateConfirmPassword(_confirmPasswordController.text);
      _termsError = !_acceptTerms ? 'You must accept the terms and conditions' : null;
    });

    // Check if all validations pass
    if (_nameError != null ||
        _emailError != null ||
        _passwordError != null ||
        _confirmPasswordError != null ||
        _termsError != null) {
      return;
    }

    // Show loading state
    setState(() {
      _isLoading = true;
    });

    try {
      // Call the authentication service to create a new user account
      final result = await _authService.signUpWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
        fullName: _nameController.text,
      );

      if (mounted) {
        if (result.success) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 4),
            ),
          );

          // Navigation is handled automatically by AuthWrapper
          // Firebase Auth automatically signs in the user after successful registration
          // The StreamBuilder in AuthWrapper will detect this and navigate to HomeScreen
          
        } else {
          // Sign-up failed - show error message
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                const Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 32.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32.0),
                buildTextField(
                    'Full Name', 'Your name', _nameController, _nameError),
                const SizedBox(height: 16.0),
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
                buildPasswordField(
                    'Confirm Password',
                    _confirmPasswordController,
                    _isConfirmPasswordVisible,
                    toggleConfirmPasswordVisibility,
                    _confirmPasswordError),
                const SizedBox(height: 16.0),
                buildTextField('Partner Invite Code (Optional)',
                    'Enter code if you have one', _inviteCodeController, null,
                    isRequired: false),
                const SizedBox(height: 24.0),
                Row(
                  children: [
                    Checkbox(
                      value: _acceptTerms,
                      onChanged: (value) {
                        setState(() {
                          _acceptTerms = value ?? false;
                          if (_acceptTerms) {
                            _termsError = null;
                          }
                        });
                      },
                      fillColor: WidgetStateProperty.resolveWith<Color>(
                        (Set<WidgetState> states) {
                          if (states.contains(WidgetState.selected)) {
                            return Colors.deepPurple;
                          }
                          return Colors.grey;
                        },
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'I agree to the Terms of Service and Privacy Policy',
                        style: TextStyle(
                          color:
                              _termsError != null ? Colors.red : Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ),
                if (_termsError != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: Text(
                      _termsError!,
                      style: const TextStyle(color: Colors.red, fontSize: 12.0),
                    ),
                  ),
                const SizedBox(height: 24.0),
                FullWidthButton(
                  text: _isLoading ? 'Creating Account...' : 'Sign Up', // Show loading text when processing
                  onPressed: _isLoading ? null : () => _handleSignUp(), // Wrap async function in sync callback
                  color: Colors.deepPurple.shade400,
                ),
                
                // Show loading indicator when signing up
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
                const Center(
                  child: Text(
                    'Or sign up with',
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
                const SizedBox(height: 24.0),
                Row(
                  children: [
                    Expanded(
                      child: FullWidthButton(
                        text: 'Google',
                        onPressed: () {
                          // Handle Google Sign Up
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
                          // Handle Apple Sign Up
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
                      // Navigate to Sign In screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignInScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Already have an account? Log In',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
