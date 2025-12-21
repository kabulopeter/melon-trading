class StrategyProfile {
  final int? id;
  final String name;
  final bool isActive;
  final double minConfidence;
  final Map<String, dynamic> indicatorsConfig;

  StrategyProfile({
    this.id,
    required this.name,
    this.isActive = false,
    this.minConfidence = 0.75,
    this.indicatorsConfig = const {},
  });

  factory StrategyProfile.fromJson(Map<String, dynamic> json) {
    return StrategyProfile(
      id: json['id'],
      name: json['name'] ?? '',
      isActive: json['is_active'] ?? false,
      minConfidence: (json['min_confidence'] ?? 0.75).toDouble(),
      indicatorsConfig: json['indicators_config'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'is_active': isActive,
      'min_confidence': minConfidence,
      'indicators_config': indicatorsConfig,
    };
  }
}
