import os
import sys
import django
from datetime import datetime, timedelta
import pandas as pd
import numpy as np

# Setup Django
sys.path.append(os.getcwd())
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from core.models import Asset, PriceHistory
from data_collector import MarketDataCollector

def fetch_large_history(symbol_api, symbol_display, days=730):
    print(f"--- Fetching {days} days of data for {symbol_display} ---")
    collector = MarketDataCollector()
    end_date = datetime.now().strftime("%Y-%m-%d")
    start_date = (datetime.now() - timedelta(days=days)).strftime("%Y-%m-%d")
    
    df = collector.fetch_historical_data(symbol_api, 1, "day", start_date, end_date)
    
    if df is not None and not df.empty:
        print(f"Successfully fetched {len(df)} rows.")
        return df
    else:
        print("Failed to fetch data. Check API limits.")
        return None

if __name__ == "__main__":
    df = fetch_large_history("AAPL", "AAPL")
    if df is not None:
        print(df.head())
        print(df.tail())
