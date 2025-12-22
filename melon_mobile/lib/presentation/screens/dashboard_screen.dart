import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/services/api_service.dart';
import '../../data/services/websocket_service.dart';
import '../../data/services/wallet_service.dart';
import '../../data/services/notification_service.dart';
import '../../data/models/trade_model.dart';
import '../../data/models/asset_model.dart';
import '../../data/services/profile_service.dart';
import '../../data/models/profile_model.dart';
import 'wallet_screen.dart';
import 'analytics_screen.dart';
import 'settings_screen.dart';
import 'challenges_screen.dart';
import '../widgets/skeleton_loading.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with TickerProviderStateMixin {
  final ApiService _api = ApiService();
  final WebSocketService _wsService = WebSocketService();
  final NotificationService _notificationService = NotificationService();
  late final WalletService _walletService;
  late final ProfileService _profileService;

  bool _isLoading = true;
  List<Trade> _trades = [];
  String _balance = "0.00";
  UserProfile? _profile;
  late TabController _pnlTabController;

  @override
  void initState() {
    super.initState();
    _pnlTabController = TabController(length: 2, vsync: this);
    _walletService = WalletService(_api);
    _profileService = ProfileService(_api);
    _notificationService.init();
    _wsService.connect();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final tradeResponse = await _api.getTrades();
      final wallet = await _walletService.getBalance();
      final profile = await _profileService.getProfile();
      
      List<Trade> loadedTrades = [];
      if (tradeResponse.statusCode == 200) {
        dynamic td = tradeResponse.data;
        List<dynamic> list = (td is Map && td.containsKey('results')) ? td['results'] : (td is List ? td : []);
        loadedTrades = list.map((json) => Trade.fromJson(json)).toList();
      }

      setState(() {
        _trades = loadedTrades;
        if (wallet != null) _balance = wallet.balance;
        _profile = profile;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("API Error: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _pnlTabController.dispose();
    _wsService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f172a),
      body: _isLoading 
        ? const DashboardSkeleton()
        : CustomScrollView(
            slivers: [
              _buildAppBar(),
              SliverToBoxAdapter(child: _buildMarquee()),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildRecentAlertsSection(),
                    const SizedBox(height: 16),
                    _buildPnLCard(),
                    const SizedBox(height: 16),
                    _buildMetricsGrid(),
                    const SizedBox(height: 16),
                    _buildMarketTrendsSection(),
                    const SizedBox(height: 16),
                    _buildMarketInsightsSection(),
                    const SizedBox(height: 16),
                    _buildEquityCurveSection(),
                    const SizedBox(height: 16),
                    _buildActiveTradesHeader(),
                    const SizedBox(height: 12),
                    ..._trades.take(2).map((t) => _buildActiveTradeCard(t)),
                    const SizedBox(height: 100), // Bottom nav space
                  ]),
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
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: CircleAvatar(
          radius: 20,
          backgroundImage: const NetworkImage("https://lh3.googleusercontent.com/aida-public/AB6AXuDzsjOCkwhaz4fS0xE4SbDQTVTs0l1qhv6LQW2sUDVgWhRFJX3-_cKVQOkWpLAA2S1Q_lhTPwxoldVHsMV5xJDXRn-e2dnfUVPYrgKNRfLzmT03f_Pl0gpddYISxN7I7YU-IC4-Pd5CS_lwXVY3zLHqSu85jNDNOXtdxCeMeCMh1fwG3k4NAzQpQbtlUdgI527NFgklTyAIlPeHY5bLgzzOBL-8mv6quU-GoQiGAx8VMfNvlqaXDIXDOfkMc41TggCpmLvfDM9ZFQsx"),
          child: Align(
            alignment: Alignment.bottomRight,
            child: Container(
              width: 10, height: 10,
              decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle, border: Border.all(color: const Color(0xFF0f172a), width: 1.5)),
            ),
          ),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Welcome back,", style: TextStyle(color: Colors.white54, fontSize: 12)),
          Text(_profile?.fullName ?? "Trader", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
      actions: [
        IconButton(
          icon: const Badge(child: Icon(Icons.notifications_none, color: Colors.white)),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildMarquee() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(color: const Color(0xFF1a2c32).withOpacity(0.5), border: const Border.symmetric(horizontal: BorderSide(color: Colors.white10))),
      child: const SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            SizedBox(width: 16),
            _MarqueeItem(color: Colors.green, text: "TP Hit: ETH/USDT +2.3%"),
            SizedBox(width: 24),
            _MarqueeItem(color: Colors.amber, text: "Price Alert: BTC > \$68k"),
            SizedBox(width: 24),
            _MarqueeItem(color: Color(0xFF13b6ec), text: "New Signal: SOL Long"),
            SizedBox(width: 24),
            _MarqueeItem(color: Colors.red, text: "SL Hit: DOGE -1.5%"),
            SizedBox(width: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentAlertsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [const Color(0xFF1a2c32), const Color(0xFF1a2c32).withOpacity(0.8)]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF13b6ec).withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.notifications_active, color: Color(0xFF13b6ec), size: 20),
                  SizedBox(width: 8),
                  Text("Recent Alerts", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: const Color(0xFF13b6ec), borderRadius: BorderRadius.circular(10)),
                    child: const Text("3 New", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.tune, color: Colors.white54, size: 18),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildAlertItem(Icons.check_circle, Colors.green, "Take Profit Hit", "ETH/USDT reached target 2600. +5.2% profit.", "2m ago"),
          const SizedBox(height: 12),
          _buildAlertItem(Icons.warning, Colors.amber, "System Warning", "High volatility detected on BTC pairs.", "15m ago"),
        ],
      ),
    );
  }

  Widget _buildAlertItem(IconData icon, Color color, String title, String desc, String time) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  Text(time, style: const TextStyle(color: Colors.white38, fontSize: 10)),
                ],
              ),
              const SizedBox(height: 2),
              Text(desc, style: const TextStyle(color: Colors.white54, fontSize: 11)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPnLCard() {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFF1a2c32), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Column(
        children: [
          _buildPnLTabs(),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Net PnL (Today)", style: TextStyle(color: Colors.white54, fontSize: 12)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Text("+\$428.50", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                              child: const Row(
                                children: [
                                  Icon(Icons.trending_up, color: Colors.green, size: 12),
                                  Text(" +3.2%", style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.05))),
                      child: const Column(
                        children: [
                          Icon(Icons.rocket_launch, color: Colors.green, size: 24),
                          Text("BULLISH", style: TextStyle(color: Colors.green, fontSize: 8, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: _buildMiniPnLTrend()),
                    const SizedBox(width: 12),
                    Expanded(child: _buildVs7dAverage()),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildPnLMetric("Trades", "8"),
                    _buildPnLMetric("Win Rate", "75%", color: const Color(0xFF13b6ec)),
                    _buildPnLMetric("Volume", "\$12.5k"),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPnLTabs() {
    return Container(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05)))),
      child: TabBar(
        controller: _pnlTabController,
        dividerColor: Colors.transparent,
        indicatorColor: const Color(0xFF13b6ec),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white54,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        tabs: const [Tab(text: "Daily View"), Tab(text: "Weekly View")],
      ),
    );
  }

  Widget _buildMiniPnLTrend() {
    return Container(
      height: 60,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("PnL TREND", style: TextStyle(color: Colors.white38, fontSize: 8, fontWeight: FontWeight.bold)),
          const Spacer(),
          SizedBox(
            height: 20,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(10, (index) => Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  height: (index + 2) * 2.0 + (index % 3 == 0 ? 10 : 0),
                  decoration: BoxDecoration(color: Colors.green.withOpacity(0.5), borderRadius: BorderRadius.circular(1)),
                ),
              )),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVs7dAverage() {
    return Container(
      height: 60,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("VS 7D AVG", style: TextStyle(color: Colors.white38, fontSize: 8, fontWeight: FontWeight.bold)),
              Text("+28%", style: TextStyle(color: Colors.green, fontSize: 8, fontWeight: FontWeight.bold)),
            ],
          ),
          Spacer(),
          Row(
            children: [
              Text("AVG: \$334", style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPnLMetric(String label, String value, {Color? color}) {
    return Column(
      children: [
        Text(label.toUpperCase(), style: const TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: color ?? Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildMetricsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        _buildMetricCard("Total Return", "+124.5%", Icons.trending_up, Colors.white, true),
        _buildMetricCard("Max Drawdown", "-12.4%", Icons.warning_rounded, Colors.redAccent, false),
        _buildMetricCard("Sharpe Ratio", "2.1", Icons.analytics, Colors.white, false),
        _buildMetricCard("Win Ratio", "1.5", Icons.balance, Colors.white, false),
      ],
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color, bool featured) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: featured ? const Color(0xFF1a2c32) : const Color(0xFF1a2c32).withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w500)),
              Icon(icon, color: featured ? const Color(0xFF13b6ec) : Colors.white24, size: 14),
            ],
          ),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
        ],
      ),
    );
  }

  Widget _buildMarketTrendsSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Market Trends", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            _buildToggleIcons(),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(color: const Color(0xFF1a2c32), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white10)),
          child: Column(
            children: [
              Row(
                children: [
                  _buildTrendTab("Top Gainers", true),
                  _buildTrendTab("Top Losers", false),
                ],
              ),
              _buildTrendItem("SUI", "L1", "\$1.85", "+15.3%", Colors.blue, true),
              _buildTrendItem("SOL", "L1", "\$142.50", "+8.4%", Colors.indigo, true),
              _buildTrendItem("BTC", "PoW", "\$67,200", "+4.2%", Colors.orange, true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTrendTab(String text, bool active) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? const Color(0xFF13b6ec).withOpacity(0.1) : Colors.transparent,
          border: Border(bottom: BorderSide(color: active ? const Color(0xFF13b6ec) : Colors.transparent, width: 2)),
        ),
        child: Text(text, style: TextStyle(color: active ? const Color(0xFF13b6ec) : Colors.white38, fontSize: 11, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildTrendItem(String symbol, String category, String price, String change, Color color, bool bullish) {
    return ListTile(
      leading: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
        child: Icon(Icons.token, color: color, size: 20),
      ),
      title: Row(
        children: [
          Text(symbol, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(width: 6),
          Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1), decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(4)), child: Text(category, style: const TextStyle(color: Colors.white38, fontSize: 9))),
        ],
      ),
      subtitle: const Text("Vol \$180M", style: TextStyle(color: Colors.white38, fontSize: 10)),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(price, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          Text(change, style: TextStyle(color: bullish ? Colors.green : Colors.red, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildMarketInsightsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Market Insights", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            TextButton(onPressed: () {}, child: const Text("View All", style: TextStyle(color: Color(0xFF13b6ec), fontSize: 12))),
          ],
        ),
        _buildInsightCard("Bitcoin Spot ETF sees record inflows", "Institutional interest drives massive volume...", "1h ago", "MARKET NEWS", Colors.blue),
        const SizedBox(height: 12),
        _buildInsightCard("Tech sector earnings impact crypto", "Correlation between Nasdaq and crypto decouples...", "3h ago", "ANALYSIS", Colors.purple),
      ],
    );
  }

  Widget _buildInsightCard(String title, String summary, String time, String tag, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1a2c32), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)), child: Text(tag, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold))),
              Text(time, style: const TextStyle(color: Colors.white38, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(summary, style: const TextStyle(color: Colors.white54, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildEquityCurveSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF1a2c32), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("EQUITY CURVE", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  Text("\$124,500.00", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
              _buildChartFilter(),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 120,
            width: double.infinity,
            child: CustomPaint(painter: _MiniChartPainter(const Color(0xFF13b6ec))),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveTradesHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Text("Active Trades", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Text("(${_trades.length})", style: const TextStyle(color: Colors.white38, fontSize: 14)),
          ],
        ),
        TextButton(onPressed: () {}, child: const Text("View All", style: TextStyle(color: Color(0xFF13b6ec), fontSize: 12))),
      ],
    );
  }

  Widget _buildActiveTradeCard(Trade trade) {
    final bullish = trade.pnl != null && trade.pnl! >= 0;
    final color = bullish ? Colors.green : Colors.red;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        // Navigation vers le détail du trade si nécessaire
      },
      child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1a2c32), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white10)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.indigo.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.token, color: Colors.indigo)),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(trade.asset.symbol, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)), child: Text("${trade.side} 20x", style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold))),
                          const SizedBox(width: 6),
                          const Text("Perp", style: TextStyle(color: Colors.white38, fontSize: 10)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("+\$342.50", style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Text("+14.2%", style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTradeDetail("Entry Price", "\$2,450.00"),
              _buildTradeDetail("Current Price", "\$2,482.15", highlighted: true, color: Colors.green),
            ],
          ),
          const SizedBox(height: 16),
          _buildTPProgress(0.68),
        ],
      ),
    ),
  );
}

  Widget _buildTradeDetail(String label, String value, {bool highlighted = false, Color? color}) {
    return Column(
      crossAxisAlignment: highlighted ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: const TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: color ?? Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildTPProgress(double value) {
    return Column(
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("STOP LOSS", style: TextStyle(color: Colors.white38, fontSize: 8, fontWeight: FontWeight.bold)),
            Text("TAKE PROFIT", style: TextStyle(color: Colors.white38, fontSize: 8, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 6,
          decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(3)),
          child: Stack(
            children: [
              FractionallySizedBox(widthFactor: value, child: Container(decoration: BoxDecoration(gradient: const LinearGradient(colors: [Colors.green, Colors.cyan]), borderRadius: BorderRadius.circular(3)))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildToggleIcons() {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(color: const Color(0xFF1a2c32), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white10)),
      child: const Row(
        children: [
          Icon(Icons.show_chart, color: Color(0xFF13b6ec), size: 16),
          SizedBox(width: 4),
          Icon(Icons.list, color: Colors.white38, size: 16),
        ],
      ),
    );
  }

  Widget _buildChartFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
      child: const Text("1W", style: TextStyle(color: Color(0xFF13b6ec), fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildNavItem(IconData icon, String label, {bool active = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: active ? const Color(0xFF13b6ec) : Colors.white38, size: 24),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: active ? const Color(0xFF13b6ec) : Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildMiddleAction() {
    return Container(
      width: 50, height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFF13b6ec),
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: const Color(0xFF13b6ec).withOpacity(0.3), blurRadius: 10, spreadRadius: 2)],
      ),
      child: const Icon(Icons.bolt, color: Colors.white, size: 30),
    );
  }
}

class _MarqueeItem extends StatelessWidget {
  final Color color;
  final String text;
  const _MarqueeItem({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _MiniChartPainter extends CustomPainter {
  final Color color;
  _MiniChartPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..strokeWidth = 2..style = PaintingStyle.stroke;
    final path = Path();
    path.moveTo(0, size.height * 0.7);
    path.quadraticBezierTo(size.width * 0.2, size.height * 0.2, size.width * 0.4, size.height * 0.5);
    path.quadraticBezierTo(size.width * 0.6, size.height * 0.8, size.width * 0.8, size.height * 0.1);
    path.lineTo(size.width, size.height * 0.3);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
