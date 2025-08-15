import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';
import '../widgets/chat/message_bubble.dart';
import '../widgets/chat/chat_input.dart';
import '../widgets/chat/chat_header.dart';



class CouplesChatScreen extends StatefulWidget {
  final String? sessionId;
  final String? partnerId;

  const CouplesChatScreen({
    Key? key,
    this.sessionId,
    this.partnerId,
  }) : super(key: key);

  @override
  State<CouplesChatScreen> createState() => _CouplesChatScreenState();
}

class _CouplesChatScreenState extends State<CouplesChatScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final AuthService _authService = AuthService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String? _currentChatId;
  String? _partnerId;
  String? _partnerName;
  bool _isLoading = true;
  bool _isPartnerOnline = false;
  List<Map<String, dynamic>> _messages = [];
  StreamSubscription<QuerySnapshot>? _messagesSubscription;

  @override
  void initState() {
    super.initState();
    print('CouplesChatScreen initState called');
    _initializeChat();
  }

  @override
  void dispose() {
    print('CouplesChatScreen disposing - cancelling message subscription');
    _messageController.dispose();
    _scrollController.dispose();
    _messagesSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeChat() async {
    try {
      final user = _authService.currentUser;
      if (user == null) {
        _showError('User not authenticated');
        return;
      }

      // Get user data to find partner
      final userResult = await _databaseService.getUserData(user.uid);
      if (!userResult.success || userResult.data == null) {
        _showError('Failed to load user data');
        return;
      }

      final userData = userResult.data as Map<String, dynamic>;
      _partnerId = widget.partnerId ?? userData['partnerId'];

      if (_partnerId == null) {
        // For testing purposes, allow chat without a partner
        print('No partner found, creating demo chat session');
        _partnerId = 'demo_partner'; // Use a demo partner ID
        _partnerName = 'Demo Partner';
      } else {
        // Get partner data
        final partnerResult = await _databaseService.getUserData(_partnerId!);
        if (partnerResult.success && partnerResult.data != null) {
          final partnerData = partnerResult.data as Map<String, dynamic>;
          _partnerName = partnerData['name'] ?? 'Partner';
        }
      }

      // Create or use existing chat
      if (widget.sessionId != null) {
        _currentChatId = widget.sessionId;
      } else {
        await _createChat();
      }

      // Set up real-time message listening
      _setupMessageListener();

      setState(() {
        _isLoading = false;
      });

      // Scroll to bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } catch (e) {
      _showError('Failed to initialize chat: $e');
    }
  }



  Future<void> _createChat() async {
    final user = _authService.currentUser;
    if (user == null) return;

    print('Creating chat for user: ${user.uid}, partner: $_partnerId');
    
    try {
      // Create a unique chat ID based on user IDs (sorted to ensure consistency)
      final userIds = [user.uid, _partnerId!]..sort();
      final chatId = '${userIds[0]}_${userIds[1]}';
      
      // Create chat document in Firestore
      await FirebaseFirestore.instance.collection('chats').doc(chatId).set({
        'participants': userIds,
        'createdAt': FieldValue.serverTimestamp(),
        'lastMessage': null,
        'lastMessageTime': null,
      }, SetOptions(merge: true));
      
      _currentChatId = chatId;
      print('Chat created successfully: $_currentChatId');
    } catch (e) {
      print('Failed to create chat: $e');
      _showError('Failed to create chat: $e');
    }
  }

  void _setupMessageListener() {
    if (_currentChatId == null) {
      print('Cannot setup message listener: chat ID is null');
      return;
    }

    print('Setting up message listener for chat: $_currentChatId');
    _messagesSubscription = FirebaseFirestore.instance
        .collection('chats')
        .doc(_currentChatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .listen(
      (snapshot) {
        print('Message snapshot received: ${snapshot.docs.length} messages');
        for (var doc in snapshot.docs) {
          print('Message: ${doc.id} - ${doc.data()}');
        }
        
        setState(() {
          _messages = snapshot.docs
              .map((doc) => {
                    'id': doc.id,
                    ...doc.data(),
                  })
              .toList();
        });

        print('Updated _messages list: ${_messages.length} messages');

        // Auto-scroll to bottom when new messages arrive
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      },
      onError: (error) {
        _showError('Failed to load messages: $error');
      },
    );
  }

  Future<void> _sendMessage() async {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty || _currentChatId == null) {
      print('Cannot send message: text empty or chat ID null');
      return;
    }

    final user = _authService.currentUser;
    if (user == null) {
      print('Cannot send message: user not authenticated');
      return;
    }

    print('Sending message to chat $_currentChatId: "$messageText"');

    try {
      // Add message to Firestore
      final docRef = await FirebaseFirestore.instance
          .collection('chats')
          .doc(_currentChatId)
          .collection('messages')
          .add({
        'senderId': user.uid,
        'senderName': user.displayName ?? 'You',
        'message': messageText,
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'text',
      });

      print('Message sent successfully with ID: ${docRef.id}');

      // Update chat document with last message info
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(_currentChatId)
          .update({
        'lastMessage': messageText,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastMessageSender': user.uid,
      });

      // Clear input
      _messageController.clear();

      // Messages will be updated automatically via the stream listener
    } catch (e) {
      print('Error sending message: $e');
      _showError('Failed to send message: $e');
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

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

  Widget _buildMessage(Map<String, dynamic> message) {
    final user = _authService.currentUser;
    final isMe = message['senderId'] == user?.uid;

    DateTime? timestamp;
    if (message['timestamp'] != null) {
      final timestampData = message['timestamp'];
      if (timestampData is Timestamp) {
        timestamp = timestampData.toDate();
      }
    }

    return MessageBubble(
      message: message['message'] ?? '',
      senderName: message['senderName'] ?? 'Partner',
      isMe: isMe,
      timestamp: timestamp,
      myMessageColor: const Color(0xFF6B46C1),
      otherMessageColor: Colors.grey[300],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ChatHeader(
          title: _partnerName ?? 'Couples Chat',
          subtitle: _isPartnerOnline ? 'recently' : 'a while ago',
          isOnline: _isPartnerOnline,
          backgroundColor: const Color(0xFF6B46C1),
          onInfoTap: () {
            // TODO: Show session info
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/chat_background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6B46C1)),
                ),
              )
            : Column(
                children: [
                  // Chat messages
                  Expanded(
                    child: _messages.isEmpty
                        ? Center(
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              margin: const EdgeInsets.symmetric(horizontal: 32),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Text(
                                'Start your conversation!\nSend a message to begin.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                              return _buildMessage(_messages[index]);
                            },
                          ),
                  ),
                  // Message input with modern styling
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: ChatInput(
                      controller: _messageController,
                      onSend: _sendMessage,
                      hintText:
                          'Type a message to ${_partnerName ?? 'your partner'}...',
                      enabled: !_isLoading,
                      sendButtonColor: const Color(0xFF6B46C1),
                    ),
                  ),
                ],
              ),
      ),
      // Bottom navigation is handled by MainNavigationScreen
    );
  }
}
