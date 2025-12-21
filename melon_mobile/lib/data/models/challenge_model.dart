class Challenge {
  final int id;
  final String title;
  final String description;
  final int xpReward;
  final String type;
  final double targetValue;
  final String iconName;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.xpReward,
    required this.type,
    required this.targetValue,
    this.iconName = 'military_tech',
  });

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      xpReward: json['xp_reward'] ?? 0,
      type: json['challenge_type'] ?? '',
      targetValue: (json['target_value'] ?? 0).toDouble(),
      iconName: json['icon_name'] ?? 'military_tech',
    );
  }
}

class UserChallenge {
  final int id;
  final int challengeId;
  final Challenge? details;
  final double currentValue;
  final bool isCompleted;
  final DateTime? completedAt;

  UserChallenge({
    required this.id,
    required this.challengeId,
    this.details,
    required this.currentValue,
    required this.isCompleted,
    this.completedAt,
  });

  factory UserChallenge.fromJson(Map<String, dynamic> json) {
    return UserChallenge(
      id: json['id'],
      challengeId: json['challenge'],
      details: json['challenge_details'] != null 
          ? Challenge.fromJson(json['challenge_details']) 
          : null,
      currentValue: (json['current_value'] ?? 0).toDouble(),
      isCompleted: json['is_completed'] ?? false,
      completedAt: json['completed_at'] != null 
          ? DateTime.parse(json['completed_at']) 
          : null,
    );
  }
}
