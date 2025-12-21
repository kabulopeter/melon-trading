#!/usr/bin/env python
"""
Script pour peupler la base de données avec des défis et badges pour Melon Trading
Langue principale: Français
"""
import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from core.models import Challenge, Badge

def populate_challenges():
    """Créer des défis réalistes en français"""
    challenges_data = [
        {
            'title': 'Premier Pas',
            'description': 'Effectuer son premier dépôt',
            'xp_reward': 100,
            'challenge_type': Challenge.Type.DEPOSIT,
            'target_value': 1.0,
            'icon_name': 'account_balance_wallet',
            'is_active': True
        },
        {
            'title': 'Main Chaude',
            'description': 'Réussir 5 trades consécutifs',
            'xp_reward': 500,
            'challenge_type': Challenge.Type.TRADE_COUNT,
            'target_value': 5.0,
            'icon_name': 'local_fire_department',
            'is_active': True
        },
        {
            'title': 'Sniper',
            'description': 'Atteindre +5% PnL cette semaine',
            'xp_reward': 300,
            'challenge_type': Challenge.Type.PNL_TARGET,
            'target_value': 5.0,
            'icon_name': 'ads_click',
            'is_active': True
        },
        {
            'title': 'Trader Actif',
            'description': 'Effectuer 10 trades en une semaine',
            'xp_reward': 200,
            'challenge_type': Challenge.Type.TRADE_COUNT,
            'target_value': 10.0,
            'icon_name': 'trending_up',
            'is_active': True
        },
        {
            'title': 'Profit Master',
            'description': 'Atteindre +10% PnL ce mois',
            'xp_reward': 1000,
            'challenge_type': Challenge.Type.PNL_TARGET,
            'target_value': 10.0,
            'icon_name': 'emoji_events',
            'is_active': True
        },
        {
            'title': 'Volume King',
            'description': 'Trader un volume total de 10,000 USD',
            'xp_reward': 750,
            'challenge_type': Challenge.Type.VOLUME,
            'target_value': 10000.0,
            'icon_name': 'bar_chart',
            'is_active': True
        },
        {
            'title': 'Série Victorieuse',
            'description': 'Réussir 10 trades consécutifs',
            'xp_reward': 1500,
            'challenge_type': Challenge.Type.TRADE_COUNT,
            'target_value': 10.0,
            'icon_name': 'military_tech',
            'is_active': True
        },
        {
            'title': 'Investisseur Sérieux',
            'description': 'Déposer un total de 1,000 USD',
            'xp_reward': 500,
            'challenge_type': Challenge.Type.DEPOSIT,
            'target_value': 1000.0,
            'icon_name': 'savings',
            'is_active': True
        }
    ]
    
    created_count = 0
    for data in challenges_data:
        challenge, created = Challenge.objects.get_or_create(
            title=data['title'],
            defaults=data
        )
        if created:
            created_count += 1
            print(f"✅ Défi créé: {challenge.title}")
        else:
            print(f"ℹ️  Défi existant: {challenge.title}")
    
    print(f"\n📊 Total: {created_count} nouveaux défis créés sur {len(challenges_data)}")

def populate_badges():
    """Créer des badges réalistes en français"""
    badges_data = [
        {
            'name': 'Early Adopter',
            'description': 'Parmi les premiers utilisateurs de Melon Trading',
            'icon_name': 'rocket_launch',
            'category': 'Spécial'
        },
        {
            'name': 'Diamond Hands',
            'description': 'Tenir une position pendant plus de 7 jours',
            'icon_name': 'diamond',
            'category': 'Trading'
        },
        {
            'name': 'Crypto King',
            'description': 'Réaliser 100 trades sur des cryptomonnaies',
            'icon_name': 'crown',
            'category': 'Trading'
        },
        {
            'name': 'Risk Manager',
            'description': 'Configurer et respecter ses limites de risque pendant 30 jours',
            'icon_name': 'shield',
            'category': 'Gestion des Risques'
        },
        {
            'name': 'Forex Expert',
            'description': 'Réaliser 50 trades sur le Forex',
            'icon_name': 'currency_exchange',
            'category': 'Trading'
        },
        {
            'name': 'Stock Master',
            'description': 'Réaliser 50 trades sur des actions',
            'icon_name': 'show_chart',
            'category': 'Trading'
        },
        {
            'name': 'Profit Legend',
            'description': 'Atteindre +50% de PnL total',
            'icon_name': 'workspace_premium',
            'category': 'Performance'
        },
        {
            'name': 'Consistent Trader',
            'description': 'Être profitable 20 jours consécutifs',
            'icon_name': 'verified',
            'category': 'Performance'
        },
        {
            'name': 'Community Leader',
            'description': 'Être dans le top 10 du classement',
            'icon_name': 'leaderboard',
            'category': 'Social'
        },
        {
            'name': 'Strategy Master',
            'description': 'Créer et backtester 5 stratégies différentes',
            'icon_name': 'psychology',
            'category': 'Stratégie'
        },
        {
            'name': 'Night Trader',
            'description': 'Effectuer 50 trades entre 22h et 6h',
            'icon_name': 'nightlight',
            'category': 'Trading'
        },
        {
            'name': 'Whale',
            'description': 'Avoir un solde de plus de 10,000 USD',
            'icon_name': 'account_balance',
            'category': 'Richesse'
        }
    ]
    
    created_count = 0
    for data in badges_data:
        badge, created = Badge.objects.get_or_create(
            name=data['name'],
            defaults=data
        )
        if created:
            created_count += 1
            print(f"🏆 Badge créé: {badge.name}")
        else:
            print(f"ℹ️  Badge existant: {badge.name}")
    
    print(f"\n📊 Total: {created_count} nouveaux badges créés sur {len(badges_data)}")

if __name__ == '__main__':
    print("=" * 60)
    print("🎮 POPULATION DES DÉFIS ET BADGES - MELON TRADING")
    print("=" * 60)
    print()
    
    print("📝 Création des défis...")
    print("-" * 60)
    populate_challenges()
    
    print()
    print("🏆 Création des badges...")
    print("-" * 60)
    populate_badges()
    
    print()
    print("=" * 60)
    print("✅ TERMINÉ!")
    print("=" * 60)
    print()
    print("💡 Prochaines étapes:")
    print("   1. Vérifier les défis: http://localhost:8000/api/v1/challenges/")
    print("   2. Vérifier les badges: http://localhost:8000/api/v1/badges/")
    print("   3. Tester l'API des défis utilisateur: http://localhost:8000/api/v1/challenges/mine/")
    print("   4. Tester le classement: http://localhost:8000/api/v1/challenges/leaderboard/")
