import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // Singleton pattern
  static final AnalyticsService _instance = AnalyticsService._internal();

  factory AnalyticsService() => _instance;

  AnalyticsService._internal();

  // Get the analytics instance
  FirebaseAnalytics get analytics => _analytics;

  // Initialize Firebase Analytics
  static Future<void> initialize() async {
    try {
      // Firebase Analytics is automatically initialized with Firebase Core
      // Additional configuration can be done here if needed
      await _analytics.setAnalyticsCollectionEnabled(true);
    } catch (e) {
      // Handle initialization errors gracefully
      print('Firebase Analytics initialization failed: $e');
    }
  }

  // Log screen view
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'screen_view',
        parameters: {
          'screen_name': screenName,
          'screen_class': screenClass ?? screenName,
        },
      );
    } catch (e) {
      print('Error logging screen view: $e');
    }
  }

  // Log custom event
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    try {
      await _analytics.logEvent(
        name: name,
        parameters: parameters,
      );
    } catch (e) {
      print('Error logging event: $e');
    }
  }

  // Log user interaction events
  Future<void> logButtonTap(String buttonName, {Map<String, Object>? parameters}) async {
    await logEvent(
      name: 'button_tap',
      parameters: {
        'button_name': buttonName,
        ...?parameters,
      },
    );
  }

  // Log search events
  Future<void> logSearch(String searchTerm, {Map<String, Object>? parameters}) async {
    await logEvent(
      name: 'search',
      parameters: {
        'search_term': searchTerm,
        ...?parameters,
      },
    );
  }

  // Log booking events
  Future<void> logBookingStart({Map<String, Object>? parameters}) async {
    await logEvent(
      name: 'begin_checkout',
      parameters: parameters,
    );
  }

  Future<void> logBookingComplete({Map<String, Object>? parameters}) async {
    await logEvent(
      name: 'purchase',
      parameters: parameters,
    );
  }

  // Log user engagement events
  Future<void> logUserEngagement(String engagementType, {Map<String, Object>? parameters}) async {
    await logEvent(
      name: 'user_engagement',
      parameters: {
        'engagement_type': engagementType,
        ...?parameters,
      },
    );
  }

  // Set user properties
  Future<void> setUserProperty(String name, String? value) async {
    try {
      await _analytics.setUserProperty(name: name, value: value);
    } catch (e) {
      print('Error setting user property: $e');
    }
  }

  // Set user ID
  Future<void> setUserId(String? userId) async {
    try {
      await _analytics.setUserId(id: userId);
    } catch (e) {
      print('Error setting user ID: $e');
    }
  }

  // Enable/disable analytics collection
  Future<void> setAnalyticsCollectionEnabled(bool enabled) async {
    try {
      await _analytics.setAnalyticsCollectionEnabled(enabled);
    } catch (e) {
      print('Error setting analytics collection: $e');
    }
  }
}