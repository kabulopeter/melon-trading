class Asset {
  final int id;
  final String symbol;
  final String name;
  final String assetType;
  final bool isActive;

  Asset({
    required this.id,
    required this.symbol,
    required this.name,
    required this.assetType,
    required this.isActive,
  });

  factory Asset.fromJson(Map<String, dynamic> json) {
    return Asset(
      id: json['id'],
      symbol: json['symbol'],
      name: json['name'],
      assetType: json['asset_type'],
      isActive: json['is_active'],
    );
  }
}
