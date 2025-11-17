import 'package:flutter/foundation.dart';

class AppConfig {
  // For mobile testing, use computer's IP address instead of localhost
  static const String _devBaseUrl = 'http://10.10.10.25:5001/api';
  static const String _devSocketUrl = 'http://10.10.10.25:5001';
  static const String _prodBaseUrl = 'https://api.hostelfinder.com/api';
  static const String _prodSocketUrl = 'https://api.hostelfinder.com';

  static String get baseUrl {
    // In production, you can set this via environment variables
    // For now, we'll use kReleaseMode to determine
    if (kReleaseMode) {
      return const String.fromEnvironment('API_BASE_URL', defaultValue: _prodBaseUrl);
    }
    return const String.fromEnvironment('API_BASE_URL', defaultValue: _devBaseUrl);
  }

  static String get socketUrl {
    if (kReleaseMode) {
      return const String.fromEnvironment('SOCKET_BASE_URL', defaultValue: _prodSocketUrl);
    }
    return const String.fromEnvironment('SOCKET_BASE_URL', defaultValue: _devSocketUrl);
  }

  static bool get isProduction => kReleaseMode;

  static String get environment => isProduction ? 'production' : 'development';
}