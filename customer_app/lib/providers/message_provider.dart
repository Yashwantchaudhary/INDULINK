import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/message.dart';
import '../services/message_service.dart';

// Message Provider
final messageProvider = StateNotifierProvider<MessageNotifier, MessageState>((ref) {
  return MessageNotifier();
});

// Message State
class MessageState {
  final List<Conversation> conversations;
  final List<Message> messages;
  final Conversation? selectedConversation;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? pagination;

  MessageState({
    this.conversations = const [],
    this.messages = const [],
    this.selectedConversation,
    this.isLoading = false,
    this.error,
    this.pagination,
  });

  MessageState copyWith({
    List<Conversation>? conversations,
    List<Message>? messages,
    Conversation? selectedConversation,
    bool? isLoading,
    String? error,
    Map<String, dynamic>? pagination,
    bool clearSelectedConversation = false,
  }) {
    return MessageState(
      conversations: conversations ?? this.conversations,
      messages: messages ?? this.messages,
      selectedConversation: clearSelectedConversation
          ? null
          : (selectedConversation ?? this.selectedConversation),
      isLoading: isLoading ?? this.isLoading,
      error: error,
      pagination: pagination ?? this.pagination,
    );
  }
}

// Message Notifier
class MessageNotifier extends StateNotifier<MessageState> {
  MessageNotifier() : super(MessageState());

  final MessageService _messageService = MessageService();

  // Get conversations
  Future<void> getConversations() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final conversations = await _messageService.getConversations();

      state = state.copyWith(
        conversations: conversations,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Get messages
  Future<void> getMessages({
    required String conversationId,
    int page = 1,
    int limit = 50,
    bool loadMore = false,
  }) async {
    try {
      if (!loadMore) {
        state = state.copyWith(isLoading: true, error: null);
      }

      final result = await _messageService.getMessages(
        conversationId: conversationId,
        page: page,
        limit: limit,
      );

      final List<Message> messages = result['messages'];
      final pagination = result['pagination'];

      state = state.copyWith(
        messages: loadMore ? [...state.messages, ...messages] : messages,
        isLoading: false,
        pagination: pagination,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Send message
  Future<void> sendMessage({
    required String receiverId,
    required String content,
    String? conversationId,
    List<String>? attachments,
  }) async {
    try {
      final message = await _messageService.sendMessage(
        receiverId: receiverId,
        content: content,
        conversationId: conversationId,
        attachments: attachments,
      );

      // Add message to local state
      state = state.copyWith(
        messages: [...state.messages, message],
      );

      // Update conversation's last message
      final updatedConversations = state.conversations.map((conv) {
        if (conv.id == message.conversationId) {
          return conv.copyWith(
            lastMessage: message,
            updatedAt: message.createdAt,
          );
        }
        return conv;
      }).toList();

      state = state.copyWith(conversations: updatedConversations);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  // Mark messages as read
  Future<void> markAsRead(String conversationId) async {
    try {
      await _messageService.markAsRead(conversationId);

      // Update local state
      final updatedMessages = state.messages.map((message) {
        if (message.conversationId == conversationId) {
          return message.copyWith(isRead: true);
        }
        return message;
      }).toList();

      final updatedConversations = state.conversations.map((conv) {
        if (conv.id == conversationId) {
          return conv.copyWith(unreadCount: 0);
        }
        return conv;
      }).toList();

      state = state.copyWith(
        messages: updatedMessages,
        conversations: updatedConversations,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Delete message
  Future<void> deleteMessage(String messageId) async {
    try {
      await _messageService.deleteMessage(messageId);

      // Remove from local state
      final updatedMessages = state.messages
          .where((message) => message.id != messageId)
          .toList();

      state = state.copyWith(messages: updatedMessages);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  // Search conversations
  Future<void> searchConversations(String query) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final conversations = await _messageService.searchConversations(query);

      state = state.copyWith(
        conversations: conversations,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Select conversation
  void selectConversation(Conversation conversation) {
    state = state.copyWith(selectedConversation: conversation);
  }

  // Clear selected conversation
  void clearSelectedConversation() {
    state = state.copyWith(clearSelectedConversation: true);
  }

  // Add incoming message (for real-time updates)
  void addIncomingMessage(Message message) {
    state = state.copyWith(
      messages: [...state.messages, message],
    );

    // Update conversation
    final updatedConversations = state.conversations.map((conv) {
      if (conv.id == message.conversationId) {
        return conv.copyWith(
          lastMessage: message,
          unreadCount: (conv.unreadCount?['count'] ?? 0) + 1,
          updatedAt: message.createdAt,
        );
      }
      return conv;
    }).toList();

    state = state.copyWith(conversations: updatedConversations);
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}
