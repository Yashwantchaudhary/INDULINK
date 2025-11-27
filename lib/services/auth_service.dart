import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../core/app_state.dart';

class AuthService extends ChangeNotifier {
  final AppState _appState;

  AuthService(this._appState);

  // Get current user
  firebase_auth.User? get firebaseUser => _appState.firebaseUser;
  dynamic get currentUser => _appState.currentUser;

  // Get authentication token
  Future<String?> getToken() async {
    try {
      final user = firebase_auth.FirebaseAuth.instance.currentUser;
      if (user != null) {
        return await user.getIdToken();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}