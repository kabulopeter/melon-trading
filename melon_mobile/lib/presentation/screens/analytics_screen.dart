import 'dart:ui';
import 'package:flutter/material.dart';
import '../../data/services/api_service.dart';
import '../../data/services/analytics_service.dart';
import '../../data/models/performance_model.dart';
import '../widgets/skeleton_loading.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final AnalyticsService _service = AnalyticsService(ApiService());
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f172a),
      body: _isLoading 
        ? const AnalyticsSkeleton()
        : Stack(
            children: [
              _buildBackgroundGlows(),
              CustomScrollView(
                slivers: [
                  _buildAppBar(),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle("ADVANCED METRICS"),
                          _buildMetricsGrid(),
                          const SizedBox(height: 24),
                          _buildSectionTitle("MONTHLY PERFORMANCE"),
                          _buildMonthlyChart(),
                          const SizedBox(height: 24),
                          _buildSectionTitle("AI MODEL INSIGHTS"),
                          _buildAIInsightCard(),
                          const SizedBox(height: 24),
                          _buildSectionTitle("ASSET HEATMAP"),
                          _buildAssetHeatmap(),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
    );
  }

  Widget _buildBackgroundGlows() {
    return Stack(
      children: [
        Positioned(top: -100, right: -50, child: Container(width: 300, height: 300, decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF00E5FF).withOpacity(0.1)), child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100), child: Container(color: Colors.transparent)))),
        Positioned(bottom: 100, left: -100, child: Container(width: 300, height: 300, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blue.withOpacity(0.05)), child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100), child: Container(color: Colors.transparent)))),
      ],
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: const Color(0xFF05080A).withOpacity(0.8),
      pinned: true,
      elevation: 0,
      leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
      title: const Text("Performance Analysis", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
      actions: [
        IconButton(icon: const Icon(Icons.tune, color: Colors.white), onPressed: () {}),
        IconButton(icon: const Icon(Icons.ios_share, color: Colors.white), onPressed: () {}),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.05))),
            child: Row(
              children: ["1W", "1M", "3M", "6M", "YTD", "ALL"].map((p) => Expanded(child: _buildPeriodItem(p, p == "3M"))).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodItem(String text, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(color: active ? const Color(0xFF00E5FF).withOpacity(0.1) : Colors.transparent, borderRadius: BorderRadius.circular(8), border: active ? Border.all(color: const Color(0xFF00E5FF).withOpacity(0.2)) : null),
      child: Center(child: Text(text, style: TextStyle(color: active ? const Color(0xFF00E5FF) : Colors.white24, fontSize: 10, fontWeight: FontWeight.bold))),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(title, style: const TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
    );
  }

  Widget _buildMetricsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildMetricCard("Profit Factor", "2.85", "+12%", Icons.account_balance_wallet, Colors.greenAccent)),
            const SizedBox(width: 12),
            Expanded(child: _buildMetricCard("Sharpe Ratio", "1.92", "Risk adj.", Icons.show_chart, Colors.blueAccent)),
          ],
        ),
        const SizedBox(height: 12),
        _buildMaxDrawdownCard(),
      ],
    );
  }

  Widget _buildMetricCard(String label, String val, String trend, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF162026).withOpacity(0.6), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.08))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 18)),
              Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Text(trend, style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.bold))),
            ],
          ),
          const SizedBox(height: 12),
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11)),
          const SizedBox(height: 2),
          Text(val, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildMaxDrawdownCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF162026).withOpacity(0.6), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.08))),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Max Drawdown", style: TextStyle(color: Colors.white38, fontSize: 11)),
                  const Text("-14.2%", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text("RECOVERY TIME", style: TextStyle(color: Colors.white24, fontSize: 8, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Row(children: [Icon(Icons.timer, color: Colors.greenAccent, size: 14), const SizedBox(width: 4), const Text("12 Days", style: TextStyle(color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.bold))]),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(12, (index) {
              double h = [10, 20, 45, 85, 65, 35, 15, 5, 2, 0, 25, 15][index].toDouble();
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  height: h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.redAccent.withOpacity(0.8), Colors.redAccent.withOpacity(0.2)]),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF162026).withOpacity(0.6), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.08))),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Performance Mensuelle", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              const Text("EXPORT CSV", style: TextStyle(color: Color(0xFF00E5FF), fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 150,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildBar("MAI", 0.4, "+4%"),
                _buildBar("JUIN", 0.65, "+6.5%"),
                _buildBar("JUIL", -0.2, "-2%", isNegative: true),
                _buildBar("AOUT", 0.85, "+8.5%"),
                _buildBar("SEPT", 0.55, "+5.5%", isCurrent: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(String label, double val, String text, {bool isNegative = false, bool isCurrent = false}) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (isCurrent) ...[
            Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.greenAccent.withOpacity(0.3))), child: Text(text, style: const TextStyle(color: Colors.greenAccent, fontSize: 8, fontWeight: FontWeight.bold))),
            const SizedBox(height: 4),
          ],
          Container(
            height: (val.abs() * 100).toDouble(),
            margin: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: isNegative ? [Colors.redAccent.withOpacity(0.3), Colors.redAccent.withOpacity(0.1)] : [isCurrent ? const Color(0xFF00E5FF) : Colors.greenAccent.withOpacity(0.3), isCurrent ? const Color(0xFF00E5FF).withOpacity(0.5) : Colors.greenAccent.withOpacity(0.1)]),
              borderRadius: isNegative ? const BorderRadius.vertical(bottom: Radius.circular(4)) : const BorderRadius.vertical(top: Radius.circular(4)),
              boxShadow: isCurrent ? [BoxShadow(color: const Color(0xFF00E5FF).withOpacity(0.3), blurRadius: 10)] : [],
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: isCurrent ? Colors.white : Colors.white24, fontSize: 9, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildAIInsightCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF162026).withOpacity(0.6), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.08))),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Prediction Accuracy", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                  const Text("Based on last 100 signals", style: TextStyle(color: Colors.white24, fontSize: 10)),
                ],
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(width: 50, height: 50, child: CircularProgressIndicator(value: 0.78, strokeWidth: 4, backgroundColor: Colors.white10, color: const Color(0xFF00E5FF))),
                  const Text("78%", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildAccuracyRow("High Confidence (>80%)", 0.82, Colors.greenAccent),
          _buildAccuracyRow("Med Confidence (50-80%)", 0.65, Colors.orangeAccent),
          _buildAccuracyRow("Low Confidence (<50%)", 0.45, Colors.redAccent),
        ],
      ),
    );
  }

  Widget _buildAccuracyRow(String label, double val, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10)), Text("${(val * 100).toInt()}% Win Rate", style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold))]),
          const SizedBox(height: 6),
          ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: val, minHeight: 4, backgroundColor: Colors.white10, color: color)),
        ],
      ),
    );
  }

  Widget _buildAssetHeatmap() {
    return Column(
      children: [
        _buildAssetItem("SOL", "Solana", 12, 0.85, "+\$3,420", Colors.indigo, Colors.greenAccent),
        _buildAssetItem("BTC", "Bitcoin", 8, 0.6, "+\$1,250", Colors.orange, Colors.greenAccent),
        _buildAssetItem("ETH", "Ethereum", 15, 0.3, "-\$450", Colors.blue, Colors.redAccent),
      ],
    );
  }

  Widget _buildAssetItem(String sym, String name, int trades, double ratio, String val, Color assetColor, Color trendColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFF162026).withOpacity(0.3), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Row(
        children: [
          Container(width: 36, height: 36, decoration: BoxDecoration(color: assetColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Center(child: Text(sym, style: TextStyle(color: assetColor, fontSize: 10, fontWeight: FontWeight.bold)))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                Text("$trades Trades", style: const TextStyle(color: Colors.white24, fontSize: 10)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(width: 80, child: ClipRRect(borderRadius: BorderRadius.circular(2), child: LinearProgressIndicator(value: ratio, minHeight: 4, backgroundColor: Colors.white10, color: trendColor))),
              const SizedBox(height: 4),
              Text(val, style: TextStyle(color: trendColor, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
