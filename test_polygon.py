import os
import sys
import django
from datetime import datetime, timedelta

# Setup Django
sys.path.append(os.getcwd())
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from data_collector import MarketDataCollector
from core.models import Asset

def test_polygon():
    collector = MarketDataCollector()
    symbol = "AAPL"
    start = "2024-12-01"
    end = "2024-12-15"
    
    print(f"Testing Polygon for {symbol}...")
    df = collector.fetch_historical_data(symbol, 1, "day", start, end)
    if df is not None:
        print(f"Success! Fetched {len(df)} rows.")
        print(df.head())
    else:
        print("Failed.")

if __name__ == "__main__":
    test_polygon()
