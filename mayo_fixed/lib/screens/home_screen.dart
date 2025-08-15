import 'package:flutter/material.dart';
import 'package:mayo_fixed/services/auth_service.dart';
import 'package:mayo_fixed/services/database_service.dart';
import 'package:mayo_fixed/screens/mood_tracker_screen.dart';
import 'package:mayo_fixed/screens/profile_screen.dart';
import 'package:mayo_fixed/screens/couples_chat_screen.dart';
import 'package:mayo_fixed/screens/notifications_screen.dart';
import 'package:mayo_fixed/widgets/greeting_header.dart';
import 'package:mayo_fixed/widgets/new_session_card.dart';
import 'package:mayo_fixed/widgets/session_history_item.dart';
import 'package:mayo_fixed/widgets/mood_tracking_section.dart';

import 'package:mayo_fixed/widgets/shimmer_widgets.dart';
import 'package:mayo_fixed/screens/onboarding_screens/onboarding_screen.dart';

/// HomeScreen - The main screen users see after successful authentication
/// This screen displays a welcome message and provides logout functionality
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();
  
  // State variables
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  bool _isLogoutLoading = false;
  String? _currentSessionId;
  
  // Helper method to get time of day for greeting
  String _getTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Morning';
    } else if (hour < 17) {
      return 'Afternoon';
    } else {
      return 'Evening';
    }
  }
  List<Map<String, dynamic>> recentSessions = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadRecentSessions();
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

  void _loadRecentSessions() async {
    // Mock data for recent sessions - replace with actual database call
    if (mounted) {
      setState(() {
        recentSessions = [
          {
            'date': 'July 20, 2024',
            'type': 'Solo',
            'avatarUrl': null,
            'moodRating': 3, // Happy mood
          },
          {
            'date': 'July 15, 2024',
            'type': 'Couples',
            'avatarUrl': null,
            'moodRating': 2, // Neutral mood
          },
          {
            'date': 'July 10, 2024',
            'type': 'Solo',
            'avatarUrl': null,
            'moodRating': 1, // Sad mood
          },
          {
            'date': 'July 5, 2024',
            'type': 'Couples',
            'avatarUrl': null,
            'moodRating': 3, // Happy mood
          },
        ];
      });
    }
  }

  /// Start a new session - shows dialog to choose session type
  Future<void> _startSession() async {
    final user = _authService.currentUser;
    if (user == null) return;
    
    // Get user data to check if they have a partner
    final userResult = await _databaseService.getUserData(user.uid);
    if (!userResult.success || userResult.data == null) {
      _showError('Failed to load user data');
      return;
    }
    
    final userData = userResult.data as Map<String, dynamic>;
    final hasPartner = userData['partnerId'] != null;
    
    // Show session type selection dialog
    final sessionType = await _showSessionTypeDialog(hasPartner);
    if (sessionType == null) return;
    
    if (sessionType == 'couples_chat') {
      // Navigate to couples chat screen
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CouplesChatScreen(
              partnerId: userData['partnerId'],
            ),
          ),
        );
      }
    } else {
      // Create individual session (existing functionality)
      final result = await _databaseService.createSession(
        userId: user.uid,
        sessionType: 'individual',
      );
      if (result.success && result.data != null) {
        setState(() {
          _currentSessionId = result.data!['sessionId'];
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Solo session started successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        _showError(result.message);
      }
    }
  }
  
  /// Show session type selection dialog
  Future<String?> _showSessionTypeDialog(bool hasPartner) async {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose Session Type'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.person, color: Color(0xFF6B46C1)),
                title: const Text('Solo Session'),
                subtitle: const Text('Chat with AI therapist alone'),
                onTap: () => Navigator.of(context).pop('individual'),
              ),
              if (hasPartner)
                ListTile(
                  leading: const Icon(Icons.people, color: Color(0xFF6B46C1)),
                  title: const Text('Couples Chat'),
                  subtitle: const Text('Chat with your partner'),
                  onTap: () => Navigator.of(context).pop('couples_chat'),
                )
              else
                ListTile(
                  leading: const Icon(Icons.people, color: Colors.grey),
                  title: const Text('Couples Chat'),
                  subtitle: const Text('Link with a partner first'),
                  enabled: false,
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
  
  /// Show error message
  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// End current session
  Future<void> _endSession() async {
    if (_currentSessionId != null) {
      final result = await _databaseService.endSession(_currentSessionId!);
      if (result.success) {
        if (mounted) {
          setState(() {
            _currentSessionId = null;
          });
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Session ended successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
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

  /// Add mood data to current session
  Future<void> _addMoodData() async {
    if (_currentSessionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please start a session first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Show mood rating dialog
    final rating = await _showMoodDialog();
    if (rating != null) {
      final user = _authService.currentUser;
      if (user == null) return;

      final result = await _databaseService.saveMoodEntry(
        userId: user.uid,
        mood: rating,
        notes: 'Mood recorded from home screen',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: result.success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  /// Show mood rating dialog
  Future<int?> _showMoodDialog() async {
    int selectedRating = 5;

    return showDialog<int>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.grey.shade900,
          title: const Text(
            'How are you feeling?',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Rate your mood from 1 (very sad) to 10 (very happy)',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 20),
              Slider(
                value: selectedRating.toDouble(),
                min: 1,
                max: 10,
                divisions: 9,
                label: selectedRating.toString(),
                activeColor: Colors.deepPurple,
                onChanged: (value) {
                  setDialogState(() {
                    selectedRating = value.round();
                  });
                },
              ),
              Text(
                'Rating: $selectedRating',
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(selectedRating),
              child: const Text(
                'Save',
                style: TextStyle(color: Colors.deepPurple),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show partner code dialog
  Future<void> _showPartnerCode() async {
    final user = _authService.currentUser;
    if (user != null) {
      final result = await _databaseService.generatePartnerCode(user.uid);
      if (result.success && result.data != null) {
        final partnerCode = result.data!['partnerCode'];
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: Colors.grey.shade900,
              title: const Text(
                'Your Partner Code',
                style: TextStyle(color: Colors.white),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Copy and share this code with your partner:',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.deepPurple),
                    ),
                    child: SelectableText(
                      partnerCode,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Close',
                    style: TextStyle(color: Colors.deepPurple),
                  ),
                ),
              ],
            ),
          );
        }
      }
    }
  }

  /// Handle user logout process
  Future<void> _handleLogout() async {
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

    if (shouldLogout == true) {
      setState(() {
        _isLogoutLoading = true;
      });

      try {
        final result = await _authService.signOut();

        if (mounted) {
          if (result.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result.message),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );

            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const OnboardingScreen(),
              ),
              (route) => false,
            );
          } else {
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
        if (mounted) {
          setState(() {
            _isLogoutLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey[100],
        body: SafeArea(
          child: SingleChildScrollView(
            child: ShimmerLayouts.homeContent(),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting Header
                    GreetingHeader(
                      greeting: 'Good ${_getTimeOfDay()}',
                      userName: _userData?['nickname'] ?? _userData?['name']?.split(' ')[0] ?? 'User',
                      onNotificationTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NotificationsScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // New Session Section
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: NewSessionCard(
                        toptext: "New Session",
                        title: 'Start solo or couples chat',
                        subtitle: 'Begin',
                        onTap: _startSession,
                        icon: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            'assets/brain_image.png',
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Recent Sessions Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Recent Sessions',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6B46C1),
                            ),
                          ),
                          const SizedBox(height: 16),
                    ...recentSessions.map((session) => SessionHistoryItem(
                          date: session['date'],
                          type: session['type'],
                          // Determine if session is solo based on type or other criteria
                          isSolo: session['type']?.toLowerCase().contains('solo') ?? true,
                          // Mood rating from session data (1=sad, 2=neutral, 3=happy)
                          moodRating: session['moodRating'] ?? 2, // Default to neutral
                          onTap: () {
                            // Handle session tap
                          },
                          onMoreTap: () {
                            // Handle more options
                          },
                        )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Mood Tracking Section
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: MoodTrackingSection(
                        monthTitle: 'This Months Mood',
                        weekTitle: 'This Week\'s Mood',
                        moodPercentage: 75,
                        weeklyChange: '+10%',
                        weeklyData: [0.6, 0.8, 0.4, 0.9, 0.7, 0.5, 0.8],
                        onTap: () {
                          // Navigate to mood tracker screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MoodTrackerScreen(),
                            ),
                          );
                        },
                      ),
                    ),
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
}
