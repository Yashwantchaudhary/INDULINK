class LoyaltyTransaction {
  final String id;
  final String userId;
  final String type; // 'earn' or 'redeem'
  final int points;
  final String reason;
  final String? relatedModel;
  final String? relatedId;
  final int balanceAfter;
  final DateTime createdAt;

  LoyaltyTransaction({
    required this.id,
    required this.userId,
    required this.type,
    required this.points,
    required this.reason,
    this.relatedModel,
    this.relatedId,
    required this.balanceAfter,
    required this.createdAt,
  });

  factory LoyaltyTransaction.fromJson(Map<String, dynamic> json) {
    return LoyaltyTransaction(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      type: json['type'] ?? 'earn',
      points: json['points'] ?? 0,
      reason: json['reason'] ?? '',
      relatedModel: json['relatedModel'],
      relatedId: json['relatedId'],
      balanceAfter: json['balanceAfter'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'type': type,
      'points': points,
      'reason': reason,
      if (relatedModel != null) 'relatedModel': relatedModel,
      if (relatedId != null) 'relatedId': relatedId,
      'balanceAfter': balanceAfter,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  bool get isEarn => type == 'earn';
  bool get isRedeem => type == 'redeem';
}

class Badge {
  final String id;
  final String name;
  final String description;
  final String icon;
  final String color;
  final int pointsReward;
  final String rarity; // 'common', 'rare', 'epic', 'legendary'
  final bool isActive;

  Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    this.color = '#2196F3',
    this.pointsReward = 0,
    this.rarity = 'common',
    this.isActive = true,
  });

  factory Badge.fromJson(Map<String, dynamic> json) {
    return Badge(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? '',
      color: json['color'] ?? '#2196F3',
      pointsReward: json['pointsReward'] ?? 0,
      rarity: json['rarity'] ?? 'common',
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'color': color,
      'pointsReward': pointsReward,
      'rarity': rarity,
      'isActive': isActive,
    };
  }
}
