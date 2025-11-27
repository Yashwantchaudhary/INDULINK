import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_api_service.dart';
import '../services/firestore_service.dart';
import '../services/realtime_database_service.dart';
import '../models/message.dart';

// =================== AUTHENTICATION CONTROLLER ===================

class AuthController {
    static Future<Map<String, dynamic>> signUp({
      required String email,
      required String password,
      required String name,
      String role = 'student',
    }) async {
      try {
        final result = await FirebaseApiService.signUpWithEmailPassword(
          email: email,
          password: password,
          name: name,
          role: role,
        );

        if (result['success'] == true) {
          // Initialize notifications for new user
          await NotificationController.initializeForUser();
        }

        return result;
      } catch (e) {
        return {'success': false, 'message': e.toString()};
      }
    }

    static Future<Map<String, dynamic>> signIn(String email, String password) async {
      try {
        final result = await FirebaseApiService.signInWithEmailPassword(email, password);

        if (result['success'] == true) {
          // Initialize notifications for signed-in user
          await NotificationController.initializeForUser();
        }

        return result;
      } catch (e) {
        return {'success': false, 'message': e.toString()};
      }
    }

    static Future<Map<String, dynamic>> signInWithGoogle() async {
      try {
        final result = await FirebaseApiService.signInWithGoogle();

        if (result['success'] == true) {
          // Initialize notifications for Google signed-in user
          await NotificationController.initializeForUser();
        }

        return result;
      } catch (e) {
        return {'success': false, 'message': e.toString()};
      }
    }

    static Future<void> signOut() async {
      try {
        // Clean up all Firebase services
        await ChatController.disconnect();
        await NotificationController.cleanup();

        await FirebaseApiService.signOut();
      } catch (e) {
        debugPrint('Error during sign out: $e');
      }
    }

