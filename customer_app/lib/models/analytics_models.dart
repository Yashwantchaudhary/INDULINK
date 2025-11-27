// Analytics Data Models

class SalesTrends {
  final List<TrendData> trends;
  final SalesTotals totals;
  final SalesComparison comparison;
  final Period period;

  SalesTrends({
    required this.trends,
    required this.totals,
    required this.comparison,
    required this.period,
  });

  factory SalesTrends.fromJson(Map<String, dynamic> json) {
    return SalesTrends(
      trends: (json['trends'] as List)
          .map((e) => TrendData.fromJson(e))
          .toList(),
      totals: SalesTotals.fromJson(json['totals']),
      comparison: SalesComparison.fromJson(json['comparison']),
      period: Period.fromJson(json['period']),
    );
  }
}

class TrendData {
  final String date;
  final double revenue;
  final int orders;
  final double averageOrderValue;

  TrendData({
    required this.date,
    required this.revenue,
    required this.orders,
    required this.averageOrderValue,
  });

  factory TrendData.fromJson(Map<String, dynamic> json) {
    return TrendData(
      date: json['_id'] ?? '',
      revenue: (json['revenue'] ?? 0).toDouble(),
      orders: json['orders'] ?? 0,
      averageOrderValue: (json['averageOrderValue'] ?? 0).toDouble(),
    );
  }
}

class SalesTotals {
  final double totalRevenue;
  final int totalOrders;
  final double averageOrderValue;

  SalesTotals({
    required this.totalRevenue,
    required this.totalOrders,
    required this.averageOrderValue,
  });

  factory SalesTotals.fromJson(Map<String, dynamic> json) {
    return SalesTotals(
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
      totalOrders: json['totalOrders'] ?? 0,
      averageOrderValue: (json['averageOrderValue'] ?? 0).toDouble(),
    );
  }
}

class SalesComparison {
  final double revenueGrowth;
  final double ordersGrowth;
  final double avgOrderValueGrowth;

  SalesComparison({
    required this.revenueGrowth,
    required this.ordersGrowth,
    required this.avgOrderValueGrowth,
  });

  factory SalesComparison.fromJson(Map<String, dynamic> json) {
    return SalesComparison(
      revenueGrowth: (json['revenueGrowth'] ?? 0).toDouble(),
      ordersGrowth: (json['ordersGrowth'] ?? 0).toDouble(),
      avgOrderValueGrowth: (json['avgOrderValueGrowth'] ?? 0).toDouble(),
    );
  }
}

class Period {
  final String start;
  final String end;
  final String interval;

  Period({
    required this.start,
    required this.end,
    required this.interval,
  });

  factory Period.fromJson(Map<String, dynamic> json) {
    return Period(
      start: json['start'] ?? '',
      end: json['end'] ?? '',
      interval: json['interval'] ?? 'day',
    );
  }
}

// Product Performance Models

class ProductPerformance {
  final List<TopProduct> topProducts;
  final List<TopProduct> bottomProducts;
  final List<CategoryPerformance> categoryPerformance;
  final StockAnalysis? stockAnalysis;

  ProductPerformance({
    required this.topProducts,
    required this.bottomProducts,
    required this.categoryPerformance,
    this.stockAnalysis,
  });

  factory ProductPerformance.fromJson(Map<String, dynamic> json) {
    return ProductPerformance(
      topProducts: (json['topProducts'] as List? ?? [])
          .map((e) => TopProduct.fromJson(e))
          .toList(),
      bottomProducts: (json['bottomProducts'] as List? ?? [])
          .map((e) => TopProduct.fromJson(e))
          .toList(),
      categoryPerformance: (json['categoryPerformance'] as List? ?? [])
          .map((e) => CategoryPerformance.fromJson(e))
          .toList(),
      stockAnalysis: json['stockAnalysis'] != null
          ? StockAnalysis.fromJson(json['stockAnalysis'])
          : null,
    );
  }
}

class TopProduct {
  final ProductInfo product;
  final double totalRevenue;
  final int totalQuantity;
  final int? orderCount;

  TopProduct({
    required this.product,
    required this.totalRevenue,
    required this.totalQuantity,
    this.orderCount,
  });

  factory TopProduct.fromJson(Map<String, dynamic> json) {
    return TopProduct(
      product: ProductInfo.fromJson(json['_id']),
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
      totalQuantity: json['totalQuantity'] ?? 0,
      orderCount: json['orderCount'],
    );
  }
}

