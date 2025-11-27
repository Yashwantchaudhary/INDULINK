import 'package:flutter/foundation.dart';
import '../services/firebase_api_service.dart';

/// State class for managing app-wide data (listings, bookings, notifications)
class AppDataState extends ChangeNotifier {
  // =================== LISTINGS STATE ===================

  List<Map<String, dynamic>> _listings = [];
  bool _isLoadingListings = false;
  Map<String, dynamic>? _listingsFilters;

  List<Map<String, dynamic>> get listings => _listings;
  bool get isLoadingListings => _isLoadingListings;
  Map<String, dynamic>? get listingsFilters => _listingsFilters;

  // =================== BOOKINGS STATE ===================

  List<Map<String, dynamic>> _bookings = [];
  bool _isLoadingBookings = false;

  List<Map<String, dynamic>> get bookings => _bookings;
  bool get isLoadingBookings => _isLoadingBookings;

  // =================== NOTIFICATIONS STATE ===================

  int _unreadNotifications = 0;
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoadingNotifications = false;

  int get unreadNotifications => _unreadNotifications;
  List<Map<String, dynamic>> get notifications => _notifications;
  bool get isLoadingNotifications => _isLoadingNotifications;

  // =================== ERROR STATE ===================

  String? _errorMessage;

  String? get errorMessage => _errorMessage;

  // =================== LISTINGS METHODS ===================

  Future<void> loadListings({
    int page = 1,
    int limit = 20,
    String? city,
    String? search,
    double? minPrice,
    double? maxPrice,
    List<String>? amenities,
  }) async {
    try {
      _isLoadingListings = true;
      _errorMessage = null;
      notifyListeners();

      final result = await FirebaseApiService.getListings(
        page: page,
        limit: limit,
        city: city,
        search: search,
        minPrice: minPrice,
        maxPrice: maxPrice,
        amenities: amenities,
      );

      if (result['success'] == true) {
        if (page == 1) {
          _listings = List<Map<String, dynamic>>.from(result['data'] ?? []);
        } else {
          _listings.addAll(List<Map<String, dynamic>>.from(result['data'] ?? []));
        }

        _listingsFilters = {
          'page': page,
          'city': city,
          'search': search,
          'minPrice': minPrice,
          'maxPrice': maxPrice,
          'amenities': amenities,
        };
      } else {
        _errorMessage = result['message'] ?? 'Failed to load listings';
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoadingListings = false;
      notifyListeners();
    }
  }

  Future<void> refreshListings() async {
    if (_listingsFilters != null) {
      await loadListings(
        page: 1,
        limit: 20,
        city: _listingsFilters!['city'],
        search: _listingsFilters!['search'],
        minPrice: _listingsFilters!['minPrice'],
        maxPrice: _listingsFilters!['maxPrice'],
        amenities: _listingsFilters!['amenities'],
      );
    }
  }

  // =================== BOOKINGS METHODS ===================

  Future<void> loadUserBookings({String? status}) async {
    try {
      _isLoadingBookings = true;
      _errorMessage = null;
      notifyListeners();

      final result = await FirebaseApiService.getUserBookings(status: status);

      if (result['success'] == true) {
        _bookings = List<Map<String, dynamic>>.from(result['data'] ?? []);
      } else {
        _errorMessage = result['message'] ?? 'Failed to load bookings';
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoadingBookings = false;
      notifyListeners();
    }
  }

  Future<bool> createBooking(Map<String, dynamic> bookingData) async {
    try {
      _errorMessage = null;
      notifyListeners();

      final result = await FirebaseApiService.createBooking(bookingData);

      if (result['success'] == true) {
        // Refresh bookings
        await loadUserBookings();
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Failed to create booking';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // =================== NOTIFICATIONS METHODS ===================

  Future<void> loadNotifications({int page = 1, int limit = 20}) async {
    try {
      _isLoadingNotifications = true;
      _errorMessage = null;
      notifyListeners();

      // This would use the notification service to get notifications from backend
      // For now, we'll initialize with empty list
      _notifications = [];
      _unreadNotifications = 0;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoadingNotifications = false;
      notifyListeners();
    }
  }

  // =================== UTILITY METHODS ===================

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearData() {
    _bookings.clear();
    _notifications.clear();
    _unreadNotifications = 0;
    _listings.clear();
    _errorMessage = null;
    notifyListeners();
  }

  // =================== NOTIFICATION SUBSCRIPTION ===================

  Future<void> subscribeToNotifications(String topic) async {
    try {
      await FirebaseApiService.subscribeToNotifications(topic);
    } catch (e) {
      _errorMessage = 'Failed to subscribe to notifications: $e';
      notifyListeners();
    }
  }

  Future<void> unsubscribeFromNotifications(String topic) async {
    try {
      await FirebaseApiService.unsubscribeFromNotifications(topic);
    } catch (e) {
      _errorMessage = 'Failed to unsubscribe from notifications: $e';
      notifyListeners();
    }
  }
}