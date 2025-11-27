import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import '../firebase_options.dart';
import '../services/firebase_api_service.dart';
import '../controllers/firebase_controllers.dart';

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // Check if Firebase is already initialized
    if (firebase_core.Firebase.apps.isEmpty) {
      debugPrint('⚠️  Firebase not initialized yet, initializing in NotificationService...');
      try {
        await firebase_core.Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        debugPrint('✅ Firebase Core initialized successfully in NotificationService');
      } catch (e) {
        debugPrint('❌ Firebase Core initialization failed in NotificationService: $e');
        return; // Cannot continue without Firebase
      }
    } else {
      debugPrint('✅ Firebase already initialized, proceeding with notifications');
    }

    // Request permission for notifications
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('✅ User granted notification permission');
    } else {
      debugPrint('⚠️  User declined or has not accepted notification permission');
    }

    // Initialize local notifications
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Get FCM token
    String? token = await _firebaseMessaging.getToken();
    debugPrint('FCM Token: $token');

    // Save token to backend if user is logged in
    if (token != null) {
      await _saveTokenToBackend(token);
    }

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_onMessageReceived);

    // Handle notification taps when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

    // Listen to real-time notifications via Firestore
    _setupFirestoreNotificationListener();
  }

  static Future<void> _saveTokenToBackend(String token) async {
    try {
      await FirebaseApiService.saveFCMToken(token);
    } catch (e) {
      debugPrint('Error saving FCM token: $e');
    }
  }

  static Future<void> _onMessageReceived(RemoteMessage message) async {
    debugPrint('Received message: ${message.notification?.title}');

    // Show local notification for foreground messages
    if (message.notification != null) {
      await _showLocalNotification(
        title: message.notification!.title ?? 'Notification',
        body: message.notification!.body ?? '',
        payload: message.data.toString(),
      );
    }
  }

  static Future<void> _onMessageOpenedApp(RemoteMessage message) async {
    debugPrint('Message opened: ${message.notification?.title}');
    // Handle navigation based on message data
    _handleNotificationNavigation(message.data);
  }

  static void _onNotificationTap(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // Handle navigation based on payload
    if (response.payload != null) {
      // Parse payload and navigate
      _handleNotificationNavigation(_parsePayload(response.payload!));
    }
  }

  static Map<String, dynamic> _parsePayload(String payload) {
    try {
      // Simple parsing - in real app, use proper JSON parsing
      Map<String, dynamic> data = {};
      payload.split(',').forEach((element) {
        final parts = element.split(':');
        if (parts.length == 2) {
          data[parts[0].trim()] = parts[1].trim();
        }
      });
      return data;
    } catch (e) {
      return {};
    }
  }

  static void _handleNotificationNavigation(Map<String, dynamic> data) {
    // Handle different types of notifications
    final type = data['type'];
    final id = data['id'];

    switch (type) {
      case 'booking':
        // Navigate to booking details
        debugPrint('Navigate to booking: $id');
        break;
      case 'message':
        // Navigate to chat
        debugPrint('Navigate to chat: $id');
        break;
      case 'listing':
        // Navigate to listing details
        debugPrint('Navigate to listing: $id');
        break;
      default:
        debugPrint('Unknown notification type: $type');
    }
  }

  static Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'hostel_finder_channel',
      'Hostel Finder Notifications',
      channelDescription: 'Notifications for hostel finder app',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000, // Unique ID
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  static Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  static Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }

  static Future<void> updateToken() async {
    String? token = await _firebaseMessaging.getToken();
    if (token != null) {
      await _saveTokenToBackend(token);
    }
  }

  static void _setupFirestoreNotificationListener() {
    NotificationController.listenToNotifications().listen((notifications) {
      for (final notification in notifications) {
        // Handle real-time notification from Firestore
        final title = notification['title'] as String? ?? 'Notification';
        final body = notification['message'] as String? ?? '';
        final notificationData = notification['data'] as Map<String, dynamic>? ?? {};

        // Show local notification
        _showLocalNotification(
          title: title,
          body: body,
          payload: notificationData.toString(),
        );

        // Handle navigation based on notification type
        _handleNotificationNavigation(notificationData);
      }
    });
  }
}

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Background message: ${message.notification?.title}');
  // Handle background messages here
}