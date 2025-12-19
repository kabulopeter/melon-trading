# 📱 Configuration de l'App Mobile Flutter

## 🔧 Mise à jour de l'URL de l'API

Après le déploiement sur Fly.io, vous devez mettre à jour l'URL de l'API dans votre application Flutter.

### Étape 1 : Créer le fichier de configuration API

Créez le fichier `melon_mobile/lib/core/config/api_config.dart` :

```dart
class ApiConfig {
  // URL de base de l'API
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://melon-trading.fly.dev',
  );
  
  // Endpoints
  static const String apiVersion = '/api/v1';
  
  // Assets
  static String get assetsUrl => '$baseUrl$apiVersion/assets/';
  static String assetDetailUrl(int id) => '$baseUrl$apiVersion/assets/$id/';
  static String assetSignalsUrl(int id) => '$baseUrl$apiVersion/assets/$id/signals/';
  
  // Trades
  static String get tradesUrl => '$baseUrl$apiVersion/trades/';
  static String tradeDetailUrl(int id) => '$baseUrl$apiVersion/trades/$id/';
  
  // Wallet
  static String get walletBalanceUrl => '$baseUrl$apiVersion/wallet/balance/';
  static String get walletDepositUrl => '$baseUrl$apiVersion/wallet/deposit/';
  static String get walletWithdrawUrl => '$baseUrl$apiVersion/wallet/withdraw/';
  static String get walletTransferUrl => '$baseUrl$apiVersion/wallet/transfer/';
  static String get walletTransactionsUrl => '$baseUrl$apiVersion/wallet/transactions/';
  
  // Analytics
  static String get analyticsStatsUrl => '$baseUrl$apiVersion/analytics/stats/';
  
  // Preferences
  static String get preferencesUrl => '$baseUrl$apiVersion/preferences/settings/';
  
  // Profile
  static String get profileUrl => '$baseUrl$apiVersion/profile/me/';
  
  // Alerts
  static String get alertsUrl => '$baseUrl$apiVersion/alerts/';
  static String alertDetailUrl(int id) => '$baseUrl$apiVersion/alerts/$id/';
  
  // Health check
  static String get healthCheckUrl => '$baseUrl/api/health/';
  
  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
```

### Étape 2 : Créer un service HTTP

Créez le fichier `melon_mobile/lib/core/services/http_service.dart` :

```dart
import 'package:dio/dio.dart';
import '../config/api_config.dart';

class HttpService {
  static final HttpService _instance = HttpService._internal();
  late Dio _dio;

  factory HttpService() {
    return _instance;
  }

  HttpService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectionTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Intercepteurs pour le logging
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
    ));
  }

  Dio get dio => _dio;

  // Méthodes helper
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) {
    return _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) {
    return _dio.post(path, data: data);
  }

  Future<Response> put(String path, {dynamic data}) {
    return _dio.put(path, data: data);
  }

  Future<Response> patch(String path, {dynamic data}) {
    return _dio.patch(path, data: data);
  }

  Future<Response> delete(String path) {
    return _dio.delete(path);
  }
}
```

### Étape 3 : Mettre à jour pubspec.yaml

Ajoutez la dépendance Dio si elle n'est pas déjà présente :

```yaml
dependencies:
  flutter:
    sdk: flutter
  dio: ^5.4.0  # Pour les requêtes HTTP
  # ... autres dépendances
```

Puis exécutez :

```bash
flutter pub get
```

### Étape 4 : Utiliser le service dans vos providers

Exemple pour le WalletProvider :

