import 'package:flutter/foundation.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfigService {
  static final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  // Singleton pattern
  static final RemoteConfigService _instance = RemoteConfigService._internal();

  factory RemoteConfigService() => _instance;

  RemoteConfigService._internal();

  // Get the remote config instance
  FirebaseRemoteConfig get remoteConfig => _remoteConfig;

  // Initialize Firebase Remote Config
  static Future<void> initialize() async {
    try {
      // Set default values
      await _setDefaults();

      // Configure remote config settings
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 1),
      ));

      // Fetch and activate
      await fetchAndActivate();

      debugPrint('✅ Firebase Remote Config initialized successfully');
    } catch (e) {
      debugPrint('❌ Firebase Remote Config initialization failed: $e');
      // Continue with defaults if initialization fails
    }
  }

  // Set default configuration values
  static Future<void> _setDefaults() async {
    try {
      await _remoteConfig.setDefaults({
        // Feature flags
        'chat_enabled': true,
        'dark_mode_default': false,
        'advanced_search_enabled': true,

        // UI configurations
        'max_search_results': 50,
        'primary_color': 'blue',
        'app_title': 'Hostel Finder',

        // Behavior settings
        'auto_refresh_interval': 30, // seconds
        'max_image_upload_size': 5, // MB
        'booking_timeout': 15, // minutes

        // Experimental features
        'new_ui_enabled': false,
        'beta_features_enabled': false,
      });
    } catch (e) {
      debugPrint('Error setting remote config defaults: $e');
    }
  }

  // Fetch latest configuration from server
  static Future<void> fetch() async {
    try {
      await _remoteConfig.fetch();
    } catch (e) {
      debugPrint('Error fetching remote config: $e');
    }
  }

  // Activate fetched configuration
  static Future<bool> activate() async {
    try {
      return await _remoteConfig.activate();
    } catch (e) {
      debugPrint('Error activating remote config: $e');
      return false;
    }
  }

  // Fetch and activate in one call
  static Future<bool> fetchAndActivate() async {
    try {
      await fetch();
      return await activate();
    } catch (e) {
      debugPrint('Error in fetchAndActivate: $e');
      return false;
    }
  }

  // Get boolean configuration value
  bool getBool(String key) {
    try {
      return _remoteConfig.getBool(key);
    } catch (e) {
      debugPrint('Error getting bool config for $key: $e');
      return false; // Return false as safe default
    }
  }

  // Get string configuration value
  String getString(String key) {
    try {
      return _remoteConfig.getString(key);
    } catch (e) {
      debugPrint('Error getting string config for $key: $e');
      return ''; // Return empty string as safe default
    }
  }

  // Get integer configuration value
  int getInt(String key) {
    try {
      return _remoteConfig.getInt(key);
    } catch (e) {
      debugPrint('Error getting int config for $key: $e');
      return 0; // Return 0 as safe default
    }
  }

  // Get double configuration value
  double getDouble(String key) {
    try {
      return _remoteConfig.getDouble(key);
    } catch (e) {
      debugPrint('Error getting double config for $key: $e');
      return 0.0; // Return 0.0 as safe default
    }
  }

  // Get value with custom default
  T getValue<T>(String key, T defaultValue) {
    try {
      if (T == bool) {
        return (_remoteConfig.getBool(key) as T) ?? defaultValue;
      } else if (T == String) {
        return (_remoteConfig.getString(key) as T) ?? defaultValue;
      } else if (T == int) {
        return (_remoteConfig.getInt(key) as T) ?? defaultValue;
      } else if (T == double) {
        return (_remoteConfig.getDouble(key) as T) ?? defaultValue;
      } else {
        return defaultValue;
      }
    } catch (e) {
      debugPrint('Error getting config value for $key: $e');
      return defaultValue;
    }
  }

  // Get last fetch status
  RemoteConfigFetchStatus get lastFetchStatus => _remoteConfig.lastFetchStatus;

  // Get last fetch time
  DateTime? get lastFetchTime => _remoteConfig.lastFetchTime;
}
