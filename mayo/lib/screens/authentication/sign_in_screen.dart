import 'package:flutter/material.dart';
import 'package:mayo/widgets/full_width_button.dart';
import 'package:mayo/widgets/form_widgets.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _isPasswordVisible = false; // Password visibility flag

  final _formKey = GlobalKey<FormState>(); // Form key for validation

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
                  'Welcome Back',
                  style: TextStyle(
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
                    onPressed: () {
                      // Handle Forgot Password
                    },
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
                const SizedBox(height: 24.0),
                FullWidthButton(
                  text: 'Log In',
                  onPressed: () {
                    setState(() {
                      _emailError = _validateEmail(_emailController.text);
                      _passwordError =
                          _validatePassword(_passwordController.text);
                    });

                    if (_formKey.currentState?.validate() ?? false) {
                      // Handle Log In if all fields are valid
                    }
                  },
                  color: Colors.deepPurple.shade400,
                ),
                const SizedBox(height: 24.0),
                const Center(
                  child: Text(
                    'Or log in with',
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
                    },
                    child: const Text(
                      "Don't have an account? Sign Up",
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
