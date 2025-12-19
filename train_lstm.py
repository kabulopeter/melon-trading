import os
import sys
import django
import pandas as pd
import numpy as np
from datetime import datetime, timedelta
from sklearn.preprocessing import MinMaxScaler
import tensorflow as tf
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import LSTM, Dense, Dropout

# Setup Django
sys.path.append(os.getcwd())
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from core.models import Asset
from data_collector import MarketDataCollector

def train_for_symbol(symbol_api, symbol_display):
    print(f"\n--- Training LSTM for {symbol_display} ---")
    
    # 1. Fetch Data (2 years)
    collector = MarketDataCollector()
    end_date = datetime.now().strftime("%Y-%m-%d")
    start_date = (datetime.now() - timedelta(days=730)).strftime("%Y-%m-%d")
    df = collector.fetch_historical_data(symbol_api, 1, "day", start_date, end_date)
    
    if df is None or len(df) < 100:
        print(f"Not enough data to train for {symbol_display}")
        return

    # 2. Preprocess
    data = df['close'].values.reshape(-1, 1)
    scaler = MinMaxScaler(feature_range=(0, 1))
    scaled_data = scaler.fit_transform(data)
    
    # Create sequences
    look_back = 20
    X, y = [], []
    for i in range(look_back, len(scaled_data)):
        X.append(scaled_data[i-look_back:i, 0])
        y.append(scaled_data[i, 0])
    
    X, y = np.array(X), np.array(y)
    X = np.reshape(X, (X.shape[0], X.shape[1], 1))
    
    # 3. Build Model
    model = Sequential([
        LSTM(units=50, return_sequences=True, input_shape=(X.shape[1], 1)),
        Dropout(0.2),
        LSTM(units=50, return_sequences=False),
        Dropout(0.2),
        Dense(units=25),
        Dense(units=1)
    ])
    
    model.compile(optimizer='adam', loss='mean_squared_error')
    
    # 4. Train
    print(f"Starting training on {len(X)} samples...")
    model.fit(X, y, batch_size=32, epochs=10, verbose=1)
    
    # 5. Save
    os.makedirs('models', exist_ok=True)
    model_path = f"models/{symbol_display}_lstm.keras"
    model.save(model_path)
    
    # Also save the scaler params so we can use them for prediction
    # In a real app we'd save the scaler object with joblib, but for simplicity:
    import joblib
    joblib.dump(scaler, f"models/{symbol_display}_scaler.save")
    
    print(f"Model saved to {model_path}")

if __name__ == "__main__":
    # Train for some main assets
    train_for_symbol("AAPL", "AAPL")
    train_for_symbol("X:BTCUSD", "BTCUSD")
