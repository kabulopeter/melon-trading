import 'package:flutter/material.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  Future<void> _loadNews() async {
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() {
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
        : Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTrendingNews(),
                      _buildLatestNewsHeader(),
                      _buildNewsItem("Bloomberg", "4h", "La FED maintient ses taux directeurs inchangés pour le moment", "Jérôme Powell insiste sur la nécessité de voir l'inflation baisser durablement.", "Macro", "Neutre", Colors.grey),
                      _buildNewsItem("Reuters", "6h", "Apple dépasse les attentes au Q4 grâce aux services", "Le géant de la tech affiche un chiffre d'affaires record, propulsant l'action.", "\$AAPL", "Haussier", Colors.green),
                      _buildNewsItem("CoinTelegraph", "8h", "Ethereum: Les développeurs annoncent une mise à jour critique", "La mise à jour Dencun promet de réduire drastiquement les frais de transaction.", "\$ETH", "Haussier", Colors.green),
                      _buildNewsItem("WSJ", "12h", "Le pétrole chute sous les 70\$ le baril", "Les craintes d'un ralentissement économique en Chine pèsent lourdement.", "Commodities", "Baissier", Colors.red),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 50, bottom: 16),
      decoration: BoxDecoration(color: const Color(0xFF0f172a), border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05)))),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
                const Text("Actualités du Marché", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.tune, color: Colors.white), onPressed: () {}),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: const Color(0xFF1a2c32), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.1))),
              child: const TextField(
                style: TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(icon: Icon(Icons.search, color: Colors.white38, size: 20), hintText: "Rechercher actif ou mot-clé...", hintStyle: TextStyle(color: Colors.white24), border: InputBorder.none),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const SizedBox(width: 16),
                _buildCategoryBadge("Tout", true),
                _buildCategoryBadge("Macro", false),
                _buildCategoryBadge("Cryptos", false),
                _buildCategoryBadge("Actions", false),
                _buildCategoryBadge("Tech", false),
                const SizedBox(width: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBadge(String text, bool active) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(color: active ? const Color(0xFF13b6ec) : const Color(0xFF1a2c32), borderRadius: BorderRadius.circular(20), border: active ? null : Border.all(color: Colors.white10), boxShadow: active ? [BoxShadow(color: const Color(0xFF13b6ec).withOpacity(0.3), blurRadius: 10)] : []),
      child: Text(text, style: TextStyle(color: active ? Colors.white : Colors.white38, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildTrendingNews() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.trending_up, color: Color(0xFF13b6ec), size: 20),
              SizedBox(width: 8),
              Text("À la une", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 240,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: const DecorationImage(
                image: NetworkImage("https://lh3.googleusercontent.com/aida-public/AB6AXuA8fHcj3cqj0fHQVisXguZLgGVzajXEhc1SqkSa0LPjluzLPavQcEY054GMYCy3BnjicMVwMSw9oxHhjNjRGWeynNEsegik5l2FSlsYxKQJwVQzPW6tjlD8f0y6h9QPQdJkN0gyTdF4IDiG4Nx7Zr0xGew7WEtR7WP6nnuAAqy0EsBS0RLGqTFD4xuRqkMfXnGIMMEAaPXd-cLNrpQuybBrOscnpyge3CFhBmQH5140eLNvtSIwfcb_vAaXhNSy1lWdCxZeoS_MG5Ly"),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black38, BlendMode.darken),
              ),
            ),
            child: Stack(
              children: [
                Positioned(top: 12, right: 12, child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.black26, shape: BoxShape.circle), child: const Icon(Icons.bookmark_border, color: Colors.white, size: 20))),
                Positioned(
                  bottom: 16, left: 16, right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.green.withOpacity(0.3))), child: const Text("HAUSSIER", style: TextStyle(color: Colors.green, fontSize: 8, fontWeight: FontWeight.bold))),
                          const SizedBox(width: 8),
                          const Text("CoinDesk • Il y a 2h", style: TextStyle(color: Colors.white70, fontSize: 10)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text("Bitcoin dépasse la résistance majeure des 45k\$", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLatestNewsHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text("Dernières nouvelles", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildNewsItem(String source, String time, String title, String summary, String tag, String sentiment, Color sentimentColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1a2c32), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(width: 20, height: 20, decoration: BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle), child: Center(child: Text(source[0], style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)))),
                  const SizedBox(width: 8),
                  Text(source, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Text("• $time", style: const TextStyle(color: Colors.white24, fontSize: 12)),
                ],
              ),
              const Icon(Icons.bookmark_border, color: Colors.white24, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(summary, style: const TextStyle(color: Colors.white54, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.white10)), child: Text(tag, style: const TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.bold))),
              const SizedBox(width: 8),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: sentimentColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)), child: Row(children: [Container(width: 6, height: 6, decoration: BoxDecoration(color: sentimentColor, shape: BoxShape.circle)), const SizedBox(width: 4), Text(sentiment, style: TextStyle(color: sentimentColor, fontSize: 9, fontWeight: FontWeight.bold))])),
            ],
          ),
        ],
      ),
    );
  }
}
