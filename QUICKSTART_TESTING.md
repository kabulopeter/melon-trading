# 🚀 Guide de Démarrage Rapide - Melon Trading

## Prérequis

- Python 3.8+ avec venv activé
- Flutter SDK installé
- Serveur Django en cours d'exécution

## 🔧 Démarrage du Backend

### 1. Activer l'environnement virtuel et démarrer le serveur

```powershell
cd C:\Users\KABULO\Desktop\projets\melon
.\venv\Scripts\Activate.ps1
python manage.py runserver
```

Le serveur sera accessible sur: `http://localhost:8000`

### 2. Vérifier que les données sont bien peuplées

```powershell
# Vérifier les défis
curl http://localhost:8000/api/v1/challenges/

# Vérifier les badges
curl http://localhost:8000/api/v1/badges/

# Vérifier les actifs
curl http://localhost:8000/api/v1/assets/
```

## 📱 Démarrage de l'Application Mobile

### 1. Ouvrir un nouveau terminal et lancer l'app Flutter

```powershell
cd C:\Users\KABULO\Desktop\projets\melon\melon_mobile
flutter run
```

### 2. Choisir le device (Windows Desktop recommandé pour le développement)

```
[1]: Windows (desktop)
[2]: Chrome (web)
```

Tapez `1` pour Windows Desktop.

## 🧪 Tests des Fonctionnalités

### Test 1: Défis et Récompenses

1. Ouvrir l'application mobile
2. Naviguer vers l'écran "Défis et Récompenses"
3. Vérifier que les défis s'affichent avec leur progression
4. Vérifier le classement
5. Vérifier les badges obtenus

**API à tester:**

```bash
# Mes défis
curl http://localhost:8000/api/v1/challenges/mine/

# Classement
curl http://localhost:8000/api/v1/challenges/leaderboard/

# Mes badges
curl http://localhost:8000/api/v1/badges/mine/
```

### Test 2: Gestion des Risques

1. Naviguer vers "Paramètres" → "Gestion des Risques"
2. Modifier le risque par trade (slider)
3. Ajuster Stop-Loss et Take-Profit
4. Activer/désactiver les coupe-circuits
5. Sauvegarder la configuration

**API à tester:**

```bash
# Obtenir la config actuelle
curl http://localhost:8000/api/v1/risk-config/current/

# Mettre à jour
curl -X PATCH http://localhost:8000/api/v1/risk-config/current/ \
  -H "Content-Type: application/json" \
  -d '{
    "risk_per_trade_percent": "2.5",
    "default_stop_loss_percent": "4.0",
    "default_take_profit_percent": "8.0"
  }'
```

### Test 3: Configuration de Stratégie

1. Naviguer vers "Configuration de Stratégie"
2. Créer un nouveau profil
3. Ajuster le filtre de confiance IA
4. Activer/configurer les indicateurs techniques (RSI, MACD, MA)
5. Sauvegarder le profil

**API à tester:**

```bash
# Lister les stratégies
curl http://localhost:8000/api/v1/strategies/

# Créer une stratégie
curl -X POST http://localhost:8000/api/v1/strategies/ \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Scalping BTC/ETH",
    "is_active": true,
    "min_confidence": 0.75,
    "indicators_config": {
      "rsi": {
        "enabled": true,
        "length": 14,
        "overbought": 70,
        "oversold": 30
      }
    }
  }'
```

### Test 4: Portefeuille et Transactions

1. Naviguer vers "Portefeuille"
2. Vérifier le solde
3. Tester un dépôt (simulation)
4. Consulter l'historique des transactions

**API à tester:**

```bash
# Consulter le solde
curl http://localhost:8000/api/v1/wallet/balance/

# Initier un dépôt
curl -X POST http://localhost:8000/api/v1/wallet/deposit/ \
  -H "Content-Type: application/json" \
  -d '{
    "amount": "100.00",
    "payment_method": "MPESA",
    "phone_number": "+243999999999"
  }'

# Historique
curl http://localhost:8000/api/v1/wallet/transactions/
```

### Test 5: Alertes de Prix

1. Naviguer vers "Alertes"
2. Créer une nouvelle alerte
3. Définir le prix cible et la condition
4. Vérifier la liste des alertes actives

**API à tester:**

