import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class CrashlyticsService {
  static final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  // Singleton pattern
  static final CrashlyticsService _instance = CrashlyticsService._internal();

  factory CrashlyticsService() => _instance;

  CrashlyticsService._internal();

  // Get the crashlytics instance
  FirebaseCrashlytics get crashlytics => _crashlytics;

  // Initialize Firebase Crashlytics
  static Future<void> initialize() async {
    try {
      // Pass all uncaught errors from the framework to Crashlytics
      FlutterError.onError = _crashlytics.recordFlutterFatalError;

      // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
      PlatformDispatcher.instance.onError = (error, stack) {
        _crashlytics.recordError(error, stack, fatal: true);
        return true;
      };

      // Enable crashlytics collection (can be controlled by user consent)
      await _crashlytics.setCrashlyticsCollectionEnabled(true);

      debugPrint('✅ Firebase Crashlytics initialized successfully');
    } catch (e) {
      // Handle initialization errors gracefully
      debugPrint('❌ Firebase Crashlytics initialization failed: $e');
    }
  }

  // Log a caught exception
  Future<void> logException(
    dynamic exception,
    StackTrace? stackTrace, {
    String? reason,
    Map<String, dynamic>? information,
    bool fatal = false,
  }) async {
    try {
      await _crashlytics.recordError(
        exception,
        stackTrace,
        reason: reason,
        fatal: fatal,
      );
    } catch (e) {
      debugPrint('Error logging exception to Crashlytics: $e');
    }
  }

  // Log a custom error message
  Future<void> logError(
    String message, {
    Map<String, dynamic>? parameters,
    StackTrace? stackTrace,
  }) async {
    try {
      await _crashlytics.log(message);
      if (parameters != null) {
        for (final entry in parameters.entries) {
          await _crashlytics.setCustomKey(entry.key, entry.value);
        }
      }
      if (stackTrace != null) {
        await _crashlytics.recordError(
          Exception(message),
          stackTrace,
          reason: 'Logged error',
        );
      }
    } catch (e) {
      debugPrint('Error logging error to Crashlytics: $e');
    }
  }

  // Set custom key for additional context
  Future<void> setCustomKey(String key, dynamic value) async {
    try {
      await _crashlytics.setCustomKey(key, value);
    } catch (e) {
      debugPrint('Error setting custom key in Crashlytics: $e');
    }
  }

  // Set multiple custom keys
  Future<void> setCustomKeys(Map<String, dynamic> keys) async {
    try {
      for (final entry in keys.entries) {
        await _crashlytics.setCustomKey(entry.key, entry.value);
      }
    } catch (e) {
      debugPrint('Error setting custom keys in Crashlytics: $e');
    }
  }

  // Set user identifier
  Future<void> setUserId(String? userId) async {
    try {
      await _crashlytics.setUserIdentifier(userId ?? '');
    } catch (e) {
      debugPrint('Error setting user ID in Crashlytics: $e');
    }
  }

  // Log user action or event
  Future<void> logUserAction(String action, {Map<String, dynamic>? parameters}) async {
    try {
      await _crashlytics.log('User action: $action');
      if (parameters != null) {
        await setCustomKeys(parameters);
      }
    } catch (e) {
      debugPrint('Error logging user action to Crashlytics: $e');
    }
  }

  // Log API call failure
  Future<void> logApiError(
    String endpoint,
    int? statusCode,
    String? errorMessage, {
    Map<String, dynamic>? requestData,
    Map<String, dynamic>? responseData,
  }) async {
    try {
      await setCustomKeys({
        'api_endpoint': endpoint,
        'api_status_code': statusCode ?? 'unknown',
        'api_error_message': errorMessage ?? 'unknown',
        if (requestData != null) 'api_request_data': requestData.toString(),
        if (responseData != null) 'api_response_data': responseData.toString(),
      });
      await _crashlytics.log('API Error: $endpoint - $statusCode - $errorMessage');
    } catch (e) {
      debugPrint('Error logging API error to Crashlytics: $e');
    }
  }

  // Log authentication error
  Future<void> logAuthError(String operation, String error, {Map<String, dynamic>? parameters}) async {
    try {
      await setCustomKeys({
        'auth_operation': operation,
        'auth_error': error,
        ...?parameters,
      });
      await _crashlytics.log('Authentication Error: $operation - $error');
    } catch (e) {
      debugPrint('Error logging auth error to Crashlytics: $e');
    }
  }

  // Enable/disable crash reporting based on user consent
  Future<void> setCrashReportingEnabled(bool enabled) async {
    try {
      await _crashlytics.setCrashlyticsCollectionEnabled(enabled);
      await setCustomKey('crash_reporting_enabled', enabled);
    } catch (e) {
      debugPrint('Error setting crash reporting enabled: $e');
    }
  }

  // Check if crash reporting is enabled
  Future<bool> isCrashReportingEnabled() async {
    try {
      return _crashlytics.isCrashlyticsCollectionEnabled;
    } catch (e) {
      debugPrint('Error checking crash reporting status: $e');
      return false;
    }
  }

  // Force a crash for testing (only in debug mode)
  void forceCrash() {
    if (kDebugMode) {
      _crashlytics.crash();
    }
  }
}