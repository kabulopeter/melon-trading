import 'dart:ui';
import 'package:flutter/material.dart';
import '../widgets/skeleton_loading.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _activeFilter = "Tous";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f172a),
      body: Column(
        children: [
          _buildAppBar(),
          _buildFilters(),
          Expanded(
            child: _isLoading 
              ? const NotificationsSkeleton()
              : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSectionHeader("Aujourd'hui"),
                _buildNotificationItem(
                  "Bitcoin dépasse les 45k\$",
                  "Il y a 10 min",
                  "Le marché montre des signes de reprise alors que les volumes d'achat augmentent significativement.",
                  Icons.trending_up,
                  const Color(0xFF13b6ec),
                  true,
                ),
                _buildNotificationItem(
                  "Mise à jour v2.4 disponible",
                  "Il y a 2h",
                  "Nouvelles fonctionnalités de graphiques avancés maintenant disponibles. Mettez à jour votre application.",
                  Icons.campaign,
                  Colors.purpleAccent,
                  true,
                ),
                const SizedBox(height: 16),
                _buildSectionHeader("Hier"),
                _buildNotificationItem(
                  "Conseil de trading : Diversification",
                  "Hier à 14:30",
                  "Apprenez comment réduire vos risques en diversifiant votre portefeuille sur différents secteurs.",
                  Icons.lightbulb,
                  Colors.amberAccent,
                  false,
                ),
                _buildNotificationItem(
                  "Clôture hebdomadaire",
                  "Hier à 09:00",
                  "Résumé des performances des principaux actifs pour la semaine écoulée.",
                  Icons.show_chart,
                  Colors.grey,
                  false,
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.only(top: 50, bottom: 8),
      decoration: BoxDecoration(color: const Color(0xFF0f172a).withOpacity(0.9), border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05)))),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20), onPressed: () => Navigator.pop(context)),
            const Text("Notifications", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            TextButton(onPressed: () {}, child: const Text("Tout lire", style: TextStyle(color: Color(0xFF13b6ec), fontSize: 14, fontWeight: FontWeight.bold))),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            const SizedBox(width: 16),
            ...["Tous", "Actualités", "Annonces", "Conseils"].map((f) => _buildFilterChip(f)),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String text) {
    bool active = _activeFilter == text;
    return GestureDetector(
      onTap: () => setState(() => _activeFilter = text),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(color: active ? const Color(0xFF13b6ec) : const Color(0xFF18282f), borderRadius: BorderRadius.circular(20), border: active ? null : Border.all(color: Colors.white.withOpacity(0.05)), boxShadow: active ? [BoxShadow(color: const Color(0xFF13b6ec).withOpacity(0.3), blurRadius: 10)] : []),
        child: Text(text, style: TextStyle(color: active ? Colors.white : Colors.white38, fontSize: 13, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(title, style: const TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
    );
  }

  Widget _buildNotificationItem(String title, String time, String desc, IconData icon, Color iconColor, bool unread) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF18282f), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Stack(
        children: [
          if (unread) Positioned(top: 0, right: 0, child: Container(width: 10, height: 10, decoration: BoxDecoration(color: const Color(0xFF13b6ec), shape: BoxShape.circle, boxShadow: [BoxShadow(color: const Color(0xFF13b6ec).withOpacity(0.6), blurRadius: 8)]))),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(width: 48, height: 48, decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(16)), child: Icon(icon, color: iconColor, size: 24)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, height: 1.2)),
                    const SizedBox(height: 4),
                    Text(time, style: const TextStyle(color: Colors.white24, fontSize: 11)),
                    const SizedBox(height: 8),
                    Text(desc, style: const TextStyle(color: Colors.white54, fontSize: 13, height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              if (!unread) const Icon(Icons.chevron_right, color: Colors.white12, size: 20),
            ],
          ),
        ],
      ),
    );
  }
}