```dart
import 'package:flutter/foundation.dart';
import '../core/services/http_service.dart';
import '../core/config/api_config.dart';

class WalletProvider with ChangeNotifier {
  final HttpService _httpService = HttpService();
  
  double _balance = 0.0;
  bool _isLoading = false;
  String? _error;

  double get balance => _balance;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchBalance() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _httpService.get(ApiConfig.walletBalanceUrl);
      
      if (response.statusCode == 200) {
        _balance = response.data['balance'].toDouble();
      }
    } catch (e) {
      _error = 'Erreur lors de la récupération du solde: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deposit(double amount, String method, String phoneNumber) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _httpService.post(
        ApiConfig.walletDepositUrl,
        data: {
          'amount': amount,
          'payment_method': method,
          'phone_number': phoneNumber,
        },
      );

      if (response.statusCode == 201) {
        await fetchBalance(); // Rafraîchir le solde
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Erreur lors du dépôt: $e';
      debugPrint(_error);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

## 🔄 Configuration pour différents environnements

### Développement local

```bash
flutter run --dart-define=API_URL=http://10.0.2.2:8000
# 10.0.2.2 est l'adresse localhost pour l'émulateur Android
```

### Production (Fly.io)

```bash
flutter run --dart-define=API_URL=https://melon-trading.fly.dev
```

### Build pour production

```bash
# Android
flutter build apk --dart-define=API_URL=https://melon-trading.fly.dev

# iOS
flutter build ios --dart-define=API_URL=https://melon-trading.fly.dev
```

## 🧪 Tester la connexion

Créez un widget de test pour vérifier la connexion :

```dart
import 'package:flutter/material.dart';
import '../core/services/http_service.dart';
import '../core/config/api_config.dart';

class ApiTestScreen extends StatefulWidget {
  @override
  _ApiTestScreenState createState() => _ApiTestScreenState();
}

class _ApiTestScreenState extends State<ApiTestScreen> {
  String _status = 'Non testé';
  bool _isLoading = false;

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _status = 'Test en cours...';
    });

    try {
      final response = await HttpService().get(ApiConfig.healthCheckUrl);
      
      if (response.statusCode == 200) {
        setState(() {
          _status = '✅ Connexion réussie!\n${response.data}';
        });
      } else {
        setState(() {
          _status = '❌ Erreur: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _status = '❌ Erreur: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Test API')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('URL: ${ApiConfig.baseUrl}'),
            SizedBox(height: 20),
            Text(_status),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _testConnection,
                    child: Text('Tester la connexion'),
                  ),
          ],
        ),
      ),
    );
  }
}
```

## 📝 Checklist de configuration

- [ ] Créer `lib/core/config/api_config.dart`
- [ ] Créer `lib/core/services/http_service.dart`
- [ ] Ajouter `dio` dans `pubspec.yaml`
- [ ] Exécuter `flutter pub get`
- [ ] Mettre à jour tous les providers pour utiliser `HttpService`
- [ ] Tester la connexion avec le health check
- [ ] Vérifier que toutes les requêtes fonctionnent
- [ ] Tester en développement local
- [ ] Tester avec l'API de production

## 🔍 Débogage

### Voir les logs réseau

```dart
// Les logs sont automatiquement affichés grâce au LogInterceptor
// Vérifiez la console pour voir les requêtes et réponses
```

### Problèmes courants

**Erreur : "Connection refused"**

- Vérifiez que l'URL est correcte
- Vérifiez que le serveur est en ligne
- Pour l'émulateur Android, utilisez `10.0.2.2` au lieu de `localhost`

**Erreur : "Certificate verification failed"**

- En développement, vous pouvez désactiver la vérification SSL (NON recommandé en production)

**Erreur : "CORS"**

- Vérifiez que `CORS_ALLOW_ALL_ORIGINS = True` dans Django settings
- Ou configurez CORS correctement pour votre domaine

## 🚀 Prochaines étapes

1. Implémenter l'authentification JWT
2. Ajouter la gestion des tokens
3. Implémenter le refresh automatique des tokens
4. Ajouter la gestion du cache
5. Implémenter le mode hors ligne

---

**Note** : Après avoir déployé sur Fly.io, remplacez `melon-trading` par le nom réel de votre application dans tous les exemples ci-dessus.
