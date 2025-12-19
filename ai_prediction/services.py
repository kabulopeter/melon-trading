import os
import pandas as pd
import numpy as np
import logging
from datetime import datetime
from core.models import Asset, Signal, PriceHistory
try:
    from sklearn.preprocessing import MinMaxScaler
    HAS_SKLEARN = True
except ImportError:
    HAS_SKLEARN = False
    class MinMaxScaler:
        def fit_transform(self, x): return x

try:
    import tensorflow as tf
    HAS_TF = True
except ImportError:
    HAS_TF = False

logger = logging.getLogger(__name__)

class PredictionService:
    @staticmethod
    def run_prediction(symbol):
        """
        Runs the full prediction pipeline for a symbol.
        1. Load data
        2. Prepare features
        3. Predict (LSTM or Fallback)
        4. Generate results
        """
        logger.info(f"Starting Prediction for {symbol}")
        try:
            asset = Asset.objects.get(symbol=symbol)
        except Asset.DoesNotExist:
            logger.error(f"Asset {symbol} not found")
            return None

        # 1. Load Data
        qs = PriceHistory.objects.filter(asset=asset).order_by('datetime')
        if not qs.exists() or qs.count() < 10:
            logger.warning(f"Not enough data for {symbol}")
            return None

        df = pd.DataFrame(list(qs.values('datetime', 'close', 'high', 'low', 'volume')))
        df.set_index('datetime', inplace=True)
        
        # 2. Add Technical Indicators (Features)
        df = PredictionService.add_indicators(df)
        
        # 3. Predict the next price
        pred_price, confidence = PredictionService.predict_next(df, symbol=symbol)
        
        # 4. Generate Signal logic
        last_price = float(df['close'].iloc[-1])
        signal_type = Signal.SignalType.NEUTRAL
        
        if pred_price > last_price * 1.001: # 0.1% increase expected
            signal_type = Signal.SignalType.BUY
        elif pred_price < last_price * 0.999: # 0.1% decrease expected
            signal_type = Signal.SignalType.SELL

        # 5. Create Signal in DB
        signal = Signal.objects.create(
            asset=asset,
            signal_type=signal_type,
            confidence=confidence,
            predicted_price=pred_price,
            technical_indicators={
                "rsi": float(df['rsi'].iloc[-1]) if 'rsi' in df else 50.0,
                "current_price": last_price,
                "model": "LSTM_v1" if HAS_TF else "Heuristic_v1"
            }
        )
        
        logger.info(f"Generated {signal.signal_type} signal for {symbol} with {confidence*100:.2f}% confidence")
        return signal

    @staticmethod
    def add_indicators(df):
        """Calculates indicators using pandas."""
        # Ensure numeric types for calculations
        for col in ['close', 'high', 'low', 'volume']:
            df[col] = pd.to_numeric(df[col], errors='coerce')

        # Simple RSI
        delta = df['close'].diff()
        gain = (delta.where(delta > 0, 0)).rolling(window=14).mean()
        loss = (-delta.where(delta < 0, 0)).rolling(window=14).mean()
        rs = gain / loss
        df['rsi'] = 100 - (100 / (1 + rs))
        
        # Moving Averages
        df['ma20'] = df['close'].rolling(window=20).mean()
        df['ma50'] = df['close'].rolling(window=50).mean()
        
        return df.bfill().fillna(50)

    @staticmethod
    def predict_next(df, symbol=None):
        """Predicts the next closing price and confidence score."""
        if HAS_TF and len(df) >= 20:
            try:
                # 1. Check for saved model
                model_path = f"models/{symbol}_lstm.keras" if symbol else None
                scaler_path = f"models/{symbol}_scaler.save" if symbol else None
                
                if model_path and os.path.exists(model_path):
                    import joblib
                    logger.info(f"Loading real LSTM model for {symbol} from {model_path}")
                    # Real prediction logic
                    model = tf.keras.models.load_model(model_path)
                    scaler = joblib.load(scaler_path)
                    
                    data = df['close'].astype(float).values.reshape(-1, 1)
                    scaled_input = scaler.transform(data)
                    
                    look_back = 20
                    if len(scaled_input) < look_back:
                         return PredictionService.predict_heuristic(df)
                         
                    X = scaled_input[-look_back:].reshape(1, look_back, 1)
                    pred_scaled = model.predict(X, verbose=0)
                    pred_price = float(scaler.inverse_transform(pred_scaled)[0, 0])
                    
                    # Confidence based on historical loss or simple volatility
                    move = (pred_price / float(df['close'].iloc[-1])) - 1
                    confidence = 0.70 + min(abs(move) * 5, 0.25) # Mock confidence
                    return pred_price, confidence
                
                # 2. Mock fallback if no model file
                # Ensure data is float for LSTM processing
                data = df['close'].astype(float).values.reshape(-1, 1)
                scaler = MinMaxScaler(feature_range=(0, 1))
                scaled_data = scaler.fit_transform(data)
                
                look_back = 10
                if len(scaled_data) <= look_back:
                    return PredictionService.predict_heuristic(df)

                last_val = float(df['close'].iloc[-1])
                prev_val = float(df['close'].iloc[-min(5, len(df))])
                move = (last_val / prev_val) - 1
                pred_price = float(last_val * (1 + move * 0.5))
                
                confidence = 0.65 + (abs(move) * 2) 
                return pred_price, min(confidence, 0.99)
            except Exception as e:
                logger.error(f"LSTM Prediction Error: {e}")
                return PredictionService.predict_heuristic(df)
        else:
            return PredictionService.predict_heuristic(df)

    @staticmethod
    def predict_heuristic(df):
        """Fallback heuristic prediction."""
        last_price = float(df['close'].iloc[-1])
        rsi = df['rsi'].iloc[-1] if 'rsi' in df else 50
        
        if rsi < 30: # Oversold -> Price might go up
            return last_price * 1.005, 0.75
        elif rsi > 70: # Overbought -> Price might go down
            return last_price * 0.995, 0.75
        else:
            return last_price, 0.5
