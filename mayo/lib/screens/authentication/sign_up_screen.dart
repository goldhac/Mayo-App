import 'package:flutter/material.dart';
import 'package:mayo/widgets/full_width_button.dart';
import 'package:mayo/widgets/form_widgets.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _isPasswordVisible = false; // Password visibility flag
  bool _isChecked = false; // Checkbox state

  final _formKey = GlobalKey<FormState>(); // Form key for validation

  // Controllers for text fields
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _partnerCodeController = TextEditingController();

  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _partnerCodeController.dispose();
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
                  'Create Your Mayo Account',
                  style: TextStyle(
                    fontSize: 32.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32.0),
                buildTextField(
                    'Full Name', 'Sophia Carter', _fullNameController, null),
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
                    _isPasswordVisible,
                    togglePasswordVisibility,
                    _confirmPasswordError),
                const SizedBox(height: 16.0),
                buildTextField('Partner Invite Code (Optional)', 'ABCD-1234',
                    _partnerCodeController, null,
                    isRequired: false), // No validation for partner code
                const SizedBox(height: 24.0),
                Row(
                  children: [
                    Checkbox(
                      value: _isChecked,
                      onChanged: (bool? value) {
                        setState(() {
                          _isChecked = value ?? false;
                        });
                      },
                      fillColor: WidgetStateProperty.all(Colors.white),
                      checkColor: Colors.deepPurple,
                    ),
                    const Expanded(
                      child: Text(
                        'I agree to the Terms of Service and Privacy Policy',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24.0),
                FullWidthButton(
                  text: 'Sign Up',
                  onPressed: () {
                    setState(() {
                      _emailError = _validateEmail(_emailController.text);
                    });

                    if (_formKey.currentState?.validate() ?? false) {
                      // Handle Sign Up if all fields are valid
                    }
                  },
                  color: Colors.deepPurple.shade400,
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
                      // Navigate to Log In screen
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
