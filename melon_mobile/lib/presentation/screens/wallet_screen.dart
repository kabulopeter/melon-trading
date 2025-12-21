import 'dart:ui';
import 'package:flutter/material.dart';
import '../../data/services/api_service.dart';
import '../../data/services/wallet_service.dart';
import '../../data/models/wallet_model.dart';
import 'package:intl/intl.dart';
import 'deposit_screen.dart';
import 'withdraw_screen.dart';
import '../widgets/skeleton_loading.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final ApiService _apiService = ApiService();
  late final WalletService _walletService;
  
  UserWallet? _wallet;
  List<WalletTransaction> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _walletService = WalletService(_apiService);
    _loadWalletData();
  }

  Future<void> _loadWalletData() async {
    setState(() => _isLoading = true);
    final wallet = await _walletService.getBalance();
    final transactions = await _walletService.getTransactions();
    
    if (mounted) {
      setState(() {
        _wallet = wallet;
        _transactions = transactions;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f172a),
      body: _isLoading 
        ? const WalletSkeleton()
        : CustomScrollView(
            slivers: [
              _buildAppBar(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildNetWorthCard(),
                      const SizedBox(height: 32),
                      _buildQuickMethods(),
                      const SizedBox(height: 32),
                      _buildAnalysisSection(),
                      const SizedBox(height: 32),
                      _buildHoldingsSection(),
                      const SizedBox(height: 32),
                      _buildTransactionsHeader(),
                      const SizedBox(height: 16),
                      _buildSearchAndFilters(),
                      const SizedBox(height: 16),
                      ..._transactions.map((tx) => _buildTransactionCard(tx)),
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
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: CircleAvatar(
          radius: 20,
          backgroundImage: const NetworkImage("https://lh3.googleusercontent.com/aida-public/AB6AXuDzsjOCkwhaz4fS0xE4SbDQTVTs0l1qhv6LQW2sUDVgWhRFJX3-_cKVQOkWpLAA2S1Q_lhTPwxoldVHsMV5xJDXRn-e2dnfUVPYrgKNRfLzmT03f_Pl0gpddYISxN7I7YU-IC4-Pd5CS_lwXVY3zLHqSu85jNDNOXtdxCeMeCMh1fwG3k4NAzQpQbtlUdgI527NFgklTyAIlPeHY5bLgzzOBL-8mv6quU-GoQiGAx8VMfNvlqaXDIXDOfkMc41TggCpmLvfDM9ZFQsx"),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Bonjour,", style: TextStyle(color: Colors.white54, fontSize: 12)),
          const Text("Trader", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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

  Widget _buildNetWorthCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1e293b).withOpacity(0.4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 30, offset: const Offset(0, 10))],
      ),
      child: Stack(
        children: [
          Positioned(top: -40, right: -40, child: Container(width: 100, height: 100, decoration: BoxDecoration(color: const Color(0xFF13b6ec).withOpacity(0.2), shape: BoxShape.circle, boxShadow: [BoxShadow(color: const Color(0xFF13b6ec).withOpacity(0.2), blurRadius: 40)]))),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("VALEUR NETTE", style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  const Icon(Icons.visibility_outlined, color: Colors.white38, size: 18),
                ],
              ),
              const SizedBox(height: 8),
              Text("\$${_wallet?.balance ?? '0.00'}", style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold, letterSpacing: -1)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFF10b981).withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFF10b981).withOpacity(0.2))),
                    child: const Row(
                      children: [
                        Icon(Icons.trending_up, color: Color(0xFF10b981), size: 12),
                        SizedBox(width: 4),
                        Text("+2.4%", style: TextStyle(color: Color(0xFF10b981), fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text("vs. mois dernier", style: TextStyle(color: Colors.white38, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DepositScreen())),
                      icon: const Icon(Icons.add_card, size: 18),
                      label: const Text("Dépôt"),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF0f172a), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WithdrawScreen())),
                      icon: const Icon(Icons.arrow_outward, size: 18),
                      label: const Text("Retrait"),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white12, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("MÉTHODES RAPIDES", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildMethodCard("M-PESA", "Vodacom", Colors.red),
              const SizedBox(width: 12),
              _buildMethodCard("Airtel", "Money", Colors.redAccent),
              const SizedBox(width: 12),
              _buildMethodCard("Carte", "Visa/Master", Colors.orange),
              const SizedBox(width: 12),
              _buildMethodCard("Crypto", "USDT/BTC", Colors.blue),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMethodCard(String title, String sub, Color color) {
    return Container(
      width: 110,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(color: const Color(0xFF1e293b).withOpacity(0.5), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Column(
        children: [
          Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 14)),
          Text(sub, style: const TextStyle(color: Colors.white38, fontSize: 9)),
        ],
      ),
    );
  }

  Widget _buildAnalysisSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Analyse", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: const Color(0xFF13b6ec).withOpacity(0.1), borderRadius: BorderRadius.circular(20)), child: const Text("RAPPORTS", style: TextStyle(color: Color(0xFF13b6ec), fontSize: 10, fontWeight: FontWeight.bold))),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: const Color(0xFF1e293b).withOpacity(0.3), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withOpacity(0.05))),
          child: Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  const SizedBox(width: 90, height: 90, child: CircularProgressIndicator(value: 0.7, strokeWidth: 8, color: Colors.orangeAccent, backgroundColor: Colors.white10)),
                  Column(
                    children: [
                      const Text("TOTAL", style: TextStyle(color: Colors.white38, fontSize: 8, fontWeight: FontWeight.bold)),
                      const Text("100%", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  children: [
                    _buildAllocationItem("Cryptos", "35%", Colors.orange),
                    const SizedBox(height: 8),
                    _buildAllocationItem("Actions", "30%", const Color(0xFF13b6ec)),
                    const SizedBox(height: 8),
                    _buildAllocationItem("Forex", "20%", const Color(0xFF10b981)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAllocationItem(String label, String val, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
        Text(val, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
      ],
    );
  }

  Widget _buildHoldingsSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Actifs Détenus", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            TextButton(onPressed: () {}, child: const Text("Détails", style: TextStyle(color: Color(0xFF13b6ec), fontSize: 12))),
          ],
        ),
        _buildHoldingCard("Bitcoin", "0.15 BTC", "\$4,987.50", "+2.58%", Colors.orange),
        const SizedBox(height: 12),
        _buildHoldingCard("Apple Inc.", "25 AAPL", "\$4,375.00", "-0.74%", Colors.blue),
      ],
    );
  }

  Widget _buildHoldingCard(String name, String qty, String val, String perf, Color color) {
    final bullish = perf.startsWith('+');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1e293b).withOpacity(0.3), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white10)),
      child: Column(
        children: [
          Row(
            children: [
              Container(width: 40, height: 40, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(Icons.token, color: color)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                    Text(qty, style: const TextStyle(color: Colors.white38, fontSize: 12)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(val, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(perf, style: TextStyle(color: bullish ? Colors.green : Colors.red, fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsHeader() {
    return const Text("Transactions", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold));
  }

  Widget _buildSearchAndFilters() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(color: const Color(0xFF1e293b).withOpacity(0.6), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.05))),
                child: const TextField(
                  style: TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(icon: Icon(Icons.search, color: Colors.white38, size: 18), hintText: "Rechercher...", hintStyle: TextStyle(color: Colors.white24), border: InputBorder.none),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(width: 42, height: 42, decoration: BoxDecoration(color: const Color(0xFF1e293b).withOpacity(0.6), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)), child: const Icon(Icons.tune, color: Colors.white54, size: 18)),
          ],
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterBadge("Tout", true),
              _buildFilterBadge("Dépôts", false),
              _buildFilterBadge("Retraits", false),
              _buildFilterBadge("En attente", false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterBadge(String text, bool active) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: active ? const Color(0xFF13b6ec) : const Color(0xFF1e293b).withOpacity(0.6), borderRadius: BorderRadius.circular(20), boxShadow: active ? [BoxShadow(color: const Color(0xFF13b6ec).withOpacity(0.3), blurRadius: 10)] : []),
      child: Text(text, style: TextStyle(color: active ? Colors.white : Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildTransactionCard(WalletTransaction tx) {
    final isDeposit = tx.transactionType == 'DEPOSIT';
    final isPending = tx.status == 'PENDING';
    final color = isDeposit ? Colors.green : Colors.orange;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1e293b).withOpacity(0.3), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white10)),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(isPending ? Icons.pending : (isDeposit ? Icons.arrow_downward : Icons.arrow_upward), color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isDeposit ? "Dépôt ${tx.paymentMethod}" : "Retrait ${tx.paymentMethod}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1), decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(4)), child: Text("TXN-${tx.id.toString().substring(0, 5)}", style: const TextStyle(color: Colors.white38, fontSize: 8, fontFamily: 'monospace'))),
                    const SizedBox(width: 8),
                    Text(DateFormat('HH:mm').format(DateTime.parse(tx.createdAt)), style: const TextStyle(color: Colors.white38, fontSize: 10)),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("${isDeposit ? '+' : '-'}\$${tx.amount}", style: TextStyle(color: isDeposit ? Colors.greenAccent : Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)), child: Text(tx.status, style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.bold))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(color: const Color(0xFF0f172a).withOpacity(0.95), border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05)))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.dashboard, "Accueil", onTap: () => Navigator.pop(context)),
          _buildNavItem(Icons.pie_chart, "Portfolio", active: true),
          _buildMiddleAction(),
          _buildNavItem(Icons.show_chart, "Signaux"),
          _buildNavItem(Icons.settings, "Réglages"),
        ],
      ),
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
      decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF13b6ec), Color(0xFF0284c7)]), shape: BoxShape.circle, boxShadow: [BoxShadow(color: const Color(0xFF13b6ec).withOpacity(0.3), blurRadius: 10)]),
      child: const Icon(Icons.swap_horiz, color: Colors.white, size: 30),
    );
  }
}
