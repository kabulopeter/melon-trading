import 'dart:ui';
import 'package:flutter/material.dart';
import '../../data/services/api_service.dart';
import '../../data/services/ai_prediction_service.dart';
import '../../data/services/asset_service.dart';
import '../../data/services/trade_service.dart';
import '../../data/services/preference_service.dart';
import '../../data/models/asset_model.dart';
import '../../data/models/preference_model.dart';
import '../widgets/skeleton_loading.dart';
import 'package:flutter/services.dart';

class AiIntelligenceScreen extends StatefulWidget {
  const AiIntelligenceScreen({super.key});

  @override
  State<AiIntelligenceScreen> createState() => _AiIntelligenceScreenState();
}

class _AiIntelligenceScreenState extends State<AiIntelligenceScreen> {
  final AiPredictionService _aiService = AiPredictionService(ApiService());
  final AssetService _assetService = AssetService(ApiService());
  final TradeService _tradeService = TradeService(ApiService());
  final PreferenceService _prefService = PreferenceService(ApiService());
  
  bool _isLoading = true;
  bool _autoTradeEnabled = false;
  List<Asset> _assets = [];
  Map<String, dynamic> _predictions = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final assets = await _assetService.getAssets();
      final prefs = await _prefService.getPreferences();
      
      if (!mounted) return;
      setState(() {
        _assets = assets;
        if (prefs != null) {
          _autoTradeEnabled = prefs.autoTrade;
        }
      });
      
      // Load initial batch predictions
      final batch = await _aiService.batchPredict();
      if (!mounted) return;
      setState(() {
        for (var p in batch) {
          final assetId = p['asset'];
          final asset = _assets.where((a) => a.id == assetId).firstOrNull;
          if (asset != null) {
            _predictions[asset.symbol] = p;
          }
        }
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading AI data: $e");
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _getPrediction(String symbol) async {
    HapticFeedback.mediumImpact();
    // Show loading for this specific item in a real app
    final pred = await _aiService.predictSymbol(symbol);
    if (pred != null) {
      setState(() {
        _predictions[symbol] = pred;
      });
    }
  }

  Future<void> _refreshAI() async {
    HapticFeedback.mediumImpact();
    final res = await _aiService.refreshAll();
    if (res != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message'] ?? "Analyse IA lancée..."),
          backgroundColor: const Color(0xFF13b6ec),
        ),
      );
    }
  }

