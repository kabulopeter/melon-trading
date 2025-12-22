import os
import sys
import django
import pandas as pd
import numpy as np
from datetime import datetime, timedelta

# Setup Django
sys.path.append(os.getcwd())
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

def generate_for_symbol(symbol, name, asset_type, start_price=100.0, volatility=2.0):
    print(f"🚀 Génération de données synthétiques pour {symbol}...")
    from core.models import Asset, PriceHistory

    # 1. Get/Create Asset
    asset, _ = Asset.objects.get_or_create(
        symbol=symbol,
        defaults={'name': name, 'asset_type': asset_type}
    )
    
    # 2. Generate Data (Random Walk)
    end_date = datetime.now()
    start_date = end_date - timedelta(days=365)
    dates = pd.date_range(start=start_date, end=end_date, freq='D')
    
    price = start_price
    batch = []
    
    for date in dates:
        change = np.random.normal(0, volatility)
        price += change
        if price < 10: price = 10
        
        open_p = price
        high_p = price + abs(np.random.normal(0, volatility/2))
        low_p = price - abs(np.random.normal(0, volatility/2))
        close_p = price + np.random.normal(0, volatility/4)
        volume = int(np.random.randint(1000000, 5000000))

        batch.append(
            PriceHistory(
                asset=asset,
                datetime=date,
                open=open_p,
                high=high_p,
                low=low_p,
                close=close_p,
                volume=volume
            )
        )
    
    # 3. Save to DB
    PriceHistory.objects.filter(asset=asset).delete()
    PriceHistory.objects.bulk_create(batch, batch_size=1000)
    print(f"✅ {symbol} : Données historiques insérées.")

if __name__ == "__main__":
    from core.models import Asset
    generate_for_symbol("AAPL", "Apple Inc.", Asset.AssetType.STOCK, start_price=150.0)
    generate_for_symbol("BTCUSD", "Bitcoin", Asset.AssetType.CRYPTO, start_price=45000.0, volatility=500.0)
    generate_for_symbol("EURUSD", "Euro / USD", Asset.AssetType.FOREX, start_price=1.08, volatility=0.01)
    generate_for_symbol("R_100", "Volatility 100 Index", Asset.AssetType.SYNTHETIC, start_price=1000.0, volatility=15.0)
    generate_for_symbol("TSLA", "Tesla Inc.", Asset.AssetType.STOCK, start_price=240.0, volatility=5.0)
    generate_for_symbol("NVDA", "NVIDIA Corp.", Asset.AssetType.STOCK, start_price=480.0, volatility=10.0)
