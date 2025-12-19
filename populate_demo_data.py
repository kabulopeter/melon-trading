import os
import django
import random
from datetime import datetime
from decimal import Decimal

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from core.models import Asset, Trade

def populate():
    print("🚀 Creating Demo Data...")

    # 1. Create Assets
    aapl, _ = Asset.objects.get_or_create(
        symbol="AAPL",
        defaults={
            "name": "Apple Inc.",
            "asset_type": Asset.AssetType.STOCK,
            "is_active": True
        }
    )
    
    r100, _ = Asset.objects.get_or_create(
        symbol="R_100",
        defaults={
            "name": "Volatility 100 Index",
            "asset_type": Asset.AssetType.SYNTHETIC,
            "is_active": True
        }
    )
    
    eurusd, _ = Asset.objects.get_or_create(
        symbol="EURUSD",
        defaults={
            "name": "Euro / USD",
            "asset_type": Asset.AssetType.FOREX,
            "is_active": True
        }
    )

    print(f"✅ Assets created: {aapl}, {r100}, {eurusd}")

    # 2. Create Trades
    assets = [aapl, r100, eurusd]
    
    # Clear existing trades (optional, strictly for demo cleanliness)
    # Trade.objects.all().delete() 

    for _ in range(5):
        asset = random.choice(assets)
        side = random.choice([Trade.Side.BUY, Trade.Side.SELL])
        entry = Decimal(random.uniform(100, 200))
        
        trade = Trade.objects.create(
            asset=asset,
            side=side,
            entry_price=entry,
            size=Decimal(10), # $10 or 10 units
            stop_loss=entry * Decimal(0.95),
            take_profit=entry * Decimal(1.05),
            confidence_score=random.uniform(0.80, 0.99),
            status=Trade.Status.OPEN,
            pnl=Decimal(random.uniform(-5, 15)) # Fake PnL
        )
        print(f"  -> Created Trade: {trade}")

    print("🎉 Demo Data populated successfully!")

if __name__ == "__main__":
    populate()
