import os
import sys
import django
from datetime import datetime, timedelta
import logging

# Setup Django
sys.path.append(os.getcwd())
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from core.models import Asset, PriceHistory
from data_collector import MarketDataCollector
from ai_prediction.services import PredictionService

# Logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def fetch_and_save(api_symbol, display_symbol, asset_type, name):
    print(f"\n--- Processing {display_symbol} ({asset_type}) via Polygon ---")
    
    # 1. Ensure Asset exists
    asset, created = Asset.objects.get_or_create(
        symbol=display_symbol,
        defaults={'name': name, 'asset_type': asset_type, 'is_active': True}
    )
    if not created and asset.asset_type != asset_type:
        asset.asset_type = asset_type
        asset.save()

    # 2. Setup Collector
    collector = MarketDataCollector()
    
    # 3. Define dates
    end_date = datetime.now().strftime("%Y-%m-%d")
    start_date = (datetime.now() - timedelta(days=60)).strftime("%Y-%m-%d") # Use shorter period for free tier
    
    # 4. Fetch data
    print(f"Fetching data for {api_symbol} (as {display_symbol})...")
    df = collector.fetch_historical_data(api_symbol, 1, "day", start_date, end_date)
    
    if df is not None and not df.empty:
        # Clear fake/old data
        PriceHistory.objects.filter(asset=asset).delete()
        print(f"Cleared old data for {display_symbol}")
        
        collector.save_to_db(df, display_symbol, asset_type=asset_type)
        print(f"[OK] Real data for {display_symbol} saved.")
    else:
        print(f"[ERROR] Failed to fetch data for {api_symbol}.")

def run():
    # Assets to fetch - Polygon prefixes: C: for Core, X: for Crypto
    assets_to_fetch = [
        {"api": "AAPL", "display": "AAPL", "type": Asset.AssetType.STOCK, "name": "Apple Inc."},
        {"api": "X:BTCUSD", "display": "BTCUSD", "type": Asset.AssetType.CRYPTO, "name": "Bitcoin / USD"},
        {"api": "C:EURUSD", "display": "EURUSD", "type": Asset.AssetType.FOREX, "name": "Euro / USD"},
        {"api": "SPY", "display": "SPY", "type": Asset.AssetType.INDICE, "name": "SP500 ETF"},
    ]
    
    for item in assets_to_fetch:
        try:
            fetch_and_save(item["api"], item["display"], item["type"], item["name"])
        except Exception as e:
            print(f"Error processing {item['display']}: {e}")

    print("\n[AI] Demarrage des predictions automatiques...")
    for item in assets_to_fetch:
        try:
            signal = PredictionService.run_prediction(item["display"])
            if signal:
                print(f"[AI] Signal {signal.signal_type} genere pour {item['display']} (Confiance: {signal.confidence*100:.1f}%)")
        except Exception as e:
            print(f"[AI] Erreur de prediction pour {item['display']}: {e}")

    print("\n--- All operations completed ---")

if __name__ == "__main__":
    run()
