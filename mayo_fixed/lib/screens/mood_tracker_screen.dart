import 'package:flutter/material.dart';
import 'package:mayo_fixed/services/database_service.dart';
import 'package:mayo_fixed/widgets/custom_bottom_navigation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

/// MoodTrackerScreen - A dedicated screen for tracking and visualizing mood data
class MoodTrackerScreen extends StatefulWidget {
  const MoodTrackerScreen({super.key});

  @override
  State<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends State<MoodTrackerScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // State variables
  bool _isLoading = true;
  List<Map<String, dynamic>> _moodHistory = [];
  String _selectedFilter = 'Last 7 Days';
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  // Chart data
  List<double> _weeklyMoodData = [0, 0, 0, 0, 0, 0, 0];

  @override
  void initState() {
    super.initState();
    _loadMoodData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  /// Load mood data from Firebase
  Future<void> _loadMoodData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        // Get mood entries from database
        final moodEntries = await _databaseService.getMoodEntries(userId);

        // Sort by date (newest first)
        moodEntries.sort(
            (a, b) => (b['timestamp'] as int).compareTo(a['timestamp'] as int));

        // Apply filter
        final filteredEntries = _filterMoodEntries(moodEntries);

        // Update state
        setState(() {
          _moodHistory = filteredEntries;
          _isLoading = false;
          _updateChartData(moodEntries);
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading mood data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Filter mood entries based on selected filter
  List<Map<String, dynamic>> _filterMoodEntries(
      List<Map<String, dynamic>> entries) {
    final now = DateTime.now();
    final searchText = _searchController.text.toLowerCase();

    return entries.where((entry) {
      // Apply date filter
      final entryDate =
          DateTime.fromMillisecondsSinceEpoch(entry['timestamp'] as int);
      bool passesDateFilter = true;

      if (_selectedFilter == 'Last 7 Days') {
        final weekAgo = now.subtract(const Duration(days: 7));
        passesDateFilter = entryDate.isAfter(weekAgo);
      } else if (_selectedFilter == 'Last 30 Days') {
        final monthAgo = now.subtract(const Duration(days: 30));
        passesDateFilter = entryDate.isAfter(monthAgo);
      } else if (_selectedFilter == 'Last 90 Days') {
        final threeMonthsAgo = now.subtract(const Duration(days: 90));
        passesDateFilter = entryDate.isAfter(threeMonthsAgo);
      }

      // Apply search filter
      bool passesSearchFilter = true;
      if (searchText.isNotEmpty) {
        final dateStr = DateFormat('MM/dd').format(entryDate).toLowerCase();
        final note = (entry['note'] as String? ?? '').toLowerCase();
        passesSearchFilter =
            dateStr.contains(searchText) || note.contains(searchText);
      }

      return passesDateFilter && passesSearchFilter;
    }).toList();
  }

  /// Update chart data based on mood entries
  void _updateChartData(List<Map<String, dynamic>> entries) {
    // Initialize with zeros
    final weeklyData = List<double>.filled(7, 0);
    final counts = List<int>.filled(7, 0);

    // Get date for 7 days ago
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 6));
    final startDate = DateTime(weekAgo.year, weekAgo.month, weekAgo.day);

    // Process entries
    for (final entry in entries) {
      final timestamp = entry['timestamp'] as int;
      final entryDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final rating = entry['rating'] as int;

      // Only include entries from the last 7 days
      if (entryDate.isAfter(startDate) ||
          entryDate.isAtSameMomentAs(startDate)) {
        final dayDiff = entryDate.difference(startDate).inDays;
        if (dayDiff >= 0 && dayDiff < 7) {
          // Normalize rating to 0-1 range (1=sad, 2=neutral, 3=happy)
          final normalizedRating = (rating / 3);
          weeklyData[dayDiff] += normalizedRating;
          counts[dayDiff]++;
        }
      }
    }

    // Calculate averages
    for (int i = 0; i < 7; i++) {
      if (counts[i] > 0) {
        weeklyData[i] = weeklyData[i] / counts[i];
      }
    }

    setState(() {
      _weeklyMoodData = weeklyData;
    });
  }

  /// Add a new mood entry
  Future<void> _addMoodEntry(int rating) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        // Show dialog for adding note
        await _showAddNoteDialog();

        // Create entry
        final entry = {
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'rating': rating,
          'note': _noteController.text,
        };

        // Add to database
        await _databaseService.addMoodEntry(userId, entry);

        // Clear note
        _noteController.clear();

        // Reload data
        await _loadMoodData();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mood entry added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding mood entry: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Show dialog for adding a note to mood entry
  Future<void> _showAddNoteDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add a Note'),
          content: TextField(
            controller: _noteController,
            decoration: const InputDecoration(
              hintText: 'How are you feeling? (optional)',
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  /// Export mood data as CSV
  Future<void> _exportMoodData() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        // Get all mood entries
        final entries = await _databaseService.getMoodEntries(userId);

        // Convert to CSV
        List<List<dynamic>> csvData = [];
        // Add header row
        csvData.add(['Date', 'Time', 'Mood', 'Note']);

        // Add data rows
        for (var entry in entries) {
          final date =
              DateTime.fromMillisecondsSinceEpoch(entry['timestamp'] as int);
          final dateStr = DateFormat('MM/dd/yyyy').format(date);
          final timeStr = DateFormat('HH:mm').format(date);
          final rating = entry['rating'] as int;
          final moodStr =
              rating == 1 ? 'Sad' : (rating == 2 ? 'Neutral' : 'Happy');
          final note = entry['note'] as String? ?? '';
          csvData.add([dateStr, timeStr, moodStr, note]);
        }

        // Generate CSV string
        final csv = const ListToCsvConverter().convert(csvData);

        // Save to temporary file
        final directory = await getTemporaryDirectory();
        final file = File('${directory.path}/mood_data.csv');
        await file.writeAsString(csv);

        // Share file
        await Share.shareFiles(
          [file.path],
          text: 'My Mood Data',
          subject: 'Mood Data Export',
        );
      }
    } catch (e) {
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error exporting mood data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Build mood history list
  Widget _buildMoodHistoryList() {
    if (_moodHistory.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'No mood entries found. Start tracking your mood!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _moodHistory.length,
      itemBuilder: (context, index) {
        final entry = _moodHistory[index];
        final timestamp = entry['timestamp'] as int;
        final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
        final dateStr = DateFormat('MM/dd').format(date);
        final rating = entry['rating'] as int;
        final note = entry['note'] as String? ?? '';

        // Determine emoji based on rating
        String emoji;
        if (rating == 1) {
          emoji = '😔'; // Sad
        } else if (rating == 2) {
          emoji = '😐'; // Neutral
        } else {
          emoji = '😊'; // Happy
        }

        // Determine mood text
        String moodText;
        if (rating == 1) {
          moodText = 'Sad';
        } else if (rating == 2) {
          moodText = 'Neutral';
        } else {
          moodText = 'Happy';
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade100, width: 1),
          ),
          child: Padding(
            padding: EdgeInsets.zero,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Emoji
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: rating == 1
                        ? Colors.blue.shade50
                        : (rating == 2
                            ? Colors.amber.shade50
                            : Colors.green.shade50),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: rating == 1
                          ? Colors.blue.shade200
                          : (rating == 2
                              ? Colors.amber.shade200
                              : Colors.green.shade200),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            moodText,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: rating == 1
                                  ? Colors.blue.shade700
                                  : (rating == 2
                                      ? Colors.amber.shade700
                                      : Colors.green.shade700),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: rating == 1
                                  ? Colors.blue.shade50
                                  : (rating == 2
                                      ? Colors.amber.shade50
                                      : Colors.green.shade50),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: rating == 1
                                    ? Colors.blue.shade200
                                    : (rating == 2
                                        ? Colors.amber.shade200
                                        : Colors.green.shade200),
                                width: 0.5,
                              ),
                            ),
                            child: Text(
                              DateFormat('HH:mm').format(date),
                              style: TextStyle(
                                color: rating == 1
                                    ? Colors.blue.shade600
                                    : (rating == 2
                                        ? Colors.amber.shade600
                                        : Colors.green.shade600),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateStr,
                        style: TextStyle(color: Colors.grey[500], fontSize: 14),
                      ),
                      if (note.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(note),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Mood Tracker',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.grey[50],
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Mood selection section
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 16.0),
                    child: const Text(
                      'Track how you\'re feeling each day and see\nyour progress over time.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Mood buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildMoodButton('Happy', 3, '😊'),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMoodButton('Neutral', 2, '😐'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Center(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.4,
                        child: _buildMoodButton('Sad', 1, '😔'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Mood chart section
                  _buildMoodChart(),
                  const SizedBox(height: 24),

                  // History section
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'History',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        _buildFilterDropdown(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Search bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search by date or note...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Mood history list
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: _buildMoodHistoryList(),
                  ),
                  const SizedBox(height: 24),

                  // Export button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _exportMoodData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          foregroundColor: Colors.black87,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text('Export Mood Data'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: 2, // Mood tracker is the 3rd tab
        onTap: (index) {
          // Handle navigation
          if (index != 2) {
            // Pop current screen first to return to previous screen
            Navigator.of(context).pop();
            
            // Additional navigation logic is handled by the HomeScreen
            // when we return there, based on the index selected
          }
        },
      ),
    );
  }

  /// Build mood selection button
  Widget _buildMoodButton(String label, int rating, String emoji) {
    return ElevatedButton(
      onPressed: () => _addMoodEntry(rating),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: rating == 1
            ? Colors.blue.shade600
            : (rating == 2 ? Colors.amber.shade600 : Colors.green.shade600),
        elevation: 0,
        shadowColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: rating == 1
                ? Colors.blue.shade200
                : (rating == 2 ? Colors.amber.shade200 : Colors.green.shade200),
            width: 1.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  /// Build mood chart
  Widget _buildMoodChart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'Mood Chart',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
          child: Text(
            'Past 7 Days',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ),
        Container(
          height: 180,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 1,
              minY: 0,
              groupsSpace: 12,
              barTouchData: BarTouchData(enabled: false),
              titlesData: FlTitlesData(
                show: true,
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barGroups: _weeklyMoodData.asMap().entries.map((entry) {
                final index = entry.key;
                final value = entry.value;

                // Determine bar color based on value
                Color barColor;
                if (value <= 0.4) {
                  barColor = Colors.blue; // Sad
                } else if (value <= 0.7) {
                  barColor = Colors.amber; // Neutral
                } else {
                  barColor = Colors.green; // Happy
                }

                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: value > 0
                          ? value
                          : 0.05, // Minimum bar height for visibility
                      color: barColor,
                      width: 20,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
        // Day labels
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text('Mon',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              Text('Tue',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              Text('Wed',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              Text('Thu',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              Text('Fri',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              Text('Sat',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              Text('Sun',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  /// Build filter dropdown
  Widget _buildFilterDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(30),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedFilter,
          icon: const Icon(Icons.keyboard_arrow_down),
          iconSize: 24,
          elevation: 0,
          style: const TextStyle(color: Colors.black87, fontSize: 14),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedFilter = newValue;
                _loadMoodData();
              });
            }
          },
          items: <String>['Last 7 Days', 'Last 30 Days', 'Last 90 Days']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }
}
