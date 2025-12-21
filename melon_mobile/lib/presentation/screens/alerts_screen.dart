import 'dart:ui';
import 'package:flutter/material.dart';
import '../../data/services/api_service.dart';
import '../../data/services/alert_service.dart';
import '../../data/services/asset_service.dart';
import '../../data/models/alert_model.dart';
import 'package:intl/intl.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  final AlertService _alertService = AlertService(ApiService());
  final AssetService _assetService = AssetService(ApiService());
  
  List<MarketAlert> _alerts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final alerts = await _alertService.getAlerts();
    if (mounted) {
      setState(() {
        _alerts = alerts;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f172a),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF13b6ec)))
        : CustomScrollView(
            slivers: [
              _buildAppBar(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRecentAlertsCard(),
                      const SizedBox(height: 24),
                      _buildSectionHeader("PARAMÈTRES D'ALERTE"),
                      _buildSettingsItem("Mode d'affichage", "Cartes", Icons.view_agenda),
                      _buildSettingsItem("Fréquence des alertes", "Toujours", Icons.timer),
                      const SizedBox(height: 24),
                      _buildSectionHeader("TYPES DE FILTRES"),
                      _buildToggleItem("Exécutions de Trade", true, Colors.green),
                      _buildToggleItem("Critiques (SL/TP)", true, Colors.redAccent),
                      _buildToggleItem("Alertes de Prix", false, Colors.blue),
                      const SizedBox(height: 32),
                      _buildSaveButton(),
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
      backgroundColor: const Color(0xFF0f172a),
      pinned: true,
      elevation: 0,
      leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
      title: const Text("Mes Alertes", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
      centerTitle: true,
      actions: [
        IconButton(icon: const Icon(Icons.tune, color: Colors.white), onPressed: () {}),
      ],
    );
  }

  Widget _buildRecentAlertsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(gradient: LinearGradient(colors: [const Color(0xFF1a2c32), const Color(0xFF1a2c32).withOpacity(0.8)]), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF13b6ec).withOpacity(0.2)), boxShadow: [BoxShadow(color: const Color(0xFF13b6ec).withOpacity(0.05), blurRadius: 20)]),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(width: 32, height: 32, decoration: BoxDecoration(color: const Color(0xFF13b6ec).withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.notifications_active, color: Color(0xFF13b6ec), size: 16)),
                  const SizedBox(width: 8),
                  const Text("Alertes Récentes", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: const Color(0xFF13b6ec), borderRadius: BorderRadius.circular(10)), child: const Text("3 Nouvelles", style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold))),
            ],
          ),
          const SizedBox(height: 16),
          _buildAlertItem("Take Profit Atteint", "ETH/USDT a atteint l'objectif 2600. Position fermée avec +5.2% profit.", "2m", Colors.green),
          const SizedBox(height: 12),
          _buildAlertItem("Alerte Système", "Forte volatilité détectée sur BTC. Levier réduit à 5x.", "15m", Colors.orange),
        ],
      ),
    );
  }

  Widget _buildAlertItem(String title, String desc, String time, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.2), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(color == Colors.green ? Icons.check_circle : Icons.warning, color: color, size: 14),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)), Text(time, style: const TextStyle(color: Colors.white24, fontSize: 10))]),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(color: Colors.white38, fontSize: 10, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(title, style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
    );
  }

  Widget _buildSettingsItem(String title, String val, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: const Color(0xFF1a2c32), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Row(
        children: [
          Icon(icon, color: Colors.white38, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14))),
          Text(val, style: const TextStyle(color: Color(0xFF13b6ec), fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: Colors.white12, size: 18),
        ],
      ),
    );
  }

  Widget _buildToggleItem(String title, bool val, Color iconColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: const Color(0xFF1a2c32), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 14)),
          const Spacer(),
          Switch(value: val, onChanged: (v) {}, activeColor: const Color(0xFF13b6ec), activeTrackColor: const Color(0xFF13b6ec).withOpacity(0.3), inactiveTrackColor: Colors.white10),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF13b6ec), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 10, shadowColor: const Color(0xFF13b6ec).withOpacity(0.4)), child: const Text("Sauvegarder les Préférences", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15))),
    );
  }
}