    static Future<Map<String, dynamic>> getCurrentUser() async {
      return await FirebaseApiService.getCurrentUserProfile();
    }
  }

  // =================== CHAT CONTROLLER ===================

  class ChatController {
    static StreamController<List<Map<String, dynamic>>>? _chatRoomsController;
    static StreamController<List<Message>>? _messagesController;
    static StreamController<List<Map<String, dynamic>>>? _typingController;
    static StreamSubscription? _messagesSubscription;
    static StreamSubscription? _typingSubscription;
    static StreamSubscription? _chatRoomsSubscription;
    static StreamSubscription? _listingsSubscription;
    static StreamSubscription? _notificationsSubscription;
    static StreamSubscription? _bookingsSubscription;

    static Future<void> initialize() async {
      _chatRoomsController = StreamController<List<Map<String, dynamic>>>.broadcast();
      _messagesController = StreamController<List<Message>>.broadcast();
      _typingController = StreamController<List<Map<String, dynamic>>>.broadcast();

      // Enable offline support
      await FirestoreService.enableOfflineSupport();
    }

    static Future<void> disconnect() async {
      _messagesSubscription?.cancel();
      _chatRoomsSubscription?.cancel();
      _listingsSubscription?.cancel();
      _notificationsSubscription?.cancel();
      _bookingsSubscription?.cancel();

      _chatRoomsController?.close();
      _messagesController?.close();
      _typingController?.close();

      _chatRoomsController = null;
      _messagesController = null;
      _typingController = null;
    }

    static Future<Map<String, dynamic>> createChatRoom(List<String> participants, {Map<String, dynamic>? metadata}) async {
      return await FirebaseApiService.createChatRoom(participants, metadata: metadata);
    }

    static Future<Map<String, dynamic>> createOrGetChat(String participantId, {String? hostelId}) async {
      return await FirebaseApiService.createOrGetChat(participantId, hostelId: hostelId);
    }

    static Future<List<Map<String, dynamic>>> getChatRooms() async {
      try {
        final result = await FirebaseApiService.getChatRooms();
        if (result['success'] == true) {
          final chatRooms = List<Map<String, dynamic>>.from(result['data'] ?? []);
          _chatRoomsController?.add(chatRooms);
          return chatRooms;
        }
        return [];
      } catch (e) {
        debugPrint('Error getting chat rooms: $e');
        return [];
      }
    }

    static Stream<List<Map<String, dynamic>>> get chatRoomsStream {
      return _chatRoomsController?.stream ?? Stream.empty();
    }

    static Future<void> joinChat(String chatId) async {
      _setupMessageListener(chatId);
      _setupChatRoomsListener();
    }

    static Future<void> leaveChat(String chatId) async {
      _messagesSubscription?.cancel();
      _chatRoomsSubscription?.cancel();
    }

    static Future<List<Message>> getChatMessages(String chatId) async {
      try {
        final result = await FirebaseApiService.getChatMessages(chatId);
        if (result['success'] == true) {
          final firebaseMessages = List<Map<String, dynamic>>.from(result['data'] ?? []);
          final messages = firebaseMessages.map((msg) => Message(
            id: msg['id'] as String,
            chatId: chatId,
            sender: MessageSender(
              id: msg['senderId'] as String,
              name: msg['senderName'] as String,
            ),
            content: msg['message'] as String,
            messageType: 'text',
            deliveryStatus: DeliveryStatus(sent: true, delivered: true),
            createdAt: DateTime.fromMillisecondsSinceEpoch(msg['timestamp'] as int),
            formattedTime: _formatMessageTime(msg['timestamp'] as int),
          )).toList();

          _messagesController?.add(messages);
          return messages;
        }
        return [];
      } catch (e) {
        debugPrint('Error getting chat messages: $e');
        return [];
      }
    }

    static Stream<List<Message>> get messagesStream {
      return _messagesController?.stream ?? Stream.empty();
    }

    static Stream<List<Map<String, dynamic>>> get typingStream {
      return _typingController?.stream ?? Stream.empty();
    }

    static Future<Map<String, dynamic>> sendMessage(String chatId, String message) async {
      try {
        // Send via Firestore for real-time delivery and persistence
        final result = await FirebaseApiService.sendMessage(chatId, message);
        return result;
      } catch (e) {
        return {'success': false, 'message': e.toString()};
      }
    }

    static Future<void> startTyping(String chatId) async {
      // Typing indicators can be implemented with Firestore if needed
      // For now, we'll skip this as it's not essential
    }

    static Future<void> stopTyping(String chatId) async {
      // Typing indicators can be implemented with Firestore if needed
      // For now, we'll skip this as it's not essential
    }

    static Future<void> markMessagesAsRead(String chatId) async {
      // Message read status can be implemented with Firestore if needed
      // For now, we'll skip this as it's not essential
    }

    static void _setupMessageListener(String chatId) {
      _messagesSubscription?.cancel();
      _messagesSubscription = RealtimeDatabaseService.listenToChatMessages(chatId).listen((firebaseMessages) {
        final messages = firebaseMessages.map((msg) => Message(
          id: msg['id'] as String,
          chatId: chatId,
          sender: MessageSender(
            id: msg['senderId'] as String,
            name: msg['senderName'] as String? ?? '',
          ),
          content: msg['message'] as String,
          messageType: 'text',
          deliveryStatus: DeliveryStatus(sent: true, delivered: true),
          createdAt: DateTime.fromMillisecondsSinceEpoch(msg['timestamp'] as int),
          formattedTime: _formatMessageTime(msg['timestamp'] as int),
        )).toList();

        _messagesController?.add(messages);
      });
    }

    static void _setupChatRoomsListener() {
      _chatRoomsSubscription?.cancel();
      _chatRoomsSubscription = RealtimeDatabaseService.listenToChatRooms().listen((chatRooms) {
        _chatRoomsController?.add(chatRooms);
      });
    }

    static String _formatMessageTime(int timestamp) {
      final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
      return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    }
  }

  // =================== NOTIFICATION CONTROLLER ===================

  class NotificationController {
    static StreamController<List<Map<String, dynamic>>>? _notificationsController;

    static Future<void> initialize() async {
      _notificationsController = StreamController<List<Map<String, dynamic>>>.broadcast();
    }

    static Future<void> dispose() async {
      _notificationsController?.close();
      _notificationsController = null;
    }

    static Future<void> initializeForUser() async {
      try {
        final user = await AuthController.getCurrentUser();
        if (user['success'] == true) {
          final userId = user['data']['id'];
          await FirebaseApiService.subscribeToChatNotifications(userId);
        }
      } catch (e) {
        debugPrint('Error initializing notifications: $e');
      }
    }

    static Future<void> cleanup() async {
      try {
        final user = await AuthController.getCurrentUser();
        if (user['success'] == true) {
          final userId = user['data']['id'];
          await FirebaseApiService.unsubscribeFromChatNotifications(userId);
        }
      } catch (e) {
        debugPrint('Error cleaning up notifications: $e');
      }
    }

    static Future<void> subscribeToTopic(String topic) async {
      await FirebaseApiService.subscribeToNotifications(topic);
    }

    static Future<void> unsubscribeFromTopic(String topic) async {
      await FirebaseApiService.unsubscribeFromNotifications(topic);
    }

    static Stream<List<Map<String, dynamic>>> listenToNotifications() {
      return FirestoreService.listenToNotifications();
    }
  }

  // =================== LISTINGS CONTROLLER ===================

  class ListingsController {
    static StreamController<List<Map<String, dynamic>>>? _listingsController;

    static Future<void> initialize() async {
      _listingsController = StreamController<List<Map<String, dynamic>>>.broadcast();
    }

    static Future<void> dispose() async {
      _listingsController?.close();
      _listingsController = null;
    }

    static Future<Map<String, dynamic>> getListings({
      int page = 1,
      int limit = 20,
      String? city,
      String? search,
      double? minPrice,
      double? maxPrice,
      List<String>? amenities,
    }) async {
      return await FirebaseApiService.getListings(
        page: page,
        limit: limit,
        city: city,
        search: search,
        minPrice: minPrice,
        maxPrice: maxPrice,
        amenities: amenities,
      );
    }

    static Future<Map<String, dynamic>> toggleFavorite(String listingId) async {
      return await FirebaseApiService.toggleFavorite(listingId);
    }

    static Future<Map<String, dynamic>> checkFavoriteStatus(String listingId) async {
      return await FirebaseApiService.checkFavoriteStatus(listingId);
    }

    static Future<Map<String, dynamic>> getUserFavorites({
      int page = 1,
      int limit = 20,
    }) async {
      return await FirebaseApiService.getUserFavorites(page: page, limit: limit);
    }

    static Stream<List<Map<String, dynamic>>> listenToListings({String? city}) {
      return FirestoreService.listenToListings(city: city);
    }
  }

  // =================== BOOKINGS CONTROLLER ===================

  class BookingsController {
    static Future<Map<String, dynamic>> getUserBookings({String? status}) async {
      return await FirebaseApiService.getUserBookings(status: status);
    }

    static Future<Map<String, dynamic>> createBooking(Map<String, dynamic> bookingData) async {
      return await FirebaseApiService.createBooking(bookingData);
    }

    static Stream<List<Map<String, dynamic>>> listenToUserBookings() {
      return FirestoreService.listenToUserBookings();
    }
  }

  // =================== PROFILE CONTROLLER ===================

  class ProfileController {
    static Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> profileData) async {
      return await FirebaseApiService.updateUserProfile(profileData);
    }

    static Future<Map<String, dynamic>> getDashboard() async {
      return await FirebaseApiService.getStudentDashboard();
    }

    static Future<Map<String, dynamic>> getDashboardStats() async {
      return await FirebaseApiService.getDashboardStats();
    }
  }

  // =================== INITIALIZATION ===================

