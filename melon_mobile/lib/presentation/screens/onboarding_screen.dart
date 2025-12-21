import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _slides = [
    {
      "title": "Trading Automatisé par IA",
      "desc": "Laissez nos algorithmes intelligents optimiser vos positions 24/7 sans que vous leviez le petit doigt.",
      "image": "https://lh3.googleusercontent.com/aida-public/AB6AXuA0lO3SkG3dAgxschIaN-EiPYHg_0T8U2zSXfOoyk4MI1musDJJUzgLZBCMuIjN1N7j6qL4bGYF3D5zoimERexVPgr5TKMGjsvYY8MdUCFd7wxOhyOQr_1q7UyE4lqf2U1WcUg4MckXsTS1DpAY2Y63Vqh2nl17Osy38wegBCVJfp_tlW2_ASSzdkGdEM1ouWftOacVH3WSn8CXC3wDJ5S61ZR5k4mP8zxEZSU4UI7oUXkRZIZGFDZHtRJK6EjRAYwHMfz9pOPbDJKu",
      "color": "0xFF13b6ec",
    },
    {
      "title": "Gestion des Risques",
      "desc": "Protégez votre capital avec des outils de stop-loss dynamiques et une sécurité de niveau bancaire.",
      "image": "https://lh3.googleusercontent.com/aida-public/AB6AXuAuyfjk3NpoPn5lHE-itnorbVF8sVmp8zKBJ6F6Xvz1_3H-urVKrN-PCkS_mssP-3mX2EkLWMSagc7RFfxWqJu-3sG3_Rh2cJaNqzj37OD4rzHbyjG3fV_9j3rTr4iZDWP1H_mPM3utjhBDe7LcsJ1c6MKBMgofx5lCAzT_dynisWP1lPuQ1samjfZv12lZ7Z7DBqckGFInOMnCfwN_AnEs7Nlafss5VN6OO88P9gNPCTLwHbG40OIon1kMZCaJya00dSSYbW-3JkUC",
      "color": "0xFF9C27B0",
    },
    {
      "title": "Analyses de Performance",
      "desc": "Visualisez vos gains avec précision et ajustez votre stratégie en temps réel grâce à nos outils.",
      "image": "https://lh3.googleusercontent.com/aida-public/AB6AXuA1ImvOg6U5L_EgRWvqPMice9635RedlamINfA2OxwV6Muf2KM3KE23UaLuusUX8btCI55fPC9DG6s5DvlWG3alMv2QtITzIlEjASzys5bVMmpRGFA_whhv1PA6OLCMxExOLce7vMI9Xi5sHeJ0YWIyv8zfJv8sbRbPxS1y9XfLnYVB8y3NbXb5IHAMkOPTuiHpVqMcuRTaKGKfrgCPe8sJVysBRUUA6V1xi2vz8u5hWg-KSnd78tLd82yRqdkfi1lbPRXYYKDeD5Ag",
      "color": "0xFF00C853",
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f172a),
      body: Stack(
        children: [
          // Background PageView
          PageView.builder(
            controller: _pageController,
            onPageChanged: (v) => setState(() => _currentPage = v),
            itemCount: _slides.length,
            itemBuilder: (context, index) {
              final slide = _slides[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildImage(slide['image']!, slide['color']!),
                    const SizedBox(height: 60),
                    Text(slide['title']!, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, height: 1.2), textAlign: TextAlign.center),
                    const SizedBox(height: 20),
                    Text(slide['desc']!, style: const TextStyle(color: Colors.white38, fontSize: 16, height: 1.5), textAlign: TextAlign.center),
                    const SizedBox(height: 100), // Space for bottom elements
                  ],
                ),
              );
            },
          ),
          
          // Fixed Top Skip Button
          Positioned(
            top: 60, right: 24,
            child: TextButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text("Passer", style: TextStyle(color: Colors.white38, fontSize: 14, fontWeight: FontWeight.bold)),
            ),
          ),
          
          // Fixed Bottom Elements
          Positioned(
            bottom: 40, left: 40, right: 40,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDots(),
                const SizedBox(height: 48),
                _buildActionButton(),
                const SizedBox(height: 24),
                _buildSignInLink(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String url, String colorHex) {
    final color = Color(int.parse(colorHex));
    return Container(
      width: 280, height: 280,
      decoration: BoxDecoration(
        color: const Color(0xFF162429),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 40, spreadRadius: -10)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: Image.network(url, fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_slides.length, (index) {
        bool active = index == _currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 6, width: active ? 24 : 6,
          decoration: BoxDecoration(color: active ? const Color(0xFF13b6ec) : Colors.white10, borderRadius: BorderRadius.circular(10)),
        );
      }),
    );
  }

  Widget _buildActionButton() {
    bool isLast = _currentPage == _slides.length - 1;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          HapticFeedback.mediumImpact();
          if (isLast) {
            Navigator.pushReplacementNamed(context, '/register');
          } else {
            _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
          }
        },
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF13b6ec), foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), elevation: 12, shadowColor: const Color(0xFF13b6ec).withOpacity(0.3)),
        child: Text(isLast ? "Démarrer" : "Suivant", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }

  Widget _buildSignInLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Déjà un compte ?", style: TextStyle(color: Colors.white38, fontSize: 14)),
        TextButton(onPressed: () => Navigator.pushReplacementNamed(context, '/login'), child: const Text("Connexion", style: TextStyle(color: Color(0xFF13b6ec), fontWeight: FontWeight.bold))),
      ],
    );
  }
}