class ProductInfo {
  final String id;
  final String title;
  final List<String> images;
  final double price;
  final String? category;
  final int? stock;

  ProductInfo({
    required this.id,
    required this.title,
    required this.images,
    required this.price,
    this.category,
    this.stock,
  });

  factory ProductInfo.fromJson(Map<String, dynamic> json) {
    return ProductInfo(
      id: json['_id'] ?? '',
      title: json['title'] ?? 'Unknown Product',
      images: List<String>.from(json['images'] ?? []),
      price: (json['price'] ?? 0).toDouble(),
      category: json['category'],
      stock: json['stock'],
    );
  }
}

class CategoryPerformance {
  final String categoryId;
  final double revenue;
  final int quantity;

  CategoryPerformance({
    required this.categoryId,
    required this.revenue,
    required this.quantity,
  });

  factory CategoryPerformance.fromJson(Map<String, dynamic> json) {
    return CategoryPerformance(
      categoryId: json['_id']?.toString() ?? 'Unknown',
      revenue: (json['revenue'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 0,
    );
  }
}

class StockAnalysis {
  final int totalProducts;
  final int lowStock;
  final int outOfStock;
  final List<LowStockProduct> lowStockProducts;

  StockAnalysis({
    required this.totalProducts,
    required this.lowStock,
    required this.outOfStock,
    required this.lowStockProducts,
  });

  factory StockAnalysis.fromJson(Map<String, dynamic> json) {
    return StockAnalysis(
      totalProducts: json['totalProducts'] ?? 0,
      lowStock: json['lowStock'] ?? 0,
      outOfStock: json['outOfStock'] ?? 0,
      lowStockProducts: (json['lowStockProducts'] as List? ?? [])
          .map((e) => LowStockProduct.fromJson(e))
          .toList(),
    );
  }
}

class LowStockProduct {
  final String id;
  final String title;
  final int stock;
  final String? image;

  LowStockProduct({
    required this.id,
    required this.title,
    required this.stock,
    this.image,
  });

  factory LowStockProduct.fromJson(Map<String, dynamic> json) {
    return LowStockProduct(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      stock: json['stock'] ?? 0,
      image: json['image'],
    );
  }
}

// Customer Behavior Models

class CustomerBehavior {
  final CustomerSummary summary;
  final List<TopCustomer> topCustomers;

  CustomerBehavior({
    required this.summary,
    required this.topCustomers,
  });

  factory CustomerBehavior.fromJson(Map<String, dynamic> json) {
    return CustomerBehavior(
      summary: CustomerSummary.fromJson(json['summary']),
      topCustomers: (json['topCustomers'] as List? ?? [])
          .map((e) => TopCustomer.fromJson(e))
          .toList(),
    );
  }
}

class CustomerSummary {
  final int totalCustomers;
  final int newCustomers;
  final int returningCustomers;
  final double avgLifetimeValue;
  final double avgOrdersPerCustomer;

  CustomerSummary({
    required this.totalCustomers,
    required this.newCustomers,
    required this.returningCustomers,
    required this.avgLifetimeValue,
    required this.avgOrdersPerCustomer,
  });

  factory CustomerSummary.fromJson(Map<String, dynamic> json) {
    return CustomerSummary(
      totalCustomers: json['totalCustomers'] ?? 0,
      newCustomers: json['newCustomers'] ?? 0,
      returningCustomers: json['returningCustomers'] ?? 0,
      avgLifetimeValue: (json['avgLifetimeValue'] ?? 0).toDouble(),
      avgOrdersPerCustomer: (json['avgOrdersPerCustomer'] ?? 0).toDouble(),
    );
  }
}

class TopCustomer {
  final CustomerInfo customer;
  final int orderCount;
  final double totalSpent;
  final String firstOrder;
  final String lastOrder;

  TopCustomer({
    required this.customer,
    required this.orderCount,
    required this.totalSpent,
    required this.firstOrder,
    required this.lastOrder,
  });

  factory TopCustomer.fromJson(Map<String, dynamic> json) {
    return TopCustomer(
      customer: CustomerInfo.fromJson(json['_id']),
      orderCount: json['orderCount'] ?? 0,
      totalSpent: (json['totalSpent'] ?? 0).toDouble(),
      firstOrder: json['firstOrder'] ?? '',
      lastOrder: json['lastOrder'] ?? '',
    );
  }
}

class CustomerInfo {
  final String id;
  final String firstName;
  final String lastName;
  final String? email;

  CustomerInfo({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.email,
  });

  factory CustomerInfo.fromJson(Map<String, dynamic> json) {
    return CustomerInfo(
      id: json['_id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'],
    );
  }

  String get fullName => '$firstName $lastName';
}

// Supplier Performance Models

class SupplierPerformance {
  final OrderMetrics orderMetrics;
  final double fulfillmentRate;
  final double avgDeliveryTime;
  final ProductStats productStats;

  SupplierPerformance({
    required this.orderMetrics,
    required this.fulfillmentRate,
    required this.avgDeliveryTime,
    required this.productStats,
  });

  factory SupplierPerformance.fromJson(Map<String, dynamic> json) {
    return SupplierPerformance(
      orderMetrics: OrderMetrics.fromJson(json['orderMetrics']),
      fulfillmentRate: double.parse(json['fulfillmentRate'] ?? '0'),
      avgDeliveryTime: double.parse(json['avgDeliveryTime'] ?? '0'),
      productStats: ProductStats.fromJson(json['productStats']),
    );
  }
}

class OrderMetrics {
  final int totalOrders;
  final int delivered;
  final int cancelled;
  final int processing;

  OrderMetrics({
    required this.totalOrders,
    required this.delivered,
    required this.cancelled,
    required this.processing,
  });

  factory OrderMetrics.fromJson(Map<String, dynamic> json) {
    return OrderMetrics(
      totalOrders: json['totalOrders'] ?? 0,
      delivered: json['delivered'] ?? 0,
      cancelled: json['cancelled'] ?? 0,
      processing: json['processing'] ?? 0,
    );
  }
}

class ProductStats {
  final int totalProducts;
  final int activeProducts;

  ProductStats({
    required this.totalProducts,
    required this.activeProducts,
  });

  factory ProductStats.fromJson(Map<String, dynamic> json) {
    return ProductStats(
      totalProducts: json['totalProducts'] ?? 0,
      activeProducts: json['activeProducts'] ?? 0,
    );
  }
}

// Comparative Analysis Models

class ComparativeAnalysis {
  final String period;
  final PeriodRange currentPeriod;
  final PeriodRange previousPeriod;
  final ComparisonMetrics comparison;

  ComparativeAnalysis({
    required this.period,
    required this.currentPeriod,
    required this.previousPeriod,
    required this.comparison,
  });

  factory ComparativeAnalysis.fromJson(Map<String, dynamic> json) {
    return ComparativeAnalysis(
      period: json['period'] ?? '',
      currentPeriod: PeriodRange.fromJson(json['currentPeriod']),
      previousPeriod: PeriodRange.fromJson(json['previousPeriod']),
      comparison: ComparisonMetrics.fromJson(json['comparison']),
    );
  }
}

class PeriodRange {
  final String start;
  final String end;

  PeriodRange({
    required this.start,
    required this.end,
  });

  factory PeriodRange.fromJson(Map<String, dynamic> json) {
    return PeriodRange(
      start: json['start'] ?? '',
      end: json['end'] ?? '',
    );
  }
}

class ComparisonMetrics {
  final MetricComparison revenue;
  final MetricComparison orders;
  final MetricComparison avgOrderValue;

  ComparisonMetrics({
    required this.revenue,
    required this.orders,
    required this.avgOrderValue,
  });

  factory ComparisonMetrics.fromJson(Map<String, dynamic> json) {
    return ComparisonMetrics(
      revenue: MetricComparison.fromJson(json['revenue']),
      orders: MetricComparison.fromJson(json['orders']),
      avgOrderValue: MetricComparison.fromJson(json['avgOrderValue']),
    );
  }
}

class MetricComparison {
  final double current;
  final double previous;
  final double change;
  final String trend;

  MetricComparison({
    required this.current,
    required this.previous,
    required this.change,
    required this.trend,
  });

  factory MetricComparison.fromJson(Map<String, dynamic> json) {
    return MetricComparison(
      current: (json['current'] ?? 0).toDouble(),
      previous: (json['previous'] ?? 0).toDouble(),
      change: (json['change'] ?? 0).toDouble(),
      trend: json['trend'] ?? 'flat',
    );
  }

  bool get isPositive => trend == 'up';
  bool get isNegative => trend == 'down';
}
