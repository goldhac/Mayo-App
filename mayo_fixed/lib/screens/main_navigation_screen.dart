import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'couples_chat_screen.dart';
import 'mood_tracker_screen.dart';
import 'profile_screen.dart';
import '../widgets/custom_bottom_navigation.dart';

/// Main navigation screen that manages all bottom navigation tabs
/// This prevents navigation stack issues by using a single screen with tab switching
class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;
  
  const MainNavigationScreen({
    Key? key,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: const [
          HomeScreenContent(), // Home content without bottom navigation
          HomeScreenContent(), // Sessions (for now, same as home)
          CouplesChatScreenContent(), // Chat content without bottom navigation
          MoodTrackerScreenContent(), // Mood content without bottom navigation
          ProfileScreenContent(), // Profile content without bottom navigation
        ],
      ),
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}

/// Wrapper for HomeScreen content without bottom navigation
class HomeScreenContent extends StatelessWidget {
  const HomeScreenContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const HomeScreen();
  }
}

/// Wrapper for CouplesChatScreen content without bottom navigation
class CouplesChatScreenContent extends StatelessWidget {
  const CouplesChatScreenContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const CouplesChatScreen();
  }
}

/// Wrapper for MoodTrackerScreen content without bottom navigation
class MoodTrackerScreenContent extends StatelessWidget {
  const MoodTrackerScreenContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MoodTrackerScreen();
  }
}

/// Wrapper for ProfileScreen content without bottom navigation
class ProfileScreenContent extends StatelessWidget {
  const ProfileScreenContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const ProfileScreen();
  }
}