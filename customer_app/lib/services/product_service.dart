import '../models/product.dart';
import 'api_client.dart';

class ProductService {
  final ApiClient _client;

  ProductService(this._client);

  // Get all products with filters
  Future<List<Product>> getProducts({
    String? category,
    String? search,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _client.get(
        '/products',
        queryParameters: {
          if (category != null) 'category': category,
          if (search != null) 'search': search,
          if (minPrice != null) 'minPrice': minPrice,
          if (maxPrice != null) 'maxPrice': maxPrice,
          if (sortBy != null) 'sortBy': sortBy,
          'page': page,
          'limit': limit,
        },
      );

      return (response.data['products'] as List)
          .map((json) => Product.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get single product by ID
  Future<Product> getProduct(String id) async {
    try {
      final response = await _client.get('/products/$id');
      return Product.fromJson(response.data['product']);
    } catch (e) {
      rethrow;
    }
  }

  // Get featured products
  Future<List<Product>> getFeaturedProducts({int limit = 10}) async {
    try {
      final response = await _client.get(
        '/products/featured',
        queryParameters: {'limit': limit},
      );

      return (response.data['products'] as List)
          .map((json) => Product.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Search products
  Future<List<Product>> searchProducts(String query, {int limit = 20}) async {
    try {
      final response = await _client.get(
        '/products/search',
        queryParameters: {
          'q': query,
          'limit': limit,
        },
      );

      return (response.data['products'] as List)
          .map((json) => Product.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get supplier products
  Future<List<Product>> getSupplierProducts(String supplierId) async {
    try {
      final response = await _client.get('/products/supplier/$supplierId');

      return (response.data['products'] as List)
          .map((json) => Product.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get my products (for current supplier)
  Future<List<Product>> getMyProducts() async {
    try {
      final response = await _client.get('/products/supplier/me');

      return (response.data['products'] as List)
          .map((json) => Product.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Create product (supplier only)
  Future<Product> createProduct({
    required String title,
    required String description,
    required double price,
    double? compareAtPrice,
    required String categoryId,
    required int stock,
    List<String>? images,
    List<String>? tags,
  }) async {
    try {
      final response = await _client.post(
        '/products',
        data: {
          'title': title,
          'description': description,
          'price': price,
          if (compareAtPrice != null) 'compareAtPrice': compareAtPrice,
          'category': categoryId,
          'stock': stock,
          if (images != null) 'images': images,
          if (tags != null) 'tags': tags,
        },
      );

      return Product.fromJson(response.data['product']);
    } catch (e) {
      rethrow;
    }
  }

  // Update product (supplier only)
  Future<Product> updateProduct(
    String id, {
    String? title,
    String? description,
    double? price,
    double? compareAtPrice,
    String? categoryId,
    int? stock,
    List<String>? images,
    bool? isFeatured,
  }) async {
    try {
      final response = await _client.put(
        '/products/$id',
        data: {
          if (title != null) 'title': title,
          if (description != null) 'description': description,
          if (price != null) 'price': price,
          if (compareAtPrice != null) 'compareAtPrice': compareAtPrice,
          if (categoryId != null) 'category': categoryId,
          if (stock != null) 'stock': stock,
          if (images != null) 'images': images,
          if (isFeatured != null) 'isFeatured': isFeatured,
        },
      );

      return Product.fromJson(response.data['product']);
    } catch (e) {
      rethrow;
    }
  }

  // Delete product (supplier only)
  Future<void> deleteProduct(String id) async {
    try {
      await _client.delete('/products/$id');
    } catch (e) {
      rethrow;
    }
  }

  // Track product view
  Future<void> trackView(String id) async {
    try {
      await _client.post('/products/$id/view');
    } catch (e) {
      // Fail silently for analytics
    }
  }

  // Get product by SKU/Barcode
  Future<Product?> getProductBySKU(String sku) async {
    try {
      final response = await _client.get('/products/barcode/$sku');
      return Product.fromJson(response.data['data']);
    } catch (e) {
      return null; // Return null if product not found
    }
  }

  // Get AI recommendations
  Future<List<Product>> getRecommendations({int limit = 10}) async {
    try {
      final response = await _client.get(
        '/products/recommendations',
        queryParameters: {'limit': limit},
      );

      return (response.data['products'] as List)
          .map((json) => Product.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
