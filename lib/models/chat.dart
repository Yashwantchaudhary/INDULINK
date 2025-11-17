// Chat Models for Firebase Realtime Database

class ChatRoom {
  final String id;
  final List<String> participants;
  final String lastMessage;
  final String lastMessageSender;
  final DateTime lastMessageTime;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  ChatRoom({
    required this.id,
    required this.participants,
    required this.lastMessage,
    required this.lastMessageSender,
    required this.lastMessageTime,
    required this.createdAt,
    this.metadata,
  });

  factory ChatRoom.fromJson(String id, Map<dynamic, dynamic> json) {
    return ChatRoom(
      id: id,
      participants: List<String>.from(json['participants'] ?? []),
      lastMessage: json['lastMessage'] ?? '',
      lastMessageSender: json['lastMessageSender'] ?? '',
      lastMessageTime: DateTime.fromMillisecondsSinceEpoch(json['lastMessageTime'] ?? 0),
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] ?? 0),
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'participants': participants,
      'lastMessage': lastMessage,
      'lastMessageSender': lastMessageSender,
      'lastMessageTime': lastMessageTime.millisecondsSinceEpoch,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'metadata': metadata,
    };
  }
}

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String message;
  final DateTime timestamp;
  final MessageType messageType;
  final Map<String, dynamic>? metadata;
  final MessageStatus status;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.timestamp,
    this.messageType = MessageType.text,
    this.metadata,
    this.status = MessageStatus.sent,
  });

  factory ChatMessage.fromJson(String id, Map<dynamic, dynamic> json) {
    return ChatMessage(
      id: id,
      senderId: json['senderId'] ?? '',
      senderName: json['senderName'] ?? '',
      message: json['message'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] ?? 0),
      messageType: MessageType.values[json['messageType'] ?? 0],
      metadata: json['metadata'],
      status: MessageStatus.values[json['status'] ?? 0],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'message': message,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'messageType': messageType.index,
      'metadata': metadata,
      'status': status.index,
    };
  }
}

enum MessageType {
  text,
  image,
  file,
  location,
  booking_request,
  booking_confirmation,
}

enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
}

class TypingIndicator {
  final String userId;
  final String userName;
  final bool isTyping;

  TypingIndicator({
    required this.userId,
    required this.userName,
    required this.isTyping,
  });

  factory TypingIndicator.fromJson(String userId, Map<dynamic, dynamic> json) {
    return TypingIndicator(
      userId: userId,
      userName: json['userName'] ?? '',
      isTyping: json['isTyping'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'isTyping': isTyping,
    };
  }
}

class ChatParticipant {
  final String userId;
  final String name;
  final String? profileImage;
  final String role; // 'student' or 'host'
  final DateTime lastSeen;
  final bool isOnline;

  ChatParticipant({
    required this.userId,
    required this.name,
    this.profileImage,
    required this.role,
    required this.lastSeen,
    this.isOnline = false,
  });

  factory ChatParticipant.fromJson(String userId, Map<dynamic, dynamic> json) {
    return ChatParticipant(
      userId: userId,
      name: json['name'] ?? '',
      profileImage: json['profileImage'],
      role: json['role'] ?? 'student',
      lastSeen: DateTime.fromMillisecondsSinceEpoch(json['lastSeen'] ?? 0),
      isOnline: json['isOnline'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'profileImage': profileImage,
      'role': role,
      'lastSeen': lastSeen.millisecondsSinceEpoch,
      'isOnline': isOnline,
    };
  }
}