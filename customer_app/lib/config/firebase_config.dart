import 'package:firebase_core/firebase_core.dart';
import '../services/firebase_messaging_service.dart';

class FirebaseConfig {
  static const String apiKey = 'AIzaSyAUOsqAjjeK_9TrO2HGdLq5xUdEzVirKm4';
  static const String projectId = 'indulink-b2b';
  static const String messagingSenderId = '123456789';
  static const String appId = '1:123456789:android:abcdef123456';

  static FirebaseMessagingService? _messagingService;

  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: apiKey,
        appId: appId,
        messagingSenderId: messagingSenderId,
        projectId: projectId,
      ),
    );

    // Initialize messaging service
    _messagingService = FirebaseMessagingService();
    await _messagingService!.initialize();
  }

  static FirebaseMessagingService get messagingService {
    if (_messagingService == null) {
      throw Exception('Firebase not initialized. Call initialize() first.');
    }
    return _messagingService!;
  }
}
