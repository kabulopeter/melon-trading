import os
import sys
import django
import pandas as pd
import numpy as np
from typing import Dict, Any
from decimal import Decimal

# Setup Django Environment
sys.path.append(os.getcwd())
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from core.models import Asset, PriceHistory, Trade, Signal
from ai_prediction.services import PredictionService

# =================================================================
# CONSTANTES DE GESTION DU RISQUE
# =================================================================
RISK_PER_TRADE = 0.02 # 2% du capital par trade
STOP_LOSS_PERCENT = 0.015 # 1.5% SL
TAKE_PROFIT_PERCENT = 0.03 # 3% TP (Ratio 1:2)
MIN_CONFIDENCE = 0.60 # Confiance minimale pour agir

class Metrics:
    def __init__(self, equity_curve, initial_capital, trades_log):
        self.equity_curve = pd.Series(equity_curve)
        self.initial_capital = initial_capital
        self.trades_log = pd.DataFrame(trades_log)

    def calculate_drawdown(self):
        peak = self.equity_curve.cummax()
        drawdown = (self.equity_curve - peak) / peak
        return drawdown.min() * 100

    def calculate_sharpe_ratio(self, risk_free_rate=0.0):
        returns = self.equity_curve.pct_change().dropna()
        if len(returns) < 2: return 0.0
        annual_returns = returns.mean() * 252
        annual_std = returns.std() * np.sqrt(252)
        if annual_std == 0: return 0.0
        return (annual_returns - risk_free_rate) / annual_std

    def calculate_key_stats(self):
        final_capital = self.equity_curve.iloc[-1]
        total_return = (final_capital - self.initial_capital) / self.initial_capital
        
        if not self.trades_log.empty:
            winning_trades = self.trades_log[self.trades_log['PnL'] > 0]
            total_trades = len(self.trades_log)
            win_rate = len(winning_trades) / total_trades * 100
        else:
            total_trades = 0
            win_rate = 0
        
        return {
            "Capital Initial": f"{self.initial_capital:,.2f} $",
            "Capital Final": f"{final_capital:,.2f} $",
            "Rendement Total": f"{total_return * 100:.2f} %",
            "Max Drawdown": f"{self.calculate_drawdown():.2f} %",
            "Ratio de Sharpe": f"{self.calculate_sharpe_ratio():.2f}",
            "Nombre de Trades": total_trades,
            "Taux de Réussite": f"{win_rate:.2f} %"
        }

class AIBacktestEngine:
    def __init__(self, symbol, initial_capital=10000.0):
        try:
            self.asset = Asset.objects.get(symbol=symbol)
        except Asset.DoesNotExist:
            raise ValueError(f"Asset {symbol} non trouvé.")

        print(f"Loading data for {symbol}...")
        qs = PriceHistory.objects.filter(asset=self.asset).order_by('datetime').values('datetime', 'open', 'high', 'low', 'close', 'volume')
        
        if not qs.exists():
            raise ValueError(f"No historical data for {symbol}")

        self.data = pd.DataFrame.from_records(qs)
        self.data.set_index('datetime', inplace=True)
        cols = ['open', 'high', 'low', 'close', 'volume']
        self.data[cols] = self.data[cols].astype(float)
        
        # Calculer les indicateurs une seule fois sur toute la série pour gagner du temps
        self.data = PredictionService.add_indicators(self.data)

        self.capital = initial_capital
        self.initial_capital = initial_capital
        self.equity_curve = [initial_capital]
        self.trades_log = []
        self.position = None 

    def calculate_position_size(self, entry_price, side):
        risk_amount = self.capital * RISK_PER_TRADE
        
        if side == "BUY":
            sl_price = entry_price * (1 - STOP_LOSS_PERCENT)
            tp_price = entry_price * (1 + TAKE_PROFIT_PERCENT)
        else: # SELL
            sl_price = entry_price * (1 + STOP_LOSS_PERCENT)
            tp_price = entry_price * (1 - TAKE_PROFIT_PERCENT)
            
        risk_per_unit = abs(entry_price - sl_price)
        quantity = risk_amount / risk_per_unit
        
        if (quantity * entry_price) > self.capital:
            quantity = self.capital / entry_price
            
        return {"quantity": quantity, "sl": sl_price, "tp": tp_price}

    def run(self, window_size=30):
        print(f"Launching AI Backtest on {len(self.data)} candles...")
        
        # On commence après window_size pour avoir assez de données pour l'IA
        for i in range(window_size, len(self.data)):
            current_row = self.data.iloc[i]
            prev_rows = self.data.iloc[i-window_size:i]
            current_close = float(current_row['close'])
            high = float(current_row['high'])
            low = float(current_row['low'])
            timestamp = self.data.index[i]

            # 1. Gérer la position existante
            if self.position:
                entry_price = self.position['entry']
                quantity = self.position['quantity']
                sl = self.position['sl']
                tp = self.position['tp']
                side = self.position['side']
                
                closed = False
                exit_price = None
                reason = None

                if side == "BUY":
                    if low <= sl:
                        exit_price = sl
                        reason = "SL"
                        closed = True
                    elif high >= tp:
                        exit_price = tp
                        reason = "TP"
                        closed = True
                else: # SELL
                    if high >= sl:
                        exit_price = sl
                        reason = "SL"
                        closed = True
                    elif low <= tp:
                        exit_price = tp
                        reason = "TP"
                        closed = True
                
                if closed:
                    pnl = (exit_price - entry_price) * quantity if side == "BUY" else (entry_price - exit_price) * quantity
                    self.capital += pnl
                    self.trades_log.append({'PnL': pnl, 'Reason': reason, 'Side': side})
                    self.position = None

            # 2. Chercher un nouveau signal (seulement si pas de position)
            if not self.position:
                pred_price, confidence = PredictionService.predict_next(prev_rows)
                
                if confidence >= MIN_CONFIDENCE:
                    side = None
                    if pred_price > current_close * 1.002: # Seuil de 0.2%
                        side = "BUY"
                    elif pred_price < current_close * 0.998:
                        side = "SELL"
                    
                    if side:
                        sizing = self.calculate_position_size(current_close, side)
                        self.position = {
                            'entry': current_close,
                            'quantity': sizing['quantity'],
                            'sl': sizing['sl'],
                            'tp': sizing['tp'],
                            'side': side,
                            'timestamp': timestamp
                        }

            # 3. Update Equity Curve
            if self.position:
                p_entry = self.position['entry']
                p_qty = self.position['quantity']
                p_side = self.position['side']
                if p_side == "BUY":
                    current_val = self.capital + (current_close - p_entry) * p_qty
                else:
                    current_val = self.capital + (p_entry - current_close) * p_qty
                self.equity_curve.append(current_val)
            else:
                self.equity_curve.append(self.capital)

        # Résultats
        metrics = Metrics(self.equity_curve, self.initial_capital, self.trades_log)
        stats = metrics.calculate_key_stats()
        
        print("\n" + "="*40)
        print(f"AI RESULTS : {self.asset.symbol}")
        print("="*40)
        for k, v in stats.items():
            print(f"{k:25}: {v}")
        print("="*40 + "\n")
        return stats

if __name__ == "__main__":
    import time
    start_time = time.time()
    
    # Symbols to test
    symbols = ["AAPL", "BTCUSD", "EURUSD", "SPY"]
    
    overall_results = {}
    for sym in symbols:
        try:
            engine = AIBacktestEngine(sym)
            overall_results[sym] = engine.run()
        except Exception as e:
            print(f"Erreur sur {sym}: {e}")
            
    print(f"Backtest terminé en {time.time() - start_time:.2f} secondes.")
