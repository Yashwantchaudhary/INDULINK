import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class RealtimeDatabaseService {
  static final FirebaseDatabase _database = FirebaseDatabase.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // =================== CHAT METHODS ===================

  static Future<Map<String, dynamic>> createChatRoom(List<String> participants, {Map<String, dynamic>? metadata}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {'success': false, 'message': 'User not authenticated'};
      }

      // Check if chat room already exists
      final existingChat = await _findExistingChat(participants);
      if (existingChat != null) {
        return {
          'success': true,
          'data': existingChat,
          'message': 'Chat room already exists',
        };
      }

      final chatId = _database.ref().child('chats').push().key!;
      final chatData = {
        'participants': participants,
        'createdBy': user.uid,
        'createdAt': ServerValue.timestamp,
        'lastMessage': '',
        'lastMessageSender': '',
        'lastMessageTime': null,
        'metadata': metadata,
      };

      await _database.ref('chats/$chatId').set(chatData);

      // Add to userChats for each participant
      for (final participantId in participants) {
        await _database.ref('userChats/$participantId/$chatId').set({
          'chatId': chatId,
          'lastMessageTime': ServerValue.timestamp,
        });
      }

      return {
        'success': true,
        'data': {
          'id': chatId,
          ...chatData,
        },
        'message': 'Chat room created successfully',
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>?> _findExistingChat(List<String> participants) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final userChatsRef = _database.ref('userChats/${user.uid}');
      final snapshot = await userChatsRef.get();

      if (!snapshot.exists) return null;

      final userChats = Map<String, dynamic>.from(snapshot.value as Map);

      for (final chatId in userChats.keys) {
        final chatRef = _database.ref('chats/$chatId');
        final chatSnapshot = await chatRef.get();

        if (chatSnapshot.exists) {
          final chatData = Map<String, dynamic>.from(chatSnapshot.value as Map);
          final chatParticipants = List<String>.from(chatData['participants'] ?? []);

          if (chatParticipants.length == participants.length &&
              chatParticipants.every((p) => participants.contains(p))) {
            return {
              'id': chatId,
              ...chatData,
            };
          }
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>> createOrGetChat(String participantId, {String? hostelId}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {'success': false, 'message': 'User not authenticated'};
      }

      final participants = [user.uid, participantId];
      final existingChat = await _findExistingChat(participants);

      if (existingChat != null) {
        return {
          'success': true,
          'data': existingChat,
        };
      }

      return await createChatRoom(participants, metadata: hostelId != null ? {'hostelId': hostelId} : null);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getChatRooms() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {'success': false, 'message': 'User not authenticated'};
      }

      final userChatsRef = _database.ref('userChats/${user.uid}');
      final snapshot = await userChatsRef.get();

      if (!snapshot.exists) {
        return {'success': true, 'data': []};
      }

      final userChats = Map<String, dynamic>.from(snapshot.value as Map);
      final chatIds = userChats.keys.toList();

      final chats = <Map<String, dynamic>>[];

      for (final chatId in chatIds) {
        final chatRef = _database.ref('chats/$chatId');
        final chatSnapshot = await chatRef.get();

        if (chatSnapshot.exists) {
          final chatData = Map<String, dynamic>.from(chatSnapshot.value as Map);
          chats.add({
            'id': chatId,
            ...chatData,
          });
        }
      }

      // Sort by lastMessageTime descending
      chats.sort((a, b) {
        final aTime = a['lastMessageTime'] as int?;
        final bTime = b['lastMessageTime'] as int?;
        if (aTime == null && bTime == null) return 0;
        if (aTime == null) return 1;
        if (bTime == null) return -1;
        return bTime.compareTo(aTime);
      });

      return {
        'success': true,
        'data': chats,
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getChatMessages(String chatId) async {
    try {
      final messagesRef = _database.ref('chats/$chatId/messages');
      final snapshot = await messagesRef.get();

      final messages = <Map<String, dynamic>>[];

      if (snapshot.exists) {
        final messagesData = Map<String, dynamic>.from(snapshot.value as Map);

        for (final messageId in messagesData.keys) {
          final messageData = Map<String, dynamic>.from(messagesData[messageId]);
          messages.add({
            'id': messageId,
            ...messageData,
          });
        }

        // Sort by timestamp ascending
        messages.sort((a, b) {
          final aTime = a['timestamp'] as int?;
          final bTime = b['timestamp'] as int?;
          if (aTime == null && bTime == null) return 0;
          if (aTime == null) return 1;
          if (bTime == null) return -1;
          return aTime.compareTo(bTime);
        });
      }

      return {
        'success': true,
        'data': messages,
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> sendMessage(String chatId, String message) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {'success': false, 'message': 'User not authenticated'};
      }

      final messageId = _database.ref('chats/$chatId/messages').push().key!;
      final messageData = {
        'senderId': user.uid,
        'senderName': '', // Will be populated client-side or via cloud function
        'message': message,
        'timestamp': ServerValue.timestamp,
        'messageType': 'text',
        'status': 'sent',
      };

      await _database.ref('chats/$chatId/messages/$messageId').set(messageData);

      // Update chat's last message
      await _database.ref('chats/$chatId').update({
        'lastMessage': message,
        'lastMessageSender': user.uid,
        'lastMessageTime': ServerValue.timestamp,
      });

      // Update userChats for all participants
      final chatRef = _database.ref('chats/$chatId');
      final chatSnapshot = await chatRef.get();

      if (chatSnapshot.exists) {
        final chatData = Map<String, dynamic>.from(chatSnapshot.value as Map);
        final participants = List<String>.from(chatData['participants'] ?? []);

        for (final participantId in participants) {
          await _database.ref('userChats/$participantId/$chatId').update({
            'lastMessageTime': ServerValue.timestamp,
          });
        }
      }

      return {
        'success': true,
        'data': {
          'id': messageId,
          ...messageData,
        },
        'message': 'Message sent successfully',
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // =================== REAL-TIME LISTENERS ===================

  static Stream<List<Map<String, dynamic>>> listenToChatMessages(String chatId) {
    final messagesRef = _database.ref('chats/$chatId/messages');

    return messagesRef.onValue.map((event) {
      final messages = <Map<String, dynamic>>[];

      if (event.snapshot.exists) {
        final messagesData = Map<String, dynamic>.from(event.snapshot.value as Map);

        for (final messageId in messagesData.keys) {
          final messageData = Map<String, dynamic>.from(messagesData[messageId]);
          messages.add({
            'id': messageId,
            ...messageData,
          });
        }

        // Sort by timestamp ascending
        messages.sort((a, b) {
          final aTime = a['timestamp'] as int?;
          final bTime = b['timestamp'] as int?;
          if (aTime == null && bTime == null) return 0;
          if (aTime == null) return 1;
          if (bTime == null) return -1;
          return aTime.compareTo(bTime);
        });
      }

      return messages;
    });
  }

  static Stream<List<Map<String, dynamic>>> listenToChatRooms() {
    final user = _auth.currentUser;
    if (user == null) return Stream.empty();

    final userChatsRef = _database.ref('userChats/${user.uid}');

    return userChatsRef.onValue.asyncMap((event) async {
      if (!event.snapshot.exists) return [];

      final userChats = Map<String, dynamic>.from(event.snapshot.value as Map);
      final chatIds = userChats.keys.toList();

      final chats = <Map<String, dynamic>>[];

      for (final chatId in chatIds) {
        final chatRef = _database.ref('chats/$chatId');
        final chatSnapshot = await chatRef.get();

        if (chatSnapshot.exists) {
          final chatData = Map<String, dynamic>.from(chatSnapshot.value as Map);
          chats.add({
            'id': chatId,
            ...chatData,
          });
        }
      }

      // Sort by lastMessageTime descending
      chats.sort((a, b) {
        final aTime = a['lastMessageTime'] as int?;
        final bTime = b['lastMessageTime'] as int?;
        if (aTime == null && bTime == null) return 0;
        if (aTime == null) return 1;
        if (bTime == null) return -1;
        return bTime.compareTo(aTime);
      });

      return chats;
    });
  }

  // =================== USER PRESENCE METHODS ===================

  static Future<void> setUserPresence(String userId, bool isOnline) async {
    try {
      await _database.ref('presence/$userId').set({
        'isOnline': isOnline,
        'lastSeen': ServerValue.timestamp,
      });
    } catch (e) {
      debugPrint('Error setting user presence: $e');
    }
  }

  static Stream<Map<String, dynamic>> listenToUserPresence(String userId) {
    final presenceRef = _database.ref('presence/$userId');

    return presenceRef.onValue.map((event) {
      if (event.snapshot.exists) {
        return Map<String, dynamic>.from(event.snapshot.value as Map);
      }
      return {'isOnline': false, 'lastSeen': null};
    });
  }

  // =================== TYPING INDICATORS ===================

  static Future<void> setTypingStatus(String chatId, String userId, bool isTyping) async {
    try {
      if (isTyping) {
        await _database.ref('chats/$chatId/typing/$userId').set({
          'userId': userId,
          'timestamp': ServerValue.timestamp,
        });
      } else {
        await _database.ref('chats/$chatId/typing/$userId').remove();
      }
    } catch (e) {
      debugPrint('Error setting typing status: $e');
    }
  }

  static Stream<List<Map<String, dynamic>>> listenToTypingStatus(String chatId) {
    final typingRef = _database.ref('chats/$chatId/typing');

    return typingRef.onValue.map((event) {
      final typingUsers = <Map<String, dynamic>>[];

      if (event.snapshot.exists) {
        final typingData = Map<String, dynamic>.from(event.snapshot.value as Map);

        for (final userId in typingData.keys) {
          final userTypingData = Map<String, dynamic>.from(typingData[userId]);
          typingUsers.add({
            'userId': userId,
            ...userTypingData,
          });
        }
      }

      return typingUsers;
    });
  }
}