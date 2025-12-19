# 🎯 COMMANDES À EXÉCUTER MAINTENANT

## ⚠️ IMPORTANT : Exécutez ces commandes dans l'ordre

Ouvrez un nouveau terminal PowerShell dans le dossier du projet et exécutez :

```powershell
cd c:\Users\KABULO\Desktop\projets\melon
```

---

## 📦 ÉTAPE 1 : Mettre à jour le remote GitHub

```powershell
# Supprimer l'ancien remote
git remote remove origin

# Ajouter le nouveau remote
git remote add origin https://github.com/kabulopeter/melon-trading.git

# Vérifier
git remote -v
```

---

## 📤 ÉTAPE 2 : Pousser sur GitHub

```powershell
# Ajouter tous les nouveaux fichiers
git add .

# Créer un commit
git commit -m "feat: Configuration complète pour déploiement Fly.io + GitHub"

# Pousser sur GitHub (première fois)
git branch -M main
git push -u origin main
```

**Si vous obtenez une erreur "repository not empty"**, utilisez :

```powershell
git push -u origin main --force
```

---

## 🚀 ÉTAPE 3 : Déployer sur Fly.io

### Option A : Script Automatique (Recommandé) ✨

```powershell
# Rendre le script exécutable et le lancer
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\deploy.ps1
```

### Option B : Commandes Manuelles

```powershell
# 1. Installer Flyctl (si pas déjà installé)
iwr https://fly.io/install.ps1 -useb | iex

# IMPORTANT : Après l'installation, FERMEZ et ROUVREZ PowerShell

# 2. Se connecter à Fly.io
flyctl auth login

# 3. Créer l'application
flyctl launch --no-deploy

# Répondez aux questions :
# - App name: melon-trading (ou laissez vide pour auto-généré)
# - Region: cdg (Paris)
# - PostgreSQL: Yes
# - Redis: No (pour l'instant)

# 4. Configurer les secrets
flyctl secrets set SECRET_KEY="django-insecure-$(Get-Random)-changez-moi-en-production"
flyctl secrets set DEBUG="False"
flyctl secrets set ALLOWED_HOSTS="*.fly.dev"

# 5. Déployer
flyctl deploy

# 6. Exécuter les migrations
flyctl ssh console -C "python manage.py migrate"

# 7. Créer un superutilisateur
flyctl ssh console
# Dans le conteneur :
python manage.py createsuperuser
# Suivez les instructions, puis tapez : exit

# 8. Ouvrir l'application
flyctl open
```

---

## ✅ ÉTAPE 4 : Vérifications

```powershell
# Vérifier le statut
flyctl status

# Voir les logs
flyctl logs

# Tester l'API
curl https://votre-app.fly.dev/api/health/
```

---

## 🔗 URLs Après Déploiement

Une fois déployé, votre application sera accessible à :

- **API** : `https://votre-app.fly.dev/api/v1/`
- **Health Check** : `https://votre-app.fly.dev/api/health/`
- **Documentation** : `https://votre-app.fly.dev/api/docs/`
- **Admin** : `https://votre-app.fly.dev/admin/`
- **Dashboard Fly.io** : <https://fly.io/dashboard/pierre-kabulo>

---

## 📱 ÉTAPE 5 : Mettre à jour l'App Mobile

Après le déploiement, mettez à jour l'URL dans votre app Flutter :

```dart
// melon_mobile/lib/core/constants/api_constants.dart
class ApiConstants {
  static const String baseUrl = 'https://votre-app.fly.dev';
  // Remplacez 'votre-app' par le nom réel de votre app Fly.io
}
```

---

## 🆘 En cas de problème

### Problème : "flyctl: command not found"

**Solution** : Fermez et rouvrez PowerShell après l'installation de Flyctl

### Problème : "App already exists"

**Solution** :

```powershell
flyctl apps destroy melon-trading
flyctl launch --no-deploy
```

### Problème : "Build failed"

**Solution** :

```powershell
flyctl logs
flyctl deploy --verbose
```

### Problème : "Cannot push to GitHub"

**Solution** :

```powershell
git push -u origin main --force
```

---

## 📞 Support

- Documentation Fly.io : <https://fly.io/docs/>
- Documentation Django : <https://docs.djangoproject.com/>
- GitHub Issues : <https://github.com/kabulopeter/melon-trading/issues>

---

## 🎉 Félicitations

Une fois ces étapes terminées, votre application sera :

- ✅ Hébergée sur GitHub
- ✅ Déployée sur Fly.io
- ✅ Accessible publiquement
- ✅ Prête pour votre app mobile

**Prochaines étapes recommandées :**

1. Configurer un nom de domaine personnalisé
2. Mettre en place le monitoring
3. Configurer les backups automatiques
4. Ajouter Redis pour Celery (tâches asynchrones)
