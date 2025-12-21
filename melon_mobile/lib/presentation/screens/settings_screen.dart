import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/theme_manager.dart';
import '../../data/services/api_service.dart';
import '../../data/services/broker_service.dart';
import '../../data/models/broker_model.dart';
import 'strategy_config_screen.dart';
import 'risk_management_screen.dart';
import 'challenges_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _darkMode;
  bool _notifications = true;
  
  final BrokerService _brokerService = BrokerService(ApiService());
  List<BrokerAccount> _brokers = [];
  bool _isLoadingBrokers = true;

  @override
  void initState() {
    super.initState();
    _darkMode = ThemeManager.instance.currentMode == ThemeMode.dark;
    _loadBrokers();
  }

  Future<void> _loadBrokers() async {
    final list = await _brokerService.getBrokers();
    if (mounted) {
      setState(() {
        _brokers = list;
        _isLoadingBrokers = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f172a),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileCard(),
                  const SizedBox(height: 24),
                  _buildSectionTitle("COMPTES & SÉCURITÉ"),
                  _buildSettingsGroup([
                    _buildSettingsItem(Icons.person_outline, "Informations Personnelles", onTap: () {}),
                    _buildSettingsItem(Icons.shield_outlined, "Sécurité (2FA, Mot de passe)", onTap: () {}),
                  ]),
                  const SizedBox(height: 24),
                  _buildSectionTitle("ÉCOSYSTÈME DE TRADING"),
                  _buildSettingsGroup([
                    _buildSettingsItem(Icons.key_outlined, "API Keys & Brokers", subtitle: "Deriv Connecté - Actif", onTap: () {}),
                    _buildSettingsItem(Icons.candlestick_chart_outlined, "Gestion des Risques", subtitle: "Strict", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RiskManagementScreen()))),
                    _buildSettingsItem(Icons.tune_outlined, "Configuration Stratégie", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => StrategyConfigScreen()))),
                  ]),
                  const SizedBox(height: 24),
                  _buildSectionTitle("NOTIFICATIONS"),
                  _buildSettingsGroup([
                    _buildToggleItem(Icons.notifications_active_outlined, "Notifications de Commerce", "Alertes push lors des exécutions", _notifications, (v) => setState(() => _notifications = v)),
                    _buildToggleItem(Icons.warning_amber_outlined, "Alertes Critiques", "Appels de marge et prix", true, (v) {}),
                  ]),
                  const SizedBox(height: 24),
                  _buildSectionTitle("PRÉFÉRENCES"),
                  _buildSettingsGroup([
                    _buildSettingsItem(Icons.attach_money, "Devise par défaut", subtitle: "USD"),
                    _buildSettingsItem(Icons.language, "Langue", subtitle: "Français"),
                    _buildToggleItem(Icons.dark_mode_outlined, "Mode Sombre", "Interface sombre", _darkMode, (v) {
                      setState(() => _darkMode = v);
                      ThemeManager.instance.toggleTheme(v);
                    }),
                  ]),
                  const SizedBox(height: 24),
                  _buildSectionTitle("AIDE & SUPPORT"),
                  _buildSettingsGroup([
                    _buildSettingsItem(Icons.live_help_outlined, "Centre d'Aide", color: Colors.greenAccent),
                    _buildSettingsItem(Icons.support_agent_outlined, "Service Client", color: Colors.greenAccent),
                  ]),
                  const SizedBox(height: 32),
                  _buildLogoutButton(),
                  const SizedBox(height: 16),
                  const Center(child: Text("Melon-Trading v2.4.1", style: TextStyle(color: Colors.white24, fontSize: 12))),
                  const SizedBox(height: 48),
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
      title: const Text("Paramètres", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
      centerTitle: true,
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF18282f), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 60, height: 60,
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFF13b6ec), width: 2), image: const DecorationImage(image: NetworkImage("https://lh3.googleusercontent.com/aida-public/AB6AXuDzsjOCkwhaz4fS0xE4SbDQTVTs0l1qhv6LQW2sUDVgWhRFJX3-_cKVQOkWpLAA2S1Q_lhTPwxoldVHsMV5xJDXRn-e2dnfUVPYrgKNRfLzmT03f_Pl0gpddYISxN7I7YU-IC4-Pd5CS_lwXVY3zLHqSu85jNDNOXtdxCeMeCMh1fwG3k4NAzQpQbtlUdgI527NFgklTyAIlPeHY5bLgzzOBL-8mv6quU-GoQiGAx8VMfNvlqaXDIXDOfkMc41TggCpmLvfDM9ZFQsx"), fit: BoxFit.cover)),
              ),
              Positioned(right: 0, bottom: 0, child: Container(width: 14, height: 14, decoration: BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle, border: Border.all(color: const Color(0xFF18282f), width: 2)))),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text("Trader", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(width: 8),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: const Color(0xFF13b6ec).withOpacity(0.2), borderRadius: BorderRadius.circular(4)), child: const Text("PRO", style: TextStyle(color: Color(0xFF13b6ec), fontSize: 8, fontWeight: FontWeight.bold))),
                  ],
                ),
                const Text("ID: 8839210", style: TextStyle(color: Colors.white38, fontSize: 12)),
              ],
            ),
          ),
          Container(width: 36, height: 36, decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle), child: const Icon(Icons.edit, color: Colors.white, size: 18)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(title, style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFF18282f), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsItem(IconData icon, String title, {String? subtitle, VoidCallback? onTap, Color? color}) {
    return ListTile(
      onTap: onTap,
      leading: Container(width: 36, height: 36, decoration: BoxDecoration(color: (color ?? const Color(0xFF13b6ec)).withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color ?? const Color(0xFF13b6ec), size: 20)),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
      subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 11)) : null,
      trailing: const Icon(Icons.chevron_right, color: Colors.white12),
    );
  }

  Widget _buildToggleItem(IconData icon, String title, String sub, bool val, Function(bool) onChanged) {
    return ListTile(
      leading: Container(width: 36, height: 36, decoration: BoxDecoration(color: const Color(0xFF13b6ec).withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: const Color(0xFF13b6ec), size: 20)),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
      subtitle: Text(sub, style: const TextStyle(color: Colors.white38, fontSize: 11)),
      trailing: Switch(value: val, onChanged: onChanged, activeColor: const Color(0xFF13b6ec), activeTrackColor: const Color(0xFF13b6ec).withOpacity(0.3), inactiveTrackColor: Colors.white10),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.logout, size: 18),
        label: const Text("Se Déconnecter", style: TextStyle(fontWeight: FontWeight.bold)),
        style: OutlinedButton.styleFrom(foregroundColor: Colors.redAccent, side: const BorderSide(color: Colors.redAccent, width: 1), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      ),
    );
  }
}
