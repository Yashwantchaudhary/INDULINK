import 'package:flutter/material.dart';
import '../services/firebase_api_service.dart';
import '../controllers/firebase_controllers.dart';
import '../models/message.dart';
import '../services/remote_config_service.dart';

class ChatMessages extends StatefulWidget {
  final VoidCallback onBack;

  const ChatMessages({super.key, required this.onBack});

  @override
  State<ChatMessages> createState() => _ChatMessagesState();
}

class _ChatMessagesState extends State<ChatMessages> {
  String? activeChat;
  String newMessage = '';
  String searchQuery = '';

  // Real-time chat properties
  List<Message> _messages = [];

  // Firebase Realtime Database properties
  Stream<Map<String, dynamic>>? _messagesStream;
  Stream<Map<String, dynamic>>? _typingStream;

  // Dynamic conversations loaded from backend
  List<Map<String, dynamic>> conversations = [];

  final messages = [
    {
      'id': '1',
      'sender': 'other',
      'content': 'Welcome to ABC Hostel! We\'re excited to have you consider our accommodation.',
      'timestamp': '10:30 AM',
      'type': 'text'
    },
    {
      'id': '2',
      'sender': 'user',
      'content': 'Hi, is there a single room available for next month?',
      'timestamp': '10:32 AM',
      'type': 'text'
    },
    {
      'id': '3',
      'sender': 'other',
      'content': 'Yes, we have single rooms available! The rent is ₹8,000 per month including WiFi and basic amenities.',
      'timestamp': '10:35 AM',
      'type': 'text'
    },
    {
      'id': '4',
      'sender': 'user',
      'content': 'That sounds great! Can I schedule a visit to see the room?',
      'timestamp': '10:37 AM',
      'type': 'text'
    },
    {
      'id': '5',
      'sender': 'other',
      'content': 'Absolutely! You can visit us anytime between 10 AM to 6 PM. Our address is 123 College Street, near DU.',
      'timestamp': '10:40 AM',
      'type': 'text'
    }
  ];

  Map<String, dynamic>? get activeChatData {
    return conversations.cast<Map<String, dynamic>>().firstWhere(
      (conv) => conv['id'] == activeChat,
      orElse: () => <String, dynamic>{},
    );
  }


