import 'dart:io';
import 'package:flutter/foundation.dart';

class AppConfig {
  // API Configuration - Dynamic based on platform
  static String get apiBaseUrl {
    // For web builds, use 127.0.0.1 (more reliable than localhost for CORS)
    if (kIsWeb) {
      return 'http://127.0.0.1:5000/api';
    }
    // For physical devices, use the computer's IP (try different formats)
    if (Platform.isAndroid || Platform.isIOS) {
      // Primary IP address - update this to match your computer's IP
      return 'http://10.10.9.113:5000/api';
      // Alternative IPs to try if the above doesn't work:
      // return 'http://192.168.137.1:5000/api';  // Virtual network adapter
      // return 'http://192.168.1.100:5000/api';  // Alternative subnet
      // return 'http://10.0.0.2:5000/api';       // Common Android emulator IP
    }
    // For emulators and other platforms, use localhost
    return 'http://localhost:5000/api';
  }

  // API URL is now automatically configured based on platform:
  // - Android/iOS physical devices: http://10.10.9.232:5000/api (your PC's IP)
  // - Emulators/Simulators/Web: http://localhost:5000/api
  // Backend runs on port 5000 by default
  // For web development, ensure backend has CORS enabled

  // Debug method to check current API URL
  static void printCurrentApiUrl() {
    print('🔗 Current API Base URL: $apiBaseUrl');
    print('🌐 Platform: ${kIsWeb ? 'Web' : Platform.isAndroid ? 'Android' : Platform.isIOS ? 'iOS' : 'Other'}');
  }

  // Test connection to backend
  static Future<bool> testConnection() async {
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 5);

      // Health endpoint is at root level, not under /api
      final baseUrl = apiBaseUrl.replaceAll('/api', '');
      final uri = Uri.parse('$baseUrl/health');
      print('🔍 Testing connection to: $uri');

      final request = await client.getUrl(uri);
      final response = await request.close();

      if (response.statusCode == 200) {
        print('✅ Backend connection successful: ${response.statusCode}');
        return true;
      } else {
        print('❌ Backend responded with status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Connection failed: $e');
      print('💡 Troubleshooting steps:');
      print('   1. Backend server is running: cd backend && npm start');
      print('   2. Check if port 5000 is open: netstat -ano | findstr :5000');
      print('   3. Firewall: Allow Node.js through Windows Firewall');
      print('   4. IP address is correct: $apiBaseUrl');
      print('   5. Same WiFi network for both devices');
      print('   6. Try alternative IPs: 192.168.137.1, 192.168.1.100');
      return false;
    }
  }
  
  static const String apiVersion = 'v1';
  
  // App Configuration
  static const String appName = 'Indulink';
  static const int defaultPageSize = 20;
  static const int maxFileSize = 5 * 1024 * 1024; // 5MB
  
  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Storage Keys
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUser = 'user';
  static const String keyOnboardingCompleted = 'onboarding_completed';
}
