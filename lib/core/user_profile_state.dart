import 'package:flutter/foundation.dart';
import '../models/user.dart' as app_user;
import '../services/firebase_api_service.dart';

/// State class for managing user profile data
class UserProfileState extends ChangeNotifier {
  app_user.User? _currentUser;
  bool _isLoadingProfile = false;
  String? _errorMessage;

  // Getters
  app_user.User? get currentUser => _currentUser;
  bool get isLoadingProfile => _isLoadingProfile;
  String? get errorMessage => _errorMessage;

  /// Load user profile from backend
  Future<bool> loadUserProfile() async {
    try {
      _isLoadingProfile = true;
      _errorMessage = null;
      notifyListeners();

      final userProfile = await FirebaseApiService.getCurrentUserProfile();
      if (userProfile['success'] == true) {
        _currentUser = app_user.User.fromJson(userProfile['data']);
        _isLoadingProfile = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to load user profile from server';
        _currentUser = null;
        _isLoadingProfile = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Failed to load user data: $e';
      _currentUser = null;
      _isLoadingProfile = false;
      notifyListeners();
      return false;
    }
  }

  /// Update user profile
  Future<bool> updateProfile(Map<String, dynamic> profileData) async {
    try {
      _errorMessage = null;
      notifyListeners();

      final result = await FirebaseApiService.updateUserProfile(profileData);

      if (result['success'] == true) {
        _currentUser = app_user.User.fromJson(result['data']);
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Failed to update profile';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Clear user profile data (on logout)
  void clearProfile() {
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Set loading state
  void setLoading(bool loading) {
    _isLoadingProfile = loading;
    notifyListeners();
  }
}