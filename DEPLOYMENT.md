# Melon Trading - Guide de Déploiement

## 📋 Prérequis

- Git installé
- Compte GitHub
- Compte Fly.io
- Flyctl CLI installé

## 🚀 Étape 1 : Pousser sur GitHub

### 1.1 Vérifier le statut Git

```bash
git status
```

### 1.2 Ajouter tous les fichiers

```bash
git add .
```

### 1.3 Créer un commit

```bash
git commit -m "Initial commit - Melon Trading Platform"
```

### 1.4 Ajouter le remote GitHub

```bash
git remote add origin https://github.com/kabulopeter/melon-trading.git
```

### 1.5 Pousser sur GitHub

```bash
git branch -M main
git push -u origin main
```

## 🌐 Étape 2 : Déployer sur Fly.io

### 2.1 Installer Flyctl (si pas déjà fait)

```powershell
# Windows PowerShell
iwr https://fly.io/install.ps1 -useb | iex
```

### 2.2 Se connecter à Fly.io

```bash
flyctl auth login
```

### 2.3 Lancer l'application

```bash
flyctl launch --no-deploy
```

### 2.4 Créer une base de données PostgreSQL

```bash
flyctl postgres create --name melon-trading-db --region cdg
```

### 2.5 Attacher la base de données

```bash
flyctl postgres attach melon-trading-db
```

### 2.6 Définir les secrets (variables d'environnement)

```bash
flyctl secrets set SECRET_KEY="votre-secret-key-super-securisee"
flyctl secrets set DEBUG="False"
flyctl secrets set ALLOWED_HOSTS="melon-trading.fly.dev,*.fly.dev"
```

### 2.7 Déployer l'application

```bash
flyctl deploy
```

### 2.8 Ouvrir l'application

```bash
flyctl open
```

## 🔧 Configuration des Variables d'Environnement

Les variables suivantes doivent être configurées sur Fly.io :

- `SECRET_KEY` : Clé secrète Django (générer une nouvelle)
- `DEBUG` : False pour la production
- `ALLOWED_HOSTS` : Votre domaine Fly.io
- `DATABASE_URL` : Automatiquement configuré par Fly.io
- `REDIS_URL` : Pour Celery (optionnel)

## 📊 Commandes Utiles

### Voir les logs

```bash
flyctl logs
```

### SSH dans le conteneur

```bash
flyctl ssh console
```

### Exécuter les migrations

```bash
flyctl ssh console -C "python manage.py migrate"
```

### Créer un superutilisateur

```bash
flyctl ssh console -C "python manage.py createsuperuser"
```

### Redéployer

```bash
flyctl deploy
```

## 🔍 Vérification du Déploiement

1. **Health Check** : `https://melon-trading.fly.dev/api/health/`
2. **API Docs** : `https://melon-trading.fly.dev/api/docs/`
3. **Admin** : `https://melon-trading.fly.dev/admin/`

## 🐛 Dépannage

### Problème de build

```bash
flyctl logs
flyctl deploy --verbose
```

### Problème de base de données

```bash
flyctl postgres connect -a melon-trading-db
```

### Redémarrer l'application

```bash
flyctl apps restart melon-trading
```

## 📱 Configuration Mobile

Après le déploiement, mettez à jour l'URL de l'API dans votre application Flutter :

```dart
// lib/core/constants/api_constants.dart
static const String baseUrl = 'https://melon-trading.fly.dev';
```

## 🔐 Sécurité

- ✅ Ne jamais commiter le fichier `.env`
- ✅ Utiliser des secrets Fly.io pour les variables sensibles
- ✅ Activer HTTPS (automatique sur Fly.io)
- ✅ Configurer CORS correctement
- ✅ Utiliser des mots de passe forts

## 📈 Monitoring

- Dashboard Fly.io : <https://fly.io/dashboard/pierre-kabulo>
- Métriques : `flyctl metrics`
- Status : `flyctl status`

---

**Note** : Ce guide suppose que vous avez déjà configuré votre projet localement et que tous les tests passent.
