# 📱 Melon Trading - Application Mobile

Application mobile de trading avec IA développée avec Flutter.

## 🎯 Fonctionnalités

### Trading

- 📊 Dashboard en temps réel
- 📈 Signaux de trading IA
- 💹 Exécution automatique de trades
- 📉 Historique complet des trades
- 🎯 Alertes de prix personnalisables

### Gamification

- 🏆 Système de niveaux et XP
- 🎮 8 défis variés
- 🏅 12 badges à débloquer
- 📊 Classement des traders
- 🎁 Récompenses progressives

### Gestion des Risques

- ⚖️ Configuration personnalisable
- 🛡️ Stop-Loss et Take-Profit automatiques
- 🚨 Coupe-circuits de sécurité
- 📊 Calcul de taille de position
- 🔔 Notifications d'alerte

### Stratégies

- 🎯 Profils multiples
- 🤖 Filtre de confiance IA
- 📊 Indicateurs techniques (RSI, MACD, MA)
- 🔬 Backtesting intégré
- 💾 Sauvegarde automatique

### Wallet

- 💰 Dépôt Mobile Money (M-Pesa, Airtel)
- 💸 Retrait sécurisé (KYC requis)
- 🔄 Transfert vers courtiers
- 📜 Historique des transactions
- 💵 Multi-devises

### Analytics

- 📊 Win rate
- 💰 Profit factor
- 📉 Max drawdown
- 📈 Courbe d'équité
- 📋 Statistiques détaillées

## 🚀 Installation

### Prérequis

- Flutter SDK 3.0+
- Dart 3.0+
- Android Studio / VS Code
- Serveur backend Django en cours d'exécution

### Étapes

1. **Cloner le projet**

```bash
cd C:\Users\KABULO\Desktop\projets\melon\melon_mobile
```

2. **Installer les dépendances**

```bash
flutter pub get
```

3. **Configurer l'URL de l'API**

Ouvrir `lib/data/services/api_service.dart` et vérifier l'URL de base :

```dart
// Pour Windows Desktop
static const String baseUrl = 'http://localhost:8000/api/v1';

// Pour émulateur Android
// static const String baseUrl = 'http://10.0.2.2:8000/api/v1';

// Pour appareil physique
// static const String baseUrl = 'http://YOUR_IP:8000/api/v1';
```

4. **Lancer l'application**

```bash
flutter run
```

## 📂 Structure du Projet

```
lib/
├── core/                    # Configuration et constantes
│   ├── constants/
│   ├── theme/
│   └── utils/
├── data/                    # Couche de données
│   ├── models/             # Modèles de données
│   │   ├── challenge_model.dart
│   │   ├── badge_model.dart
│   │   ├── risk_config_model.dart
│   │   ├── strategy_profile_model.dart
│   │   └── ...
│   └── services/           # Services API
│       ├── api_service.dart
│       ├── gamification_service.dart
│       ├── risk_service.dart
│       ├── strategy_service.dart
│       └── ...
└── presentation/           # Interface utilisateur
    ├── screens/           # Écrans
    │   ├── dashboard_screen.dart
    │   ├── challenges_screen.dart
    │   ├── risk_management_screen.dart
    │   ├── strategy_config_screen.dart
    │   └── ...
    └── widgets/           # Widgets réutilisables
```

## 🔧 Configuration

### Variables d'Environnement

Créer un fichier `.env` à la racine du projet :

```env
API_BASE_URL=http://localhost:8000/api/v1
ENABLE_LOGGING=true
```

### Thème

Le thème est configuré dans `lib/core/theme/app_theme.dart` :

```dart
// Couleur principale
primaryColor: Color(0xFF13b6ec)

// Mode sombre par défaut
darkMode: true
```

## 📱 Écrans Disponibles

### Navigation Principale

1. **Dashboard** - Vue d'ensemble
2. **Wallet** - Portefeuille
3. **Analytics** - Statistiques
4. **Challenges** - Défis et récompenses
5. **Settings** - Paramètres

### Écrans Secondaires

