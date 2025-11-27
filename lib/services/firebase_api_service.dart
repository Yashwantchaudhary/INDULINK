import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../core/config.dart';
import 'firestore_service.dart';
import 'realtime_database_service.dart';
import 'crashlytics_service.dart';
import 'performance_service.dart';

class FirebaseApiService {
  static String get baseUrl => AppConfig.baseUrl;


  // =================== AUTHENTICATION METHODS ===================

  static Future<Map<String, dynamic>> signUpWithEmailPassword({
    required String email,
    required String password,
    required String name,
    String role = 'student',
  }) async {
    return PerformanceService().trackAuthOperation(
      'signup',
      () => PerformanceService().trackApiCall(
        'auth/signup',
        () async {
          try {
            final response = await http.post(
              Uri.parse('$baseUrl/auth/signup'),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({
                'email': email,
                'password': password,
                'name': name,
                'role': role,
              }),
            );

            final data = json.decode(response.body);
            return {
              'success': response.statusCode == 201,
              'message': data['message'] ?? 'Signup successful',
              'data': data['data'],
            };
          } catch (e) {
            // Log authentication error to Crashlytics
            await CrashlyticsService().logAuthError(
              'signUpWithEmailPassword',
              e.toString(),
              parameters: {
                'email': email,
                'role': role,
              },
            );
            return {'success': false, 'message': e.toString()};
          }
        },
        method: 'POST',
        parameters: {'email': email, 'role': role},
      ),
    );
  }

  static Future<Map<String, dynamic>> signInWithEmailPassword(String email, String password) async {
    return PerformanceService().trackAuthOperation(
      'signin',
      () => PerformanceService().trackApiCall(
        'auth/signin',
        () async {
          try {
            final response = await http.post(
              Uri.parse('$baseUrl/auth/signin'),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({
                'email': email,
                'password': password,
              }),
            );

            final data = json.decode(response.body);
            return {
              'success': response.statusCode == 200,
              'message': data['message'] ?? 'Signin successful',
              'data': data['data'],
            };
          } catch (e) {
            // Log authentication error to Crashlytics
            await CrashlyticsService().logAuthError(
              'signInWithEmailPassword',
              e.toString(),
              parameters: {
                'email': email,
              },
            );
            return {'success': false, 'message': e.toString()};
          }
        },
        method: 'POST',
        parameters: {'email': email},
      ),
    );
  }