  Future<void> _executeDecision(Asset asset, Map<String, dynamic> pred) async {
    HapticFeedback.heavyImpact();
    
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1e293b),
        title: Text("Confirmer le Trade ${asset.symbol}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Action: ${pred['signal_type']}", style: TextStyle(color: pred['signal_type'] == "BUY" ? Colors.greenAccent : Colors.redAccent, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Prix Prédit: \$${pred['predicted_price']}"),
            Text("Confiance: ${((pred['confidence'] ?? 0) * 100).toInt()}%"),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Annuler", style: TextStyle(color: Colors.white38))),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF13b6ec)),
            child: const Text("Exécuter"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await _tradeService.createTrade({
        'asset': asset.id,
        'side': pred['signal_type'],
        'size': '1.0', // Default size
        'entry_price': pred['technical_indicators']['current_price'].toString(),
        'stop_loss': (pred['technical_indicators']['current_price'] * 0.95).toString(),
        'take_profit': (pred['technical_indicators']['current_price'] * 1.10).toString(),
        'confidence_score': pred['confidence'],
        'status': 'OPEN',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success != null ? "Trade exécuté avec succès !" : "Erreur lors de l'exécution du trade."),
            backgroundColor: success != null ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f172a),
      body: Stack(
        children: [
          _buildGlow(),
          CustomScrollView(
            slivers: [
              _buildAppBar(),
              _buildHeader(),
              _isLoading 
                ? const SliverFillRemaining(child: DashboardSkeleton())
                : SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildAssetPredictionCard(_assets[index]),
                        childCount: _assets.length,
                      ),
                    ),
                  ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGlow() {
    return Positioned(
      top: -100, left: -100,
      child: Container(
        width: 400, height: 400,
        decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF13b6ec).withOpacity(0.1)),
        child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100), child: Container(color: Colors.transparent)),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      title: const Text("IA Intelligence", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
      actions: [
        IconButton(icon: const Icon(Icons.refresh), onPressed: () => _loadData()),
        IconButton(icon: const Icon(Icons.auto_awesome), onPressed: () => _refreshAI()),
      ],
    );
  }

  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [const Color(0xFF1e293b), const Color(0xFF0f172a)]),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("ANALYSE PRÉDICTIVE IA", style: TextStyle(color: Color(0xFF13b6ec), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(child: Text("Anticipez les mouvements du marché avec une précision algorithmique.", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
                  Column(
                    children: [
                      Switch.adaptive(
                        value: _autoTradeEnabled,
                        activeColor: const Color(0xFF13b6ec),
                        onChanged: (val) async {
                          HapticFeedback.selectionClick();
                          final updated = await _prefService.updatePreferences({'auto_trade': val});
                          if (updated != null) {
                            setState(() => _autoTradeEnabled = updated.autoTrade);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(_autoTradeEnabled ? "Mode Auto-Trading Activé 🤖" : "Mode Auto-Trading Désactivé"),
                                backgroundColor: _autoTradeEnabled ? Colors.blue : Colors.grey,
                              ),
                            );
                          }
                        },
                      ),
                      const Text("BOT MODE", style: TextStyle(color: Colors.white24, fontSize: 8, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _buildStat("Précision", "84.2%"),
                  const SizedBox(width: 24),
                  _buildStat("Signaux/Jour", "12"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildAssetPredictionCard(Asset asset) {
    final pred = _predictions[asset.symbol];
    final hasPred = pred != null;
    final signalType = hasPred ? pred['signal_type'] : "NEUTRAL";
    
    Color signalColor = Colors.grey;
    IconData signalIcon = Icons.trending_flat;
    
    if (signalType == "BUY") {
      signalColor = Colors.greenAccent;
      signalIcon = Icons.trending_up;
    } else if (signalType == "SELL") {
      signalColor = Colors.redAccent;
      signalIcon = Icons.trending_down;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1e293b).withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(width: 48, height: 48, decoration: BoxDecoration(color: const Color(0xFF13b6ec).withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.currency_bitcoin, color: Color(0xFF13b6ec))),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(asset.symbol, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(asset.name, style: const TextStyle(color: Colors.white38, fontSize: 12)),
                  ],
                ),
              ),
              if (!hasPred)
                ElevatedButton(
                  onPressed: () => _getPrediction(asset.symbol),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF13b6ec), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                  child: const Text("Prédire"),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Icon(signalIcon, color: signalColor, size: 16),
                        const SizedBox(width: 4),
                        Text(signalType, style: TextStyle(color: signalColor, fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),
                    Text("${((pred['confidence'] ?? 0) * 100).toInt()}% Conf.", style: const TextStyle(color: Colors.white24, fontSize: 10)),
                  ],
                ),
            ],
          ),
          if (hasPred) ...[
            const Divider(color: Colors.white10, height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSmallStat("Prix Prédit", "\$${pred['predicted_price']}"),
                _buildSmallStat("Tendance", signalType == "BUY" ? "BULLISH" : "BEARISH", color: signalColor),
                ElevatedButton(
                  onPressed: () => _executeDecision(asset, pred),
                  style: ElevatedButton.styleFrom(backgroundColor: signalColor.withOpacity(0.2), foregroundColor: signalColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0),
                  child: const Text("Prendre Décision", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSmallStat(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 9)),
        Text(value, style: TextStyle(color: color ?? Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
