class MarketAlert {
  final int id;
  final int assetId;
  final String assetSymbol;
  final double targetPrice;
  final String condition; // ABOVE, BELOW
  final bool isActive;
  final bool isTriggered;
  final DateTime createdAt;

  MarketAlert({
    required this.id,
    required this.assetId,
    required this.assetSymbol,
    required this.targetPrice,
    required this.condition,
    required this.isActive,
    required this.isTriggered,
    required this.createdAt,
  });

  factory MarketAlert.fromJson(Map<String, dynamic> json) {
    return MarketAlert(
      id: json['id'],
      assetId: json['asset'],
      assetSymbol: json['asset_symbol'] ?? '',
      targetPrice: double.parse(json['target_price'].toString()),
      condition: json['condition'],
      isActive: json['is_active'] ?? true,
      isTriggered: json['is_triggered'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
