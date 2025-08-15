import 'package:flutter/material.dart';
import 'package:mayo_fixed/services/auth_service.dart';
import 'package:mayo_fixed/services/database_service.dart';

import 'package:mayo_fixed/widgets/shimmer_widgets.dart';
import 'package:mayo_fixed/screens/authentication/sign_in_screen.dart';
import 'package:mayo_fixed/screens/partner_link_screen.dart';
import 'package:mayo_fixed/screens/onboarding_screens/onboarding_screen.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();

  bool _isLoading = true;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// Load user data from Firestore
  Future<void> _loadUserData() async {
    final user = _authService.currentUser;
    if (user != null) {
      final result = await _databaseService.getUserData(user.uid);
      if (result.success && result.data != null) {
        setState(() {
          _userData = result.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showChangeNicknameDialog() async {
    final TextEditingController nicknameController = TextEditingController();
    nicknameController.text = _userData?['nickname'] ?? '';

    final String? newNickname = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            'Change Nickname',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Enter your new nickname',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nicknameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Nickname',
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.grey[800],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
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
                Navigator.of(context).pop(nicknameController.text);
              },
              child: const Text(
                'Save',
                style: TextStyle(color: Colors.deepPurple),
              ),
            ),
          ],
        );
      },
    );

    if (newNickname != null && newNickname.isNotEmpty) {
      final user = _authService.currentUser;
      if (user != null) {
        final result = await _databaseService.updateUserNickname(
          userId: user.uid,
          nickname: newNickname,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: result.success ? Colors.green : Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );

          if (result.success) {
            _loadUserData(); // Reload user data to reflect changes
          }
        }
      }
    }
  }

  void _showResetPasswordScreen() async {
    final TextEditingController emailController = TextEditingController();
    emailController.text = _userData?['email'] ?? '';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ResetPasswordScreen(email: _userData?['email'] ?? ''),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey[100],
        body: SafeArea(
          child: SingleChildScrollView(
            child: ShimmerLayouts.profileSection(),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Profile & Settings',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Account Info Section
                    const Text(
                      'Account Info',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSettingsItem(
                      'Email',
                      _userData?['email'] ?? 'No email',
                      onTap: () {},
                      showEditIcon: false,
                    ),
                    _buildDivider(),
                    _buildSettingsItem(
                      'Nickname',
                      _userData?['nickname'] ?? 'No nickname',
                      onTap: _showChangeNicknameDialog,
                    ),
                    _buildDivider(),
                    _buildSettingsItem(
                      'Password',
                      '••••••••',
                      onTap: _showResetPasswordScreen,
                    ),

                    const SizedBox(height: 24),

                    // Couple Management Section
                    const Text(
                      'Couple Management',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSettingsItem(
                      'Manage Partner',
                      '',
                      onTap: () async {
                        final user = _authService.currentUser;
                        if (user != null) {
                          // Generate partner code if user doesn't have one
                          await _databaseService.generatePartnerCode(user.uid);

                          if (mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PartnerLinkScreen(),
                              ),
                            );
                          }
                        }
                      },
                      showArrow: true,
                    ),

                    const SizedBox(height: 24),

                    // Notification Preferences Section
                    const Text(
                      'Notification Preferences',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildToggleItem(
                      'Session Reminders',
                      true,
                      (value) {
                        // Handle toggle
                      },
                    ),

                    const SizedBox(height: 24),

                    // Data & Privacy Controls Section
                    const Text(
                      'Data & Privacy Controls',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSettingsItem(
                      'Manage Data and Privacy Settings',
                      '',
                      onTap: () {},
                      showArrow: true,
                    ),

                    const SizedBox(height: 24),

                    // Help & Support Section
                    const Text(
                      'Help & Support',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSettingsItem(
                      'FAQ',
                      '',
                      onTap: () {},
                      showArrow: true,
                    ),
                    _buildDivider(),
                    _buildSettingsItem(
                      'Contact Support',
                      '',
                      onTap: () {},
                      showArrow: true,
                    ),
                    _buildSettingsItem('Logout', '', onTap: () async {
                      final result = await _authService.signOut();
                      if (result.success) {
                        // Navigate to the onboarding screen after successful sign out
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => const OnboardingScreen()),
                          (route) => false, // Remove all previous routes
                        );
                      } else {
                        // Show error message if sign out fails
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(result.message)),
                        );
                      }
                    })
                  ],
                ),
              ),
            ),
            // Bottom navigation is handled by MainNavigationScreen
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem(
    String title,
    String subtitle, {
    required VoidCallback onTap,
    bool showEditIcon = false,
    bool showArrow = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (showEditIcon)
              Icon(Icons.edit, color: Colors.grey[600], size: 20),
            if (showArrow)
              Icon(Icons.arrow_forward_ios, color: Colors.grey[600], size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleItem(String title, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF6B46C1),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(color: Colors.grey[300], height: 1);
  }
}

class ResetPasswordScreen extends StatefulWidget {
  final String email;

  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _toggleNewPasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
    });
  }

  String? _validatePassword(String value) {
    if (value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String value) {
    if (value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _newPasswordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // In a real app, you would call a method to reset the password
        // For now, we'll just simulate success and navigate back
        await Future.delayed(const Duration(seconds: 1));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password reset successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Reset Your Password',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Enter your new password and confirm it to regain access.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 32),
                // New Password Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'New Password',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _newPasswordController,
                      obscureText: !_isPasswordVisible,
                      validator: (value) => _validatePassword(value!),
                      decoration: InputDecoration(
                        hintText: 'Enter new password',
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: _toggleNewPasswordVisibility,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Confirm Password Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Confirm Password',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: !_isConfirmPasswordVisible,
                      validator: (value) => _validateConfirmPassword(value!),
                      decoration: InputDecoration(
                        hintText: 'Confirm new password',
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isConfirmPasswordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: _toggleConfirmPasswordVisibility,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // Progress Indicator
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: Colors.grey[200],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            color: const Color(0xFF6B46C1),
                          ),
                        ),
                      ),
                      Expanded(flex: 1, child: Container()),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _resetPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6B46C1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Save New Password',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                // Login Link
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignInScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Already have access? Log in',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
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
