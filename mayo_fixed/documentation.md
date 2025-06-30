# Mayo App Documentation

## Mayo Authentication

### Overview

The Mayo app implements a comprehensive Firebase-based authentication system with a reactive architecture that provides seamless user experience and robust security. The authentication flow is designed around automatic state management and centralized service handling.

### Architecture Components

#### 1. File Structure
```
lib/
├── main.dart                    # App entry point with AuthWrapper
├── services/
│   └── auth_service.dart       # Centralized Firebase Auth operations
├── screens/
│   ├── authentication/
│   │   ├── sign_in_screen.dart # Sign-in interface
│   │   └── sign_up_screen.dart # Registration interface
│   ├── onboarding_screen.dart  # Welcome/landing page
│   └── home_screen.dart        # Main app interface
└── widgets/
    └── full_width_button.dart  # Reusable button component
```

#### 2. AuthWrapper (main.dart)

The `AuthWrapper` is the core component that manages authentication state reactively:

```dart
class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        if (snapshot.hasData) {
          return const HomeScreen();
        } else {
          return const OnboardingScreen();
        }
      },
    );
  }
}
```

**Key Features:**
- **Reactive Design**: Uses `StreamBuilder` to listen to Firebase Auth state changes
- **Automatic Navigation**: No manual navigation needed - responds to auth state automatically
- **Loading States**: Shows loading indicator during authentication checks
- **Clean Separation**: Separates authentication logic from UI components

#### 3. AuthService (services/auth_service.dart)

Centralized service handling all Firebase Authentication operations:

```dart
class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Stream for reactive authentication state
  static Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  // Current user getter
  static User? get currentUser => _auth.currentUser;
  
  // Sign in with email and password
  static Future<AuthResult> signInWithEmailAndPassword(String email, String password) async {
    // Implementation with error handling
  }
  
  // Register new user
  static Future<AuthResult> signUpWithEmailAndPassword(String email, String password, String displayName) async {
    // Implementation with profile setup
  }
  
  // Sign out
  static Future<void> signOut() async {
    await _auth.signOut();
  }
}
```

**Key Features:**
- **Static Methods**: Easy access throughout the app
- **Error Handling**: Comprehensive error catching and user-friendly messages
- **Profile Management**: Automatic display name setup during registration
- **Email Verification**: Sends verification emails for new accounts

### Authentication Flow

#### Sign-In Process
1. User enters credentials in `SignInScreen`
2. Form validation ensures data integrity
3. `AuthService.signInWithEmailAndPassword()` called
4. Firebase processes authentication
5. `AuthWrapper`'s `StreamBuilder` detects state change
6. User automatically navigated to `HomeScreen`

#### Sign-Up Process
1. User fills registration form in `SignUpScreen`
2. Password confirmation and validation performed
3. `AuthService.signUpWithEmailAndPassword()` called
4. Firebase creates account and sets display name
5. Email verification sent automatically
6. User automatically signed in and navigated to `HomeScreen`
7. No manual navigation to sign-in screen needed

#### Logout Process
1. User triggers logout action
2. `AuthService.signOut()` called
3. `AuthWrapper` detects state change
4. User automatically redirected to `OnboardingScreen`

### Key Implementation Details

#### 1. Type Safety Fixes

Resolved Flutter/Dart type compatibility issues:

```dart
// Before (caused type errors)
onPressed: _handleSignIn,  // Future<void> Function() not assignable to void Function()

// After (fixed)
onPressed: () => _handleSignIn(),  // Wrapped in synchronous callback
```

#### 2. Automatic Navigation

Removed manual navigation calls from authentication screens:

```dart
// Removed from both sign-in and sign-up screens
// Navigator.pop(context);           // Manual navigation removed
// Navigator.pushReplacement(...);   // Manual navigation removed

// AuthWrapper now handles all navigation automatically
```

#### 3. Loading State Management

Implemented proper loading states during authentication:

```dart
bool _isLoading = false;

Future<void> _handleSignIn() async {
  setState(() => _isLoading = true);
  
  try {
    final result = await _authService.signInWithEmailAndPassword(email, password);
    if (!result.success) {
      // Show error message
    }
    // AuthWrapper handles navigation automatically
  } finally {
    setState(() => _isLoading = false);
  }
}
```

### Security Features

1. **Input Validation**: Email format and password strength validation
2. **Error Handling**: Secure error messages that don't expose system details
3. **Email Verification**: Automatic verification emails for new accounts
4. **State Protection**: Authentication state managed securely by Firebase
5. **Session Management**: Automatic session handling and persistence

### UI/UX Features

1. **Loading Indicators**: Visual feedback during authentication operations
2. **Password Visibility**: Toggle for password field visibility
3. **Form Validation**: Real-time validation with user-friendly error messages
4. **Responsive Design**: Consistent button styling with `FullWidthButton` widget
5. **Seamless Navigation**: No jarring transitions - automatic state-based navigation

### Benefits of This Architecture

1. **Separation of Concerns**: Authentication logic separated from UI components
2. **Reactive Design**: UI automatically responds to authentication state changes
3. **Centralized Logic**: All auth operations handled in one service
4. **Error Resilience**: Comprehensive error handling at multiple levels
5. **User Experience**: Smooth, automatic navigation without manual intervention
6. **Maintainability**: Clean, modular code structure easy to modify and extend
7. **Type Safety**: Proper Dart type handling prevents runtime errors
8. **Scalability**: Easy to add new authentication methods (Google, Apple, etc.)

### Technical Implementation Notes

- **Async/Await Patterns**: Proper handling of asynchronous operations
- **State Management**: Uses Flutter's built-in `setState` for local state
- **Stream Handling**: Leverages Firebase Auth streams for reactive updates
- **Widget Communication**: Clean separation between widgets and services
- **Error Propagation**: Structured error handling from service to UI

This authentication system provides a robust, user-friendly, and maintainable foundation for the Mayo app's user management needs.