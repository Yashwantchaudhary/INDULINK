import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../models/cart.dart';

/// Cart service for managing shopping cart operations
class CartService {
  final Dio _dio;

  CartService({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: AppConfig.apiBaseUrl,
              headers: {
                'Content-Type': 'application/json',
              },
            ));

  /// Set authorization token
  void setToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Get user's cart
  Future<Cart> getCart() async {
    try {
      final response = await _dio.get('/cart');

      if (response.statusCode == 200 && response.data['success'] == true) {
        return Cart.fromJson(response.data['data']);
      } else {
        // Return empty cart if not found
        return Cart.empty();
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return Cart.empty();
      }
      throw _handleError(e);
    }
  }

  /// Add item to cart
  Future<Cart> addToCart({
    required String productId,
    required int quantity,
  }) async {
    try {
      final response = await _dio.post(
        '/cart',
        data: {
          'product': productId,
          'quantity': quantity,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return Cart.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to add item to cart');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Update cart item quantity
  Future<Cart> updateCartItem({
    required String itemId,
    required int quantity,
  }) async {
    try {
      final response = await _dio.put(
        '/cart/$itemId',
        data: {
          'quantity': quantity,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return Cart.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to update cart item');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Remove item from cart
  Future<Cart> removeFromCart(String itemId) async {
    try {
      final response = await _dio.delete('/cart/$itemId');

      if (response.statusCode == 200 && response.data['success'] == true) {
        return Cart.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to remove item from cart');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Clear entire cart
  Future<void> clearCart() async {
    try {
      await _dio.delete('/cart');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Handle Dio errors
  String _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['message'];
        if (statusCode == 401) {
          return 'Unauthorized. Please login again.';
        } else if (statusCode == 404) {
          return 'Resource not found.';
        } else if (statusCode == 400) {
          return message ?? 'Invalid request.';
        } else if (statusCode == 500) {
          return 'Server error. Please try again later.';
        }
        return message ?? 'An error occurred. Please try again.';
      case DioExceptionType.cancel:
        return 'Request cancelled.';
      case DioExceptionType.unknown:
        return 'Network error. Please check your internet connection.';
      default:
        return 'An unexpected error occurred.';
    }
  }
}
