class Wishlist {
  final String id;
  final String userId;
  final List<String> productIds;
  final DateTime updatedAt;

  Wishlist({
    required this.id,
    required this.userId,
    this.productIds = const [],
    required this.updatedAt,
  });

  factory Wishlist.fromJson(Map<String, dynamic> json) {
    return Wishlist(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      productIds: (json['products'] as List<dynamic>?)
              ?.map((p) => p['productId'].toString())
              .toList() ??
          [],
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'products': productIds.map((id) => {'productId': id}).toList(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  bool contains(String productId) => productIds.contains(productId);

  int get count => productIds.length;

  bool get isEmpty => productIds.isEmpty;
}
