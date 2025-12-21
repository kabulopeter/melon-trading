class Badge {
  final int id;
  final String name;
  final String description;
  final String iconName;
  final String category;

  Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
    required this.category,
  });

  factory Badge.fromJson(Map<String, dynamic> json) {
    return Badge(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      iconName: json['icon_name'] ?? 'shield',
      category: json['category'] ?? 'Trading',
    );
  }
}

class UserBadge {
  final int id;
  final int badgeId;
  final Badge? details;
  final DateTime earnedAt;

  UserBadge({
    required this.id,
    required this.badgeId,
    this.details,
    required this.earnedAt,
  });

  factory UserBadge.fromJson(Map<String, dynamic> json) {
    return UserBadge(
      id: json['id'],
      badgeId: json['badge'],
      details: json['badge_details'] != null 
          ? Badge.fromJson(json['badge_details']) 
          : null,
      earnedAt: DateTime.parse(json['earned_at']),
    );
  }
}
