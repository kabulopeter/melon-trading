# 🍈 Melon Trading - AI-Powered Trading Platform

[![Django](https://img.shields.io/badge/Django-5.1.4-green.svg)](https://www.djangoproject.com/)
[![Python](https://img.shields.io/badge/Python-3.12-blue.svg)](https://www.python.org/)
[![Flutter](https://img.shields.io/badge/Flutter-Mobile-02569B.svg)](https://flutter.dev/)
[![Fly.io](https://img.shields.io/badge/Deployed%20on-Fly.io-blueviolet.svg)](https://fly.io/)

Backend Django + Application Mobile Flutter pour une plateforme de trading automatisé avec intelligence artificielle.

## 📋 Table des matières

- [Fonctionnalités](#-fonctionnalités)
- [Architecture](#-architecture)
- [Déploiement](#-déploiement)
- [Développement Local](#-développement-local)
- [Documentation](#-documentation)
- [Support](#-support)

## ✨ Fonctionnalités

### Backend (Django + DRF)

- 🤖 **Trading Automatisé** avec IA et analyse technique
- 📊 **Analyse de marché** en temps réel (Stocks, Crypto, Forex)
- 💰 **Gestion de portefeuille** et wallet intégré
- 📱 **Paiement Mobile Money** (Airtel Money, M-Pesa, Orange Money)
- 🔔 **Alertes et notifications** en temps réel
- 📈 **Analytics et statistiques** de performance
- 🔐 **API REST** sécurisée avec authentification

### Mobile (Flutter)

- 📱 Application mobile cross-platform (Android/iOS)
- 💼 Dashboard de trading en temps réel
- 💳 Gestion du wallet et transactions
- 📊 Visualisation des performances
- ⚙️ Paramètres et préférences utilisateur
- 🌍 Support multilingue (FR/EN)

## 🏗️ Architecture

```
melon/
├── config/              # Configuration Django
├── core/                # App principale (API, Models, Views)
├── ai_prediction/       # Module d'IA pour les prédictions
├── melon_mobile/        # Application Flutter
├── Dockerfile           # Image Docker
├── fly.toml             # Configuration Fly.io
└── requirements.txt     # Dépendances Python
```

## 🚀 Déploiement

### Déploiement sur Fly.io (Recommandé)

**📖 Pour un guide complet, consultez : [`COMMANDES.md`](./COMMANDES.md)**

#### Déploiement rapide

```powershell
# 1. Installer Flyctl
iwr https://fly.io/install.ps1 -useb | iex

# 2. Se connecter
flyctl auth login

# 3. Utiliser le script automatique
.\deploy.ps1
```

#### Ou suivez les étapes manuelles

```powershell
# 1. Créer l'application
flyctl launch --no-deploy

# 2. Créer et attacher PostgreSQL
flyctl postgres create --name melon-trading-db --region cdg
flyctl postgres attach melon-trading-db

# 3. Configurer les secrets
flyctl secrets set SECRET_KEY="votre-secret-key"
flyctl secrets set DEBUG="False"
flyctl secrets set ALLOWED_HOSTS="*.fly.dev"

# 4. Déployer
flyctl deploy

# 5. Exécuter les migrations
flyctl ssh console -C "python manage.py migrate"

# 6. Créer un superutilisateur
flyctl ssh console
python manage.py createsuperuser
exit
```

### Déploiement sur GitHub

```powershell
# Mettre à jour le remote
git remote remove origin
git remote add origin https://github.com/kabulopeter/melon-trading.git

# Pousser le code
git add .
git commit -m "feat: Configuration complète pour déploiement"
git push -u origin main
```

## 💻 Développement Local

### Prérequis

- Python 3.12+
- PostgreSQL
- Redis (optionnel)
- Flutter SDK (pour l'app mobile)

### Installation

1. **Cloner le repository**

```bash
git clone https://github.com/kabulopeter/melon-trading.git
cd melon-trading
```

2. **Créer un environnement virtuel**

```bash
python -m venv venv
source venv/bin/activate  # Linux/Mac
# ou
.\venv\Scripts\Activate.ps1  # Windows
```

3. **Installer les dépendances**

```bash
pip install -r requirements.txt
```

4. **Configurer les variables d'environnement**

```bash
cp .env.example .env
# Éditez .env avec vos valeurs
```

5. **Exécuter les migrations**

```bash
python manage.py migrate
```

6. **Créer un superutilisateur**

```bash
python manage.py createsuperuser
```

7. **Lancer le serveur**

```bash
python manage.py runserver 0.0.0.0:8000
```

### Application Mobile

```bash
cd melon_mobile
flutter pub get
flutter run
```

**Note** : Voir [`MOBILE_CONFIG.md`](./MOBILE_CONFIG.md) pour configurer l'URL de l'API.

## 📚 Documentation

- **[COMMANDES.md](./COMMANDES.md)** - ⭐ Commandes de déploiement étape par étape
- **[README_DEPLOYMENT.md](./README_DEPLOYMENT.md)** - Vue d'ensemble du déploiement
- **[QUICKSTART.md](./QUICKSTART.md)** - Guide de démarrage rapide
- **[DEPLOYMENT.md](./DEPLOYMENT.md)** - Guide détaillé avec troubleshooting
- **[MOBILE_CONFIG.md](./MOBILE_CONFIG.md)** - Configuration de l'app Flutter
- **[RECAP.txt](./RECAP.txt)** - Récapitulatif visuel

## 🌐 URLs de Production

Après déploiement sur Fly.io :

- **Application** : <https://melon-trading.fly.dev>
- **Health Check** : <https://melon-trading.fly.dev/api/health/>
- **API v1** : <https://melon-trading.fly.dev/api/v1/>
- **Documentation API** : <https://melon-trading.fly.dev/api/docs/>
- **Admin** : <https://melon-trading.fly.dev/admin/>
- **Dashboard Fly.io** : <https://fly.io/dashboard/pierre-kabulo>

## 🛠️ Technologies Utilisées

### Backend

- **Django 5.1.4** - Framework web
- **Django REST Framework** - API REST
- **Daphne** - Serveur ASGI
- **PostgreSQL** - Base de données
- **Redis** - Cache et Celery
- **Celery** - Tâches asynchrones
- **Channels** - WebSockets

### Mobile

- **Flutter** - Framework mobile
- **Provider** - State management
- **Dio** - HTTP client

### Déploiement

- **Fly.io** - Hébergement cloud
- **Docker** - Containerisation
- **GitHub** - Contrôle de version

## 🔑 Variables d'Environnement

Voir [`.env.example`](./.env.example) pour la liste complète des variables.

Principales variables :

- `SECRET_KEY` - Clé secrète Django
- `DEBUG` - Mode debug (False en production)
- `DATABASE_URL` - URL de la base de données
- `ALLOWED_HOSTS` - Domaines autorisés
- `POLYGON_API_KEY` - Clé API pour les données de marché
- `ALPHAVANTAGE_API_KEY` - Clé API pour les données financières

## 📊 Commandes Utiles

```bash
# Voir les logs
flyctl logs -f

# Redéployer
flyctl deploy

# Exécuter une commande Django
flyctl ssh console -C "python manage.py <commande>"

# Voir le statut
flyctl status

# Redémarrer l'app
flyctl apps restart
```

## 🐛 Résolution de Problèmes

Consultez [DEPLOYMENT.md](./DEPLOYMENT.md) pour les solutions aux problèmes courants.

## 📞 Support

- **Documentation Fly.io** : <https://fly.io/docs/>
- **Documentation Django** : <https://docs.djangoproject.com/>
- **GitHub Issues** : <https://github.com/kabulopeter/melon-trading/issues>

## 📄 Licence

Ce projet est sous licence privée. Tous droits réservés.

## 👨‍💻 Auteur

**Pierre Kabulo**

- GitHub: [@kabulopeter](https://github.com/kabulopeter)
- Fly.io: [Dashboard](https://fly.io/dashboard/pierre-kabulo)

---

**🎉 Prêt à déployer ?** Commencez par lire [`COMMANDES.md`](./COMMANDES.md) !
