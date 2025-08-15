import 'package:flutter/material.dart';

/// Reusable chat header widget for displaying chat information
class ChatHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool isOnline;
  final VoidCallback? onInfoTap;
  final VoidCallback? onBackTap;
  final Color? backgroundColor;
  final Color? textColor;
  
  const ChatHeader({
    Key? key,
    required this.title,
    this.subtitle,
    this.isOnline = false,
    this.onInfoTap,
    this.onBackTap,
    this.backgroundColor,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: textColor ?? Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              style: TextStyle(
                color: (textColor ?? Colors.white).withOpacity(0.8),
                fontSize: 12,
              ),
            ),
        ],
      ),
      backgroundColor: backgroundColor ?? Colors.blue[600],
      foregroundColor: textColor ?? Colors.white,
      leading: onBackTap != null
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onBackTap,
            )
          : null,
      actions: [
        if (isOnline)
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'Last seen',
                  style: TextStyle(
                    color: (textColor ?? Colors.white).withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        if (onInfoTap != null)
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: onInfoTap,
          ),
      ],
    );
  }
}