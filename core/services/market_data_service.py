import os
import requests
import pandas as pd
import logging
from datetime import datetime, timedelta
from django.conf import settings
from core.models import Asset, PriceHistory

logger = logging.getLogger(__name__)

class MarketDataService:
    def __init__(self):
        self.polygon_key = os.getenv("POLYGON_API_KEY")
        self.alpaca_key = os.getenv("ALPACA_API_KEY")
        self.alpaca_secret = os.getenv("ALPACA_SECRET_KEY")
        self.alpaca_base_url = os.getenv("ALPACA_BASE_URL", "https://paper-api.alpaca.markets")

    def fetch_and_store_data(self, symbol: str, days: int = 1):
        """
        Fetches data for the given symbol and stores it in the database.
        Automatically checks the asset type to decide provider.
        """
        try:
            asset = Asset.objects.get(symbol=symbol)
        except Asset.DoesNotExist:
            logger.warning(f"Asset {symbol} does not exist. Creating default STOCK.")
            asset = Asset.objects.create(symbol=symbol, name=symbol, asset_type=Asset.AssetType.STOCK)

        df = None
        if asset.asset_type == Asset.AssetType.STOCK:
             # Prefer Alpaca for stocks if keys exist
            if self.alpaca_key and self.alpaca_secret:
                df = self._fetch_alpaca(symbol, days)
            else:
                df = self._fetch_polygon(symbol, days)
        elif asset.asset_type == Asset.AssetType.CRYPTO:
             # Basic crypto support via Polygon
             df = self._fetch_polygon(f"X:{symbol}USD", days) # Polygon Crypto Ticker
        
        if df is not None and not df.empty:
            self._save_to_db(asset, df)
            return len(df)
        
        return 0

    def _fetch_polygon(self, ticker, days):
        if not self.polygon_key:
            logger.error("Polygon API Key missing")
            return None

        end_date = datetime.now().strftime("%Y-%m-%d")
        start_date = (datetime.now() - timedelta(days=days)).strftime("%Y-%m-%d")
        
        url = f"https://api.polygon.io/v2/aggs/ticker/{ticker}/range/1/day/{start_date}/{end_date}"
        params = {"adjusted": "true", "sort": "asc", "limit": 50000, "apiKey": self.polygon_key}
        
        try:
            resp = requests.get(url, params=params)
            data = resp.json()
            if data.get('status') != 'OK' or 'results' not in data:
                return None
                
            df = pd.DataFrame(data['results'])
            df = df.rename(columns={'t': 'timestamp', 'o': 'open', 'h': 'high', 'l': 'low', 'c': 'close', 'v': 'volume'})
            df['datetime'] = pd.to_datetime(df['timestamp'], unit='ms')
            df.set_index('datetime', inplace=True)
            return df
        except Exception as e:
            logger.error(f"Polygon fetch error: {e}")
            return None

    def _fetch_alpaca(self, symbol, days):
        try:
            import alpaca_trade_api as tradeapi
            from alpaca_trade_api.rest import TimeFrame
        except ImportError:
            logger.error("Alpaca library not installed")
            return None

        api = tradeapi.REST(self.alpaca_key, self.alpaca_secret, self.alpaca_base_url, api_version='v2')
        end_date = datetime.now()
        start_date = end_date - timedelta(days=days)
        
        try:
            bars = api.get_bars(symbol, TimeFrame.Day, start=start_date.isoformat(), end=end_date.isoformat(), adjustment='raw').df
            if bars.empty: return None
            
            if bars.index.tz is not None:
                bars.index = bars.index.tz_convert(None)
            
            # Ensure columns are lower case
            bars.columns = [c.lower() for c in bars.columns]
            return bars
        except Exception as e:
            logger.error(f"Alpaca fetch error: {e}")
            return None

    def _save_to_db(self, asset, df):
        # Clean data
        df = df[~df.index.duplicated(keep='first')]
        df = df.dropna()
        
        batch = []
        for index, row in df.iterrows():
            batch.append(
                PriceHistory(
                    asset=asset,
                    datetime=index,
                    open=row['open'],
                    high=row['high'],
                    low=row['low'],
                    close=row['close'],
                    volume=row.get('volume', 0)
                )
            )
        PriceHistory.objects.bulk_create(batch, batch_size=2000, ignore_conflicts=True)
        logger.info(f"Saved {len(batch)} records for {asset.symbol}")
