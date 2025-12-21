# 📡 API Endpoints - Melon Trading

## Base URL

```
http://localhost:8000/api/v1/
```

## 🎯 Assets & Market Data

### Assets

- `GET /assets/` - Liste tous les actifs
- `GET /assets/{id}/` - Détails d'un actif
- `GET /assets/{id}/signals/` - Signaux pour un actif spécifique

### Price History

- `GET /prices/` - Historique des prix
- `GET /prices/?asset={asset_id}` - Historique filtré par actif

## 💼 Trading

### Trades

- `GET /trades/` - Liste tous les trades
- `POST /trades/` - Créer un nouveau trade
- `GET /trades/{id}/` - Détails d'un trade
- `PATCH /trades/{id}/` - Mettre à jour un trade
- `DELETE /trades/{id}/` - Supprimer un trade
- Filtres: `?asset=`, `?status=`, `?side=`

## 💰 Wallet & Transactions

### Wallet

- `GET /wallet/balance/` - Consulter le solde
- `POST /wallet/deposit/` - Initier un dépôt

  ```json
  {
    "amount": "100.00",
    "payment_method": "MPESA",
    "phone_number": "+243XXXXXXXXX"
  }
  ```

- `POST /wallet/withdraw/` - Initier un retrait (KYC requis)

  ```json
  {
    "amount": "50.00",
    "payment_method": "AIRTEL",
    "phone_number": "+243XXXXXXXXX"
  }
  ```

- `POST /wallet/transfer/` - Transférer vers un compte broker

  ```json
  {
    "amount": "200.00",
    "broker_account_id": 1
  }
  ```

- `GET /wallet/transactions/` - Historique des transactions

## 👤 User Profile & Preferences

### Profile

- `GET /profile/me/` - Profil utilisateur
- `PATCH /profile/me/` - Mettre à jour le profil

  ```json
  {
    "full_name": "John Doe",
    "country": "RDC",
    "kyc_document_id": "ABC123456"
  }
  ```

### Preferences

- `GET /preferences/settings/` - Préférences utilisateur
- `PATCH /preferences/settings/` - Mettre à jour les préférences

  ```json
  {
    "auto_trade": true,
    "min_confidence": 0.85,
    "max_risk_per_trade": "15.00"
  }
  ```

## 📊 Analytics

### Analytics

- `GET /analytics/stats/` - Statistiques de trading
  - Retourne: win_rate, total_pnl, profit_factor, max_drawdown, total_trades, equity_curve

## 🔔 Alerts

### Market Alerts

- `GET /alerts/` - Liste des alertes
- `POST /alerts/` - Créer une alerte

  ```json
  {
    "asset": 1,
    "target_price": "50000.00",
    "condition": "ABOVE"
  }
  ```

- `PATCH /alerts/{id}/` - Mettre à jour une alerte
- `DELETE /alerts/{id}/` - Supprimer une alerte

## 🎮 Gamification

### Challenges

- `GET /challenges/` - Liste tous les défis actifs
- `GET /challenges/mine/` - Défis de l'utilisateur avec progression
- `GET /challenges/leaderboard/` - Classement par XP (Top 10)

### Badges

- `GET /badges/` - Liste tous les badges
- `GET /badges/mine/` - Badges obtenus par l'utilisateur

## ⚙️ Strategy & Risk Management

### Strategy Profiles

- `GET /strategies/` - Liste des profils de stratégie
- `POST /strategies/` - Créer un profil

  ```json
  {
    "name": "Scalping BTC/ETH",
    "is_active": true,
    "min_confidence": 0.75,
    "indicators_config": {
      "rsi": {
        "enabled": true,
        "length": 14,
        "overbought": 70,
        "oversold": 30
      },
      "ma": {
        "enabled": true,
        "type": "SMA",
        "length": 200
      }
    }
  }
  ```

- `PATCH /strategies/{id}/` - Mettre à jour un profil
- `DELETE /strategies/{id}/` - Supprimer un profil

### Risk Configuration

- `GET /risk-config/current/` - Configuration de risque actuelle
- `PATCH /risk-config/current/` - Mettre à jour la configuration

  ```json
  {
    "risk_per_trade_percent": "2.0",
    "default_stop_loss_percent": "5.0",
    "default_take_profit_percent": "10.0",
    "daily_max_loss_amount": "150.0",
    "daily_max_loss_is_percent": true,
    "drawdown_threshold_percent": "15.0",
    "auto_sizing_enabled": true,
    "risk_notifications_enabled": true
  }
  ```

## 🏢 Brokers

### Broker Accounts

- `GET /brokers/` - Liste des comptes broker
- `POST /brokers/` - Connecter un nouveau broker
- `GET /brokers/{id}/` - Détails d'un compte broker
- `PATCH /brokers/{id}/` - Mettre à jour un compte broker
- `DELETE /brokers/{id}/` - Déconnecter un broker

## 📝 Notes Importantes

### Authentification

- Actuellement: `AllowAny` (mode démo)
- Production: Utiliser `IsAuthenticated` avec JWT tokens

### Pagination

- Par défaut: 100 items par page
- Utiliser `?page=2` pour la pagination

### Filtres

- Utiliser Django Filter Backend
- Exemples: `?asset_type=CRYPTO`, `?is_active=true`

### Recherche

- Assets: `?search=BTC`
- Recherche sur symbol et name

### Format des Dates

- ISO 8601: `2024-12-21T20:00:00Z`

### Codes d'Erreur

- `200` - OK
- `201` - Created
- `400` - Bad Request
- `403` - Forbidden (ex: KYC non vérifié)
- `404` - Not Found
- `500` - Server Error

## 🧪 Tests avec cURL

### Obtenir les défis de l'utilisateur

```bash
curl http://localhost:8000/api/v1/challenges/mine/
```

### Créer une alerte de prix

```bash
curl -X POST http://localhost:8000/api/v1/alerts/ \
  -H "Content-Type: application/json" \
  -d '{
    "asset": 1,
    "target_price": "50000.00",
    "condition": "ABOVE"
  }'
```

### Mettre à jour la configuration de risque

```bash
curl -X PATCH http://localhost:8000/api/v1/risk-config/current/ \
  -H "Content-Type: application/json" \
  -d '{
    "risk_per_trade_percent": "3.0",
    "default_stop_loss_percent": "4.0"
  }'
```

### Initier un dépôt

```bash
curl -X POST http://localhost:8000/api/v1/wallet/deposit/ \
  -H "Content-Type: application/json" \
  -d '{
    "amount": "100.00",
    "payment_method": "MPESA",
    "phone_number": "+243999999999"
  }'
```
