class MessageSender {
  final String id;
  final String name;
  final String? profilePicture;

  MessageSender({
    required this.id,
    required this.name,
    this.profilePicture,
  });

  factory MessageSender.fromJson(Map<String, dynamic> json) {
    return MessageSender(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      profilePicture: json['profilePicture'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'profilePicture': profilePicture,
    };
  }
}

class DeliveryStatus {
  bool sent;
  bool delivered;
  DateTime? deliveredAt;
  bool read;
  DateTime? readAt;
  List<Map<String, dynamic>> readBy;

  DeliveryStatus({
    this.sent = false,
    this.delivered = false,
    this.deliveredAt,
    this.read = false,
    this.readAt,
    this.readBy = const [],
  });

  factory DeliveryStatus.fromJson(Map<String, dynamic> json) {
    return DeliveryStatus(
      sent: json['sent'] ?? false,
      delivered: json['delivered'] ?? false,
      deliveredAt: json['deliveredAt'] != null
          ? DateTime.parse(json['deliveredAt'])
          : null,
      read: json['read'] ?? false,
      readAt: json['readAt'] != null
          ? DateTime.parse(json['readAt'])
          : null,
      readBy: List<Map<String, dynamic>>.from(json['readBy'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sent': sent,
      'delivered': delivered,
      'deliveredAt': deliveredAt?.toIso8601String(),
      'read': read,
      'readAt': readAt?.toIso8601String(),
      'readBy': readBy,
    };
  }
}

class Message {
  final String id;
  final String chatId;
  final MessageSender sender;
  final String content;
  final String messageType;
  final String? replyTo;
  final DeliveryStatus deliveryStatus;
  final DateTime createdAt;
  final String formattedTime;

  Message({
    required this.id,
    required this.chatId,
    required this.sender,
    required this.content,
    required this.messageType,
    this.replyTo,
    required this.deliveryStatus,
    required this.createdAt,
    required this.formattedTime,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] ?? '',
      chatId: json['chatId'] ?? '',
      sender: MessageSender.fromJson(json['sender'] ?? {}),
      content: json['content'] ?? '',
      messageType: json['messageType'] ?? 'text',
      replyTo: json['replyTo'],
      deliveryStatus: DeliveryStatus.fromJson(json['deliveryStatus'] ?? {}),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      formattedTime: json['formattedTime'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chatId': chatId,
      'sender': sender.toJson(),
      'content': content,
      'messageType': messageType,
      'replyTo': replyTo,
      'deliveryStatus': deliveryStatus.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'formattedTime': formattedTime,
    };
  }

  Message copyWith({
    String? id,
    String? chatId,
    MessageSender? sender,
    String? content,
    String? messageType,
    String? replyTo,
    DeliveryStatus? deliveryStatus,
    DateTime? createdAt,
    String? formattedTime,
  }) {
    return Message(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      sender: sender ?? this.sender,
      content: content ?? this.content,
      messageType: messageType ?? this.messageType,
      replyTo: replyTo ?? this.replyTo,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
      createdAt: createdAt ?? this.createdAt,
      formattedTime: formattedTime ?? this.formattedTime,
    );
  }
}