```bash
# Lister les alertes
curl http://localhost:8000/api/v1/alerts/

# Créer une alerte
curl -X POST http://localhost:8000/api/v1/alerts/ \
  -H "Content-Type: application/json" \
  -d '{
    "asset": 1,
    "target_price": "50000.00",
    "condition": "ABOVE"
  }'
```

### Test 6: Analytics et Statistiques

1. Naviguer vers "Analytics"
2. Vérifier les statistiques de trading
3. Consulter la courbe d'équité
4. Vérifier le win rate et le profit factor

**API à tester:**

```bash
# Statistiques
curl http://localhost:8000/api/v1/analytics/stats/
```

### Test 7: Profil Utilisateur

1. Naviguer vers "Profil"
2. Mettre à jour les informations personnelles
3. Vérifier le niveau et l'XP
4. Consulter les badges obtenus

**API à tester:**

```bash
# Profil
curl http://localhost:8000/api/v1/profile/me/

# Mettre à jour
curl -X PATCH http://localhost:8000/api/v1/profile/me/ \
  -H "Content-Type: application/json" \
  -d '{
    "full_name": "John Doe",
    "country": "RDC"
  }'
```

## 🔍 Vérifications de Synchronisation

### Vérifier que les données du backend sont bien affichées dans l'app

1. **Défis**: Les 8 défis créés doivent apparaître
2. **Badges**: Les 12 badges doivent être listés
3. **Actifs**: Les actifs (AAPL, BTCUSD, EURUSD, SPY) doivent être disponibles
4. **Configuration**: Les paramètres sauvegardés doivent persister

### Vérifier la langue

- ✅ Tous les textes doivent être en français
- ✅ Les noms des défis en français
- ✅ Les descriptions des badges en français
- ✅ Les messages d'erreur en français

## 🐛 Dépannage

### Problème: "Connection refused" dans l'app mobile

**Solution:**

- Vérifier que le serveur Django est bien démarré
- Vérifier l'URL de base dans `api_service.dart`
- Pour Windows Desktop, utiliser `http://localhost:8000`
- Pour émulateur Android, utiliser `http://10.0.2.2:8000`

### Problème: "No data" dans les listes

**Solution:**

```bash
# Re-peupler la base de données
python populate_challenges_badges.py
python populate_demo_data.py
```

### Problème: Erreur 403 sur le retrait

**Solution:**

- Le KYC doit être vérifié
- Mettre à jour le profil avec un `kyc_document_id`

### Problème: Les défis ne se mettent pas à jour

**Solution:**

- Vérifier que les signaux sont bien créés dans `signals.py`
- Les défis sont mis à jour automatiquement après chaque trade

## 📊 Endpoints de Test Rapide

### Sanity Check Complet

```bash
# 1. Assets
curl http://localhost:8000/api/v1/assets/

# 2. Challenges
curl http://localhost:8000/api/v1/challenges/mine/

# 3. Badges
curl http://localhost:8000/api/v1/badges/mine/

# 4. Wallet
curl http://localhost:8000/api/v1/wallet/balance/

# 5. Risk Config
curl http://localhost:8000/api/v1/risk-config/current/

# 6. Strategies
curl http://localhost:8000/api/v1/strategies/

# 7. Analytics
curl http://localhost:8000/api/v1/analytics/stats/

# 8. Profile
curl http://localhost:8000/api/v1/profile/me/

# 9. Leaderboard
curl http://localhost:8000/api/v1/challenges/leaderboard/

# 10. Alerts
curl http://localhost:8000/api/v1/alerts/
```

Si tous ces endpoints retournent des données valides (pas d'erreur 500), le backend est opérationnel ! ✅

## 🎯 Checklist de Validation

- [ ] Serveur Django démarré sur port 8000
- [ ] Application Flutter lancée
- [ ] 8 défis visibles dans l'app
- [ ] 12 badges listés
- [ ] Configuration de risque modifiable
- [ ] Profils de stratégie créables
- [ ] Alertes de prix fonctionnelles
- [ ] Statistiques affichées correctement
- [ ] Classement visible
- [ ] Langue française partout
- [ ] Pas d'erreurs dans la console

## 🚀 Prêt pour le Déploiement

Une fois tous les tests validés, le projet est prêt pour :

1. Migration vers PostgreSQL
2. Déploiement sur Render.com
3. Configuration des variables d'environnement
4. Tests en production
5. Publication de l'application mobile

---

**Bon développement ! 🎉**
