import 'package:flutter/material.dart';
import '../../data/models/trade_model.dart';
import 'package:intl/intl.dart';

class TradeDetailScreen extends StatelessWidget {
  final Trade trade;

  const TradeDetailScreen({super.key, required this.trade});

  @override
  Widget build(BuildContext context) {
    final bool isProfit = (trade.pnl ?? 0) >= 0;
    final bool isLong = trade.side == 'BUY';
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    return Scaffold(
      backgroundColor: const Color(0xFF0f172a),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMainCard(isProfit, isLong),
                  const SizedBox(height: 24),
                  _buildSectionTitle("DÉTAILS DE L'EXÉCUTION"),
                  _buildDetailsCard(dateFormat),
                  const SizedBox(height: 24),
                  _buildSectionTitle("AI INSIGHTS & ANALYTICS"),
                  _buildAIInsightCard(),
                  const SizedBox(height: 24),
                  _buildSectionTitle("TIMELINE"),
                  _buildTimelineCard(dateFormat),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: const Color(0xFF0f172a),
      pinned: true,
      leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20), onPressed: () => Navigator.pop(context)),
      title: Text("${trade.asset.symbol} / USDT", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
      actions: [
        IconButton(icon: const Icon(Icons.ios_share, color: Colors.white24), onPressed: () {}),
      ],
    );
  }

  Widget _buildMainCard(bool isProfit, bool isLong) {
    final color = isProfit ? Colors.greenAccent : Colors.redAccent;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1c2427),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.1)),
        boxShadow: [BoxShadow(color: color.withOpacity(0.05), blurRadius: 20)],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)), child: Text(isLong ? "LONG" : "SHORT", style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1))),
              const Icon(Icons.verified, color: Color(0xFF13b6ec), size: 20),
            ],
          ),
          const SizedBox(height: 20),
          Text(isProfit ? "+\$${trade.pnl?.toStringAsFixed(2)}" : "-\$${trade.pnl?.abs().toStringAsFixed(2)}", style: TextStyle(color: color, fontSize: 40, fontWeight: FontWeight.bold)),
          const Text("PROFIT RÉALISÉ", style: TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSimpleMetric("ROI", "${isProfit ? '+' : ''}12.4%"),
              _buildSimpleMetric("VOL.", "${trade.size} BTC"),
              _buildSimpleMetric("DURÉE", "4h 20m"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleMetric(String label, String val) {
    return Column(children: [Text(label, style: const TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text(val, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold))]);
  }

  Widget _buildSectionTitle(String title) {
    return Padding(padding: const EdgeInsets.only(left: 4, bottom: 12), child: Text(title, style: const TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)));
  }

  Widget _buildDetailsCard(DateFormat fmt) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF162429), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Column(
        children: [
          _buildDetailRow("Prix d'Entrée", "\$${trade.entryPrice.toStringAsFixed(2)}"),
          _buildDetailRow("Prix de Sortie", "\$${(trade.exitPrice ?? 0).toStringAsFixed(2)}"),
          _buildDetailRow("Stop Loss", "\$${trade.stopLoss.toStringAsFixed(2)}", valColor: Colors.redAccent),
          _buildDetailRow("Take Profit", "\$${trade.takeProfit.toStringAsFixed(2)}", valColor: Colors.greenAccent),
          const Divider(color: Colors.white10),
          _buildDetailRow("Frais Réseaux", "\$1.25"),
          _buildDetailRow("Broker / Exchange", "Binance"),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String val, {Color? valColor}) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(color: Colors.white38, fontSize: 13)), Text(val, style: TextStyle(color: valColor ?? Colors.white, fontSize: 14, fontWeight: FontWeight.bold, fontFeatures: const [FontFeature.tabularFigures()]))]));
  }

  Widget _buildAIInsightCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF13b6ec).withOpacity(0.05), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF13b6ec).withOpacity(0.1))),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(children: [Icon(Icons.smart_toy, color: Color(0xFF13b6ec), size: 20), SizedBox(width: 8), Text("Confidence Score", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold))]),
              Text("${(trade.confidenceScore * 100).toInt()}%", style: const TextStyle(color: Color(0xFF13b6ec), fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: trade.confidenceScore, minHeight: 6, backgroundColor: Colors.white10, color: const Color(0xFF13b6ec))),
          const SizedBox(height: 16),
          const Text("L'IA avait prédit ce mouvement avec une haute probabilité en raison d'une divergence haussière sur le RSI et d'un support solide à 28k.", style: TextStyle(color: Colors.white54, fontSize: 12, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildTimelineCard(DateFormat fmt) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF162429), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Column(
        children: [
          _buildTimelineItem("Ouverture", fmt.format(trade.openedAt), true, Colors.blue),
          _buildTimelineItem("Stop Loss Ajusté", "Aujourd'hui, 10:15", false, Colors.orange),
          _buildTimelineItem("Clôture", trade.closedAt != null ? fmt.format(trade.closedAt!) : "--", false, Colors.green, isLast: true),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String label, String time, bool active, Color color, {bool isLast = false}) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle, boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 4)])),
              if (!isLast) Expanded(child: Container(width: 2, color: Colors.white10)),
            ],
          ),
          const SizedBox(width: 16),
          Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)), Text(time, style: const TextStyle(color: Colors.white24, fontSize: 11))]),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF0f172a), border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05)))),
      child: Row(
        children: [
          Expanded(child: OutlinedButton(onPressed: () {}, style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white10), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: const Text("Journal de bord"))),
          const SizedBox(width: 12),
          Expanded(child: ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF13b6ec), foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: const Text("Re-Trade", style: TextStyle(fontWeight: FontWeight.bold)))),
        ],
      ),
    );
  }
}
