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

## Home Screen & Session History

### Overview

The Mayo app's home screen provides a comprehensive dashboard for users to access their therapy sessions and view their session history. The interface features a modern, user-friendly design with personalized greetings, session management, and detailed session history cards.

### Architecture Components

#### 1. File Structure
```
lib/
├── screens/
│   └── home_screen.dart        # Main dashboard interface
└── widgets/
    └── session_history_item.dart # Reusable session history card
```

#### 2. Home Screen Features

**Personalized Welcome Section:**
- Dynamic greeting based on user's display name
- Time-aware greetings (Good morning, afternoon, evening)
- Motivational messaging for therapy engagement

**Session Management:**
- Quick access buttons for different session types
- Solo therapy sessions
- Couples therapy sessions
- Interactive AI-powered sessions

**Recent Sessions Display:**
- Scrollable list of recent therapy sessions
- Session type identification (Solo/Couples)
- Date and time information
- Mood tracking with emoji indicators

#### 3. Session History Item Widget

The `SessionHistoryItem` widget is a reusable component that displays individual session information:

```dart
class SessionHistoryItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSolo;
  final int moodRating;
  
  const SessionHistoryItem({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.isSolo,
    this.moodRating = 2, // Default to neutral
  }) : super(key: key);
}
```

**Key Features:**
- **Dynamic Avatar Display**: Shows different images based on session type
  - Solo sessions: `solo_session_image.png`
  - Couples sessions: `couples_image.png`
  - Fallback to default avatar on image load failure
- **Mood Emoji Integration**: Displays mood-based emojis
  - Rating 1: 😢 (Sad)
  - Rating 2: 😐 (Neutral)
  - Rating 3: 😊 (Happy)
- **Error Handling**: Robust image loading with fallback mechanisms
- **Consistent Styling**: Matches app's design language

### Asset Management

#### Image Assets
The app uses several image assets stored in the `assets/` directory:

```
assets/
├── brain_image.png              # Brain illustration
├── couples_image.png            # Couples session avatar
├── default_avatar.svg           # Fallback avatar
├── interactive_ai_sessions.png  # AI session illustration
├── solo_session_image.png       # Solo session avatar
└── welcome_illustration.png     # Welcome screen illustration
```

**Asset Loading Strategy:**
- Primary asset loading with error handling
- Fallback to default avatar on load failure
- Optimized asset paths for Flutter's asset system

### Data Management

#### Mock Data Structure
The home screen currently uses mock data for development and testing:

```dart
List<Map<String, dynamic>> recentSessions = [
  {
    'title': 'Solo Therapy Session',
    'subtitle': 'July 20, 2024 • 3:00 PM',
    'type': 'solo',
    'moodRating': 3, // Happy
  },
  {
    'title': 'Couples Therapy Session',
    'subtitle': 'July 15, 2024 • 2:00 PM',
    'type': 'couples',
    'moodRating': 2, // Neutral
  },
  // Additional sessions...
];
```

**Data Properties:**
- **title**: Session type description
- **subtitle**: Date and time information
- **type**: Session category (solo/couples)
- **moodRating**: User's mood rating (1-3 scale)

### UI/UX Implementation

#### 1. Responsive Design
- Adaptive layout for different screen sizes
- Consistent spacing and typography
- Material Design principles

#### 2. Visual Hierarchy
- Clear section separation
- Prominent call-to-action buttons
- Organized session history display

#### 3. Interactive Elements
- Tappable session cards
- Hover effects and visual feedback
- Smooth scrolling for session history

#### 4. Mood Visualization
- Color-coded mood emojis with light purple tint
- Intuitive mood representation
- Consistent emoji sizing and positioning

### Technical Implementation

#### 1. State Management
```dart
class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> recentSessions = [];
  
  @override
  void initState() {
    super.initState();
    _loadRecentSessions();
  }
  
  void _loadRecentSessions() {
    // Load mock data for development
    setState(() {
      recentSessions = [...]; // Mock session data
    });
  }
}
```

#### 2. Dynamic Content Rendering
```dart
// Session type determination
bool isSolo = session['type']?.toString().toLowerCase().contains('solo') ?? false;

// Mood emoji selection
Widget _buildMoodEmojis(int moodRating) {
  String emoji;
  switch (moodRating) {
    case 1: emoji = '😢'; break;
    case 3: emoji = '😊'; break;
    default: emoji = '😐'; break;
  }
  return Text(emoji, style: TextStyle(fontSize: 20));
}
```

#### 3. Error Handling
```dart
Image.asset(
  isSolo ? 'assets/solo_session_image.png' : 'assets/couples_image.png',
  errorBuilder: (context, error, stackTrace) {
    return Image.asset('assets/default_avatar.svg');
  },
)
```

### Future Enhancements

1. **Backend Integration**: Replace mock data with real session data from Firebase/API
2. **Advanced Mood Tracking**: Expand mood scale and add mood analytics
3. **Session Details**: Add detailed session view with notes and progress tracking
4. **Search and Filter**: Implement session search and filtering capabilities
5. **Offline Support**: Cache session data for offline viewing
6. **Push Notifications**: Session reminders and mood check-ins

### Benefits of This Implementation

1. **Modular Design**: Reusable `SessionHistoryItem` widget
2. **Scalable Architecture**: Easy to extend with new session types
3. **User-Centric**: Intuitive mood tracking and session visualization
4. **Error Resilient**: Robust image loading and fallback mechanisms
5. **Performance Optimized**: Efficient asset loading and state management
6. **Maintainable**: Clean separation of concerns and well-documented code

This home screen implementation provides a solid foundation for user engagement and session management in the Mayo therapy app.