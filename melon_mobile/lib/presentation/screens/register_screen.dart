import 'dart:ui';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _obscureText = true;
  bool _obscureConfirmText = true;
  bool _acceptTerms = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f172a),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              _buildAppBar(),
              const SizedBox(height: 24),
              _buildLogo(),
              const SizedBox(height: 24),
              const Text("Créer un compte", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -1)),
              const SizedBox(height: 8),
              const Text("Bienvenue sur Melon-Trading. Inscrivez-vous pour commencer à trader.", style: TextStyle(color: Colors.white38, fontSize: 15, height: 1.4), textAlign: TextAlign.center),
              const SizedBox(height: 32),
              _buildRegisterForm(),
              const SizedBox(height: 24),
              _buildSecurityChecklist(),
              const SizedBox(height: 24),
              _buildTermsCheckbox(),
              const SizedBox(height: 24),
              _buildRegisterButton(),
              const SizedBox(height: 32),
              _buildSocialSection(),
              const SizedBox(height: 32),
              _buildSignInLink(),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Row(
      children: [
        IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        const Expanded(child: Center(child: Text("Inscription", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)))),
        const SizedBox(width: 48),
      ],
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 64, height: 64,
      decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF13b6ec), Colors.blueAccent]), borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: const Color(0xFF13b6ec).withOpacity(0.2), blurRadius: 10)]),
      child: const Icon(Icons.candlestick_chart, color: Colors.white, size: 32),
    );
  }

  Widget _buildRegisterForm() {
    return Column(
      children: [
        _buildTextField("Nom d'utilisateur", Icons.person, "MelonTrader"),
        const SizedBox(height: 20),
        _buildTextField("Adresse e-mail", Icons.mail, "exemple@email.com"),
        const SizedBox(height: 20),
        _buildPasswordField("Mot de passe", true),
        const SizedBox(height: 20),
        _buildPasswordField("Confirmer le mot de passe", false),
      ],
    );
  }

  Widget _buildTextField(String label, IconData icon, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.only(left: 4, bottom: 8), child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500))),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          height: 60,
          decoration: BoxDecoration(color: const Color(0xFF1a262b), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05))),
          child: TextField(
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(icon: Icon(icon, color: Colors.white24, size: 20), hintText: hint, hintStyle: const TextStyle(color: Colors.white10), border: InputBorder.none),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(String label, bool isFirst) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.only(left: 4, bottom: 8), child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500))),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          height: 60,
          decoration: BoxDecoration(color: const Color(0xFF1a262b), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05))),
          child: TextField(
            obscureText: isFirst ? _obscureText : _obscureConfirmText,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              icon: Icon(isFirst ? Icons.lock : Icons.lock_reset, color: Colors.white24, size: 20),
              hintText: "••••••••",
              hintStyle: const TextStyle(color: Colors.white10),
              border: InputBorder.none,
              suffixIcon: IconButton(icon: Icon((isFirst ? _obscureText : _obscureConfirmText) ? Icons.visibility : Icons.visibility_off, color: Colors.white24, size: 20), onPressed: () => setState(() { if (isFirst) _obscureText = !_obscureText; else _obscureConfirmText = !_obscureConfirmText; })),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityChecklist() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1a262b).withOpacity(0.5), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.02))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("SÉCURITÉ DU MOT DE PASSE", style: TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          const SizedBox(height: 12),
          _buildCheckItem("Minimum 8 caractères", false),
          const SizedBox(height: 8),
          _buildCheckItem("Au moins une majuscule", true),
          const SizedBox(height: 8),
          _buildCheckItem("Au moins un chiffre", false),
        ],
      ),
    );
  }

  Widget _buildCheckItem(String text, bool completed) {
    return Row(
      children: [
        Container(width: 20, height: 20, decoration: BoxDecoration(color: completed ? Colors.green.withOpacity(0.1) : Colors.white10, shape: BoxShape.circle), child: Icon(Icons.check, color: completed ? Colors.greenAccent : Colors.white24, size: 12)),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(color: completed ? Colors.white70 : Colors.white24, fontSize: 13)),
      ],
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      children: [
        Checkbox(value: _acceptTerms, onChanged: (v) => setState(() => _acceptTerms = v!), activeColor: const Color(0xFF13b6ec), side: BorderSide(color: Colors.white.withOpacity(0.1))),
        const Expanded(child: Text("J'accepte la politique de confidentialité et les conditions d'utilisation.", style: TextStyle(color: Colors.white38, fontSize: 12, height: 1.4))),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF13b6ec), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 12, shadowColor: const Color(0xFF13b6ec).withOpacity(0.3)),
        child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text("S'inscrire", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), SizedBox(width: 8), Icon(Icons.arrow_forward, size: 18)]),
      ),
    );
  }

  Widget _buildSocialSection() {
    return Column(
      children: [
        Row(children: [const Expanded(child: Divider(color: Colors.white12)), Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text("OU CONTINUER AVEC", style: TextStyle(color: Colors.white24, fontSize: 11, fontWeight: FontWeight.bold))), const Expanded(child: Divider(color: Colors.white12))]),
        const SizedBox(height: 24),
        _buildSocialItem("Continuer avec Google", Icons.g_mobiledata, false),
        const SizedBox(height: 12),
        _buildSocialItem("Continuer avec Apple", Icons.apple, true),
      ],
    );
  }

  Widget _buildSocialItem(String text, IconData icon, bool isApple) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(color: const Color(0xFF1a262b), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildSignInLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Vous avez déjà un compte ?", style: TextStyle(color: Colors.white38, fontSize: 14)),
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Se connecter", style: TextStyle(color: Color(0xFF13b6ec), fontWeight: FontWeight.bold, fontSize: 14))),
      ],
    );
  }
}
