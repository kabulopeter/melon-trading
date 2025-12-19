#!/usr/bin/env bash
# Script de déploiement automatique pour Fly.io

set -e

echo "🚀 Déploiement de Melon Trading sur Fly.io"
echo "=========================================="

# Vérifier si flyctl est installé
if ! command -v flyctl &> /dev/null; then
    echo "❌ Flyctl n'est pas installé. Installez-le d'abord :"
    echo "   iwr https://fly.io/install.ps1 -useb | iex"
    exit 1
fi

# Vérifier si l'utilisateur est connecté
if ! flyctl auth whoami &> /dev/null; then
    echo "🔐 Connexion à Fly.io..."
    flyctl auth login
fi

# Vérifier si l'application existe
if ! flyctl status &> /dev/null; then
    echo "📦 Création de l'application..."
    flyctl launch --no-deploy
    
    echo "🗄️  Création de la base de données PostgreSQL..."
    flyctl postgres create --name melon-trading-db --region cdg
    
    echo "🔗 Attachement de la base de données..."
    flyctl postgres attach melon-trading-db
    
    echo "🔑 Configuration des secrets..."
    read -p "Entrez votre SECRET_KEY Django : " secret_key
    flyctl secrets set SECRET_KEY="$secret_key"
    flyctl secrets set DEBUG="False"
    flyctl secrets set ALLOWED_HOSTS="melon-trading.fly.dev,*.fly.dev"
fi

# Déployer
echo "🚢 Déploiement en cours..."
flyctl deploy

echo "✅ Déploiement terminé !"
echo "🌐 Votre application est disponible à : https://melon-trading.fly.dev"
echo "📊 Dashboard : https://fly.io/dashboard/pierre-kabulo"
echo ""
echo "Commandes utiles :"
echo "  flyctl logs          - Voir les logs"
echo "  flyctl ssh console   - SSH dans le conteneur"
echo "  flyctl status        - Voir le status"
