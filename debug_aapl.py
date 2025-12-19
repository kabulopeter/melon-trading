import os
import sys
import django
from datetime import datetime, timedelta

# Setup Django
sys.path.append(os.getcwd())
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from core.models import Asset, PriceHistory
from data_collector import MarketDataCollector

def debug_save():
    collector = MarketDataCollector()
    symbol = "AAPL"
    start = "2024-11-01"
    end = "2024-11-10"
    
    print(f"--- Debugging {symbol} ---")
    df = collector.fetch_historical_data(symbol, 1, "day", start, end)
    if df is not None:
        print(f"Data fetched: {len(df)} rows.")
        collector.save_to_db(df, symbol)
        
        # Verify directly
        asset = Asset.objects.get(symbol=symbol)
        count = PriceHistory.objects.filter(asset=asset).count()
        print(f"Database count for {symbol}: {count}")
    else:
        print("Fetch failed.")

if __name__ == "__main__":
    debug_save()
