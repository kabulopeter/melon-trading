import os
import django
import time
import random
from decimal import Decimal

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from core.models import Signal, Asset, UserPreference
from django.contrib.auth.models import User

def simulate_massive_signals():
    print("🚀 DÉMARRAGE DE LA SIMULATION MASSIVE DE SIGNAUX IA")
    print("--------------------------------------------------")
    
    # 1. S'assurer que le mode Auto-Trade est activé pour l'utilisateur démo
    user = User.objects.first()
    if user:
        prefs, _ = UserPreference.objects.get_or_create(user=user)
        prefs.auto_trade = True
        prefs.min_confidence = 0.80 # Seuil bas pour la simulation
        prefs.save()
        print(f"✅ Auto-Trade activé pour {user.username} (Seuil: {prefs.min_confidence})")

    # 2. Liste des actifs à simuler
    symbols = ["AAPL", "TSLA", "NVDA", "BTC/USD", "EUR/USD", "GOLD"]
    
    # S'assurer que les actifs existent
    for sym in symbols:
        Asset.objects.get_or_create(
            symbol=sym, 
            defaults={'name': sym, 'asset_type': Asset.AssetType.STOCK if '/' not in sym else Asset.AssetType.CRYPTO}
        )

    assets = Asset.objects.filter(symbol__in=symbols)

    print("\n📡 Envoi de signaux en cours (Regardez votre application mobile !)...")
    
    try:
        for i in range(5): # Simuler 5 signaux
            asset = random.choice(assets)
            side = random.choice([Signal.SignalType.BUY, Signal.SignalType.SELL])
            confidence = round(random.uniform(0.85, 0.99), 2)
            price = Decimal(str(random.uniform(100, 200))) if asset.symbol != "BTC/USD" else Decimal("45000")
            
            print(f"[{i+1}/5] Génération Signal: {asset.symbol} | {side} | Confiance: {confidence*100}%")
            
            Signal.objects.create(
                asset=asset,
                signal_type=side,
                confidence=confidence,
                predicted_price=price
            )
            
            # Pause pour laisser le temps au WebSocket de notifier et au Bot de trader
            time.sleep(3)
            
        print("\n✅ Simulation terminée. Vérifiez l'onglet 'Active Trades' sur votre mobile.")
        
    except KeyboardInterrupt:
        print("\n🛑 Simulation interrompue.")

if __name__ == "__main__":
    simulate_massive_signals()
