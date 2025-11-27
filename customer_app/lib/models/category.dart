/// Category model
library;

class Category {
  final String id;
  final String name;
  final String description;
  final String? image;
  final int productCount;
  final bool isActive;
  final DateTime createdAt;

  Category({
    required this.id,
    required this.name,
    required this.description,
    this.image,
    this.productCount = 0,
    this.isActive = true,
    required this.createdAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      image: json['image'],
      productCount: json['productCount'] ?? 0,
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'name': name,
        'description': description,
        'image': image,
        'productCount': productCount,
        'isActive': isActive,
        'createdAt': createdAt.toIso8601String(),
      };
}
