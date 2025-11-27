import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'auth_state.dart';
import 'user_profile_state.dart';
import 'app_data_state.dart';

/// Unified App State that coordinates between AuthState, UserProfileState, and AppDataState
class AppState extends ChangeNotifier {
  final AuthState _authState;
  final UserProfileState _userProfileState;
  final AppDataState _appDataState;

  AppState()
      : _authState = AuthState(),
        _userProfileState = UserProfileState(),
        _appDataState = AppDataState() {
    // Listen to auth state changes to coordinate profile loading
    _authState.addListener(_onAuthStateChanged);
  }

  // =================== COORDINATED GETTERS ===================

  // Auth getters
  firebase_auth.User? get firebaseUser => _authState.firebaseUser;
  bool get isLoading => _authState.isLoading || _userProfileState.isLoadingProfile;
  bool get isAuthenticated => _authState.isAuthenticated && _userProfileState.currentUser != null;
  String? get authError => _authState.errorMessage;

  // User profile getters
  get currentUser => _userProfileState.currentUser;
  bool get isLoadingProfile => _userProfileState.isLoadingProfile;
  String? get profileError => _userProfileState.errorMessage;

  // App data getters
  List<Map<String, dynamic>> get listings => _appDataState.listings;
  bool get isLoadingListings => _appDataState.isLoadingListings;
  Map<String, dynamic>? get listingsFilters => _appDataState.listingsFilters;

  List<Map<String, dynamic>> get bookings => _appDataState.bookings;
  bool get isLoadingBookings => _appDataState.isLoadingBookings;

  int get unreadNotifications => _appDataState.unreadNotifications;
  List<Map<String, dynamic>> get notifications => _appDataState.notifications;
  bool get isLoadingNotifications => _appDataState.isLoadingNotifications;

  // Combined error getter
  String? get errorMessage => _authState.errorMessage ?? _userProfileState.errorMessage ?? _appDataState.errorMessage;

  // =================== COORDINATION LOGIC ===================

  Future<void> _onAuthStateChanged() async {
    if (_authState.isAuthenticated) {
      // User is authenticated, load their profile
      await _userProfileState.loadUserProfile();
    } else {
      // User is not authenticated, clear profile and app data
      _userProfileState.clearProfile();
      _appDataState.clearData();
    }
    notifyListeners();
  }

  // =================== AUTHENTICATION METHODS ===================

  Future<bool> signUpWithEmailPassword({
    required String email,
    required String password,
    required String name,
    String role = 'student',
  }) async {
    final result = await _authState.signUpWithEmailPassword(
      email: email,
      password: password,
      name: name,
      role: role,
    );
    notifyListeners();
    return result;
  }

  Future<bool> signInWithEmailPassword(String email, String password) async {
    final result = await _authState.signInWithEmailPassword(email, password);
    notifyListeners();
    return result;
  }

  Future<bool> signInWithGoogle() async {
    final result = await _authState.signInWithGoogle();
    notifyListeners();
    return result;
  }

  Future<void> signOut() async {
    await _authState.signOut();
    // Profile and data clearing is handled by _onAuthStateChanged
    notifyListeners();
  }

  // =================== PROFILE METHODS ===================

  Future<bool> updateProfile(Map<String, dynamic> profileData) async {
    final result = await _userProfileState.updateProfile(profileData);
    notifyListeners();
    return result;
  }

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
    await _appDataState.loadListings(
      page: page,
      limit: limit,
      city: city,
      search: search,
      minPrice: minPrice,
      maxPrice: maxPrice,
      amenities: amenities,
    );
    notifyListeners();
  }

  Future<void> refreshListings() async {
    await _appDataState.refreshListings();
    notifyListeners();
  }

  // =================== BOOKINGS METHODS ===================

  Future<void> loadUserBookings({String? status}) async {
    await _appDataState.loadUserBookings(status: status);
    notifyListeners();
  }

  Future<bool> createBooking(Map<String, dynamic> bookingData) async {
    final result = await _appDataState.createBooking(bookingData);
    notifyListeners();
    return result;
  }

  // =================== NOTIFICATIONS METHODS ===================

  Future<void> loadNotifications({int page = 1, int limit = 20}) async {
    await _appDataState.loadNotifications(page: page, limit: limit);
    notifyListeners();
  }

  // =================== UTILITY METHODS ===================

  void clearError() {
    _authState.clearError();
    _userProfileState.clearError();
    _appDataState.clearError();
    notifyListeners();
  }

  // =================== NOTIFICATION SUBSCRIPTION ===================

  Future<void> subscribeToNotifications(String topic) async {
    await _appDataState.subscribeToNotifications(topic);
    notifyListeners();
  }

  Future<void> unsubscribeFromNotifications(String topic) async {
    await _appDataState.unsubscribeFromNotifications(topic);
    notifyListeners();
  }
}