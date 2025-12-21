import 'package:flutter/material.dart';
import '../../data/models/strategy_profile_model.dart';
import '../../data/services/strategy_service.dart';
import '../../data/services/api_service.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import '../widgets/skeleton_loading.dart';

class StrategyConfigScreen extends StatefulWidget {
  @override
  _StrategyConfigScreenState createState() => _StrategyConfigScreenState();
}

class _StrategyConfigScreenState extends State<StrategyConfigScreen> {
  late StrategyService _strategyService;
  List<StrategyProfile> _strategies = [];
  StrategyProfile? _activeStrategy;
  bool _isLoading = true;

  double _minConfidence = 0.75;
  
  // Indicators states
  bool _rsiEnabled = true;
  bool _macdEnabled = false;
  bool _maEnabled = true;

  @override
  void initState() {
    super.initState();
    _strategyService = StrategyService(ApiService());
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final strategies = await _strategyService.getStrategies();
      setState(() {
        _strategies = strategies;
        _activeStrategy = strategies.firstWhere((s) => s.isActive, orElse: () => strategies.isNotEmpty ? strategies.first : StrategyProfile(name: 'Scalping BTC/ETH'));
        _minConfidence = _activeStrategy?.minConfidence ?? 0.75;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading strategies: $e");
      setState(() {
        _strategies = [StrategyProfile(name: 'Scalping BTC/ETH', isActive: true)];
        _activeStrategy = _strategies.first;
        _isLoading = false;
      });
    }
  }

  Future<void> _saveStrategy() async {
    HapticFeedback.mediumImpact();
    if (_activeStrategy == null) return;
    
    final Map<String, dynamic> data = {
      'min_confidence': _minConfidence,
      'indicators_config': {
        'rsi': {'enabled': _rsiEnabled},
        'macd': {'enabled': _macdEnabled},
        'ma': {'enabled': _maEnabled},
      }
    };

    final result = await _strategyService.updateStrategy(_activeStrategy!.id!, data);
    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Stratégie mise à jour"), backgroundColor: Color(0xFF10b981)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f172a),
      body: _isLoading
          ? const StrategySkeleton()
          : CustomScrollView(
              slivers: [
                _buildAppBar(),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildActiveProfileCard(),
                        SizedBox(height: 32),
                        _buildStrategyProfilesManager(),
                        SizedBox(height: 32),
                        _buildAIConfidenceSection(),
                        SizedBox(height: 32),
                        _buildTechnicalIndicatorsSection(),
                        SizedBox(height: 32),
                        _buildBacktestButton(),
                        SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: const Color(0xFF0f172a).withOpacity(0.8),
      pinned: true,
      elevation: 0,
      centerTitle: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Paramètres", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w500)),
          Text("Configuration Stratégie", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(icon: Icon(Icons.notifications_none), onPressed: () {}),
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                height: 8,
                width: 8,
                decoration: BoxDecoration(color: Color(0xFF13b6ec), shape: BoxShape.circle),
              ),
            ),
          ],
        ),
        SizedBox(width: 8),
      ],
    );
  }

  Widget _buildActiveProfileCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF1a2c32),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("PROFIL ACTIF", style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          SizedBox(height: 16),
          Row(
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: Color(0xFF13b6ec).withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: Color(0xFF13b6ec).withOpacity(0.2)),
                ),
                child: Icon(Icons.analytics_rounded, color: Color(0xFF13b6ec), size: 26),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_activeStrategy?.name ?? "Scalping BTC/ETH", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 2),
                    Text("Modifié: Aujourd'hui 10:42", style: TextStyle(color: Colors.white38, fontSize: 12)),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text("Modifier", style: TextStyle(color: Color(0xFF13b6ec), fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ],
          ),
          SizedBox(height: 20),
          Container(height: 1, color: Colors.white.withOpacity(0.05)),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildQuickAction(Icons.save_rounded, "Sauver", () => _saveStrategy()),
              _buildQuickAction(Icons.folder_open_rounded, "Charger", () {}),
              _buildQuickAction(Icons.edit_rounded, "Nommer", () {}),
              _buildQuickAction(Icons.delete_outline_rounded, "Suppr.", () {}, isDestructive: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label, VoidCallback onTap, {bool isDestructive = false}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle),
            child: Icon(icon, color: isDestructive ? Colors.redAccent.withOpacity(0.7) : Colors.white70, size: 18),
          ),
          SizedBox(height: 8),
          Text(label, style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildStrategyProfilesManager() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.folder_open, color: Color(0xFF13b6ec), size: 18),
            SizedBox(width: 8),
            Text("Profils de Stratégie", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        SizedBox(height: 16),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(0xFF1a2c32),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Column(
            children: [
              Text("CHARGER UN PROFIL EXISTANT", style: TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(color: Color(0xFF0f172a), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          dropdownColor: Color(0xFF1a2c32),
                          underline: SizedBox(),
                          icon: Icon(Icons.keyboard_arrow_down, color: Colors.white38),
                          value: _strategies.any((s) => s.name == (_activeStrategy?.name)) ? _activeStrategy?.name : (_strategies.isNotEmpty ? _strategies.first.name : null),
                          items: (_strategies.isEmpty ? [StrategyProfile(name: "Default Scalper")] : _strategies).map((StrategyProfile strategy) {
                            return DropdownMenuItem<String>(
                              value: strategy.name, 
                              child: Text(strategy.name, style: TextStyle(color: Colors.white, fontSize: 14))
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _activeStrategy = _strategies.firstWhere((s) => s.name == val);
                                _minConfidence = _activeStrategy?.minConfidence ?? 0.75;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  _buildIconAction(Icons.edit_rounded, Colors.grey),
                  SizedBox(width: 10),
                  _buildIconAction(Icons.delete_rounded, Colors.redAccent),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildSecondaryButton(Icons.save_as_rounded, "Sauver")),
                  SizedBox(width: 12),
                  Expanded(child: _buildSecondaryButton(Icons.add_rounded, "Nouveau")),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIconAction(IconData icon, Color color) {
    return Container(
      height: 42,
      width: 42,
      decoration: BoxDecoration(color: Color(0xFF0f172a), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white10)),
      child: Icon(icon, color: color.withOpacity(0.7), size: 20),
    );
  }

  Widget _buildSecondaryButton(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(color: Color(0xFF0f172a), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white70, size: 16),
          SizedBox(width: 8),
          Text(label, style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildAIConfidenceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.psychology, color: Color(0xFF13b6ec), size: 18),
            SizedBox(width: 8),
            Text("AI Risk Management", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        SizedBox(height: 16),
        Container(
          width: double.infinity,
          height: 140,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            image: DecorationImage(
              image: NetworkImage("https://lh3.googleusercontent.com/aida-public/AB6AXuBbTqE87lt3dLTuFY1_qAallRIvyWop02b35cUL93vRAu0GN8xQpC-ygNXjkWsMk-bXHKOodvSoufNlCtrijUd7mdefaAxO3mu_Utoj68PlaSb1hIKajn3um_4T37RTiWbgX843M-hl9MKnZDZLK_eWGD-wr0uwdqxcvYW58igVJHl2twkUgKM8jsTv5IpyzYTFMr7m3n8zX83BjNGsUvU-aWFkjUtOuF_vDZFOWDSr8QgkRK-xk3vmfVWi6P6gL-YraCtWNMCutQLk"),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [const Color(0xFF0f172a).withOpacity(0.9), Colors.transparent]),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("AI Confidence Filter", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text("Exécution basée sur la probabilité de succès.", style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Color(0xFF1a2c32),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Minimum Confidence", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                  Text("${(_minConfidence * 100).toInt()}%", style: TextStyle(color: const Color(0xFF13b6ec), fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(height: 20),
              Slider(
                value: _minConfidence,
                min: 0.6,
                max: 1.0,
                activeColor: Color(0xFF13b6ec),
                onChanged: (val) => setState(() => _minConfidence = val),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Conservateur (90%)", style: TextStyle(color: Colors.white38, fontSize: 10)),
                  Text("Agressif (60%)", style: TextStyle(color: Colors.white38, fontSize: 10)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTechnicalIndicatorsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.candlestick_chart_rounded, color: Color(0xFF13b6ec), size: 18),
            SizedBox(width: 8),
            Text("Indicateurs Techniques", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        SizedBox(height: 16),
        _buildIndicatorCard("RSI", "Relative Strength Index", "Momentum", _rsiEnabled, (val) => setState(() => _rsiEnabled = val), color: Colors.purpleAccent),
        SizedBox(height: 12),
        _buildIndicatorCard("MACD", "MACD", "Trend-following", _macdEnabled, (val) => setState(() => _macdEnabled = val), color: Colors.orangeAccent),
        SizedBox(height: 12),
        _buildIndicatorCard("MA", "Moyennes Mobiles", "Trend", _maEnabled, (val) => setState(() => _maEnabled = val), color: Colors.blueAccent),
      ],
    );
  }

  Widget _buildIndicatorCard(String code, String name, String type, bool enabled, Function(bool) onToggle, {required Color color}) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF1a2c32),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withOpacity(0.2))),
                  child: Center(child: Text(code, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10))),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                      Text(type, style: TextStyle(color: Colors.white38, fontSize: 11)),
                    ],
                  ),
                ),
                Switch(
                  value: enabled,
                  onChanged: onToggle,
                  activeColor: Color(0xFF13b6ec),
                ),
              ],
            ),
          ),
          if (enabled && code == "RSI")
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(color: Colors.black12, border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05)))),
              child: Row(
                children: [
                  Expanded(child: _buildParamInput("Length", "14")),
                  SizedBox(width: 10),
                  Expanded(child: _buildParamInput("Over", "70")),
                  SizedBox(width: 10),
                  Expanded(child: _buildParamInput("Under", "30")),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildParamInput(String label, String value) {
    return Column(
      children: [
        Text(label.toUpperCase(), style: TextStyle(color: Colors.white38, fontSize: 8, fontWeight: FontWeight.bold)),
        SizedBox(height: 6),
          Container(
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: const Color(0xFF0f172a), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white10)),
            child: Text(value, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'monospace')),
          ),
      ],
    );
  }

  Widget _buildBacktestButton() {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF13b6ec), Color(0xFF0284c7)]),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Color(0xFF13b6ec).withOpacity(0.3), blurRadius: 15, spreadRadius: 2),
            ],
          ),
          child: Container(
            height: 55,
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history_edu_rounded, color: Colors.white),
                SizedBox(width: 12),
                Text("Backtester la Stratégie", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.all(20),
      color: const Color(0xFF0f172a),
      child: ElevatedButton(
        onPressed: _saveStrategy,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF13b6ec),
          minimumSize: Size(double.infinity, 55),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text("Sauvegarder les Paramètres", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}
