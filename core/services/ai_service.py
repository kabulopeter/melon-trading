from core.models import Asset, Signal, PriceHistory
from core.services.market_data_service import MarketDataService
from core.services.news_service import NewsService
import pandas as pd
import numpy as np
import logging

logger = logging.getLogger(__name__)

class AIService:
    @staticmethod
    def analyze_market(symbol):
        """
        Main entry point for analyzing a specific asset.
        """
        logger.info(f"AI Analysis starting for {symbol}")
        try:
            asset = Asset.objects.get(symbol=symbol)
        except Asset.DoesNotExist:
            logger.error(f"Asset {symbol} not found")
            return None

        # 1. Update Data (Ingestion on Demand or Check freshness)
        # For optimization, we might assume the periodic task 'collect_market_data' runs separately, 
        # but here we ensure we have data.
        md_service = MarketDataService()
        # md_service.fetch_and_store_data(symbol, days=2) # Ensure we have recent data
        
        # 2. Load Data from DB
        qs = PriceHistory.objects.filter(asset=asset).order_by('datetime')
        if not qs.exists():
            return None
            
        df = pd.DataFrame(list(qs.values('datetime', 'close', 'high', 'low', 'volume')))
        df.set_index('datetime', inplace=True)
        
        if len(df) < 50:
            return None # Not enough data
        
        # 3. Technical Analysis
        ta_result = AIService.calculate_technical_indicators(df)
        
        # 4. Sentiment Analysis
        news_service = NewsService()
        sentiment = news_service.get_sentiment(asset.name or symbol)
        
        # 5. Signal Logic (Heuristic for now, ML later)
        # Example Strategy: RSI < 30 (Buy) or > 70 (Sell) + Positive Sentiment
        rsi = ta_result.get('rsi', 50)
        signal_type = Signal.SignalType.NEUTRAL
        confidence = 0.5
        
        if rsi < 30 and sentiment >= 0:
            signal_type = Signal.SignalType.BUY
            confidence = 0.7 + (0.1 * sentiment) # Boost confidence with sentiment
        elif rsi > 70 and sentiment <= 0:
            signal_type = Signal.SignalType.SELL
            confidence = 0.7 + (0.1 * abs(sentiment))
            
        if signal_type == Signal.SignalType.NEUTRAL:
            return None # Do not spam neutral signals
        
        # 6. Generate Signal
        signal = Signal.objects.create(
            asset=asset,
            signal_type=signal_type,
            confidence=min(confidence, 0.99),
            technical_indicators={**ta_result, "sentiment": sentiment}
        )
        
        # 7. AUTOMATED TRADING TRIGGER
        # If confidence is high enough (> 0.8), automatically create a trade
        if signal.confidence >= 0.8:
            from core.services.trade_service import TradeService
            logger.info(f"🚀 High Confidence Signal for {signal.asset.symbol}! Auto-trading...")
            TradeService.create_trade_from_signal(signal, size=10.0) # Fixed size for demo
            
        return signal

    @staticmethod
    def calculate_technical_indicators(df):
        """
        Calculates RSI and MACD manually to avoid heavy ta-lib dependency issues directly.
        """
        close = df['close']
        
        # RSI
        delta = close.diff()
        gain = (delta.where(delta > 0, 0)).rolling(window=14).mean()
        loss = (-delta.where(delta < 0, 0)).rolling(window=14).mean()
        rs = gain / loss
        rsi = 100 - (100 / (1 + rs))
        
        # MACD
        exp1 = close.ewm(span=12, adjust=False).mean()
        exp2 = close.ewm(span=26, adjust=False).mean()
        macd = exp1 - exp2
        signal_line = macd.ewm(span=9, adjust=False).mean()
        
        return {
            "rsi": float(rsi.iloc[-1]) if not pd.isna(rsi.iloc[-1]) else 50.0,
            "macd": float(macd.iloc[-1]) if not pd.isna(macd.iloc[-1]) else 0.0,
            "macd_signal": float(signal_line.iloc[-1]) if not pd.isna(signal_line.iloc[-1]) else 0.0,
            "current_price": float(close.iloc[-1])
        }

    @staticmethod
    def predict_trend(df):
        # Placeholder for LSTM/XGBoost
        return 0.0
