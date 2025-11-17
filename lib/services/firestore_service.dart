import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/chat.dart';
import '../models/message.dart';
import '../models/user.dart';

class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Diagnostic: Check Firebase initialization
  static void _logFirebaseStatus() {
    debugPrint('🔍 FirestoreService: Firebase Auth current user: ${_auth.currentUser?.uid ?? 'null'}');
    debugPrint('🔍 FirestoreService: Firestore instance initialized');
  }

  // =================== USER PROFILE METHODS ===================

  static Future<Map<String, dynamic>> getCurrentUserProfile() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {'success': false, 'message': 'User not authenticated'};
      }

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          return <String, dynamic>{
            'success': true,
            'data': <String, dynamic>{
              'id': user.uid,
              ...data,
            },
          };
        }
      }
      return <String, dynamic>{'success': false, 'message': 'User profile not found'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> updateUserProfile(Map<String, dynamic> profileData) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {'success': false, 'message': 'User not authenticated'};
      }

      await _firestore.collection('users').doc(user.uid).update({
        ...profileData,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return {
        'success': true,
        'message': 'Profile updated successfully',
        'data': profileData,
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
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
      Query query = _firestore.collection('listings').where('isActive', isEqualTo: true);

      if (city != null && city.isNotEmpty) {
        query = query.where('city', isEqualTo: city);
      }

      if (minPrice != null) {
        query = query.where('price', isGreaterThanOrEqualTo: minPrice);
      }

      if (maxPrice != null) {
        query = query.where('price', isLessThanOrEqualTo: maxPrice);
      }

      // For amenities, we'll filter client-side since Firestore array-contains-any has limitations
      QuerySnapshot snapshot = await query
          .orderBy('createdAt', descending: true)
          .limit(limit * page)
          .get();

      List<Map<String, dynamic>> listings = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      }).toList();

      // Client-side filtering for amenities and search
      if (amenities != null && amenities.isNotEmpty) {
        listings = listings.where((listing) {
          final listingAmenities = List<String>.from(listing['amenities'] ?? []);
          return amenities.any((amenity) => listingAmenities.contains(amenity));
        }).toList();
      }

      if (search != null && search.isNotEmpty) {
        final searchLower = search.toLowerCase();
        listings = listings.where((listing) {
          final title = (listing['title'] ?? '').toString().toLowerCase();
          final description = (listing['description'] ?? '').toString().toLowerCase();
          final city = (listing['city'] ?? '').toString().toLowerCase();
          return title.contains(searchLower) ||
                 description.contains(searchLower) ||
                 city.contains(searchLower);
        }).toList();
      }

      // Pagination
      final startIndex = (page - 1) * limit;
      final endIndex = startIndex + limit;
      final paginatedListings = listings.length > startIndex
          ? listings.sublist(startIndex, endIndex.clamp(0, listings.length))
          : [];

      return {
        'success': true,
        'data': paginatedListings,
        'total': listings.length,
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // =================== BOOKINGS METHODS ===================

  static Future<Map<String, dynamic>> getUserBookings({String? status}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {'success': false, 'message': 'User not authenticated'};
      }

      Query query = _firestore.collection('bookings').where('userId', isEqualTo: user.uid);

      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }

      final snapshot = await query.orderBy('createdAt', descending: true).get();

      final bookings = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        return <String, dynamic>{
          'id': doc.id,
          ...data,
        };
      }).toList();

      return {
        'success': true,
        'data': bookings,
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> createBooking(Map<String, dynamic> bookingData) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {'success': false, 'message': 'User not authenticated'};
      }

      final docRef = await _firestore.collection('bookings').add({
        ...bookingData,
        'userId': user.uid,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return {
        'success': true,
        'data': {
          'id': docRef.id,
          ...bookingData,
        },
        'message': 'Booking created successfully',
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // =================== FAVORITES METHODS ===================

  static Future<Map<String, dynamic>> toggleFavorite(String listingId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {'success': false, 'message': 'User not authenticated'};
      }

      final favoriteRef = _firestore.collection('favorites').doc('${user.uid}_$listingId');

      final doc = await favoriteRef.get();
      if (doc.exists) {
        // Remove favorite
        await favoriteRef.delete();
        return {
          'success': true,
          'data': {'isFavorite': false},
          'message': 'Removed from favorites',
        };
      } else {
        // Add favorite
        await favoriteRef.set({
          'userId': user.uid,
          'listingId': listingId,
          'createdAt': FieldValue.serverTimestamp(),
        });
        return {
          'success': true,
          'data': {'isFavorite': true},
          'message': 'Added to favorites',
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> checkFavoriteStatus(String listingId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {'success': false, 'message': 'User not authenticated'};
      }

      final doc = await _firestore.collection('favorites').doc('${user.uid}_$listingId').get();

      return {
        'success': true,
        'data': {'isFavorite': doc.exists},
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getUserFavorites({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {'success': false, 'message': 'User not authenticated'};
      }

      final favoritesSnapshot = await _firestore
          .collection('favorites')
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .limit(limit * page)
          .get();

      final listingIds = favoritesSnapshot.docs.map((doc) => doc['listingId'] as String).toList();

      if (listingIds.isEmpty) {
        return {
          'success': true,
          'data': [],
        };
      }

      // Get listings data
      final listingsSnapshot = await _firestore.collection('listings').where(FieldPath.documentId, whereIn: listingIds).get();

      final listings = listingsSnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }).toList();

      // Sort by favorite creation date
      final favoriteMap = Map.fromEntries(
        favoritesSnapshot.docs.map((doc) => MapEntry(doc['listingId'], doc['createdAt']))
      );

      listings.sort((a, b) {
        final aTime = favoriteMap[a['id']] as Timestamp?;
        final bTime = favoriteMap[b['id']] as Timestamp?;
        if (aTime == null || bTime == null) return 0;
        return bTime.compareTo(aTime);
      });

      // Pagination
      final startIndex = (page - 1) * limit;
      final endIndex = startIndex + limit;
      final paginatedListings = listings.length > startIndex
          ? listings.sublist(startIndex, endIndex.clamp(0, listings.length))
          : [];

      return {
        'success': true,
        'data': paginatedListings,
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // =================== CHAT METHODS ===================

  static Future<Map<String, dynamic>> createChatRoom(List<String> participants, {Map<String, dynamic>? metadata}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {'success': false, 'message': 'User not authenticated'};
      }

      // Check if chat room already exists
      final existingChat = await _findExistingChat(participants);
      if (existingChat != null) {
        return {
          'success': true,
          'data': existingChat,
          'message': 'Chat room already exists',
        };
      }

      final chatData = {
        'participants': participants,
        'createdBy': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'lastMessage': '',
        'lastMessageSender': '',
        'lastMessageTime': null,
        'metadata': metadata,
      };

      final docRef = await _firestore.collection('chats').add(chatData);

      return {
        'success': true,
        'data': {
          'id': docRef.id,
          ...chatData,
        },
        'message': 'Chat room created successfully',
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>?> _findExistingChat(List<String> participants) async {
    try {
      final query = await _firestore.collection('chats')
          .where('participants', arrayContains: participants.first)
          .get();

      for (final doc in query.docs) {
        final chatParticipants = List<String>.from(doc['participants'] ?? []);
        if (chatParticipants.length == participants.length &&
            chatParticipants.every((p) => participants.contains(p))) {
          return {
            'id': doc.id,
            ...doc.data(),
          };
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>> createOrGetChat(String participantId, {String? hostelId}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {'success': false, 'message': 'User not authenticated'};
      }

      final participants = [user.uid, participantId];
      final existingChat = await _findExistingChat(participants);

      if (existingChat != null) {
        return {
          'success': true,
          'data': existingChat,
        };
      }

      return await createChatRoom(participants, metadata: hostelId != null ? {'hostelId': hostelId} : null);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getChatRooms() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {'success': false, 'message': 'User not authenticated'};
      }

      final snapshot = await _firestore.collection('chats')
          .where('participants', arrayContains: user.uid)
          .orderBy('lastMessageTime', descending: true)
          .get();

      final chats = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }).toList();

      return {
        'success': true,
        'data': chats,
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getChatMessages(String chatId) async {
    try {
      final snapshot = await _firestore.collection('chats').doc(chatId).collection('messages')
          .orderBy('timestamp', descending: false)
          .get();

      final messages = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }).toList();

      return {
        'success': true,
        'data': messages,
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> sendMessage(String chatId, String message) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {'success': false, 'message': 'User not authenticated'};
      }

      final messageData = {
        'senderId': user.uid,
        'senderName': '', // Will be populated by cloud function or client-side
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'messageType': 'text',
        'status': 'sent',
      };

      final messageRef = await _firestore.collection('chats').doc(chatId).collection('messages').add(messageData);

      // Update chat's last message
      await _firestore.collection('chats').doc(chatId).update({
        'lastMessage': message,
        'lastMessageSender': user.uid,
        'lastMessageTime': FieldValue.serverTimestamp(),
      });

      return {
        'success': true,
        'data': {
          'id': messageRef.id,
          ...messageData,
        },
        'message': 'Message sent successfully',
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // =================== DASHBOARD METHODS ===================

  static Future<Map<String, dynamic>> getStudentDashboard() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {'success': false, 'message': 'User not authenticated'};
      }

      // Get user profile
      final profileResult = await getCurrentUserProfile();
      if (!profileResult['success']) {
        return profileResult;
      }

      // Get recent bookings
      final bookingsResult = await getUserBookings();
      final recentBookings = bookingsResult['success'] == true
          ? (bookingsResult['data'] as List).take(5).toList()
          : [];

      // Get favorite listings count
      final favoritesResult = await getUserFavorites();
      final favoritesCount = favoritesResult['success'] == true
          ? (favoritesResult['data'] as List).length
          : 0;

      return {
        'success': true,
        'data': {
          'profile': profileResult['data'],
          'recentBookings': recentBookings,
          'favoritesCount': favoritesCount,
        },
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // =================== ADMIN METHODS ===================

  static Future<Map<String, dynamic>> getAdminStats() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {'success': false, 'message': 'User not authenticated'};
      }

      // Get all users count
      final usersSnapshot = await _firestore.collection('users').get();
      final totalUsers = usersSnapshot.docs.length;
      final activeUsers = usersSnapshot.docs.where((doc) {
        final data = doc.data();
        return data['isActive'] != false; // Assuming isActive field
      }).length;

      // Get all listings count
      final listingsSnapshot = await _firestore.collection('listings').get();
      final totalProperties = listingsSnapshot.docs.length;
      final activeProperties = listingsSnapshot.docs.where((doc) {
        final data = doc.data();
        return data['isActive'] == true;
      }).length;

      // Get all bookings count
      final bookingsSnapshot = await _firestore.collection('bookings').get();
      final totalBookings = bookingsSnapshot.docs.length;
      final confirmedBookings = bookingsSnapshot.docs.where((doc) {
        final data = doc.data();
        return data['status'] == 'confirmed';
      }).length;

      // Calculate total revenue from confirmed bookings
      int totalRevenue = 0;
      for (final doc in bookingsSnapshot.docs) {
        final data = doc.data();
        if (data['status'] == 'confirmed' && data['amount'] != null) {
          totalRevenue += (data['amount'] as num).toInt();
        }
      }

      // Get average rating from reviews
      final reviewsSnapshot = await _firestore.collection('reviews').get();
      double avgRating = 0.0;
      if (reviewsSnapshot.docs.isNotEmpty) {
        final ratings = reviewsSnapshot.docs.map((doc) => doc.data()['rating'] as num? ?? 0).toList();
        avgRating = ratings.reduce((a, b) => a + b) / ratings.length;
      }

      return {
        'success': true,
        'data': {
          'totalUsers': totalUsers,
          'activeUsers': activeUsers,
          'totalProperties': totalProperties,
          'activeProperties': activeProperties,
          'totalBookings': totalBookings,
          'confirmedBookings': confirmedBookings,
          'totalRevenue': totalRevenue,
          'avgRating': avgRating,
        },
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getAllUsers({int page = 1, int limit = 20}) async {
    try {
      final snapshot = await _firestore.collection('users')
          .orderBy('createdAt', descending: true)
          .limit(limit * page)
          .get();

      final users = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }).toList();

      // Pagination
      final startIndex = (page - 1) * limit;
      final endIndex = startIndex + limit;
      final paginatedUsers = users.length > startIndex
          ? users.sublist(startIndex, endIndex.clamp(0, users.length))
          : [];

      return {
        'success': true,
        'data': paginatedUsers,
        'total': users.length,
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getAllListings({int page = 1, int limit = 20}) async {
    try {
      final snapshot = await _firestore.collection('listings')
          .orderBy('createdAt', descending: true)
          .limit(limit * page)
          .get();

      final listings = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }).toList();

      // Pagination
      final startIndex = (page - 1) * limit;
      final endIndex = startIndex + limit;
      final paginatedListings = listings.length > startIndex
          ? listings.sublist(startIndex, endIndex.clamp(0, listings.length))
          : [];

      return {
        'success': true,
        'data': paginatedListings,
        'total': listings.length,
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getAllBookings({int page = 1, int limit = 20}) async {
    try {
      final snapshot = await _firestore.collection('bookings')
          .orderBy('createdAt', descending: true)
          .limit(limit * page)
          .get();

      final bookings = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }).toList();

      // Pagination
      final startIndex = (page - 1) * limit;
      final endIndex = startIndex + limit;
      final paginatedBookings = bookings.length > startIndex
          ? bookings.sublist(startIndex, endIndex.clamp(0, bookings.length))
          : [];

      return {
        'success': true,
        'data': paginatedBookings,
        'total': bookings.length,
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getAllReviews({int page = 1, int limit = 20}) async {
    try {
      final snapshot = await _firestore.collection('reviews')
          .orderBy('createdAt', descending: true)
          .limit(limit * page)
          .get();

      final reviews = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }).toList();

      // Pagination
      final startIndex = (page - 1) * limit;
      final endIndex = startIndex + limit;
      final paginatedReviews = reviews.length > startIndex
          ? reviews.sublist(startIndex, endIndex.clamp(0, reviews.length))
          : [];

      return {
        'success': true,
        'data': paginatedReviews,
        'total': reviews.length,
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {'success': false, 'message': 'User not authenticated'};
      }

      // Get booking stats
      final bookingsSnapshot = await _firestore.collection('bookings')
          .where('userId', isEqualTo: user.uid)
          .get();

      final bookings = bookingsSnapshot.docs;
      final totalBookings = bookings.length;
      final pendingBookings = bookings.where((doc) => doc['status'] == 'pending').length;
      final confirmedBookings = bookings.where((doc) => doc['status'] == 'confirmed').length;

      return {
        'success': true,
        'data': {
          'totalBookings': totalBookings,
          'pendingBookings': pendingBookings,
          'confirmedBookings': confirmedBookings,
        },
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // =================== REAL-TIME LISTENERS ===================

  static Stream<List<Map<String, dynamic>>> listenToChatMessages(String chatId) {
    return _firestore.collection('chats').doc(chatId).collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return {
              'id': doc.id,
              ...doc.data(),
            };
          }).toList();
        });
  }

  static Stream<List<Map<String, dynamic>>> listenToChatRooms() {
    final user = _auth.currentUser;
    if (user == null) return Stream.empty();

    return _firestore.collection('chats')
        .where('participants', arrayContains: user.uid)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return {
              'id': doc.id,
              ...doc.data(),
            };
          }).toList();
        });
  }

  static Stream<List<Map<String, dynamic>>> listenToNotifications() {
    final user = _auth.currentUser;
    if (user == null) return Stream.empty();

    return _firestore.collection('notifications')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return {
              'id': doc.id,
              ...doc.data(),
            };
          }).toList();
        });
  }

  static Stream<List<Map<String, dynamic>>> listenToListings({String? city}) {
    Query query = _firestore.collection('listings').where('isActive', isEqualTo: true);

    if (city != null && city.isNotEmpty) {
      query = query.where('city', isEqualTo: city);
    }

    return query
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>? ?? {};
            return <String, dynamic>{
              'id': doc.id,
              ...data,
            };
          }).toList();
        });
  }

  static Stream<List<Map<String, dynamic>>> listenToUserBookings() {
    final user = _auth.currentUser;
    if (user == null) return Stream.empty();

    return _firestore.collection('bookings')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return {
              'id': doc.id,
              ...doc.data(),
            };
          }).toList();
        });
  }

  // =================== OFFLINE SUPPORT ===================

  static Future<void> enableOfflineSupport() async {
    try {
      _firestore.settings = const Settings(persistenceEnabled: true);
      debugPrint('Offline support enabled');
    } catch (e) {
      debugPrint('Error enabling offline support: $e');
    }
  }

  static Future<void> disableOfflineSupport() async {
    try {
      _firestore.settings = const Settings(persistenceEnabled: false);
      debugPrint('Offline support disabled');
    } catch (e) {
      debugPrint('Error disabling offline support: $e');
    }
  }
}