  String _formatTimestamp(int? timestamp) {
    if (timestamp == null) return 'now';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'now';
    }
  }

  void _loadConversations() async {
    try {
      // Load conversations from Firebase Realtime Database
      final chatRoomsResult = await FirebaseApiService.getChatRooms();
      if (chatRoomsResult['success'] == true) {
        final chatRooms = List<Map<String, dynamic>>.from(chatRoomsResult['data'] ?? []);
        setState(() {
          conversations = chatRooms.map((room) {
            return {
              'id': room['id'],
              'name': 'Chat Room ${room['id'].substring(0, 8)}', // Short ID for display
              'avatar': 'https://via.placeholder.com/48x48?text=Chat',
              'lastMessage': room['lastMessage'] ?? 'No messages yet',
              'timestamp': _formatTimestamp(room['lastMessageTime']),
              'type': 'chat',
              'isOnline': true,
              'participants': room['participants'] ?? [],
            };
          }).toList();
        });
      } else {
        // Fallback to static data if no chat rooms
        setState(() {
          conversations = [
            {
              'id': 'sample_1',
              'name': 'ABC Hostel',
              'avatar': 'https://images.unsplash.com/photo-1697603899008-a4027a95fd95?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxob3N0ZWwlMjByb29tJTIwaW50ZXJpb3J8ZW58MXx8fHwxNzU4NTI0MjQ1fDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
              'lastMessage': 'Welcome! Ready to book your room?',
              'timestamp': '2h ago',
              'type': 'hostel',
              'isOnline': true
            },
          ];
        });
      }
    } catch (e) {
      // Fallback to static data
      setState(() {
        conversations = [
          {
            'id': 'sample_1',
            'name': 'ABC Hostel',
            'avatar': 'https://images.unsplash.com/photo-1697603899008-a4027a95fd95?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxob3N0ZWwlMjByb29tJTIwaW50ZXJpb3J8ZW58MXx8fHwxNzU4NTI0MjQ1fDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral',
            'lastMessage': 'Welcome! Ready to book your room?',
            'timestamp': '2h ago',
            'type': 'hostel',
            'isOnline': true
          },
        ];
      });
    }
  }

  void _loadMessages() async {
    if (activeChat == null) return;

    try {
      // Load messages from Firebase Realtime Database
      final messagesResult = await FirebaseApiService.getChatMessages(activeChat!);
      if (messagesResult['success'] == true) {
        final firebaseMessages = List<Map<String, dynamic>>.from(messagesResult['data'] ?? []);

        setState(() {
          _messages = firebaseMessages.map((msg) => Message(
            id: msg['id'] as String,
            chatId: activeChat!,
            sender: MessageSender(
              id: msg['senderId'] as String,
              name: msg['senderName'] as String,
            ),
            content: msg['message'] as String,
            messageType: 'text', // Firebase stores as enum index
            deliveryStatus: DeliveryStatus(sent: true, delivered: true),
            createdAt: DateTime.fromMillisecondsSinceEpoch(msg['timestamp'] as int),
            formattedTime: _formatMessageTime(msg['timestamp'] as int),
          )).toList();
        });

        // Set up real-time listeners
        _setupMessageListener();
      } else {
        // Fallback to static data
        setState(() {
          _messages = messages.map((msg) => Message(
            id: msg['id'] as String,
            chatId: activeChat!,
            sender: MessageSender(
              id: msg['sender'] == 'user' ? 'current_user' : 'other_user',
              name: msg['sender'] == 'user' ? 'You' : activeChatData!['name'] as String,
            ),
            content: msg['content'] as String,
            messageType: msg['type'] as String,
            deliveryStatus: DeliveryStatus(sent: true, delivered: true),
            createdAt: DateTime.now(),
            formattedTime: msg['timestamp'] as String,
          )).toList();
        });
      }
    } catch (e) {
      // Fallback to static data
      setState(() {
        _messages = messages.map((msg) => Message(
          id: msg['id'] as String,
          chatId: activeChat!,
          sender: MessageSender(
            id: msg['sender'] == 'user' ? 'current_user' : 'other_user',
            name: msg['sender'] == 'user' ? 'You' : activeChatData!['name'] as String,
          ),
          content: msg['content'] as String,
          messageType: msg['type'] as String,
          deliveryStatus: DeliveryStatus(sent: true, delivered: true),
          createdAt: DateTime.now(),
          formattedTime: msg['timestamp'] as String,
        )).toList();
      });
    }
  }

  void _setupMessageListener() {
    if (activeChat == null) return;

    // Use ChatController for real-time message listening
    ChatController.joinChat(activeChat!);

    // Listen to messages stream
    ChatController.messagesStream.listen((messages) {
      setState(() {
        _messages = messages;
      });
    });
  }

  String _formatMessageTime(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    }
  }

  void sendMessage() async {
    if (newMessage.trim().isNotEmpty && activeChat != null) {
      try {
        // Send message via ChatController (which uses Realtime Database)
        final result = await ChatController.sendMessage(activeChat!, newMessage.trim());

        if (result['success'] == true) {
          setState(() {
            newMessage = '';
          });
        } else {
          // Show error
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to send message: ${result['message']}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error sending message'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _startTyping() async {
    // Typing indicators removed for simplicity
  }


  @override
  void initState() {
    super.initState();
    _loadConversations();
    // Initialize Firebase controllers
    firebaseManager.initialize();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (activeChat != null) {
      _loadMessages();
    }
  }

  @override
  void dispose() {
    // Leave chat room
    if (activeChat != null) {
      ChatController.leaveChat(activeChat!);
    }

    // Cancel streams
    _messagesStream = null;
    _typingStream = null;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width >= 600 && screenSize.width < 1024;
    final isDesktop = screenSize.width >= 1024;

    // Check if chat feature is enabled via Remote Config
    final chatEnabled = RemoteConfigService().getBool('chat_enabled');

    // Responsive dimensions
    final maxWidth = isDesktop ? 1400.0 : isTablet ? 1000.0 : 420.0;
    final horizontalPadding = isDesktop ? 48.0 : isTablet ? 32.0 : 20.0;

    // If chat is disabled, show disabled message
    if (!chatEnabled) {
      return Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          constraints: BoxConstraints(maxWidth: maxWidth),
          margin: EdgeInsets.symmetric(horizontal: isDesktop ? 0 : horizontalPadding),
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1976D2),
                Color(0xFF7C4DFF),
                Color(0xFF1976D2),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: isDesktop ? 120 : isTablet ? 100 : 80,
                color: Colors.white.withOpacity(0.7),
              ),
              SizedBox(height: isDesktop ? 32 : isTablet ? 28 : 24),
              Text(
                'Chat Feature Disabled',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isDesktop ? 32 : isTablet ? 28 : 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isDesktop ? 16 : 12),
              Text(
                'The chat feature is currently disabled.\nPlease check back later.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: isDesktop ? 18 : isTablet ? 16 : 14,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isDesktop ? 48 : isTablet ? 40 : 32),
              ElevatedButton(
                onPressed: widget.onBack,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF1976D2),
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 32 : isTablet ? 28 : 24,
                    vertical: isDesktop ? 16 : 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
                  ),
                ),
                child: Text(
                  'Go Back',
                  style: TextStyle(
                    fontSize: isDesktop ? 16 : 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (activeChat != null && activeChatData!.isNotEmpty) {
      return Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          constraints: BoxConstraints(maxWidth: maxWidth),
          margin: EdgeInsets.symmetric(horizontal: isDesktop ? 0 : horizontalPadding),
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1976D2),
                Color(0xFF7C4DFF),
                Color(0xFF1976D2),
              ],
            ),
          ),
          child: Column(
            children: [
              // Chat Header
              Container(
                padding: EdgeInsets.all(isDesktop ? 24 : isTablet ? 20 : 16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => setState(() => activeChat = null),
                      icon: Icon(Icons.arrow_back, color: Colors.white, size: isDesktop ? 28 : 24),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        padding: EdgeInsets.all(isDesktop ? 16 : 12),
                      ),
                    ),
                    SizedBox(width: isDesktop ? 16 : 12),
                    Container(
                      width: isDesktop ? 56 : isTablet ? 48 : 40,
                      height: isDesktop ? 56 : isTablet ? 48 : 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(isDesktop ? 28 : isTablet ? 24 : 20),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(isDesktop ? 28 : isTablet ? 24 : 20),
                        child: Image.network(
                          activeChatData!['avatar'] as String,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.person,
                              size: isDesktop ? 28 : isTablet ? 24 : 20,
                              color: Colors.grey,
                            );
                          },
                        ),
                      ),
                    ),
                    if (activeChatData!['isOnline'] as bool)
                      Container(
                        width: isDesktop ? 16 : 12,
                        height: isDesktop ? 16 : 12,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                    SizedBox(width: isDesktop ? 16 : 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activeChatData!['name'] as String,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isDesktop ? 20 : isTablet ? 18 : 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            activeChatData!['isOnline'] as bool ? 'Online' : 'Last seen 2h ago',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: isDesktop ? 14 : 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isDesktop || isTablet) ...[
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.phone, color: Colors.white, size: isDesktop ? 24 : 20),
                        padding: EdgeInsets.all(isDesktop ? 12 : 8),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.videocam, color: Colors.white, size: isDesktop ? 24 : 20),
                        padding: EdgeInsets.all(isDesktop ? 12 : 8),
                      ),
                    ],
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.more_vert, color: Colors.white, size: isDesktop ? 24 : 20),
                      padding: EdgeInsets.all(isDesktop ? 12 : 8),
                    ),
                  ],
                ),
              ),

              // Messages
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(isDesktop ? 24 : isTablet ? 20 : 16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    final isUser = message.sender.id == 'current_user';

                    return Align(
                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.only(bottom: isDesktop ? 16 : 12),
                        padding: EdgeInsets.all(isDesktop ? 16 : isTablet ? 14 : 12),
                        constraints: BoxConstraints(
                          maxWidth: screenSize.width * (isDesktop ? 0.6 : isTablet ? 0.7 : 0.8),
                        ),
                        decoration: BoxDecoration(
                          color: isUser ? const Color(0xFF1976D2) : Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(isDesktop ? 20 : 16),
                            topRight: Radius.circular(isDesktop ? 20 : 16),
                            bottomLeft: isUser ? Radius.circular(isDesktop ? 20 : 16) : Radius.circular(isDesktop ? 8 : 4),
                            bottomRight: isUser ? Radius.circular(isDesktop ? 8 : 4) : Radius.circular(isDesktop ? 20 : 16),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: isDesktop ? 6 : 4,
                              offset: Offset(0, isDesktop ? 3 : 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              message.content,
                              style: TextStyle(
                                color: isUser ? Colors.white : const Color(0xFF1E293B),
                                fontSize: isDesktop ? 16 : isTablet ? 15 : 14,
                              ),
                            ),
                            SizedBox(height: isDesktop ? 6 : 4),
                            Text(
                              message.formattedTime,
                              style: TextStyle(
                                color: isUser ? Colors.white70 : const Color(0xFF64748B),
                                fontSize: isDesktop ? 12 : 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Message Input
              Container(
                padding: EdgeInsets.all(isDesktop ? 24 : isTablet ? 20 : 16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(
                      color: Color(0xFFE5E7EB),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    if (isDesktop || isTablet)
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.attach_file, color: const Color(0xFF6B7280), size: isDesktop ? 24 : 20),
                        padding: EdgeInsets.all(isDesktop ? 12 : 8),
                      ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isDesktop ? 20 : 16,
                          vertical: isDesktop ? 16 : 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
                        ),
                        child: TextField(
                          controller: TextEditingController(text: newMessage),
                          onChanged: (value) {
                            setState(() => newMessage = value);
                            _startTyping();
                          },
                          onSubmitted: (_) => sendMessage(),
                          style: TextStyle(fontSize: isDesktop ? 16 : 14),
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            hintStyle: TextStyle(
                              color: Colors.grey[500],
                              fontSize: isDesktop ? 16 : 14,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: isDesktop ? 12 : 8),
                    Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFF1976D2),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: sendMessage,
                        icon: Icon(
                          Icons.send,
                          color: Colors.white,
                          size: isDesktop ? 20 : 18,
                        ),
                        padding: EdgeInsets.all(isDesktop ? 12 : 10),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        constraints: BoxConstraints(maxWidth: maxWidth),
        margin: EdgeInsets.symmetric(horizontal: isDesktop ? 0 : horizontalPadding),
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1976D2),
              Color(0xFF7C4DFF),
              Color(0xFF1976D2),
            ],
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(isDesktop ? 32 : isTablet ? 28 : 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: widget.onBack,
                        icon: Icon(Icons.arrow_back, color: Colors.white, size: isDesktop ? 28 : 24),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          padding: EdgeInsets.all(isDesktop ? 16 : 12),
                        ),
                      ),
                      SizedBox(width: isDesktop ? 16 : 12),
                      Text(
                        'Messages',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isDesktop ? 24 : isTablet ? 20 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
                    ),
                    child: IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.edit, color: const Color(0xFF1976D2), size: isDesktop ? 24 : 20),
                      padding: EdgeInsets.all(isDesktop ? 12 : 8),
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar
            Container(
              padding: EdgeInsets.all(isDesktop ? 24 : isTablet ? 20 : 16),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: isDesktop ? 20 : 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: isDesktop ? 12 : 8,
                      offset: Offset(0, isDesktop ? 6 : 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: const Color(0xFF6B7280), size: isDesktop ? 24 : 20),
                    SizedBox(width: isDesktop ? 16 : 12),
                    Expanded(
                      child: TextField(
                        controller: TextEditingController(text: searchQuery),
                        onChanged: (value) => setState(() => searchQuery = value),
                        style: TextStyle(fontSize: isDesktop ? 16 : 14),
                        decoration: InputDecoration(
                          hintText: 'Search conversations...',
                          hintStyle: TextStyle(
                            color: Colors.grey[500],
                            fontSize: isDesktop ? 16 : 14,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Conversations List
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(isDesktop ? 24 : isTablet ? 20 : 16),
                itemCount: conversations.length,
                itemBuilder: (context, index) {
                  final conversation = conversations[index];

                  return GestureDetector(
                    onTap: () => setState(() => activeChat = conversation['id'] as String),
                    child: Container(
                      margin: EdgeInsets.only(bottom: isDesktop ? 12 : 8),
                      padding: EdgeInsets.all(isDesktop ? 20 : isTablet ? 18 : 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: isDesktop ? 8 : 4,
                            offset: Offset(0, isDesktop ? 4 : 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: isDesktop ? 64 : isTablet ? 56 : 48,
                            height: isDesktop ? 64 : isTablet ? 56 : 48,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(isDesktop ? 32 : isTablet ? 28 : 24),
                            ),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(isDesktop ? 32 : isTablet ? 28 : 24),
                                  child: Image.network(
                                    conversation['avatar'] as String,
                                    width: isDesktop ? 64 : isTablet ? 56 : 48,
                                    height: isDesktop ? 64 : isTablet ? 56 : 48,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        Icons.person,
                                        size: isDesktop ? 32 : isTablet ? 28 : 24,
                                        color: Colors.grey,
                                      );
                                    },
                                  ),
                                ),
                                if (conversation['isOnline'] as bool)
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      width: isDesktop ? 16 : 12,
                                      height: isDesktop ? 16 : 12,
                                      decoration: const BoxDecoration(
                                        color: Colors.green,
                                        shape: BoxShape.circle,
                                        border: Border.fromBorderSide(
                                          BorderSide(color: Colors.white, width: 2),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          SizedBox(width: isDesktop ? 16 : 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          conversation['name'] as String,
                                          style: TextStyle(
                                            fontSize: isDesktop ? 16 : isTablet ? 15 : 14,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF1E293B),
                                          ),
                                        ),
                                        SizedBox(width: isDesktop ? 12 : 8),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: isDesktop ? 8 : 6,
                                            vertical: isDesktop ? 4 : 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: (conversation['type'] == 'hostel'
                                                ? const Color(0xFF1976D2)
                                                : const Color(0xFF7C4DFF)).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
                                          ),
                                          child: Text(
                                            conversation['type'] == 'hostel' ? '🏠' : '👤',
                                            style: TextStyle(fontSize: isDesktop ? 12 : 10),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          conversation['timestamp'] as String,
                                          style: TextStyle(
                                            fontSize: isDesktop ? 12 : 10,
                                            color: const Color(0xFF64748B),
                                          ),
                                        ),
                                        if (conversation.containsKey('unreadCount'))
                                          Container(
                                            margin: EdgeInsets.only(left: isDesktop ? 12 : 8),
                                            padding: EdgeInsets.all(isDesktop ? 6 : 4),
                                            constraints: BoxConstraints(
                                              minWidth: isDesktop ? 24 : 20,
                                              minHeight: isDesktop ? 24 : 20,
                                            ),
                                            decoration: const BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Text(
                                              conversation['unreadCount'].toString(),
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: isDesktop ? 12 : 10,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: isDesktop ? 6 : 4),
                                Text(
                                  conversation['lastMessage'] as String,
                                  style: TextStyle(
                                    fontSize: isDesktop ? 14 : 12,
                                    color: const Color(0xFF64748B),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
