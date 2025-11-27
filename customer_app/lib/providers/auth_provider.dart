import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/firebase_auth_service.dart';
import '../config/firebase_config.dart';

// Auth State
class AuthState {
  final User? user;
  final String? token;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  AuthState({
    this.user,
    this.token,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    User? user,
    String? token,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      user: user ?? this.user,
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

// Auth Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService = AuthService();
  final FirebaseAuthService _firebaseAuthService = FirebaseAuthService();

  AuthNotifier() : super(AuthState()) {
    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    try {
      await FirebaseConfig.initialize();
      await checkAuthStatus();
    } catch (e) {
      print('Firebase initialization error: $e');
      // Continue with local auth if Firebase fails
      await checkAuthStatus();
    }
  }

  // Check if user is already logged in
  Future<void> checkAuthStatus() async {
    final isLoggedIn = await _authService.isLoggedIn();
    if (isLoggedIn) {
      final user = await _authService.getCurrentUser();
      state = state.copyWith(
        user: user,
        isAuthenticated: true,
      );
    }
  }

  // Login
  Future<bool> login(String email, String password, {String? role}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Try Firebase login first
      final firebaseResult = await _firebaseAuthService.signInWithEmail(email, password);

      if (firebaseResult['success']) {
        state = state.copyWith(
          user: firebaseResult['user'],
          isLoading: false,
          isAuthenticated: true,
        );
        return true;
      } else {
        // Fallback to regular API if Firebase fails
        final result = await _authService.login(
          email: email,
          password: password,
          role: role,
        );

        if (result['success']) {
          state = state.copyWith(
            user: result['user'],
            isLoading: false,
            isAuthenticated: true,
          );
          return true;
        } else {
          state = state.copyWith(
            isLoading: false,
            error: result['message'],
          );
          return false;
        }
      }
    } catch (e) {
      // Fallback to regular API
      final result = await _authService.login(
        email: email,
        password: password,
        role: role,
      );

      if (result['success']) {
        state = state.copyWith(
          user: result['user'],
          isLoading: false,
          isAuthenticated: true,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: result['message'] ?? e.toString(),
        );
        return false;
      }
    }
  }

  // Register
  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phone,
    String role = 'customer',
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Try Firebase registration first
      final firebaseResult = await _firebaseAuthService.signUpWithEmail(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        role: role,
      );

      if (firebaseResult['success']) {
        final user = firebaseResult['user'] as User;
        state = state.copyWith(
          user: user,
          isLoading: false,
          isAuthenticated: true,
        );

        // Subscribe to messaging topics
        try {
          await FirebaseConfig.messagingService.subscribeToUserTopics(
            user.id,
            user.role,
          );
        } catch (e) {
          print('Failed to subscribe to messaging topics: $e');
        }

        return true;
      } else {
        // Fallback to regular API if Firebase fails
        final result = await _authService.register(
          firstName: firstName,
          lastName: lastName,
          email: email,
          password: password,
          phone: phone,
          role: role,
        );

        if (result['success']) {
          final user = result['user'] as User;
          state = state.copyWith(
            user: user,
            isLoading: false,
            isAuthenticated: true,
          );
    
          // Subscribe to messaging topics
          try {
            await FirebaseConfig.messagingService.subscribeToUserTopics(
              user.id,
              user.role,
            );
          } catch (e) {
            print('Failed to subscribe to messaging topics: $e');
          }
    
          return true;
        } else {
          state = state.copyWith(
            isLoading: false,
            error: result['message'],
          );
          return false;
        }
      }
    } catch (e) {
      // Fallback to regular API
      final result = await _authService.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        phone: phone,
        role: role,
      );

      if (result['success']) {
        state = state.copyWith(
          user: result['user'],
          isLoading: false,
          isAuthenticated: true,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: result['message'] ?? e.toString(),
        );
        return false;
      }
    }
  }

  // Google Sign In
  Future<bool> signInWithGoogle({String? role}) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _firebaseAuthService.signInWithGoogle(role: role);

    if (result['success']) {
      state = state.copyWith(
        user: result['user'],
        isLoading: false,
        isAuthenticated: true,
      );
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        error: result['message'],
      );
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    await _authService.logout();
    await _firebaseAuthService.signOut();
    state = AuthState();
  }

  // Forgot Password
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    
    final result = await _authService.forgotPassword(email);
    
    state = state.copyWith(
      isLoading: false,
      error: result['success'] ? null : result['message'],
    );
    
    return result;
  }

  // Reset Password
  Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    final result = await _authService.resetPassword(
      token: token,
      newPassword: newPassword,
    );
    
    state = state.copyWith(
      isLoading: false,
      error: result['success'] ? null : result['message'],
    );
    
    return result;
  }

  // Update Password
  Future<Map<String, dynamic>> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    final result = await _authService.updatePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
    
    state = state.copyWith(
      isLoading: false,
      error: result['success'] ? null : result['message'],
    );
    
    return result;
  }

  // Upload Profile Image
  Future<void> uploadProfileImage(dynamic imageFile) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final result = await _authService.uploadProfileImage(imageFile);
      
      if (result['success'] && result['user'] != null) {
        state = state.copyWith(
          user: result['user'],
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: result['message'] ?? 'Failed to upload image',
        );
        throw Exception(result['message'] ?? 'Failed to upload image');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Update Profile
  Future<void> updateProfile({
    required String name,
    required String email,
    required String phone,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final result = await _authService.updateProfile(
        name: name,
        email: email,
        phone: phone,
      );
      
      if (result['success'] && result['user'] != null) {
        state = state.copyWith(
          user: result['user'],
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: result['message'] ?? 'Failed to update profile',
        );
        throw Exception(result['message'] ?? 'Failed to update profile');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Update user
  void updateUser(User user) {
    state = state.copyWith(user: user);
  }
}

// Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
