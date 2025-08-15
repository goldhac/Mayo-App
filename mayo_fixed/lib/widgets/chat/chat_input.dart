import 'package:flutter/material.dart';

/// Reusable chat input widget for sending messages
class ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final String hintText;
  final bool enabled;
  final Color? backgroundColor;
  final Color? sendButtonColor;
  
  const ChatInput({
    Key? key,
    required this.controller,
    required this.onSend,
    this.hintText = 'Type a message...',
    this.enabled = true,
    this.backgroundColor,
    this.sendButtonColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              decoration: InputDecoration(
                hintText: hintText,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: enabled ? (_) => onSend() : null,
            ),
          ),
          const SizedBox(width: 12),
          FloatingActionButton(
            onPressed: enabled ? onSend : null,
            backgroundColor: enabled 
                ? (sendButtonColor ?? Colors.blue[600]) 
                : Colors.grey[400],
            mini: true,
            child: const Icon(
              Icons.send,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}