import 'package:flutter/material.dart';

/// Modern message bubble widget for chat interfaces with classic design
class MessageBubble extends StatelessWidget {
  final String message;
  final String senderName;
  final bool isMe;
  final DateTime? timestamp;
  final Color? myMessageColor;
  final Color? otherMessageColor;
  
  const MessageBubble({
    Key? key,
    required this.message,
    required this.senderName,
    required this.isMe,
    this.timestamp,
    this.myMessageColor,
    this.otherMessageColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ..._buildAvatar(),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isMe)
                  Padding(
                    padding: const EdgeInsets.only(left: 12, bottom: 4),
                    child: Text(
                      senderName,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: isMe 
                        ? (myMessageColor ?? const Color(0xFF6B46C1))
                        : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isMe ? 20 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message,
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                if (timestamp != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 12, right: 12),
                    child: Text(
                      _formatTime(timestamp!),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black38,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (isMe) ..._buildAvatar(),
        ],
      ),
    );
  }
  
  List<Widget> _buildAvatar() {
    // Use first letter of sender name, or 'M' for Mayo (AI messages)
    String avatarLetter;
    if (isMe) {
      // For user messages, use first letter of their name
      avatarLetter = senderName.isNotEmpty ? senderName[0].toUpperCase() : 'U';
    } else {
      // For AI/Mayo messages, always use 'M'
      avatarLetter = 'M';
    }
    
    return [
      Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isMe ? const Color(0xFF6B46C1) : Colors.grey[300],
        ),
        child: Center(
          child: Text(
            avatarLetter,
            style: TextStyle(
              color: isMe ? Colors.white : Colors.black54,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    ];
  }
  
  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : hour;
    return '$displayHour:$minute';
  }
}