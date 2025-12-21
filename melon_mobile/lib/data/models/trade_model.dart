import 'asset_model.dart';

class Trade {
  final int id;
  final Asset asset;
  final String side;
  final double entryPrice;
  final double? exitPrice;
  final double size;
  final double stopLoss;
  final double takeProfit;
  final double confidenceScore;
  final String status;
  final double? pnl;
  final DateTime openedAt;
  final DateTime? closedAt;

  Trade({
    required this.id,
    required this.asset,
    required this.side,
    required this.entryPrice,
    this.exitPrice,
    required this.size,
    required this.stopLoss,
    required this.takeProfit,
    required this.confidenceScore,
    required this.status,
    this.pnl,
    required this.openedAt,
    this.closedAt,
  });

  factory Trade.fromJson(Map<String, dynamic> json) {
    return Trade(
      id: json['id'],
      asset: Asset.fromJson(json['asset']),
      side: json['side'],
      entryPrice: double.parse(json['entry_price'].toString()),
      exitPrice: json['exit_price'] != null
          ? double.parse(json['exit_price'].toString())
          : null,
      size: double.parse(json['size'].toString()),
      stopLoss: double.parse(json['stop_loss'].toString()),
      takeProfit: double.parse(json['take_profit'].toString()),
      confidenceScore: json['confidence_score'] != null
          ? double.parse(json['confidence_score'].toString())
          : 0.0,
      status: json['status'],
      pnl: json['pnl'] != null ? double.parse(json['pnl'].toString()) : null,
      openedAt: DateTime.parse(json['opened_at']),
      closedAt: json['closed_at'] != null
          ? DateTime.parse(json['closed_at'])
          : null,
    );
  }
}
