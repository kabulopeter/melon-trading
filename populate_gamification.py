import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from core.models import Challenge, Badge

def populate_gamification():
    # Challenges
    challenges = [
        {
            "title": "Premier Pas",
            "description": "Effectuer son premier dépôt",
            "xp_reward": 100,
            "challenge_type": Challenge.Type.DEPOSIT,
            "target_value": 1.0,
            "icon_name": "account_balance_wallet"
        },
        {
            "title": "Main Chaude",
            "description": "Réussir 5 trades consécutifs",
            "xp_reward": 500,
            "challenge_type": Challenge.Type.TRADE_COUNT,
            "target_value": 5.0,
            "icon_name": "local_fire_department"
        },
        {
            "title": "Sniper",
            "description": "Atteindre +5% PnL cette semaine",
            "xp_reward": 300,
            "challenge_type": Challenge.Type.PNL_TARGET,
            "target_value": 5.0,
            "icon_name": "ads_click"
        },
    ]

    for c_data in challenges:
        Challenge.objects.get_or_create(
            title=c_data["title"],
            defaults=c_data
        )
        print(f"Challenge '{c_data['title']}' vérifié/créé.")

    # Badges
    badges = [
        {
            "name": "Early Adopter",
            "description": "Membre de la première vague de traders Melon",
            "icon_name": "rocket_launch",
            "category": "Community"
        },
        {
            "name": "Diamond Hands",
            "description": "A maintenu une position gagnante pendant plus de 48h",
            "icon_name": "diamond",
            "category": "Trading"
        },
        {
            "name": "Crypto King",
            "description": "A réalisé un profit significatif sur les cryptomonnaies",
            "icon_name": "crown",
            "category": "Expertise"
        },
        {
            "name": "Risk Manager",
            "description": "A utilisé un stop-loss sur 10 trades consécutifs",
            "icon_name": "shield",
            "category": "Safety"
        },
    ]

    for b_data in badges:
        Badge.objects.get_or_create(
            name=b_data["name"],
            defaults=b_data
        )
        print(f"Badge '{b_data['name']}' vérifié/créé.")

if __name__ == "__main__":
    populate_gamification()