- **Deposit** - Dépôt de fonds
- **Withdraw** - Retrait de fonds
- **History** - Historique
- **Trade Detail** - Détails d'un trade
- **Alerts** - Alertes de prix
- **Strategy Config** - Configuration de stratégie
- **Risk Management** - Gestion des risques
- **Profile** - Profil utilisateur
- **News** - Actualités
- **Onboarding** - Introduction

## 🌐 API Backend

L'application communique avec le backend Django via REST API.

### Endpoints Principaux

```
GET  /challenges/mine/          # Mes défis
GET  /badges/mine/              # Mes badges
GET  /challenges/leaderboard/   # Classement
GET  /risk-config/current/      # Config de risque
PATCH /risk-config/current/     # Modifier config
GET  /strategies/               # Mes stratégies
POST /strategies/               # Créer stratégie
GET  /wallet/balance/           # Solde
POST /wallet/deposit/           # Dépôt
POST /wallet/withdraw/          # Retrait
GET  /analytics/stats/          # Statistiques
```

Voir `API_ENDPOINTS.md` pour la documentation complète.

## 🧪 Tests

### Lancer les tests unitaires

```bash
flutter test
```

### Lancer les tests d'intégration

```bash
flutter test integration_test/
```

### Tester sur un appareil spécifique

```bash
# Windows Desktop
flutter run -d windows

# Android
flutter run -d android

# iOS
flutter run -d ios
```

## 🎨 Design

Le design suit les principes Material Design 3 avec :

- Mode sombre par défaut
- Glassmorphisme
- Animations fluides
- Micro-interactions
- Couleurs vibrantes

### Couleurs Principales

- **Primary:** `#13b6ec` (Bleu cyan)
- **Background Dark:** `#101d22`
- **Surface Dark:** `#18282e`
- **Success:** `#10b981`
- **Error:** `#ef4444`

## 🌍 Langue

**Langue principale:** Français (FR)  
**Langue secondaire:** Anglais (EN)

Tous les textes de l'interface sont en français.

## 📦 Dépendances Principales

```yaml
dependencies:
  flutter:
    sdk: flutter
  dio: ^5.0.0                    # HTTP client
  provider: ^6.0.0               # State management
  shared_preferences: ^2.0.0     # Stockage local
  fl_chart: ^0.60.0              # Graphiques
  intl: ^0.18.0                  # Internationalisation
  local_auth: ^2.1.0             # Authentification biométrique
  web_socket_channel: ^2.4.0     # WebSocket
```

## 🚀 Build & Déploiement

### Build Android (APK)

```bash
flutter build apk --release
```

### Build Android (App Bundle)

```bash
flutter build appbundle --release
```

### Build iOS

```bash
flutter build ios --release
```

### Build Windows

```bash
flutter build windows --release
```

## 🐛 Dépannage

### Problème: "Connection refused"

**Solution:**

- Vérifier que le serveur Django est démarré
- Vérifier l'URL dans `api_service.dart`
- Pour Android émulateur, utiliser `10.0.2.2` au lieu de `localhost`

### Problème: "No data displayed"

**Solution:**

```bash
# Re-peupler la base de données
cd ../
python populate_challenges_badges.py
python populate_demo_data.py
```

### Problème: Erreur de build

**Solution:**

```bash
# Nettoyer et reconstruire
flutter clean
flutter pub get
flutter run
```

## 📚 Documentation

- [API Endpoints](../API_ENDPOINTS.md)
- [Guide de Démarrage](../QUICKSTART_TESTING.md)
- [Intégration Complète](../INTEGRATION_COMPLETE.md)
- [Tests Validation](../TESTS_VALIDATION.md)

## 🤝 Contribution

1. Fork le projet
2. Créer une branche (`git checkout -b feature/AmazingFeature`)
3. Commit les changements (`git commit -m 'Add AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

## 📄 Licence

Ce projet est sous licence privée.

## 👥 Équipe

- **Développeur Principal:** KABULO
- **IA Assistant:** Antigravity

## 📞 Support

Pour toute question ou problème :

- Ouvrir une issue sur GitHub
- Contacter l'équipe de développement

---

**Version:** 1.0.0  
**Dernière mise à jour:** 21 Décembre 2024  
**Statut:** ✅ Opérationnel
