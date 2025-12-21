import 'package:flutter/material.dart';
import '../../data/models/challenge_model.dart';
import '../../data/models/badge_model.dart';
import '../../data/services/gamification_service.dart';
import '../../data/services/api_service.dart';
import 'dart:ui';
import '../widgets/skeleton_loading.dart';

class ChallengesScreen extends StatefulWidget {
  @override
  _ChallengesScreenState createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GamificationService _gamificationService = GamificationService(ApiService());
  List<UserChallenge> _challenges = [];
  List<UserBadge> _badges = [];
  List<Map<String, dynamic>> _leaderboard = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _gamificationService.getMyChallenges(),
        _gamificationService.getMyBadges(),
        _gamificationService.getLeaderboard(),
      ]);
      setState(() {
        _challenges = results[0] as List<UserChallenge>;
        _badges = results[1] as List<UserBadge>;
        _leaderboard = results[2] as List<Map<String, dynamic>>;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading gamification data: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f172a),
      body: _isLoading
          ? const ChallengesSkeleton()
          : CustomScrollView(
              slivers: [
                _buildSliverAppBar(),
                SliverToBoxAdapter(
                  child: _buildProfileHeader(),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverAppBarDelegate(
                    TabBar(
                      controller: _tabController,
                      indicatorColor: Color(0xFF13b6ec),
                      indicatorWeight: 3,
                      labelColor: Color(0xFF13b6ec),
                      unselectedLabelColor: Colors.grey,
                      labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      tabs: [
                        Tab(text: "Mes Défis"),
                        Tab(text: "Classement"),
                        Tab(text: "Mes Badges"),
                      ],
                    ),
                  ),
                ),
                SliverFillRemaining(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildChallengesList(),
                      _buildLeaderboardList(),
                      _buildBadgesGrid(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 0,
      floating: false,
      pinned: true,
      backgroundColor: Color(0xFF0f172a),
      elevation: 0,
      title: Text("Défis & Récompenses", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.help_outline, size: 20),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    padding: EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(colors: [Color(0xFF13b6ec), Color(0xFF13b6ec).withOpacity(0.3)]),
                    ),
                    child: CircleAvatar(
                      radius: 35,
                      backgroundImage: NetworkImage("https://lh3.googleusercontent.com/aida-public/AB6AXuDzsjOCkwhaz4fS0xE4SbDQTVTs0l1qhv6LQW2sUDVgWhRFJX3-_cKVQOkWpLAA2S1Q_lhTPwxoldVHsMV5xJDXRn-e2dnfUVPYrgKNRfLzmT03f_Pl0gpddYISxN7I7YU-IC4-Pd5CS_lwXVY3zLHqSu85jNDNOXtdxCeMeCMh1fwG3k4NAzQpQbtlUdgI527NFgklTyAIlPeHY5bLgzzOBL-8mv6quU-GoQiGAx8VMfNvlqaXDIXDOfkMc41TggCpmLvfDM9ZFQsx"),
                    ),
                  ),
                  Container(
                    height: 24,
                    width: 24,
                    decoration: BoxDecoration(
                      color: Color(0xFF13b6ec),
                      shape: BoxShape.circle,
                      border: Border.all(color: Color(0xFF0f172a), width: 2),
                    ),
                    child: Center(
                      child: Text("5", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text("Kabulo Peter", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        SizedBox(width: 8),
                        Icon(Icons.verified, color: Color(0xFF13b6ec), size: 18),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text("Trader Élite • Rang #42", style: TextStyle(color: Colors.grey, fontSize: 14)),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Niveau 5", style: TextStyle(color: Color(0xFF13b6ec), fontWeight: FontWeight.bold, fontSize: 12)),
                        Text("2450 / 3000 XP", style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                    SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: 2450 / 3000,
                        minHeight: 8,
                        backgroundColor: Colors.white10,
                        color: Color(0xFF13b6ec),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            children: [
              _buildMetricCard("Rang Global", "#1,248", Icons.public),
              SizedBox(width: 12),
              _buildMetricCard("Série Actuelle", "12 Jours", Icons.local_fire_department, isAccent: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, {bool isAccent = false}) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isAccent ? Color(0xFF13b6ec).withOpacity(0.1) : Color(0xFF18282e),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isAccent ? Color(0xFF13b6ec).withOpacity(0.3) : Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Icon(icon, color: isAccent ? Color(0xFF13b6ec) : Colors.grey, size: 20),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: Colors.grey, fontSize: 11)),
                Text(value, style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChallengesList() {
    if (_challenges.isEmpty) {
      return Center(child: Text("Aucun défi actif", style: TextStyle(color: Colors.grey)));
    }
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _challenges.length,
      itemBuilder: (context, index) {
        final uc = _challenges[index];
        final details = uc.details;
        if (details == null) return SizedBox.shrink();

        double progress = uc.currentValue / details.targetValue;
        if (progress > 1.0) progress = 1.0;

        return Container(
          margin: EdgeInsets.only(bottom: 16),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(0xFF18282e),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Color(0xFF13b6ec).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(_getIconData(details.iconName), color: Color(0xFF13b6ec), size: 28),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(details.title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        SizedBox(height: 2),
                        Text(details.description, style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Color(0xFF10b981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text("+${details.xpReward} XP", style: TextStyle(color: Color(0xFF10b981), fontWeight: FontWeight.bold, fontSize: 11)),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Progression", style: TextStyle(color: Colors.grey, fontSize: 11)),
                  Text("${uc.currentValue.toInt()} / ${details.targetValue.toInt()}", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(height: 8),
              Stack(
                children: [
                  Container(
                    height: 8,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [Color(0xFF13b6ec), Color(0xFF0284c7)]),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(color: Color(0xFF13b6ec).withOpacity(0.3), blurRadius: 4, spreadRadius: 1),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLeaderboardList() {
    if (_leaderboard.isEmpty) {
      return Center(child: Text("Chargement du classement...", style: TextStyle(color: Colors.grey)));
    }
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _leaderboard.length,
      itemBuilder: (context, index) {
        final item = _leaderboard[index];
        final isTop3 = index < 3;
        final isMe = item['username'] == "Kabulo Peter"; // Replace with real check

        Color rankColor = Colors.grey;
        if (index == 0) rankColor = Color(0xFFFFD700); // Gold
        if (index == 1) rankColor = Color(0xFFC0C0C0); // Silver
        if (index == 2) rankColor = Color(0xFFCD7F32); // Bronze

        return Container(
          margin: EdgeInsets.only(bottom: 10),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isMe ? Color(0xFF13b6ec).withOpacity(0.05) : Color(0xFF18282e),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isMe ? Color(0xFF13b6ec) : Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                child: Text(
                  "${index + 1}",
                  style: TextStyle(
                    color: isTop3 ? rankColor : Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              CircleAvatar(
                radius: 20,
                backgroundColor: Color(0xFF13b6ec).withOpacity(0.1),
                child: Text(item['username'][0].toUpperCase(), style: TextStyle(color: Color(0xFF13b6ec), fontWeight: FontWeight.bold)),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['username'], style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    Text("Niveau ${item['level']}", style: TextStyle(color: Colors.grey, fontSize: 11)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("${item['xp']} XP", style: TextStyle(color: Color(0xFF13b6ec), fontWeight: FontWeight.bold, fontSize: 14)),
                  if (isTop3) Icon(Icons.emoji_events, color: rankColor, size: 14),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBadgesGrid() {
    return GridView.builder(
      padding: EdgeInsets.all(20),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 20,
        mainAxisSpacing: 25,
        childAspectRatio: 0.75,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        final ub = index < _badges.length ? _badges[index] : null;
        final details = ub?.details;
        
        bool isUnlocked = ub != null;
        String name = details?.name ?? "Verrouillé";
        IconData icon = _getIconData(details?.iconName ?? "lock");

        return Column(
          children: [
            Container(
              height: 75,
              width: 75,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isUnlocked ? Color(0xFF13b6ec).withOpacity(0.1) : Colors.white.withOpacity(0.02),
                border: Border.all(
                  color: isUnlocked ? Color(0xFF13b6ec) : Colors.white.withOpacity(0.1),
                  width: 2,
                ),
                boxShadow: isUnlocked ? [
                  BoxShadow(color: Color(0xFF13b6ec).withOpacity(0.2), blurRadius: 10, spreadRadius: 2),
                ] : [],
              ),
              child: Center(
                child: Icon(
                  isUnlocked ? icon : Icons.lock_outline,
                  color: isUnlocked ? Color(0xFF13b6ec) : Colors.grey.withOpacity(0.3),
                  size: 30,
                ),
              ),
            ),
            SizedBox(height: 10),
            Text(
              name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isUnlocked ? Colors.white : Colors.grey,
                fontSize: 11,
                fontWeight: isUnlocked ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        );
      },
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'account_balance_wallet': return Icons.account_balance_wallet;
      case 'local_fire_department': return Icons.local_fire_department;
      case 'ads_click': return Icons.ads_click;
      case 'rocket_launch': return Icons.rocket_launch;
      case 'diamond': return Icons.diamond;
      case 'military_tech': return Icons.military_tech;
      case 'shield': return Icons.shield;
      case 'crown': return Icons.emoji_events;
      case 'currency_exchange': return Icons.currency_exchange;
      case 'show_chart': return Icons.show_chart;
      case 'workspace_premium': return Icons.workspace_premium;
      case 'verified': return Icons.verified;
      case 'leaderboard': return Icons.leaderboard;
      case 'psychology': return Icons.psychology;
      case 'nightlight': return Icons.nightlight;
      case 'account_balance': return Icons.account_balance;
      case 'savings': return Icons.savings;
      case 'trending_up': return Icons.trending_up;
      case 'bar_chart': return Icons.bar_chart;
      default: return Icons.military_tech;
    }
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          color: Color(0xFF0f172a).withOpacity(0.8),
          child: _tabBar,
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
