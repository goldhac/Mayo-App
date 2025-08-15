import 'package:flutter/material.dart';
import 'package:mayo_fixed/services/database_service.dart';
import 'package:mayo_fixed/widgets/shimmer_widgets.dart';

/// Widget that displays linked partner information and provides unlink functionality
/// 
/// This widget shows:
/// - Partner's profile picture (if available)
/// - Partner's name and nickname
/// - Unlink partner button
/// - Loading states and error handling
class LinkedPartnerWidget extends StatefulWidget {
  /// The current user's ID
  final String userId;
  
  /// The partner's user ID
  final String partnerId;
  
  /// Callback function called when partner is successfully unlinked
  final VoidCallback? onPartnerUnlinked;
  
  const LinkedPartnerWidget({
    super.key,
    required this.userId,
    required this.partnerId,
    this.onPartnerUnlinked,
  });

  @override
  State<LinkedPartnerWidget> createState() => _LinkedPartnerWidgetState();
}

class _LinkedPartnerWidgetState extends State<LinkedPartnerWidget> {
  final DatabaseService _databaseService = DatabaseService();
  
  bool _isLoading = true;
  bool _isUnlinking = false;
  Map<String, dynamic>? _partnerData;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPartnerData();
  }

  /// Load partner's data from database
  Future<void> _loadPartnerData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _databaseService.getUserData(widget.partnerId);
      if (result.success && result.data != null) {
        if (mounted) {
          setState(() {
            _partnerData = result.data as Map<String, dynamic>;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = result.message;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error loading partner data: $e';
          _isLoading = false;
        });
      }
    }
  }

  /// Handle unlinking from partner
  Future<void> _handleUnlinkPartner() async {
    // Show confirmation dialog
    final shouldUnlink = await _showUnlinkConfirmationDialog();
    if (!shouldUnlink) return;

    if (!mounted) return;
    setState(() {
      _isUnlinking = true;
      _errorMessage = null;
    });

    try {
      final result = await _databaseService.unlinkPartner(widget.userId);
      if (result.success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: Colors.green,
            ),
          );
        }
        // Call the callback to notify parent widget
        widget.onPartnerUnlinked?.call();
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = result.message;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error unlinking partner: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUnlinking = false;
        });
      }
    }
  }

  /// Show confirmation dialog before unlinking
  Future<bool> _showUnlinkConfirmationDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unlink Partner'),
        content: const Text(
          'Are you sure you want to unlink from your partner? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Unlink'),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return ShimmerLayouts.linkedPartner();
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: TextStyle(
                color: Colors.red.shade400,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPartnerData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_partnerData == null) {
      return const Center(
        child: Text('No partner data available'),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Header
          const Text(
            'Manage your linked partner to share the\nexperience',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          // Partner Profile Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.grey.shade200,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Profile Picture
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade300,
                  ),
                  child: _partnerData!['profilePicture'] != null &&
                          _partnerData!['profilePicture'].toString().isNotEmpty
                      ? ClipOval(
                          child: Image.network(
                            _partnerData!['profilePicture'],
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildDefaultAvatar();
                            },
                          ),
                        )
                      : _buildDefaultAvatar(),
                ),
                const SizedBox(width: 16),
                
                // Partner Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _partnerData!['name'] ?? 'Unknown',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Linked Partner',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      if (_partnerData!['nickname'] != null &&
                          _partnerData!['nickname'].toString().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'Nickname: ${_partnerData!['nickname']}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Unlink Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isUnlinking ? null : _handleUnlinkPartner,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade50,
                foregroundColor: Colors.red.shade700,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: Colors.red.shade200,
                    width: 1,
                  ),
                ),
              ),
              child: _isUnlinking
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.red.shade700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('Unlinking...'),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.link_off,
                          size: 18,
                          color: Colors.red.shade700,
                        ),
                        const SizedBox(width: 8),
                        const Text('Unlink Partner'),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build default avatar when no profile picture is available
  Widget _buildDefaultAvatar() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey.shade300,
      ),
      child: Icon(
        Icons.person,
        size: 30,
        color: Colors.grey.shade600,
      ),
    );
  }
}