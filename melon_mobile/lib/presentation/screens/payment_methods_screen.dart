import 'package:flutter/material.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f172a),
      body: Column(
        children: [
          _buildAppBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Méthodes de Paiement", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text("Gérez vos comptes et cartes liés pour les dépôts et retraits. Sélectionnez l'étoile pour définir votre favori.", style: TextStyle(color: Colors.white38, fontSize: 13, height: 1.4)),
                  const SizedBox(height: 32),
                  _buildSectionHeader("MOBILE MONEY"),
                  _buildMethodItem("Vodacom M-Pesa", "+243 81 *** **12", "Compte Business", "https://upload.wikimedia.org/wikipedia/commons/e/ea/M-Pesa_Logo-01.png", true, Colors.red),
                  _buildMethodItem("Airtel Money", "+243 99 *** **88", "Mon Airtel Perso", "https://upload.wikimedia.org/wikipedia/commons/d/d4/Airtel_logo_2010.png", false, Colors.redAccent),
                  const SizedBox(height: 24),
                  _buildSectionHeader("CARTES BANCAIRES"),
                  _buildCardItem("Visa Equity", "4242", "Expire le 12/25", true),
                  const SizedBox(height: 40),
                  const Center(child: Text("Vos informations de paiement sont chiffrées et sécurisées selon les standards PCI-DSS.", style: TextStyle(color: Colors.white12, fontSize: 11), textAlign: TextAlign.center)),
                ],
              ),
            ),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.only(top: 50, bottom: 8),
      decoration: BoxDecoration(color: const Color(0xFF0f172a), border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05)))),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
            const Expanded(child: Center(child: Text("Portefeuille", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)))),
            const SizedBox(width: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(padding: const EdgeInsets.only(bottom: 16), child: Text(title, style: const TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)));
  }

  Widget _buildMethodItem(String title, String sub, String note, String logoUrl, bool isDefault, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1c2e36), borderRadius: BorderRadius.circular(20), border: Border.all(color: isDefault ? const Color(0xFF13b6ec) : Colors.white.withOpacity(0.05))),
      child: Row(
        children: [
          Container(width: 50, height: 50, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.phone_android, color: Colors.white24)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)), if (isDefault) ...[const SizedBox(width: 8), Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: const Color(0xFF13b6ec).withOpacity(0.2), borderRadius: BorderRadius.circular(4)), child: const Text("DÉFAUT", style: TextStyle(color: Color(0xFF13b6ec), fontSize: 8, fontWeight: FontWeight.bold)))]]),
                Text(sub, style: const TextStyle(color: Colors.white38, fontSize: 12)),
                Text(note, style: const TextStyle(color: Colors.white12, fontSize: 11)),
              ],
            ),
          ),
          IconButton(icon: Icon(isDefault ? Icons.star : Icons.star_border, color: isDefault ? Colors.amber : Colors.white12), onPressed: () {}),
        ],
      ),
    );
  }

  Widget _buildCardItem(String name, String last4, String expiry, bool hasWarning) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1c2e36), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Row(
        children: [
          Container(width: 56, height: 56, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF1a1f71), Colors.black]), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.credit_card, color: Colors.white54)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)), if (hasWarning) ...[const SizedBox(width: 8), const Icon(Icons.warning, color: Colors.amber, size: 14)]]),
                Row(children: [const Text("•••• ", style: TextStyle(color: Colors.white24, fontSize: 14)), Text(last4, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14))]),
                Text(expiry, style: const TextStyle(color: Colors.white12, fontSize: 11)),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.star_border, color: Colors.white12), onPressed: () {}),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(color: Color(0xFF0f172a)),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add, size: 18),
          label: const Text("Ajouter une méthode"),
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF13b6ec), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 12, shadowColor: const Color(0xFF13b6ec).withOpacity(0.2)),
        ),
      ),
    );
  }
}
