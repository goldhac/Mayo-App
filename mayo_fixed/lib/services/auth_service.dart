import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'database_service.dart';

/// AuthService class handles all Firebase Authentication operations
/// This service provides methods for user registration, login, logout, and password reset
class AuthService {
  // Private constructor to implement singleton pattern
  AuthService._privateConstructor();

  // Static instance of AuthService (singleton)
  static final AuthService _instance = AuthService._privateConstructor();

  // Factory constructor that returns the singleton instance
  factory AuthService() => _instance;

  // Firebase Auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Database service instance
  final DatabaseService _databaseService = DatabaseService();

  /// Get the current user
  /// Returns null if no user is signed in
  User? get currentUser => _auth.currentUser;

  /// Stream of authentication state changes
  /// This stream emits whenever the user signs in or out
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Check if a user is currently signed in
  /// Returns true if user is authenticated, false otherwise
  bool get isSignedIn => _auth.currentUser != null;

  /// Sign up a new user with email and password
  ///
  /// Parameters:
  /// - [email]: User's email address
  /// - [password]: User's password (should be at least 8 characters)
  /// - [fullName]: User's full name (will be stored in displayName)
  /// - [inviteCode]: Optional partner invite code
  ///
  /// Returns:
  /// - [AuthResult]: Contains success status and user data or error message
  Future<AuthResult> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
    String? inviteCode,
  }) async {
    try {
      // Validate input parameters
      if (email.isEmpty || password.isEmpty || fullName.isEmpty) {
        return AuthResult(
          success: false,
          message: 'All fields are required',
        );
      }

      if (password.length < 8) {
        return AuthResult(
          success: false,
          message: 'Password must be at least 8 characters long',
        );
      }

      // Create user account with Firebase Auth
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Update user profile with display name
      await userCredential.user?.updateDisplayName(fullName);

      // Send email verification
      await userCredential.user?.sendEmailVerification();

      // Create user document in Firestore
      if (userCredential.user != null) {
        final dbResult = await _databaseService.createUserDocument(
          user: userCredential.user!,
          inviteCode: inviteCode,
        );

        if (!dbResult.success) {
          if (kDebugMode) {
            print('Failed to create user document: ${dbResult.message}');
          }
          // Don't fail the entire sign-up process if database creation fails
        }

        // Update login status
        await _databaseService.updateUserLoginStatus(
            userCredential.user!.uid, true);
      }

      if (kDebugMode) {
        print('User signed up successfully: ${userCredential.user?.email}');
      }

      String successMessage =
          'Account created successfully! Please check your email for verification.';
      if (inviteCode != null && inviteCode.isNotEmpty) {
        successMessage += ' Partner linking will be processed.';
      }

      return AuthResult(
        success: true,
        message: successMessage,
        user: userCredential.user,
      );
    } on FirebaseAuthException catch (e) {
      // Handle Firebase Auth specific errors
      String errorMessage = _getFirebaseErrorMessage(e.code);

      if (kDebugMode) {
        print('Firebase Auth Error: ${e.code} - ${e.message}');
      }

      return AuthResult(
        success: false,
        message: errorMessage,
      );
    } catch (e) {
      // Handle any other errors
      if (kDebugMode) {
        print('Unexpected error during sign up: $e');
      }

      return AuthResult(
        success: false,
        message: 'An unexpected error occurred. Please try again.',
      );
    }
  }

  /// Sign in an existing user with email and password
  ///
  /// Parameters:
  /// - [email]: User's email address
  /// - [password]: User's password
  ///
  /// Returns:
  /// - [AuthResult]: Contains success status and user data or error message
  Future<AuthResult> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      // Validate input parameters
      if (email.isEmpty || password.isEmpty) {
        return AuthResult(
          success: false,
          message: 'Email and password are required',
        );
      }

      // Sign in user with Firebase Auth
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Update user login status in database
      if (userCredential.user != null) {
        await _databaseService.updateUserLoginStatus(
            userCredential.user!.uid, true);
      }

      if (kDebugMode) {
        print('User signed in successfully: ${userCredential.user?.email}');
      }

      return AuthResult(
        success: true,
        message: 'Signed in successfully!',
        user: userCredential.user,
      );
    } on FirebaseAuthException catch (e) {
      // Handle Firebase Auth specific errors
      String errorMessage = _getFirebaseErrorMessage(e.code);

      if (kDebugMode) {
        print('Firebase Auth Error: ${e.code} - ${e.message}');
      }

      return AuthResult(
        success: false,
        message: errorMessage,
      );
    } catch (e) {
      // Handle any other errors
      if (kDebugMode) {
        print('Unexpected error during sign in: $e');
      }

      return AuthResult(
        success: false,
        message: 'An unexpected error occurred. Please try again.',
      );
    }
  }

  /// Sign out the current user
  ///
  /// Returns:
  /// - [AuthResult]: Contains success status and message
  Future<AuthResult> signOut() async {
    try {
      // Update user login status in database before signing out
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        await _databaseService.updateUserLoginStatus(currentUser.uid, false);
      }

      await _auth.signOut();

      if (kDebugMode) {
        print('User signed out successfully');
      }

      return AuthResult(
        success: true,
        message: 'Signed out successfully',
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error during sign out: $e');
      }

      return AuthResult(
        success: false,
        message: 'Error signing out. Please try again.',
      );
    }
  }

  /// Send password reset email
  ///
  /// Parameters:
  /// - [email]: User's email address
  ///
  /// Returns:
  /// - [AuthResult]: Contains success status and message
  Future<AuthResult> sendPasswordResetEmail(String email) async {
    try {
      if (email.isEmpty) {
        return AuthResult(
          success: false,
          message: 'Email address is required',
        );
      }

      await _auth.sendPasswordResetEmail(email: email.trim());

      if (kDebugMode) {
        print('Password reset email sent to: $email');
      }

      return AuthResult(
        success: true,
        message: 'Password reset email sent! Check your inbox.',
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = _getFirebaseErrorMessage(e.code);

      if (kDebugMode) {
        print('Firebase Auth Error: ${e.code} - ${e.message}');
      }

      return AuthResult(
        success: false,
        message: errorMessage,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected error during password reset: $e');
      }

      return AuthResult(
        success: false,
        message: 'An unexpected error occurred. Please try again.',
      );
    }
  }

  /// Delete the current user account
  /// Note: This requires recent authentication
  ///
  /// Returns:
  /// - [AuthResult]: Contains success status and message
  Future<AuthResult> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return AuthResult(
          success: false,
          message: 'No user is currently signed in',
        );
      }

      await user.delete();

      if (kDebugMode) {
        print('User account deleted successfully');
      }

      return AuthResult(
        success: true,
        message: 'Account deleted successfully',
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = _getFirebaseErrorMessage(e.code);

      if (kDebugMode) {
        print('Firebase Auth Error: ${e.code} - ${e.message}');
      }

      return AuthResult(
        success: false,
        message: errorMessage,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected error during account deletion: $e');
      }

      return AuthResult(
        success: false,
        message: 'An unexpected error occurred. Please try again.',
      );
    }
  }

  /// Convert Firebase Auth error codes to user-friendly messages
  ///
  /// Parameters:
  /// - [errorCode]: Firebase Auth error code
  ///
  /// Returns:
  /// - [String]: User-friendly error message
  String _getFirebaseErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No account found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled. Please contact support.';
      case 'requires-recent-login':
        return 'This operation requires recent authentication. Please sign in again.';
      case 'invalid-credential':
        return 'Invalid email or password. Please check your credentials.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}

/// AuthResult class to encapsulate authentication operation results
/// This class provides a consistent way to handle success and error states
class AuthResult {
  /// Whether the operation was successful
  final bool success;

  /// Message describing the result (success message or error message)
  final String message;

  /// User object if the operation was successful and returned a user
  final User? user;

  /// Constructor for AuthResult
  ///
  /// Parameters:
  /// - [success]: Whether the operation was successful
  /// - [message]: Descriptive message about the result
  /// - [user]: Optional user object for successful authentication operations
  AuthResult({
    required this.success,
    required this.message,
    this.user,
  });

  /// Convert AuthResult to string for debugging
  @override
  String toString() {
    return 'AuthResult(success: $success, message: $message, user: ${user?.email})';
  }
}
