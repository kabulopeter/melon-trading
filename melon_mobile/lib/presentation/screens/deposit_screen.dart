import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/services/api_service.dart';
import '../../data/services/wallet_service.dart';

class DepositScreen extends StatefulWidget {
  const DepositScreen({super.key});

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  final TextEditingController _amountCtrl = TextEditingController();
  final WalletService _walletService = WalletService(ApiService());
  bool _isLoading = false;
  String _selectedMethod = 'MPESA';

  Future<void> _initiateDeposit() async {
    final amount = _amountCtrl.text.trim();
    if (amount.isEmpty || double.tryParse(amount) == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Veuillez entrer un montant valide")));
      return;
    }

    setState(() => _isLoading = true);
    HapticFeedback.heavyImpact();

    try {
      final tx = await _walletService.initiateDeposit(
        amount: amount,
        method: _selectedMethod,
        phoneNumber: "0810000000",
      );

      if (mounted) {
        if (tx != null) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Dépôt initié avec succès.")));
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erreur lors de l'initiation du dépôt.")));
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
                  _buildBalanceCard(),
                  const SizedBox(height: 24),
                  _buildSectionTitle("Méthode enregistrée", onAction: () {}),
                  _buildPaymentMethods(),
                  const SizedBox(height: 24),
                  _buildSectionTitle("Montant à déposer"),
                  _buildAmountInput(),
                  _buildQuickAmounts(),
                  const SizedBox(height: 24),
                  _buildTransactionDetails(),
                  const SizedBox(height: 40),
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
      padding: const EdgeInsets.only(top: 50, bottom: 16),
      decoration: BoxDecoration(color: const Color(0xFF0f172a).withOpacity(0.8), border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05)))),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
            const Column(
              children: [
                Text("Dépôt de Fonds", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Text("Melon-Trading Wallet", style: TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
            IconButton(icon: const Icon(Icons.help_outline, color: Colors.white24), onPressed: () {}),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF1a2c32), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("SOLDE DISPONIBLE", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
              const SizedBox(height: 4),
              const Text("1,240.50 \$", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
          Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFF13b6ec).withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.account_balance_wallet, color: Color(0xFF13b6ec), size: 20)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, {VoidCallback? onAction}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold)),
          if (onAction != null) GestureDetector(onTap: onAction, child: const Text("Gérer", style: TextStyle(color: Color(0xFF13b6ec), fontSize: 12, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Column(
      children: [
        _buildMethodItem("M-Pesa Vodacom", "081 *** 892 • Justin M.", Icons.phone_iphone, Colors.redAccent, true, 'MPESA'),
        _buildMethodItem("Airtel Money", "099 *** 123 • Justin M.", Icons.sim_card, Colors.red, false, 'AIRTEL'),
        _buildMethodItem("Visa • Equity Bank", "**** 4242 • Exp 12/25", Icons.credit_card, Colors.blue, false, 'CARD'),
        _buildAddMethod(),
      ],
    );
  }

  Widget _buildMethodItem(String title, String sub, IconData icon, Color iconColor, bool isDefault, String id) {
    bool active = _selectedMethod == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: active ? const Color(0xFF13b6ec).withOpacity(0.05) : const Color(0xFF1a2c32), borderRadius: BorderRadius.circular(16), border: Border.all(color: active ? const Color(0xFF13b6ec) : Colors.white.withOpacity(0.05), width: active ? 2 : 1)),
        child: Row(
          children: [
            Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle), child: Icon(icon, color: iconColor, size: 20)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)), if (isDefault) ...[const SizedBox(width: 8), Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: const Color(0xFF13b6ec), borderRadius: BorderRadius.circular(4)), child: const Text("DÉFAUT", style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)))]]),
                  Text(sub, style: const TextStyle(color: Colors.white24, fontSize: 11)),
                ],
              ),
            ),
            if (active) const Icon(Icons.check_circle, color: Color(0xFF13b6ec), size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildAddMethod() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.add, size: 18),
        label: const Text("Ajouter une nouvelle méthode"),
        style: OutlinedButton.styleFrom(foregroundColor: Colors.white38, side: BorderSide(color: Colors.white.withOpacity(0.1)), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
      ),
    );
  }

  Widget _buildAmountInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(color: const Color(0xFF1a2c32), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Row(
        children: [
          Expanded(child: TextField(controller: _amountCtrl, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold), keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: "0.00", hintStyle: TextStyle(color: Colors.white10), border: InputBorder.none))),
          const Text("USD", style: TextStyle(color: Colors.white38, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildQuickAmounts() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: ["10 \$", "50 \$", "100 \$", "500 \$"].map((a) => _buildQuickAmountItem(a)).toList(),
      ),
    );
  }

  Widget _buildQuickAmountItem(String text) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          _amountCtrl.text = text.replaceAll(' \$', '');
        },
        child: Container(margin: const EdgeInsets.only(right: 8), padding: const EdgeInsets.symmetric(vertical: 10), decoration: BoxDecoration(color: const Color(0xFF1a2c32), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white.withOpacity(0.05))), child: Center(child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)))),
      ),
    );
  }

  Widget _buildTransactionDetails() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF152329), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("DÉTAILS DE LA TRANSACTION", style: TextStyle(color: Colors.white24, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 16),
          _buildDetailRow("Compte débité", "M-Pesa (**892)", icon: Icons.phone_iphone),
          _buildDetailRow("Montant", "0.00 \$"),
          _buildDetailRow("Frais (1.5%)", "0.00 \$", help: true),
          _buildDetailRow("Temps de traitement", "Immédiat", isTag: true),
          const SizedBox(height: 12),
          const Divider(color: Colors.white10),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total à payer", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const Text("0.00 \$", style: TextStyle(color: Color(0xFF13b6ec), fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String val, {IconData? icon, bool help = false, bool isTag = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [Text(label, style: const TextStyle(color: Colors.white38, fontSize: 13)), if (help) ...[const SizedBox(width: 4), const Icon(Icons.info_outline, color: Colors.white24, size: 14)]]),
          if (isTag) Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(4)), child: Text(val, style: const TextStyle(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.bold))) else Row(children: [if (icon != null) ...[Icon(icon, color: Colors.white24, size: 14), const SizedBox(width: 4)], Text(val, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold))]),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF0f172a), border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05)))),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _initiateDeposit,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF13b6ec), foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 10, shadowColor: const Color(0xFF13b6ec).withOpacity(0.2)),
              child: _isLoading 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text("Confirmer le Dépôt", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), SizedBox(width: 8), Icon(Icons.arrow_forward)]),
            ),
          ),
          const SizedBox(height: 12),
          const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.lock, color: Colors.white24, size: 12), SizedBox(width: 4), Text("Transactions sécurisées et cryptées par SSL", style: TextStyle(color: Colors.white24, fontSize: 10))]),
        ],
      ),
    );
  }
}
