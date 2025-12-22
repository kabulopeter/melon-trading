import 'package:flutter/material.dart';
import '../../data/models/risk_config_model.dart';
import '../../data/services/risk_service.dart';
import '../../data/services/api_service.dart';
import 'dart:ui';
import 'package:flutter/services.dart';

class RiskManagementScreen extends StatefulWidget {
  const RiskManagementScreen({super.key});

  @override
  _RiskManagementScreenState createState() => _RiskManagementScreenState();
}

class _RiskManagementScreenState extends State<RiskManagementScreen> {
  late RiskService _riskService;
  RiskConfig? _config;
  bool _isLoading = true;

  // Controllers for numeric inputs
  final TextEditingController _stopLossController = TextEditingController(text: "5.0");
  final TextEditingController _takeProfitController = TextEditingController(text: "10.0");
  final TextEditingController _dailyLossController = TextEditingController(text: "150");
  final TextEditingController _drawdownController = TextEditingController(text: "15.0");

  double _riskPerTrade = 2.0;
  bool _autoSizing = true;
  bool _dailyLossEnabled = true;
  bool _riskNotifications = true;
  bool _isDailyLossPercent = true;

  @override
  void initState() {
    super.initState();
    _riskService = RiskService(ApiService());
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final config = await _riskService.getRiskConfig();
    setState(() {
      _config = config ?? RiskConfig();
      _riskPerTrade = _config!.riskPerTradePercent;
      _autoSizing = _config!.autoSizingEnabled;
      _riskNotifications = _config!.riskNotificationsEnabled;
      _stopLossController.text = _config!.defaultStopLossPercent.toStringAsFixed(1);
      _takeProfitController.text = _config!.defaultTakeProfitPercent.toStringAsFixed(1);
      _dailyLossController.text = _config!.dailyMaxLossAmount.toStringAsFixed(0);
      _drawdownController.text = _config!.drawdownThresholdPercent.toStringAsFixed(1);
      _isDailyLossPercent = _config!.dailyMaxLossIsPercent;
      _isLoading = false;
    });
  }

