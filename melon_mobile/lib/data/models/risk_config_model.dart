class RiskConfig {
  final double riskPerTradePercent;
  final double defaultStopLossPercent;
  final double defaultTakeProfitPercent;
  final double dailyMaxLossAmount;
  final bool dailyMaxLossIsPercent;
  final double drawdownThresholdPercent;
  final bool autoSizingEnabled;
  final bool riskNotificationsEnabled;

  RiskConfig({
    this.riskPerTradePercent = 2.0,
    this.defaultStopLossPercent = 5.0,
    this.defaultTakeProfitPercent = 10.0,
    this.dailyMaxLossAmount = 150.0,
    this.dailyMaxLossIsPercent = true,
    this.drawdownThresholdPercent = 15.0,
    this.autoSizingEnabled = true,
    this.riskNotificationsEnabled = true,
  });

  factory RiskConfig.fromJson(Map<String, dynamic> json) {
    return RiskConfig(
      riskPerTradePercent: (json['risk_per_trade_percent'] ?? 2.0).toDouble(),
      defaultStopLossPercent: (json['default_stop_loss_percent'] ?? 5.0).toDouble(),
      defaultTakeProfitPercent: (json['default_take_profit_percent'] ?? 10.0).toDouble(),
      dailyMaxLossAmount: (json['daily_max_loss_amount'] ?? 150.0).toDouble(),
      dailyMaxLossIsPercent: json['daily_max_loss_is_percent'] ?? true,
      drawdownThresholdPercent: (json['drawdown_threshold_percent'] ?? 15.0).toDouble(),
      autoSizingEnabled: json['auto_sizing_enabled'] ?? true,
      riskNotificationsEnabled: json['risk_notifications_enabled'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'risk_per_trade_percent': riskPerTradePercent,
      'default_stop_loss_percent': defaultStopLossPercent,
      'default_take_profit_percent': defaultTakeProfitPercent,
      'daily_max_loss_amount': dailyMaxLossAmount,
      'daily_max_loss_is_percent': dailyMaxLossIsPercent,
      'drawdown_threshold_percent': drawdownThresholdPercent,
      'auto_sizing_enabled': autoSizingEnabled,
      'risk_notifications_enabled': riskNotificationsEnabled,
    };
  }
}