// =================== SINGLETON INSTANCE ===================

/// Singleton instance for Firebase controllers
class FirebaseControllersManager {
  static final FirebaseControllersManager _instance = FirebaseControllersManager._internal();
  factory FirebaseControllersManager() => _instance;
  FirebaseControllersManager._internal();

  final AuthController auth = AuthController();
  final ChatController chat = ChatController();
  final NotificationController notifications = NotificationController();
  final ListingsController listings = ListingsController();
  final BookingsController bookings = BookingsController();
  final ProfileController profile = ProfileController();

  Future<void> initialize() async {
    await ChatController.initialize();
    await ListingsController.initialize();
    await NotificationController.initialize();
  }

  Future<void> dispose() async {
    await ChatController.disconnect();
    await ListingsController.dispose();
    await NotificationController.dispose();
  }
}

// =================== SINGLETON INSTANCE ===================

/// Singleton instance for Firebase controllers
class FirebaseManager {
  static final FirebaseManager _instance = FirebaseManager._internal();
  factory FirebaseManager() => _instance;
  FirebaseManager._internal();

  final AuthController auth = AuthController();
  final ChatController chat = ChatController();
  final NotificationController notifications = NotificationController();
  final ListingsController listings = ListingsController();
  final BookingsController bookings = BookingsController();
  final ProfileController profile = ProfileController();

  Future<void> initialize() async {
    await ChatController.initialize();
  }

  Future<void> dispose() async {
    await ChatController.disconnect();
  }
}

final FirebaseManager firebaseManager = FirebaseManager();