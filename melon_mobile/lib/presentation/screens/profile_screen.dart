import 'dart:ui';
import 'package:flutter/material.dart';
import '../../data/services/api_service.dart';
import '../../data/services/profile_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileService _service = ProfileService(ApiService());
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f172a),
      body: Column(
        children: [
          _buildAppBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 40),
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildInfoSection(),
                  const SizedBox(height: 24),
                  _buildConsentSection(),
                  const SizedBox(height: 24),
                  _buildDownloadSection(),
                  const SizedBox(height: 32),
                  _buildDangerZone(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.only(top: 50, bottom: 16),
      decoration: BoxDecoration(color: const Color(0xFF0f172a), border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05)))),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20), onPressed: () => Navigator.pop(context)),
            const Expanded(child: Center(child: Text("Données Personnelles", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)))),
            const SizedBox(width: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [Color(0xFF13b6ec), Colors.blueAccent])),
            child: CircleAvatar(
              radius: 40,
              backgroundColor: const Color(0xFF16262c),
              backgroundImage: const NetworkImage("https://lh3.googleusercontent.com/aida-public/AB6AXuDRqMfgGnI0khDyayYD-0rIKuzXTMlfGHMtVJwbUx8VRul3yZAQaLqmSu7Ou5onUdwfB1YA8dFwFlaomT7eN3duTqdvLPgz19HVVIaOAfxJd6NqwfZvX8PsXfq7QMuFf4CfXy8zLZp4ptSTn0o-fBLi7tP1SjvN-MBr3BDEVShBr3x-u7YGbmXz1BTrXdr4NEhl58gcTgJh0SEqqJDdYqgZLbaa8p_NU4AD7BimDqAUSZSFFGPX__A0rMp4itlPZAu-Sskb3u1Aposc"),
            ),
          ),
          const SizedBox(height: 16),
          const Text("Jean Dupont", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const Text("Membre depuis 2021", style: TextStyle(color: Colors.white38, fontSize: 12)),
          const SizedBox(height: 8),
          Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(20)), child: const Text("Compte Vérifié", style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8), child: Text("Mes Informations", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: const Color(0xFF16262c), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withOpacity(0.05))),
          child: Column(
            children: [
              _buildInfoTile(Icons.person, "Nom complet", "Jean Dupont", true),
              _buildInfoTile(Icons.mail, "Email", "jean.dupont@melon.com", true),
              _buildInfoTile(Icons.smartphone, "Téléphone", "+33 6 12 34 56 78", false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String val, bool showBorder) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(border: showBorder ? Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))) : null),
      child: Row(
        children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFF13b6ec).withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: const Color(0xFF13b6ec), size: 20)),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)), Text(val, style: const TextStyle(color: Colors.white38, fontSize: 12))])),
          const Icon(Icons.edit, color: Colors.white24, size: 18),
        ],
      ),
    );
  }

  Widget _buildConsentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8), child: Text("Gestion des Consentements", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: const Color(0xFF16262c), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withOpacity(0.05))),
          child: Column(
            children: [
              _buildSwitchTile("Communications Marketing", "Recevoir des offres personnalisées et des nouvelles.", true),
              _buildSwitchTile("Analyse et Performance", "Autoriser la collecte de données anonymes pour améliorer l'application.", true),
              _buildAITile(),
              _buildSwitchTile("Partage Partenaires", "Partager certaines données avec nos partenaires.", false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(String title, String desc, bool val) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05)))),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)), const SizedBox(width: 4), const Icon(Icons.info_outline, color: Colors.white12, size: 14)]),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(color: Colors.white24, fontSize: 11, height: 1.4)),
              ],
            ),
          ),
          Switch(value: val, onChanged: (v) {}, activeColor: const Color(0xFF13b6ec)),
        ],
      ),
    );
  }

  Widget _buildAITile() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: const Color(0xFF13b6ec).withOpacity(0.03),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05)))),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [const Icon(Icons.smart_toy, color: Color(0xFF13b6ec), size: 18), const SizedBox(width: 8), const Text("Amélioration de l'IA", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold))]),
                const SizedBox(height: 4),
                const Text("Partager des données anonymisées pour améliorer la précision.", style: TextStyle(color: Colors.white24, fontSize: 11, height: 1.4)),
              ],
            ),
          ),
          Switch(value: false, onChanged: (v) {}, activeColor: const Color(0xFF13b6ec)),
        ],
      ),
    );
  }

  Widget _buildDownloadSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8), child: Text("Portabilité", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: const Color(0xFF16262c), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withOpacity(0.05))),
            child: Column(
              children: [
                const Text("Vous pouvez demander une archive complète de vos données personnelles au format CSV ou JSON.", style: TextStyle(color: Colors.white38, fontSize: 12, height: 1.4)),
                const SizedBox(height: 20),
                SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.download, size: 18), label: const Text("Télécharger mes données"), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF13b6ec).withOpacity(0.1), foregroundColor: const Color(0xFF13b6ec), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDangerZone() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8), child: Text("Zone de Danger", style: TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold))),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.red.withOpacity(0.05), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.red.withOpacity(0.1))),
            child: Column(
              children: [
                const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(Icons.warning, color: Colors.orangeAccent, size: 20), SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Suppression du compte", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 14)), SizedBox(height: 4), Text("Cette action est irréversible. Toutes vos données seront effacées.", style: TextStyle(color: Colors.redAccent, fontSize: 11, height: 1.4))]))]),
                const SizedBox(height: 20),
                SizedBox(width: double.infinity, child: OutlinedButton(onPressed: () {}, style: OutlinedButton.styleFrom(foregroundColor: Colors.redAccent, side: const BorderSide(color: Colors.redAccent, width: 1), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: const Text("Supprimer mon compte"))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
