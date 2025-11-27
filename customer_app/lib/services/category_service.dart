import 'package:dio/dio.dart';
import '../models/category.dart';
import '../config/app_config.dart';

/// Category service for API communication
class CategoryService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConfig.apiBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  /// Get all categories
  Future<List<Category>> getCategories() async {
    try {
      final response = await _dio.get('/categories');

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((json) => Category.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch categories');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Handle errors
  String _handleError(DioException error) {
    if (error.response != null) {
      final data = error.response!.data;
      if (data is Map && data.containsKey('message')) {
        return data['message'];
      }
      return 'Server error: ${error.response!.statusCode}';
    } else if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'Connection timeout. Please try again.';
    } else if (error.type == DioExceptionType.unknown) {
      return 'Network error. Please check your connection.';
    }
    return 'An unexpected error occurred';
  }
}
