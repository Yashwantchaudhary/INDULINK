import 'package:firebase_performance/firebase_performance.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class PerformanceService {
  static final FirebasePerformance _performance = FirebasePerformance.instance;

  // Singleton pattern
  static final PerformanceService _instance = PerformanceService._internal();

  factory PerformanceService() => _instance;

  PerformanceService._internal();

  // Get the performance instance
  FirebasePerformance get performance => _performance;

  // Initialize Firebase Performance
  static Future<void> initialize() async {
    try {
      // Enable performance monitoring
      await _performance.setPerformanceCollectionEnabled(true);
      debugPrint('✅ Firebase Performance initialized successfully');
    } catch (e) {
      // Handle initialization errors gracefully
      debugPrint('❌ Firebase Performance initialization failed: $e');
    }
  }

  // Create a custom trace
  Trace createTrace(String name) {
    try {
      return _performance.newTrace(name);
    } catch (e) {
      debugPrint('Error creating trace "$name": $e');
      rethrow;
    }
  }

  // Start a trace with automatic error handling
  Future<T> traceOperation<T>(
    String traceName,
    Future<T> Function(Trace trace) operation, {
    Map<String, String>? attributes,
  }) async {
    final trace = createTrace(traceName);

    try {
      // Set attributes if provided
      if (attributes != null) {
        attributes.forEach((key, value) {
          trace.putAttribute(key, value);
        });
      }

      // Start the trace
      await trace.start();

      // Execute the operation
      final result = await operation(trace);

      // Stop the trace
      await trace.stop();

      return result;
    } catch (e) {
      // Record the error in the trace
      trace.putAttribute('error', e.toString());
      await trace.stop();
      rethrow;
    }
  }

  // Create HTTP metric for manual tracking
  // HttpMetric createHttpMetric(String url) {
  //   try {
  //     // HttpMethod parameter removed in newer versions
  //     return _performance.newHttpMetric(url);
  //   } catch (e) {
  //     debugPrint('Error creating HTTP metric for $url: $e');
  //     rethrow;
  //   }
  // }

  // Track HTTP request with automatic metric collection
  Future<http.Response> trackHttpRequest(
    String url,
    Future<http.Response> Function() request, {
    Map<String, String>? headers,
  }) async {
    // Firebase Performance HTTP tracking temporarily disabled due to API changes
    return await request();
  }

  // Track screen loading time
  Future<void> trackScreenLoad(
    String screenName,
    Future<void> Function() screenLoadOperation,
  ) async {
    await traceOperation(
      'screen_load_$screenName',
      (trace) async {
        trace?.putAttribute('screen_name', screenName);
        await screenLoadOperation();
      },
    );
  }

  // Track authentication operation
  Future<T> trackAuthOperation<T>(
    String operationName,
    Future<T> Function() authOperation,
  ) async {
    return traceOperation(
      'auth_$operationName',
      (trace) async {
        trace?.putAttribute('auth_operation', operationName);
        return await authOperation();
      },
    );
  }

  // Track API call
  Future<T> trackApiCall<T>(
    String endpoint,
    Future<T> Function() apiCall, {
    String? method = 'GET',
    Map<String, String>? parameters,
  }) async {
    return traceOperation(
      'api_call_$endpoint',
      (trace) async {
        trace?.putAttribute('api_endpoint', endpoint);
        trace?.putAttribute('api_method', method ?? 'GET');

        if (parameters != null) {
          parameters.forEach((key, value) {
            trace?.putAttribute('param_$key', value);
          });
        }

        return await apiCall();
      },
    );
  }

  // Enable/disable performance collection
  Future<void> setPerformanceCollectionEnabled(bool enabled) async {
    try {
      await _performance.setPerformanceCollectionEnabled(enabled);
      debugPrint('Performance collection ${enabled ? 'enabled' : 'disabled'}');
    } catch (e) {
      debugPrint('Error setting performance collection: $e');
    }
  }

  // Check if performance collection is enabled
  Future<bool> isPerformanceCollectionEnabled() async {
    try {
      return await _performance.isPerformanceCollectionEnabled() ?? false;
    } catch (e) {
      debugPrint('Error checking performance collection status: $e');
      return false;
    }
  }
}