  static Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/google-signin'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'idToken': await _getGoogleIdToken(),
        }),
      );

      final data = json.decode(response.body);
      return {
        'success': response.statusCode == 200,
        'message': data['message'] ?? 'Google signin successful',
        'data': data['data'],
      };
    } catch (e) {
      // Log authentication error to Crashlytics
      await CrashlyticsService().logAuthError(
        'signInWithGoogle',
        e.toString(),
      );
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<String?> _getGoogleIdToken() async {
    try {
      final user = firebase_auth.FirebaseAuth.instance.currentUser;
      if (user != null) {
        return await user.getIdToken();
      }
      return null;
    } catch (e) {
      debugPrint('Error getting Google ID token: $e');
      return null;
    }
  }

  // =================== NOTIFICATION METHODS ===================

  static Future<Map<String, dynamic>> saveFCMToken(String token) async {
    try {
      final user = firebase_auth.FirebaseAuth.instance.currentUser;
      if (user == null) return {'success': false, 'message': 'User not authenticated'};

      final response = await http.post(
        Uri.parse('$baseUrl/notifications/subscribe'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await user.getIdToken()}',
        },
        body: json.encode({
          'fcmToken': token,
          'platform': defaultTargetPlatform.name,
        }),
      );

      final data = json.decode(response.body);
      return {
        'success': response.statusCode == 200,
        'message': data['message'] ?? 'Token saved successfully',
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> subscribeToNotifications(String topic) async {
    try {
      final user = firebase_auth.FirebaseAuth.instance.currentUser;
      if (user == null) return {'success': false, 'message': 'User not authenticated'};

      final response = await http.post(
        Uri.parse('$baseUrl/notifications/subscribe'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await user.getIdToken()}',
        },
        body: json.encode({
          'topic': topic,
        }),
      );

      final data = json.decode(response.body);
      return {
        'success': response.statusCode == 200,
        'message': data['message'] ?? 'Subscribed successfully',
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> unsubscribeFromNotifications(String topic) async {
    try {
      final user = firebase_auth.FirebaseAuth.instance.currentUser;
      if (user == null) return {'success': false, 'message': 'User not authenticated'};

      final response = await http.post(
        Uri.parse('$baseUrl/notifications/unsubscribe'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await user.getIdToken()}',
        },
        body: json.encode({
          'topic': topic,
        }),
      );

      final data = json.decode(response.body);
      return {
        'success': response.statusCode == 200,
        'message': data['message'] ?? 'Unsubscribed successfully',
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> subscribeToChatNotifications(String userId) async {
    return await subscribeToNotifications('chat_$userId');
  }

  static Future<Map<String, dynamic>> unsubscribeFromChatNotifications(String userId) async {
    return await unsubscribeFromNotifications('chat_$userId');
  }

  // =================== PROFILE METHODS ===================

  static Future<Map<String, dynamic>> getCurrentUserProfile() async {
    return await FirestoreService.getCurrentUserProfile();
  }

  static Future<Map<String, dynamic>> updateUserProfile(Map<String, dynamic> profileData) async {
    return await FirestoreService.updateUserProfile(profileData);
  }

  // =================== LISTINGS METHODS ===================

  static Future<Map<String, dynamic>> getListings({
    int page = 1,
    int limit = 20,
    String? city,
    String? search,
    double? minPrice,
    double? maxPrice,
    List<String>? amenities,
  }) async {
    try {
      return await FirestoreService.getListings(
        page: page,
        limit: limit,
        city: city,
        search: search,
        minPrice: minPrice,
        maxPrice: maxPrice,
        amenities: amenities,
      );
    } catch (e) {
      // Log API error to Crashlytics
      await CrashlyticsService().logApiError(
        'getListings',
        null,
        e.toString(),
        requestData: {
          'page': page,
          'limit': limit,
          'city': city,
          'search': search,
          'minPrice': minPrice,
          'maxPrice': maxPrice,
          'amenities': amenities,
        },
      );
      rethrow;
    }
  }

  // =================== BOOKINGS METHODS ===================

  static Future<Map<String, dynamic>> getUserBookings({String? status}) async {
    try {
      return await FirestoreService.getUserBookings(status: status);
    } catch (e) {
      // Log API error to Crashlytics
      await CrashlyticsService().logApiError(
        'getUserBookings',
        null,
        e.toString(),
        requestData: {
          'status': status,
        },
      );
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> createBooking(Map<String, dynamic> bookingData) async {
    try {
      return await FirestoreService.createBooking(bookingData);
    } catch (e) {
      // Log API error to Crashlytics
      await CrashlyticsService().logApiError(
        'createBooking',
        null,
        e.toString(),
        requestData: bookingData,
      );
      rethrow;
    }
  }

  // =================== FAVORITES METHODS ===================

  static Future<Map<String, dynamic>> toggleFavorite(String listingId) async {
    return await FirestoreService.toggleFavorite(listingId);
  }

  static Future<Map<String, dynamic>> checkFavoriteStatus(String listingId) async {
    return await FirestoreService.checkFavoriteStatus(listingId);
  }

  static Future<Map<String, dynamic>> getUserFavorites({
    int page = 1,
    int limit = 20,
  }) async {
    return await FirestoreService.getUserFavorites(page: page, limit: limit);
  }

  // =================== CHAT METHODS ===================

  static Future<Map<String, dynamic>> createChatRoom(List<String> participants, {Map<String, dynamic>? metadata}) async {
    return await RealtimeDatabaseService.createChatRoom(participants, metadata: metadata);
  }

  static Future<Map<String, dynamic>> createOrGetChat(String participantId, {String? hostelId}) async {
    return await RealtimeDatabaseService.createOrGetChat(participantId, hostelId: hostelId);
  }

  static Future<Map<String, dynamic>> getChatRooms() async {
    return await RealtimeDatabaseService.getChatRooms();
  }

  static Future<Map<String, dynamic>> getChatMessages(String chatId) async {
    return await RealtimeDatabaseService.getChatMessages(chatId);
  }

  static Future<Map<String, dynamic>> sendMessage(String chatId, String message) async {
    return await RealtimeDatabaseService.sendMessage(chatId, message);
  }


  // =================== DASHBOARD METHODS ===================

  static Future<Map<String, dynamic>> getStudentDashboard() async {
    return await FirestoreService.getStudentDashboard();
  }

  static Future<Map<String, dynamic>> getDashboardStats() async {
    return await FirestoreService.getDashboardStats();
  }

  // =================== PASSWORD RESET METHODS ===================

  static Future<Map<String, dynamic>> sendPasswordResetEmail(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );

      final data = json.decode(response.body);
      return {
        'success': response.statusCode == 200,
        'message': data['message'] ?? 'Reset email sent successfully',
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // =================== SMS VERIFICATION METHODS ===================

  static Future<Map<String, dynamic>> verifyPhoneNumber(String phoneNumber) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verification/send-sms'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'phoneNumber': phoneNumber}),
      );

      final data = json.decode(response.body);
      return {
        'success': response.statusCode == 200,
        'data': data['data'],
        'message': data['message'] ?? 'SMS sent successfully',
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> verifySmsCode(String verificationId, String code) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verification/verify-sms'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'verificationId': verificationId,
          'code': code,
        }),
      );

      final data = json.decode(response.body);
      return {
        'success': response.statusCode == 200,
        'data': data['data'],
        'message': data['message'] ?? 'SMS verified successfully',
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> resetPasswordWithPhone(String phoneNumber, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/reset-password-phone'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'phoneNumber': phoneNumber,
          'newPassword': newPassword,
        }),
      );

      final data = json.decode(response.body);
      return {
        'success': response.statusCode == 200,
        'message': data['message'] ?? 'Password reset successfully',
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // =================== SIGN OUT ===================

  static Future<void> signOut() async {
    try {
      await firebase_auth.FirebaseAuth.instance.signOut();
    } catch (e) {
      debugPrint('Error signing out: $e');
    }
  }
}