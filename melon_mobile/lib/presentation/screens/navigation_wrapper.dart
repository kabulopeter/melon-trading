import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dashboard_screen.dart';
import 'wallet_screen.dart';
import 'analytics_screen.dart';
import 'settings_screen.dart';
import 'challenges_screen.dart';

class NavigationWrapper extends StatefulWidget {
  const NavigationWrapper({super.key});

  @override
  State<NavigationWrapper> createState() => _NavigationWrapperState();
}

class _NavigationWrapperState extends State<NavigationWrapper> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const WalletScreen(),
    const AnalyticsScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f172a),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: IndexedStack(
          key: ValueKey<int>(_currentIndex),
          index: _currentIndex,
          children: _screens,
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0f172a).withOpacity(0.95),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.grid_view_rounded, "Accueil", 0),
          _buildNavItem(Icons.account_balance_wallet_outlined, "Portefeuille", 1),
          _buildMiddleAction(),
          _buildNavItem(Icons.analytics_outlined, "Signaux", 2),
          _buildNavItem(Icons.settings_outlined, "Paramètres", 3),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool active = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _currentIndex = index);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: active ? const Color(0xFF13b6ec) : Colors.white38,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: active ? const Color(0xFF13b6ec) : Colors.white38,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiddleAction() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        // Optionnel: Ouvrir une page de trade rapide ou défis
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ChallengesScreen()),
        );
      },
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF13b6ec), Color(0xFF0284c7)],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF13b6ec).withOpacity(0.3),
              blurRadius: 10,
            ),
          ],
        ),
        child: const Icon(Icons.swap_horiz, color: Colors.white, size: 30),
      ),
    );
  }
}
