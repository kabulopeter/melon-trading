import 'dart:ui';
import 'package:flutter/material.dart';
import '../widgets/skeleton_loading.dart';
import '../../data/services/api_service.dart';
import '../../data/models/trade_model.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final ApiService _api = ApiService();
  bool _isLoading = true;
  List<Trade> _closedTrades = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final response = await _api.getTrades();
      if (response.statusCode == 200) {
        dynamic td = response.data;
        List<dynamic> list = (td is Map && td.containsKey('results')) ? td['results'] : (td is List ? td : []);
        final allTrades = list.map((json) => Trade.fromJson(json)).toList();
        // Filter for closed trades if status field exists
        _closedTrades = allTrades; 
      }
      setState(() => _isLoading = false);
    } catch (e) {
      debugPrint("History Error: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f172a),
      body: _isLoading 
        ? const HistorySkeleton()
        : CustomScrollView(
            slivers: [
              _buildAppBar(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRealizedPnLCard(),
                      const SizedBox(height: 24),
                      _buildSearchAndFilters(),
                      const SizedBox(height: 16),
                      ..._closedTrades.map((t) => _buildTradeHistoryCard(t)),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: const Color(0xFF0f172a).withOpacity(0.8),
      pinned: true,
      elevation: 0,
      leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
      title: const Text("Trade History", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
      actions: [
        IconButton(icon: const Icon(Icons.tune, color: Colors.white), onPressed: () {}),
      ],
    );
  }

  Widget _buildRealizedPnLCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF1a2c32), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("REALIZED PNL", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  const SizedBox(height: 4),
                  const Text("+\$12,450.00", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.trending_up, color: Colors.green, size: 14),
                      const SizedBox(width: 4),
                      const Text("+18.2%", style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      const Text("this month", style: TextStyle(color: Colors.white24, fontSize: 10)),
                    ],
                  ),
                ],
              ),
              Container(padding: const EdgeInsets.all(2), decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)), child: const Row(children: [Text("PnL", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)), SizedBox(width: 8), Text("Vol", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold))])),
            ],
          ),
          const SizedBox(height: 20),
          Container(height: 80, width: double.infinity, child: CustomPaint(painter: _PnLChartPainter(const Color(0xFF13b6ec)))),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ["24H", "1W", "1M", "3M", "ALL"].map((f) => _buildChartFilterItem(f, f == "1M")).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildChartFilterItem(String text, bool active) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: active ? Colors.white.withOpacity(0.1) : Colors.transparent, borderRadius: BorderRadius.circular(8)), child: Text(text, style: TextStyle(color: active ? Colors.white : Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)));
  }

  Widget _buildSearchAndFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterBadge(Icons.search, "Search...", Colors.white12),
          _buildFilterBadge(Icons.calendar_today, "This Month", Colors.white12),
          _buildFilterBadge(null, "All Types", const Color(0xFF13b6ec).withOpacity(0.2), color: const Color(0xFF13b6ec)),
          _buildFilterBadge(null, "PnL", Colors.white12),
        ],
      ),
    );
  }

  Widget _buildFilterBadge(IconData? icon, String text, Color bg, {Color color = Colors.white54}) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Row(
        children: [
          if (icon != null) ...[Icon(icon, color: color, size: 14), const SizedBox(width: 6)],
          Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(width: 4),
          const Icon(Icons.arrow_drop_down, color: Colors.white24, size: 14),
        ],
      ),
    );
  }

  Widget _buildTradeHistoryCard(Trade trade) {
    final profit = (trade.pnl ?? 0) >= 0;
    final color = profit ? Colors.greenAccent : Colors.redAccent;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1a2c32), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.indigo.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.token, color: Colors.indigo)),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(trade.asset.symbol, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(width: 6),
                          Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1), decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(4)), child: Text("${trade.side} 5x", style: const TextStyle(color: Colors.redAccent, fontSize: 8, fontWeight: FontWeight.bold))),
                        ],
                      ),
                      const SizedBox(height: 2),
                      const Text("Oct 24, 14:30 • Manual Entry", style: TextStyle(color: Colors.white24, fontSize: 10)),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("${profit ? '+' : ''}\$${(trade.pnl ?? 0).toStringAsFixed(2)}", style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)), child: Text("${profit ? '+' : ''}12.5%", style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetric("ENTRY PRICE", "\$${trade.entryPrice}"),
              _buildMetric("EXIT PRICE", "\$128.50"),
              _buildMetric("QUANTITY", "500 ${trade.asset.symbol}"),
            ],
          ),
          const SizedBox(height: 16),
          _buildAIInsight(),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String val) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 8, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(val, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildAIInsight() {
    return Container(
      padding: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05)))),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.smart_toy, color: Color(0xFF13b6ec), size: 14),
              SizedBox(width: 6),
              Text("AI CONFIDENCE", style: TextStyle(color: Colors.white38, fontSize: 8, fontWeight: FontWeight.bold)),
              SizedBox(width: 4),
              Text("94%", style: TextStyle(color: Color(0xFF13b6ec), fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
          Row(
            children: [
              Text("EXIT REASON:", style: TextStyle(color: Colors.white38, fontSize: 8, fontWeight: FontWeight.bold)),
              SizedBox(width: 4),
              Text("AI Take Profit", style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}

class _PnLChartPainter extends CustomPainter {
  final Color color;
  _PnLChartPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..strokeWidth = 2..style = PaintingStyle.stroke;
    final path = Path();
    path.moveTo(0, size.height * 0.8);
    path.cubicTo(size.width * 0.2, size.height * 0.8, size.width * 0.25, size.height * 0.5, size.width * 0.4, size.height * 0.5);
    path.cubicTo(size.width * 0.6, size.height * 0.5, size.width * 0.7, size.height * 0.2, size.width, size.height * 0.1);
    canvas.drawPath(path, paint);
    
    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();
    canvas.drawPath(fillPath, Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [color.withOpacity(0.3), color.withOpacity(0)]).createShader(Rect.fromLTWH(0, 0, size.width, size.height)));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
