class UserPreference {
  final bool autoTrade;
  final double minConfidence;
  final double maxRiskPerTrade;

  UserPreference({
    required this.autoTrade,
    required this.minConfidence,
    required this.maxRiskPerTrade,
  });

  factory UserPreference.fromJson(Map<String, dynamic> json) {
    return UserPreference(
      autoTrade: json['auto_trade'] ?? false,
      minConfidence: (json['min_confidence'] ?? 0.90).toDouble(),
      maxRiskPerTrade: double.parse((json['max_risk_per_trade'] ?? '10.00').toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'auto_trade': autoTrade,
      'min_confidence': minConfidence,
      'max_risk_per_trade': maxRiskPerTrade,
    };
  }
}
