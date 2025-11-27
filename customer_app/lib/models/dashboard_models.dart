/// Dashboard data models for customer and supplier analytics

class CustomerDashboardData {
  final CustomerStats stats;
  final List<OrderSummary> recentOrders;
  final List<OrderSummary> activeOrders;

  CustomerDashboardData({
    required this.stats,
    required this.recentOrders,
    required this.activeOrders,
  });

  factory CustomerDashboardData.fromJson(Map<String, dynamic> json) {
    return CustomerDashboardData(
      stats: CustomerStats.fromJson(json['stats'] ?? {}),
      recentOrders: (json['recentOrders'] as List<dynamic>?)
              ?.map((e) => OrderSummary.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      activeOrders: (json['activeOrders'] as List<dynamic>?)
              ?.map((e) => OrderSummary.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stats': stats.toJson(),
      'recentOrders': recentOrders.map((e) => e.toJson()).toList(),
      'activeOrders': activeOrders.map((e) => e.toJson()).toList(),
    };
  }
}

class CustomerStats {
  final int totalOrders;
  final double totalSpent;
  final int deliveredOrders;
  final int pendingOrders;

  CustomerStats({
    required this.totalOrders,
    required this.totalSpent,
    required this.deliveredOrders,
    this.pendingOrders = 0,
  });

  factory CustomerStats.fromJson(Map<String, dynamic> json) {
    return CustomerStats(
      totalOrders: (json['totalOrders'] as num?)?.toInt() ?? 0,
      totalSpent: (json['totalSpent'] as num?)?.toDouble() ?? 0.0,
      deliveredOrders: (json['deliveredOrders'] as num?)?.toInt() ?? 0,
      pendingOrders: (json['pendingOrders'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalOrders': totalOrders,
      'totalSpent': totalSpent,
      'deliveredOrders': deliveredOrders,
      'pendingOrders': pendingOrders,
    };
  }
}

class SupplierDashboardData {
  final RevenueData revenue;
  final List<OrderStatusData> ordersByStatus;
  final List<TopProduct> topProducts;
  final List<RevenueOverTime> revenueOverTime;
  final ProductStats productStats;
  final List<OrderSummary> recentOrders;

  SupplierDashboardData({
    required this.revenue,
    required this.ordersByStatus,
    required this.topProducts,
    required this.revenueOverTime,
    required this.productStats,
    required this.recentOrders,
  });

  factory SupplierDashboardData.fromJson(Map<String, dynamic> json) {
    return SupplierDashboardData(
      revenue: RevenueData.fromJson(json['revenue'] ?? {}),
      ordersByStatus: (json['ordersByStatus'] as List<dynamic>?)
              ?.map((e) => OrderStatusData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      topProducts: (json['topProducts'] as List<dynamic>?)
              ?.map((e) => TopProduct.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      revenueOverTime: (json['revenueOverTime'] as List<dynamic>?)
              ?.map((e) => RevenueOverTime.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      productStats: ProductStats.fromJson(json['productStats'] ?? {}),
      recentOrders: (json['recentOrders'] as List<dynamic>?)
              ?.map((e) => OrderSummary.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'revenue': revenue.toJson(),
      'ordersByStatus': ordersByStatus.map((e) => e.toJson()).toList(),
      'topProducts': topProducts.map((e) => e.toJson()).toList(),
      'revenueOverTime': revenueOverTime.map((e) => e.toJson()).toList(),
      'productStats': productStats.toJson(),
      'recentOrders': recentOrders.map((e) => e.toJson()).toList(),
    };
  }
}

class RevenueData {
  final double totalRevenue;
  final int totalOrders;
  final double averageOrderValue;
  final double growthPercentage;

  RevenueData({
    required this.totalRevenue,
    required this.totalOrders,
    required this.averageOrderValue,
    this.growthPercentage = 0.0,
  });

  factory RevenueData.fromJson(Map<String, dynamic> json) {
    return RevenueData(
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
      totalOrders: (json['totalOrders'] as num?)?.toInt() ?? 0,
      averageOrderValue: (json['averageOrderValue'] as num?)?.toDouble() ?? 0.0,
      growthPercentage: (json['growthPercentage'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalRevenue': totalRevenue,
      'totalOrders': totalOrders,
      'averageOrderValue': averageOrderValue,
      'growthPercentage': growthPercentage,
    };
  }
}

class OrderStatusData {
  final String status;
  final int count;

  OrderStatusData({
    required this.status,
    required this.count,
  });

  factory OrderStatusData.fromJson(Map<String, dynamic> json) {
    return OrderStatusData(
      status: json['_id'] as String? ?? json['status'] as String? ?? 'unknown',
      count: (json['count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': status,
      'count': count,
    };
  }
}

class TopProduct {
  final String productId;
  final String title;
  final String? image;
  final double price;
  final int totalQuantity;
  final double totalRevenue;

  TopProduct({
    required this.productId,
    required this.title,
    this.image,
    required this.price,
    required this.totalQuantity,
    required this.totalRevenue,
  });

  factory TopProduct.fromJson(Map<String, dynamic> json) {
    final productData = json['_id'] as Map<String, dynamic>?;
    final images = productData?['images'] as List<dynamic>?;
    final firstImage = images?.isNotEmpty == true ? images![0] : null;

    return TopProduct(
      productId: (productData?['_id'] as String?) ?? '',
      title: (productData?['title'] as String?) ?? 'Unknown Product',
      image: firstImage is Map ? firstImage['url'] as String? : null,
      price: (productData?['price'] as num?)?.toDouble() ?? 0.0,
      totalQuantity: (json['totalQuantity'] as num?)?.toInt() ?? 0,
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': {
        '_id': productId,
        'title': title,
        'images': image != null ? [{'url': image}] : [],
        'price': price,
      },
      'totalQuantity': totalQuantity,
      'totalRevenue': totalRevenue,
    };
  }
}

class RevenueOverTime {
  final String date;
  final double revenue;
  final int orders;

  RevenueOverTime({
    required this.date,
    required this.revenue,
    required this.orders,
  });

  factory RevenueOverTime.fromJson(Map<String, dynamic> json) {
    return RevenueOverTime(
      date: json['_id'] as String? ?? '',
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0.0,
      orders: (json['orders'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': date,
      'revenue': revenue,
      'orders': orders,
    };
  }
}

class ProductStats {
  final int totalProducts;
  final int activeProducts;
  final int outOfStock;
  final int totalStock;
  final int lowStock;

  ProductStats({
    required this.totalProducts,
    required this.activeProducts,
    required this.outOfStock,
    required this.totalStock,
    this.lowStock = 0,
  });

  factory ProductStats.fromJson(Map<String, dynamic> json) {
    return ProductStats(
      totalProducts: (json['totalProducts'] as num?)?.toInt() ?? 0,
      activeProducts: (json['activeProducts'] as num?)?.toInt() ?? 0,
      outOfStock: (json['outOfStock'] as num?)?.toInt() ?? 0,
      totalStock: (json['totalStock'] as num?)?.toInt() ?? 0,
      lowStock: (json['lowStock'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalProducts': totalProducts,
      'activeProducts': activeProducts,
      'outOfStock': outOfStock,
      'totalStock': totalStock,
      'lowStock': lowStock,
    };
  }
}

class OrderSummary {
  final String id;
  final String orderNumber;
  final String status;
  final double total;
  final DateTime createdAt;
  final String? customerName;
  final String? supplierName;
  final String? businessName;
  final List<OrderItem> items;

  OrderSummary({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.total,
    required this.createdAt,
    this.customerName,
    this.supplierName,
    this.businessName,
    this.items = const [],
  });

  factory OrderSummary.fromJson(Map<String, dynamic> json) {
    final customerData = json['customer'] as Map<String, dynamic>?;
    final supplierData = json['supplier'] as Map<String, dynamic>?;

    return OrderSummary(
      id: json['_id'] as String? ?? '',
      orderNumber: json['orderNumber'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      customerName: customerData != null
          ? '${customerData['firstName'] ?? ''} ${customerData['lastName'] ?? ''}'.trim()
          : null,
      supplierName: supplierData != null
          ? '${supplierData['firstName'] ?? ''} ${supplierData['lastName'] ?? ''}'.trim()
          : null,
      businessName: supplierData?['businessName'] as String?,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'orderNumber': orderNumber,
      'status': status,
      'total': total,
      'createdAt': createdAt.toIso8601String(),
      'customer': customerName != null
          ? {'firstName': customerName!.split(' ').first}
          : null,
      'supplier': {
        'firstName': supplierName?.split(' ').first,
        'businessName': businessName,
      },
      'items': items.map((e) => e.toJson()).toList(),
    };
  }
}

class OrderItem {
  final String productId;
  final String? title;
  final String? image;
  final int quantity;
  final double price;
  final double subtotal;

  OrderItem({
    required this.productId,
    this.title,
    this.image,
    required this.quantity,
    required this.price,
    required this.subtotal,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final productData = json['product'] as Map<String, dynamic>?;
    final snapshotData = json['productSnapshot'] as Map<String, dynamic>?;
    final images = productData?['images'] as List<dynamic>?;
    final firstImage = images?.isNotEmpty == true ? images![0] : null;

    return OrderItem(
      productId: (productData?['_id'] as String?) ?? json['product'] as String? ?? '',
      title: (productData?['title'] as String?) ?? snapshotData?['title'] as String?,
      image: firstImage is Map
          ? firstImage['url'] as String?
          : snapshotData?['image'] as String?,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': productId,
      'productSnapshot': {
        'title': title,
        'image': image,
      },
      'quantity': quantity,
      'price': price,
      'subtotal': subtotal,
    };
  }
}
