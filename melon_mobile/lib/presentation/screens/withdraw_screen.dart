import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/services/api_service.dart';
import '../../data/services/wallet_service.dart';

class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({super.key});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final TextEditingController _amountCtrl = TextEditingController();
  final TextEditingController _otpCtrl = TextEditingController();
  final WalletService _walletService = WalletService(ApiService());
  bool _isLoading = false;
  String _selectedMethod = 'mpesa';

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
                  _buildSectionHeader("Compte de réception", onAction: () {}),
                  _buildWithdrawalMethods(),
                  const SizedBox(height: 24),
                  _buildSectionHeader("Montant du retrait"),
                  _buildAmountInput(),
                  const SizedBox(height: 24),
                  _buildSecuritySection(),
                  const SizedBox(height: 24),
                  _buildSummaryCard(),
                  const SizedBox(height: 16),
                  _buildWarningNote(),
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
      decoration: BoxDecoration(color: const Color(0xFF0f172a), border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05)))),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
            const Expanded(child: Center(child: Text("Retrait de Fonds", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)))),
            const SizedBox(width: 48), // Spacer for center alignment
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF1c2427), Color(0xFF0f172a)]), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Center(
        child: Column(
          children: [
            const Text("SOLDE RETIRABLE", style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 8),
            const Text("\$1,250.00", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.green.withOpacity(0.2))), child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.check_circle, color: Colors.greenAccent, size: 14), SizedBox(width: 6), Text("Disponible", style: TextStyle(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.bold))])),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onAction}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
          if (onAction != null) GestureDetector(onTap: onAction, child: const Text("Gérer", style: TextStyle(color: Color(0xFF13b6ec), fontSize: 12, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildWithdrawalMethods() {
    return Column(
      children: [
        _buildMethodItem("M-Pesa Vodacom", "+243 812 ••• •89", Icons.payments, Colors.redAccent, true, 'mpesa'),
        _buildMethodItem("Visa Débit", "•••• •••• •••• 4242", Icons.credit_card, Colors.blueAccent, false, 'visa'),
        _buildMethodItem("Airtel Money", "+243 998 ••• •12", Icons.phonelink_ring, Colors.red, false, 'airtel'),
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
        decoration: BoxDecoration(color: active ? const Color(0xFF13b6ec).withOpacity(0.1) : const Color(0xFF1c2427), borderRadius: BorderRadius.circular(16), border: Border.all(color: active ? const Color(0xFF13b6ec) : Colors.white.withOpacity(0.05))),
        child: Row(
          children: [
            Container(width: 40, height: 40, decoration: BoxDecoration(color: iconColor.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: iconColor, size: 20)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)), if (isDefault) ...[const SizedBox(width: 8), Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: const Color(0xFF13b6ec), borderRadius: BorderRadius.circular(4)), child: const Text("Défaut", style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)))]]),
                  Text(sub, style: const TextStyle(color: Colors.white24, fontSize: 11)),
                ],
              ),
            ),
            Container(width: 20, height: 20, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: active ? const Color(0xFF13b6ec) : Colors.white24, width: 2), color: active ? const Color(0xFF13b6ec) : Colors.transparent), child: active ? const Icon(Icons.check, color: Colors.white, size: 12) : null),
          ],
        ),
      ),
    );
  }

  Widget _buildAddMethod() {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(16), side: BorderSide(color: Colors.white.withOpacity(0.1)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
      child: Row(
        children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle), child: const Icon(Icons.add, color: Colors.white38, size: 20)),
          const SizedBox(width: 16),
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Ajouter une méthode", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 14)), Text("Mobile Money ou Carte Bancaire", style: TextStyle(color: Colors.white24, fontSize: 11))])),
          const Icon(Icons.chevron_right, color: Colors.white24),
        ],
      ),
    );
  }

  Widget _buildAmountInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(color: const Color(0xFF1c2427), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Row(
        children: [
          const Text("\$", style: TextStyle(color: Colors.white38, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(child: TextField(controller: _amountCtrl, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold), keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: "0.00", hintStyle: TextStyle(color: Colors.white10), border: InputBorder.none))),
          TextButton(onPressed: () => _amountCtrl.text = "1250", style: TextButton.styleFrom(backgroundColor: const Color(0xFF13b6ec).withOpacity(0.1), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: const Text("MAX", style: TextStyle(color: Color(0xFF13b6ec), fontSize: 12, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildSecuritySection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF13b6ec).withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF13b6ec).withOpacity(0.2))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(children: [Icon(Icons.lock_clock, color: Color(0xFF13b6ec), size: 20), SizedBox(width: 8), Text("Vérification de sécurité", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold))]),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: const Color(0xFF1c2427), borderRadius: BorderRadius.circular(6)), child: const Row(children: [Icon(Icons.timer, color: Color(0xFF13b6ec), size: 14), SizedBox(width: 4), Text("01:59", style: TextStyle(color: Color(0xFF13b6ec), fontSize: 11, fontWeight: FontWeight.bold))])),
            ],
          ),
          const SizedBox(height: 12),
          const Text("Un code OTP a été envoyé à votre numéro (+243 ••• •89). Veuillez le saisir ci-dessous pour confirmer.", style: TextStyle(color: Colors.white38, fontSize: 11, height: 1.4)),
          const SizedBox(height: 16),
          TextField(controller: _otpCtrl, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 8), decoration: InputDecoration(hintText: "------", hintStyle: const TextStyle(color: Colors.white10), contentPadding: const EdgeInsets.symmetric(vertical: 16), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withOpacity(0.05))), filled: true, fillColor: const Color(0xFF1c2427))),
          const SizedBox(height: 8),
          Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () {}, child: const Text("Renvoyer le code", style: TextStyle(color: Colors.white38, fontSize: 12)))),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF1c2427).withOpacity(0.5), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Column(
        children: [
          _buildSummaryRow("Frais de transaction", "\$2.00"),
          _buildSummaryRow("Délai de traitement", "Instant - 24h"),
          const SizedBox(height: 12),
          const Divider(color: Colors.white10),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Montant reçu estimé", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)), const Text("\$0.00", style: TextStyle(color: Color(0xFF13b6ec), fontSize: 18, fontWeight: FontWeight.bold))]),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String val) {
    return Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(color: Colors.white38, fontSize: 13)), Text(val, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold))]));
  }

  Widget _buildWarningNote() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info, color: Colors.orangeAccent, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text("Les retraits par Mobile Money sont limités à \$500 par transaction. Pour des montants plus élevés, veuillez utiliser le virement bancaire.", style: TextStyle(color: Colors.orangeAccent, fontSize: 11, height: 1.4))),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF0f172a), border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05)))),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            HapticFeedback.heavyImpact();
          },
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF13b6ec), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 10, shadowColor: const Color(0xFF13b6ec).withOpacity(0.2)),
          child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.lock, size: 18), SizedBox(width: 8), Text("Confirmer le retrait", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))]),
        ),
      ),
    );
  }
}
