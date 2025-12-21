class EquityPoint {
  final DateTime? date;
  final double equity;

  EquityPoint({this.date, required this.equity});

  factory EquityPoint.fromJson(Map<String, dynamic> json) {
    return EquityPoint(
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      equity: (json['equity'] ?? 0.0).toDouble(),
    );
  }
}

class PerformanceStats {
  final double winRate;
  final double totalPnl;
  final double profit_factor;
  final double maxDrawdown;
  final int totalTrades;
  final List<EquityPoint> equityCurve;

  PerformanceStats({
    required this.winRate,
    required this.totalPnl,
    required this.profit_factor,
    required this.maxDrawdown,
    required this.totalTrades,
    required this.equityCurve,
  });

  factory PerformanceStats.fromJson(Map<String, dynamic> json) {
    return PerformanceStats(
      winRate: (json['win_rate'] ?? 0.0).toDouble(),
      totalPnl: (json['total_pnl'] ?? 0.0).toDouble(),
      profit_factor: (json['profit_factor'] ?? 0.0).toDouble(),
      maxDrawdown: (json['max_drawdown'] ?? 0.0).toDouble(),
      totalTrades: json['total_trades'] ?? 0,
      equityCurve: (json['equity_curve'] as List? ?? [])
          .map((e) => EquityPoint.fromJson(e))
          .toList(),
    );
  }
}