  Future<void> _saveConfig() async {
    HapticFeedback.mediumImpact();
    final Map<String, dynamic> data = {
      'risk_per_trade_percent': _riskPerTrade,
      'default_stop_loss_percent': double.tryParse(_stopLossController.text) ?? 5.0,
      'default_take_profit_percent': double.tryParse(_takeProfitController.text) ?? 10.0,
      'daily_max_loss_amount': double.tryParse(_dailyLossController.text) ?? 150.0,
      'daily_max_loss_is_percent': _isDailyLossPercent,
      'drawdown_threshold_percent': double.tryParse(_drawdownController.text) ?? 15.0,
      'auto_sizing_enabled': _autoSizing,
      'risk_notifications_enabled': _riskNotifications,
    };

    final result = await _riskService.updateRiskConfig(data);
    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Configuration sauvegardée avec succès"),
          backgroundColor: Color(0xFF10b981),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0f172a),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text("Gestion des Risques", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFF13b6ec)))
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildIntroInfo(),
                  SizedBox(height: 32),
                  _buildTradeParamsSection(),
                  SizedBox(height: 32),
                  _buildCircuitBreakersSection(),
                  SizedBox(height: 32),
                  _buildPreferencesSection(),
                  SizedBox(height: 120),
                ],
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _buildSaveButton(),
    );
  }

  Widget _buildIntroInfo() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF13b6ec).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFF13b6ec).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.verified_user, color: Color(0xFF13b6ec), size: 22),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Configurez vos paramètres de sécurité. Ces règles seront appliquées automatiquement par l'IA Melon-Trading pour protéger votre capital.",
                  style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          TextButton.icon(
            onPressed: () {},
            icon: Icon(Icons.info_outline, size: 16, color: Color(0xFF13b6ec)),
            label: Text("Guide Fonctionnalités Clés", style: TextStyle(color: Color(0xFF13b6ec), fontSize: 12, fontWeight: FontWeight.bold)),
            style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
          ),
        ],
      ),
    );
  }

  Widget _buildTradeParamsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("PARAMÈTRES PAR TRADE"),
        SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Color(0xFF1a2c32),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text("Risque par Trade", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                            SizedBox(width: 4),
                            Icon(Icons.help_outline, color: Colors.grey, size: 16),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(color: Color(0xFF13b6ec).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                          child: Text("${_riskPerTrade.toStringAsFixed(1)}%", style: TextStyle(color: Color(0xFF13b6ec), fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'monospace')),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text("Pourcentage max du capital total risqué sur une seule position.", style: TextStyle(color: Colors.grey, fontSize: 11)),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Text("0.5%", style: TextStyle(color: Colors.grey, fontSize: 10)),
                        Expanded(
                          child: Slider(
                            value: _riskPerTrade,
                            min: 0.5,
                            max: 5.0,
                            activeColor: Color(0xFF13b6ec),
                            inactiveColor: Colors.white10,
                            onChanged: (val) => setState(() => _riskPerTrade = val),
                          ),
                        ),
                        Text("5.0%", style: TextStyle(color: Colors.grey, fontSize: 10)),
                      ],
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: Colors.white.withOpacity(0.05)),
              IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(child: _buildRiskInput("Stop-Loss (%)", _stopLossController)),
                    Container(width: 1, color: Colors.white.withOpacity(0.05)),
                    Expanded(child: _buildRiskInput("Take-Profit (%)", _takeProfitController)),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
                  border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.balance, color: Colors.grey, size: 16),
                        SizedBox(width: 8),
                        Text("Ratio Risque/Récompense", style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Color(0xFF10b981).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Color(0xFF10b981).withOpacity(0.2)),
                      ),
                      child: Text("1 : 2.0", style: TextStyle(color: Color(0xFF10b981), fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRiskInput(String label, TextEditingController controller) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w500)),
          SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'monospace'),
            textAlign: TextAlign.right,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 8),
              suffixText: " %",
              suffixStyle: TextStyle(color: Colors.grey, fontSize: 14),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircuitBreakersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("COUPE-CIRCUIT (PROTECTION)"),
        SizedBox(height: 12),
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Color(0xFF1a2c32),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Column(
            children: [
              _buildToggleRow(
                "Perte Journalière Max",
                "Suspend le trading pour 24h si la perte cumulée atteint ce seuil.",
                _dailyLossEnabled,
                (val) => setState(() => _dailyLossEnabled = val),
                icon: Icons.warning_amber_rounded,
                iconBg: Colors.orange.withOpacity(0.1),
                iconColor: Colors.orange,
              ),
              SizedBox(height: 16),
              _buildCurrencyInput(_dailyLossController, isPercent: _isDailyLossPercent, onToggle: (val) => setState(() => _isDailyLossPercent = val)),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Divider(height: 1, color: Colors.white.withOpacity(0.05)),
              ),
              _buildToggleRow(
                "Seuil Drawdown Global",
                "Arrêt d'urgence si le capital total chute de ce pourcentage.",
                true,
                (val) {},
                icon: Icons.trending_down_rounded,
                iconBg: Colors.red.withOpacity(0.1),
                iconColor: Colors.red,
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(color: Color(0xFF0f172a), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _drawdownController,
                              keyboardType: TextInputType.number,
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                              textAlign: TextAlign.right,
                              decoration: InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero),
                            ),
                          ),
                          Text(" %", style: TextStyle(color: Colors.grey, fontSize: 14)),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Container(
                    width: 120,
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.red.withOpacity(0.05), border: Border.all(color: Colors.red.withOpacity(0.1)), borderRadius: BorderRadius.circular(10)),
                    child: Text("Action critique requise", textAlign: TextAlign.center, style: TextStyle(color: Colors.red.withOpacity(0.7), fontSize: 10, fontWeight: FontWeight.bold, height: 1.2)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildToggleRow(String title, String subtitle, bool value, Function(bool) onChanged, {required IconData icon, required Color iconBg, required Color iconColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 30,
          width: 30,
          decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              SizedBox(height: 4),
              Text(subtitle, style: TextStyle(color: Colors.grey, fontSize: 11, height: 1.4)),
            ],
          ),
        ),
        SizedBox(width: 8),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: Color(0xFF13b6ec),
          activeTrackColor: Color(0xFF13b6ec).withOpacity(0.3),
        ),
      ],
    );
  }

  Widget _buildCurrencyInput(TextEditingController controller, {required bool isPercent, required Function(bool) onToggle}) {
    return Container(
      height: 50,
      decoration: BoxDecoration(color: Color(0xFF0f172a), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
                border: InputBorder.none,
                hintText: "Valeur",
                hintStyle: TextStyle(color: Colors.white24),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.all(4),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                _buildUnitButton("USD", !isPercent, () => onToggle(false)),
                _buildUnitButton("%", isPercent, () => onToggle(true)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitButton(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: active ? Color(0xFF13b6ec) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(label, style: TextStyle(color: active ? Colors.white : Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildPreferencesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("PRÉFÉRENCES"),
        SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Color(0xFF1a2c32),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Column(
            children: [
              _buildListToggle("Calcul de Taille Auto", "Ajuster la taille de position selon le risque", _autoSizing, (val) => setState(() => _autoSizing = val)),
              Divider(height: 1, color: Colors.white.withOpacity(0.05)),
              _buildListToggle("Notifications de Risque", "Alertes push avant d'atteindre les limites", _riskNotifications, (val) => setState(() => _riskNotifications = val)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildListToggle(String title, String subtitle, bool value, Function(bool) onChanged) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      title: Text(title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey, fontSize: 12, height: 1.5)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: Color(0xFF13b6ec),
        activeTrackColor: Color(0xFF13b6ec).withOpacity(0.3),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        SizedBox(width: 4),
        Text(title, style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.5)),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Container(
      padding: EdgeInsets.all(20),
      color: Colors.transparent,
      child: ElevatedButton(
        onPressed: _saveConfig,
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
              BoxShadow(color: Color(0xFF13b6ec).withOpacity(0.3), blurRadius: 15, spreadRadius: 2, offset: Offset(0, 4)),
            ],
          ),
          child: Container(
            height: 55,
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.save_rounded, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Text("Enregistrer les Paramètres", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
