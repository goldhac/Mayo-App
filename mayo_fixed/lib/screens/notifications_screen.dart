import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Modern notifications screen with standard features
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Messages', 'Sessions', 'System', 'Partner'];
  
  // Sample notification data - in real app this would come from a service
  List<NotificationItem> _notifications = [
    NotificationItem(
      id: '1',
      title: 'New message from Sarah',
      message: 'Hey! How are you feeling today?',
      type: NotificationType.message,
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      isRead: false,
      avatarText: 'S',
    ),
    NotificationItem(
      id: '2',
      title: 'Session reminder',
      message: 'Your couples therapy session starts in 30 minutes',
      type: NotificationType.session,
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      isRead: false,
    ),
    NotificationItem(
      id: '3',
      title: 'Partner linked successfully',
      message: 'Mark has been linked as your partner',
      type: NotificationType.partner,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: true,
      avatarText: 'M',
    ),
    NotificationItem(
      id: '4',
      title: 'Mood tracking reminder',
      message: 'Don\'t forget to log your mood for today',
      type: NotificationType.system,
      timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      isRead: true,
    ),
    NotificationItem(
      id: '5',
      title: 'New message from Mark',
      message: 'I\'m ready for our session today',
      type: NotificationType.message,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
      avatarText: 'M',
    ),
  ];

  List<NotificationItem> get _filteredNotifications {
    if (_selectedFilter == 'All') return _notifications;
    
    NotificationType? filterType;
    switch (_selectedFilter) {
      case 'Messages':
        filterType = NotificationType.message;
        break;
      case 'Sessions':
        filterType = NotificationType.session;
        break;
      case 'System':
        filterType = NotificationType.system;
        break;
      case 'Partner':
        filterType = NotificationType.partner;
        break;
    }
    
    return _notifications.where((n) => n.type == filterType).toList();
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.grey[200],
          ),
        ),
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text(
                'Mark all read',
                style: TextStyle(
                  color: Color(0xFF6B46C1),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black54),
            onSelected: (value) {
              if (value == 'clear_all') {
                _showClearAllDialog();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear_all',
                child: Row(
                  children: [
                    Icon(Icons.clear_all, size: 20, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Clear all'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter tabs
          Container(
            height: 50,
            color: Colors.white,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = _selectedFilter == filter;
                
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: FilterChip(
                    label: Text(
                      filter,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black54,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    backgroundColor: Colors.grey[100],
                    selectedColor: const Color(0xFF6B46C1),
                    checkmarkColor: Colors.white,
                    elevation: 0,
                    pressElevation: 2,
                  ),
                );
              },
            ),
          ),
          
          // Notifications list
          Expanded(
            child: _filteredNotifications.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredNotifications.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final notification = _filteredNotifications[index];
                      return _buildNotificationCard(notification);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(NotificationItem notification) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 24,
        ),
      ),
      onDismissed: (direction) {
        _deleteNotification(notification.id);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: notification.isRead 
              ? Border.all(color: Colors.grey[200]!) 
              : Border.all(color: const Color(0xFF6B46C1), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _markAsRead(notification.id),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar or icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getNotificationColor(notification.type),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: notification.avatarText != null
                        ? Center(
                            child: Text(
                              notification.avatarText!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          )
                        : Icon(
                            _getNotificationIcon(notification.type),
                            color: Colors.white,
                            size: 24,
                          ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: TextStyle(
                                  fontWeight: notification.isRead 
                                      ? FontWeight.w500 
                                      : FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            if (!notification.isRead)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF6B46C1),
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notification.message,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _formatTimestamp(notification.timestamp),
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _selectedFilter == 'All' 
                ? 'No notifications yet'
                : 'No $_selectedFilter notifications',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'ll see notifications here when they arrive',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.message:
        return const Color(0xFF6B46C1);
      case NotificationType.session:
        return Colors.green;
      case NotificationType.system:
        return Colors.orange;
      case NotificationType.partner:
        return Colors.pink;
    }
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.message:
        return Icons.chat_bubble;
      case NotificationType.session:
        return Icons.event;
      case NotificationType.system:
        return Icons.settings;
      case NotificationType.partner:
        return Icons.people;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(timestamp);
    }
  }

  void _markAsRead(String id) {
    setState(() {
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
      }
    });
  }

  void _markAllAsRead() {
    setState(() {
      _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    });
  }

  void _deleteNotification(String id) {
    setState(() {
      _notifications.removeWhere((n) => n.id == id);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Notification deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            // In a real app, you'd restore the notification here
          },
        ),
      ),
    );
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear all notifications?'),
        content: const Text(
          'This action cannot be undone. All notifications will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _notifications.clear();
              });
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Clear all'),
          ),
        ],
      ),
    );
  }
}

/// Notification item model
class NotificationItem {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;
  final String? avatarText;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    required this.isRead,
    this.avatarText,
  });

  NotificationItem copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    DateTime? timestamp,
    bool? isRead,
    String? avatarText,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      avatarText: avatarText ?? this.avatarText,
    );
  }
}

/// Notification types
enum NotificationType {
  message,
  session,
  system,
  partner,
}