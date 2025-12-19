# 🚀 Guide de Déploiement Rapide - Melon Trading

## ✅ Fichiers de déploiement créés

Les fichiers suivants ont été créés pour faciliter le déploiement :

- ✅ `fly.toml` - Configuration Fly.io
- ✅ `Dockerfile` - Image Docker optimisée pour production
- ✅ `.dockerignore` - Exclusions pour Docker
- ✅ `Procfile` - Définition des processus
- ✅ `deploy.ps1` - Script de déploiement PowerShell (Windows)
- ✅ `deploy.sh` - Script de déploiement Bash (Linux/Mac)
- ✅ `DEPLOYMENT.md` - Guide détaillé

## 📝 Étapes à suivre MAINTENANT

### 1️⃣ Pousser sur GitHub (5 minutes)

Ouvrez un nouveau terminal PowerShell et exécutez :

```powershell
cd c:\Users\KABULO\Desktop\projets\melon

# Ajouter tous les fichiers
git add .

# Créer un commit
git commit -m "feat: Configuration initiale pour déploiement sur Fly.io"

# Vérifier si le remote existe déjà
git remote -v

# Si le remote n'existe pas, l'ajouter
git remote add origin https://github.com/kabulopeter/melon-trading.git

# Pousser sur GitHub
git branch -M main
git push -u origin main
```

**Note** : Si le repository existe déjà sur GitHub, vous devrez peut-être utiliser `git push -f origin main` pour forcer le push.

### 2️⃣ Déployer sur Fly.io (10 minutes)

#### Option A : Utiliser le script automatique (Recommandé)

```powershell
# Exécuter le script de déploiement
.\deploy.ps1
```

#### Option B : Déploiement manuel

```powershell
# 1. Installer Flyctl (si pas déjà fait)
iwr https://fly.io/install.ps1 -useb | iex

# 2. Redémarrer PowerShell, puis se connecter
flyctl auth login

# 3. Lancer l'application (suivre les instructions)
flyctl launch --no-deploy

# 4. Créer une base de données PostgreSQL
flyctl postgres create --name melon-trading-db --region cdg

# 5. Attacher la base de données
flyctl postgres attach melon-trading-db

# 6. Configurer les secrets
flyctl secrets set SECRET_KEY="django-insecure-CHANGEZ-MOI-EN-PRODUCTION-$(Get-Random)"
flyctl secrets set DEBUG="False"
flyctl secrets set ALLOWED_HOSTS="melon-trading.fly.dev,*.fly.dev"

# 7. Déployer
flyctl deploy

# 8. Ouvrir l'application
flyctl open
```

### 3️⃣ Vérifications Post-Déploiement

Après le déploiement, vérifiez que tout fonctionne :

```powershell
# Vérifier le status
flyctl status

# Voir les logs
flyctl logs

# Tester le health check
curl https://melon-trading.fly.dev/api/health/

# Accéder à la documentation API
# Ouvrir dans le navigateur : https://melon-trading.fly.dev/api/docs/
```

### 4️⃣ Configuration de la Base de Données

```powershell
# Se connecter au conteneur
flyctl ssh console

# Dans le conteneur, exécuter :
python manage.py migrate
python manage.py createsuperuser
exit
```

### 5️⃣ Mettre à jour l'Application Mobile

Modifiez le fichier Flutter pour pointer vers votre API déployée :

```dart
// melon_mobile/lib/core/constants/api_constants.dart
class ApiConstants {
  static const String baseUrl = 'https://melon-trading.fly.dev';
  // ... reste du code
}
```

## 🔧 Commandes Utiles

```powershell
# Voir les logs en temps réel
flyctl logs -f

# Redéployer après des modifications
git add .
git commit -m "Update: description des changements"
git push
flyctl deploy

# Redémarrer l'application
flyctl apps restart

# Voir les métriques
flyctl metrics

# SSH dans le conteneur
flyctl ssh console

# Exécuter une commande Django
flyctl ssh console -C "python manage.py migrate"
```

## 🐛 Résolution de Problèmes

### Problème : "App not found"

```powershell
flyctl launch --no-deploy
```

### Problème : "Database connection failed"

```powershell
flyctl postgres attach melon-trading-db
```

### Problème : "Build failed"

```powershell
flyctl logs
flyctl deploy --verbose
```

### Problème : "Health check failed"

Vérifiez que l'endpoint `/api/health/` répond correctement :

```powershell
flyctl ssh console -C "curl http://localhost:8000/api/health/"
```

## 📊 URLs Importantes

Après le déploiement, votre application sera accessible à :

- **Application** : <https://melon-trading.fly.dev>
- **Health Check** : <https://melon-trading.fly.dev/api/health/>
- **API Docs** : <https://melon-trading.fly.dev/api/docs/>
- **Admin** : <https://melon-trading.fly.dev/admin/>
- **Dashboard Fly.io** : <https://fly.io/dashboard/pierre-kabulo>

## 🎯 Prochaines Étapes

1. ✅ Pousser le code sur GitHub
2. ✅ Déployer sur Fly.io
3. ⏳ Configurer un nom de domaine personnalisé (optionnel)
4. ⏳ Configurer Redis pour Celery (optionnel)
5. ⏳ Mettre en place le monitoring
6. ⏳ Configurer les backups automatiques

## 💡 Conseils

- Utilisez `flyctl secrets list` pour voir vos variables d'environnement
- Activez le scaling automatique si nécessaire : `flyctl scale count 2`
- Surveillez vos coûts sur le dashboard Fly.io
- Configurez des alertes pour les erreurs

---

**Besoin d'aide ?** Consultez la documentation complète dans `DEPLOYMENT.md`
