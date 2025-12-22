import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f172a),
      body: Stack(
        children: [
          _buildBackgroundPattern(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 48),
                  _buildLogo(),
                  const SizedBox(height: 32),
                  const Text("Bienvenue", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text("Connectez-vous pour accéder à votre portefeuille", style: TextStyle(color: Colors.white38, fontSize: 14), textAlign: TextAlign.center),
                  const SizedBox(height: 32),
                  _buildInputFields(),
                  const SizedBox(height: 16),
                  _buildForgotPassword(),
                  const SizedBox(height: 24),
                  _buildLoginButton(),
                  const SizedBox(height: 32),
                  _buildSocialDivider(),
                  const SizedBox(height: 24),
                  _buildSocialButtons(),
                  const SizedBox(height: 48),
                  _buildSignUpLink(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundPattern() {
    return Positioned.fill(
      child: Opacity(
        opacity: 0.05,
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 10),
          itemBuilder: (ctx, idx) => Container(margin: const EdgeInsets.all(15), decoration: const BoxDecoration(color: Color(0xFF13b6ec), shape: BoxShape.circle)),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
      ],
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 80, height: 80,
      decoration: BoxDecoration(color: const Color(0xFF13b6ec).withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF13b6ec).withOpacity(0.2)), boxShadow: [BoxShadow(color: const Color(0xFF13b6ec).withOpacity(0.1), blurRadius: 20)]),
      child: const Icon(Icons.candlestick_chart, color: Color(0xFF13b6ec), size: 40),
    );
  }

  Widget _buildInputFields() {
    return Column(
      children: [
        _buildTextField("Email ou nom d'utilisateur", Icons.mail, false),
        const SizedBox(height: 20),
        _buildTextField("Mot de passe", Icons.lock, true),
      ],
    );
  }

  Widget _buildTextField(String hint, IconData icon, bool isPassword) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(hint, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: const Color(0xFF1c2427), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05))),
          child: TextField(
            obscureText: isPassword && _obscureText,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              icon: Icon(icon, color: Colors.white24, size: 20),
              hintText: isPassword ? "••••••••" : "exemple@email.com",
              hintStyle: const TextStyle(color: Colors.white10),
              border: InputBorder.none,
              suffixIcon: isPassword ? IconButton(icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off, color: Colors.white24, size: 20), onPressed: () => setState(() => _obscureText = !_obscureText)) : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(onPressed: () {}, child: const Text("Mot de passe oublié ?", style: TextStyle(color: Color(0xFF13b6ec), fontSize: 12, fontWeight: FontWeight.bold))),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => Navigator.pushReplacementNamed(context, '/dashboard'),
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF13b6ec), foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 10, shadowColor: const Color(0xFF13b6ec).withOpacity(0.3)),
        child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text("Se connecter", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), SizedBox(width: 8), Icon(Icons.login, size: 18)]),
      ),
    );
  }

  Widget _buildSocialDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: Colors.white12)),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text("OU CONTINUER AVEC", style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2))),
        const Expanded(child: Divider(color: Colors.white12)),
      ],
    );
  }

  Widget _buildSocialButtons() {
    return Column(
      children: [
        _buildSocialItem("Continuer avec Google", "https://upload.wikimedia.org/wikipedia/commons/5/53/Google_%22G%22_Logo.svg", false),
        const SizedBox(height: 12),
        _buildSocialItem("Continuer avec Apple", "", true),
      ],
    );
  }

  Widget _buildSocialItem(String text, String iconUrl, bool isApple) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(color: isApple ? Colors.white : const Color(0xFF1c2427), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(isApple ? Icons.apple : Icons.g_mobiledata, color: isApple ? Colors.black : Colors.white, size: 24),
          const SizedBox(width: 12),
          Text(text, style: TextStyle(color: isApple ? Colors.black : Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Vous n'avez pas de compte ?", style: TextStyle(color: Colors.white38, fontSize: 13)),
        TextButton(onPressed: () => Navigator.pushNamed(context, '/register'), child: const Text("S'inscrire", style: TextStyle(color: Color(0xFF13b6ec), fontWeight: FontWeight.bold, fontSize: 13))),
      ],
    );
  }
}
