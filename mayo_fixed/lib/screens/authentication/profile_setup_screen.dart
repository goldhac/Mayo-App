import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/database_service.dart';
import '../../widgets/full_width_button.dart';
import '../home_screen.dart';
import '../../utilities/auth_theme.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  final _picker = ImagePicker();
  final _databaseService = DatabaseService();
  
  File? _selectedImage;
  bool _isUploading = false;

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
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
        leading: Container(),
        actions: [
          TextButton(
            onPressed: _skipProfilePicture,
            child: const Text(
              'Skip',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Text(
                  'Complete Your Profile',
                  style: AuthTheme.getAuthTextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Add a nickname and profile picture to personalize your experience.',
                  style: AuthTheme.getAuthTextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _nicknameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Nickname',
                    labelStyle: const TextStyle(color: Colors.white70),
                    hintText: 'Enter your nickname',
                    hintStyle: const TextStyle(color: Colors.white54),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white30),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.deepPurple),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a nickname';
                    }
                    if (value.trim().length < 2) {
                      return 'Nickname must be at least 2 characters';
                    }
                    if (value.trim().length > 20) {
                      return 'Nickname must be less than 20 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),
                Center(
                  child: GestureDetector(
                    onTap: _showImageSourceDialog,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.deepPurple,
                          width: 3,
                        ),
                        color: Colors.grey.shade800,
                      ),
                      child: _selectedImage != null
                          ? ClipOval(
                              child: Image.file(
                                _selectedImage!,
                                fit: BoxFit.cover,
                                width: 150,
                                height: 150,
                              ),
                            )
                          : const Icon(
                              Icons.add_a_photo,
                              size: 50,
                              color: Colors.white70,
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Tap to add photo',
                  style: AuthTheme.getAuthTextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                if (_selectedImage != null)
                  Column(
                    children: [
                      FullWidthButton(
                        text: _isUploading ? 'Setting up...' : 'Complete Profile',
                        onPressed: _isUploading ? null : _completeProfileWithPicture,
                        color: Colors.deepPurple,
                        textColor: Colors.white,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                FullWidthButton(
                  text: 'Complete with Default Avatar',
                  onPressed: _completeProfileWithDefault,
                  color: Colors.grey.shade800,
                  textColor: Colors.white,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    ),);
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey.shade900,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Choose Photo Source',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.white),
              title: const Text(
                'Camera',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.white),
              title: const Text(
                'Gallery',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick image: $e');
    }
  }

  Future<void> _completeProfileWithPicture() async {
    if (_selectedImage == null || !_formKey.currentState!.validate()) return;

    setState(() {
      _isUploading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showErrorSnackBar('User not authenticated');
        return;
      }

      final nicknameResult = await _databaseService.updateUserNickname(
        userId: user.uid,
        nickname: _nicknameController.text.trim(),
      );

      if (!nicknameResult.success) {
        _showErrorSnackBar(nicknameResult.message);
        return;
      }

      // Try to upload image to Firebase Storage with retry
      String profilePictureUrl = '';
      bool uploadSuccessful = false;
      
      for (int attempt = 0; attempt < 2 && !uploadSuccessful; attempt++) {
        try {
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('profile_pictures')
              .child('${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg');

          final uploadTask = storageRef.putFile(_selectedImage!);
          final snapshot = await uploadTask;
          profilePictureUrl = await snapshot.ref.getDownloadURL();
          uploadSuccessful = true;
        } catch (storageError) {
          print('Storage upload attempt ${attempt + 1} failed: $storageError');
          if (attempt == 1) {
            // Final attempt failed, show user-friendly message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Image upload failed. Your profile will be saved with a default avatar. You can update your photo later from settings.'),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 4),
              ),
            );
            profilePictureUrl = ''; // Use empty string for default avatar
          } else {
            // Wait before retry
            await Future.delayed(const Duration(seconds: 1));
          }
        }
      }

      final result = await _databaseService.updateUserProfilePicture(
        userId: user.uid,
        profilePictureUrl: profilePictureUrl,
      );

      if (result.success) {
        await _markProfileSetupComplete(user.uid);
        _navigateToHome();
      } else {
        _showErrorSnackBar(result.message);
      }
    } catch (e) {
      _showErrorSnackBar('Failed to complete profile setup: $e');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _completeProfileWithDefault() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isUploading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showErrorSnackBar('User not authenticated');
        return;
      }

      final nicknameResult = await _databaseService.updateUserNickname(
        userId: user.uid,
        nickname: _nicknameController.text.trim(),
      );

      if (!nicknameResult.success) {
        _showErrorSnackBar(nicknameResult.message);
        return;
      }

      final result = await _databaseService.updateUserProfilePicture(
        userId: user.uid,
        profilePictureUrl: '',
      );

      if (result.success) {
        await _markProfileSetupComplete(user.uid);
        _navigateToHome();
      } else {
        _showErrorSnackBar(result.message);
      }
    } catch (e) {
      _showErrorSnackBar('Failed to complete profile setup: $e');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  void _skipProfilePicture() {
    _completeProfileWithDefault();
  }

  Future<void> _markProfileSetupComplete(String userId) async {
    try {
      await _databaseService.updateUserProfileSetupStatus(
        userId: userId,
        isComplete: true,
      );
    } catch (e) {
      print('Error marking profile setup complete: $e');
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
      (route) => false,
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
