import pandas as pd
import numpy as np
# import talib
from pathlib import Path
from typing import Dict, Any
from numpy.random import uniform

# =================================================================
# CONSTANTES CRITIQUES POUR LA GESTION DU RISQUE (MM)
# =================================================================
RISK_PER_TRADE = 0.01 # Risque maximum de 1% du capital par transaction (VALEUR FONDAMENTALE)
STOP_LOSS_PERCENT = 0.02 # Stop-Loss fixé à 2% sous le prix d'entrée
TAKE_PROFIT_PERCENT = 0.04 # Take-Profit fixé à 4% au-dessus du prix d'entrée (Ratio Risque/Rendement 1:2)
TARGET_CONFIDENCE = 0.97 # 97% ou 0.97

# Réutilisation de la classe Metrics de backtester.py
# (En pratique on pourrait les mettre dans un fichier common.py)
class Metrics:
    """
    Calcule les indicateurs de performance clés (KPIs) après un backtest.
    """
    def __init__(self, equity_curve, initial_capital, trades_log):
        self.equity_curve = pd.Series(equity_curve)
        self.initial_capital = initial_capital
        self.trades_log = pd.DataFrame(trades_log)

    def calculate_drawdown(self):
        """ Calcule le Drawdown Maximal (Max Drawdown - MDD). """
        peak = self.equity_curve.cummax()
        drawdown = (self.equity_curve - peak) / peak
        return drawdown.min() * 100

    def calculate_sharpe_ratio(self, risk_free_rate=0.0):
        """ Calcule le Ratio de Sharpe. """
        returns = self.equity_curve.pct_change().dropna()
        annual_returns = returns.mean() * 252
        annual_std = returns.std() * np.sqrt(252)
        if annual_std == 0: return np.nan
        return (annual_returns - risk_free_rate) / annual_std

    def calculate_key_stats(self):
        """ Compile tous les KPIs. """
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
            "Maximum Drawdown (MDD)": f"{self.calculate_drawdown():.2f} %",
            "Ratio de Sharpe": f"{self.calculate_sharpe_ratio():.2f}",
            "Nombre de Trades": total_trades,
            "Taux de Réussite (Win Rate)": f"{win_rate:.2f} %"
        }

class AIConfidenceFilter:
    """
    Simule la sortie d'un modèle d'IA (ex: LSTM/TensorFlow)
    qui prédit le mouvement du prix et attribue un score de confiance.
    """
    def __init__(self, model_path=None):
        # En production, ce module chargerait le modèle LSTM pré-entraîné
        # self.model = tf.keras.models.load_model(model_path)
        print("🤖 AI Confidence Filter initialisé. Modèle chargé.")

    def get_confidence_score(self, current_data_row: pd.Series) -> float:
        """
        Génère un score de confiance pour le mouvement haussier/baissier.
        """
        # --- LOGIQUE DE SIMULATION ---
        # Simulation d'un événement de haute confiance :
        if uniform(0, 1) < 0.20: # 20% de chance (Augmenté pour la démo)
            # Génère un score de 97% à 99%
            score = uniform(TARGET_CONFIDENCE, 0.99)
        else:
            # Score de confiance "normal" (non suffisant pour le filtre)
            score = uniform(0.50, TARGET_CONFIDENCE)
        return score

class RiskManagedBacktestEngine:
    def __init__(self, symbol, initial_capital=10000.0):
        # Setup Django access
        from core.models import Asset, PriceHistory
        
        try:
            self.asset = Asset.objects.get(symbol=symbol)
        except Asset.DoesNotExist:
            raise ValueError(f"❌ Actif non trouvé : {symbol}")

        print(f"🔄 Chargement des données pour {symbol} depuis la base de données...")
        
        # Chargement rapide via Pandas et Django ORM
        qs = PriceHistory.objects.filter(asset=self.asset).order_by('datetime').values('datetime', 'open', 'high', 'low', 'close', 'volume')
        
        if not qs.exists():
            raise ValueError(f"❌ Aucune donnée historique pour {symbol}")

        self.data = pd.DataFrame.from_records(qs)
        self.data.set_index('datetime', inplace=True)
        # Conversion explicite des Decimals en float pour éviter les erreurs de type
        cols = ['open', 'high', 'low', 'close', 'volume']
        self.data[cols] = self.data[cols].astype(float)
        self.data.sort_index(inplace=True)

        self.capital = initial_capital
        self.initial_capital = initial_capital
        self.equity_curve = [initial_capital]
        self.trades_log = []
        self.position = None # (Prix d'entrée, quantité, prix_sl, prix_tp, score_confiance, trade_obj_id)
        self.ai_filter = AIConfidenceFilter()

    def calculate_position_size(self, entry_price: float) -> Dict[str, float]:
        """
        Calcule la quantité à acheter et les prix SL/TP pour respecter le risque de 1%.
        """
        risk_amount = self.capital * RISK_PER_TRADE # Ex: 10000 * 0.01 = 100 $
        
        # 1. Définition des Prix SL/TP
        stop_loss_price = entry_price * (1 - STOP_LOSS_PERCENT) # Prix du SL
        take_profit_price = entry_price * (1 + TAKE_PROFIT_PERCENT) # Prix du TP
        
        # 2. Calcul de la distance du Stop-Loss (en $)
        risk_per_share = entry_price - stop_loss_price # Ex: 2% du prix d'entrée
        
        if risk_per_share <= 0:
            return {"quantity": 0, "sl": 0, "tp": 0}

        # 3. Calcul de la QUANTITÉ (Taille de Position)
        quantity = risk_amount / risk_per_share
        
        # S'assurer que la quantité totale ne dépasse pas le capital disponible
        if (quantity * entry_price) > self.capital:
            quantity = self.capital / entry_price
        
        return {
            "quantity": quantity,
            "sl": stop_loss_price,
            "tp": take_profit_price
        }

    def simulate_trade_step(self, current_close: float, high: float, low: float) -> bool:
        """
        Vérifie si le trade en cours touche le Stop-Loss ou le Take-Profit sur la bougie suivante.
        """
        if self.position is None:
            return False

        # On gère le tuple de position qui peut avoir 4 ou 5 éléments
        # (Prix d'entrée, quantité, prix_sl, prix_tp, [score_confiance])
        entry_price = self.position[0]
        quantity = self.position[1]
        sl_price = self.position[2]
        tp_price = self.position[3]
        
        # --- LOGIQUE DE SORTIE (SL ou TP) ---
        exit_price = None
        exit_reason = None

        # Vérification SL : Le prix bas (low) de la bougie touche-t-il le SL ?
        if low <= sl_price:
            exit_price = sl_price
            exit_reason = "STOP_LOSS"
        
        # Vérification TP : Le prix haut (high) de la bougie touche-t-il le TP ?
        elif high >= tp_price:
            exit_price = tp_price
            exit_reason = "TAKE_PROFIT"
        
        # Si un seuil a été touché, exécuter la sortie
        if exit_price is not None:
            pnl_raw = (exit_price - entry_price) * quantity
            self.capital += pnl_raw
            
            self.trades_log.append({
                'PnL': pnl_raw,
                'Exit Reason': exit_reason,
            })

            # DB: Fermeture du trade
            if len(self.position) > 5:
                trade_id = self.position[5]
                if trade_id:
                    self.close_trade_db(trade_id, exit_price, pnl_raw)

            self.position = None # Fermeture de la position
            return True # Trade clôturé
        
        return False # Trade toujours en cours


    def run_strategy_macrossover(self, fast_period=50, slow_period=200):
        """
        Stratégie de Croisement de MAs avec Money Management ET Filtre IA > 97%.
        """
        print(f"\n🚀 Lancement du Backtest filtré par IA (Confiance min: {TARGET_CONFIDENCE*100}%)")

        # self.data['MA_Fast'] = talib.SMA(self.data['close'], timeperiod=fast_period)
        # self.data['MA_Slow'] = talib.SMA(self.data['close'], timeperiod=slow_period)
        self.data['MA_Fast'] = self.data['close'].rolling(window=fast_period).mean()
        self.data['MA_Slow'] = self.data['close'].rolling(window=slow_period).mean()
        self.data.dropna(inplace=True)

        for i, (index, row) in enumerate(self.data.iterrows()):
            if i == 0: continue # On commence à la bougie suivante pour vérifier SL/TP
            
            current_close = row['close']
            
            # Vérification et clôture des trades en cours (SL/TP)
            if self.position is not None:
                trade_closed = self.simulate_trade_step(current_close, row['high'], row['low'])
                if trade_closed:
                    pass

            # Vérification du signal d'ACHAT
            if row['MA_Fast'] > row['MA_Slow']:
                if self.position is None:
                    # VÉRIFICATION DU FILTRE D'IA
                    confidence_score = self.ai_filter.get_confidence_score(row)
                    
                    if confidence_score >= TARGET_CONFIDENCE:
                        # EXÉCUTION DU TRADE
                        sizing = self.calculate_position_size(current_close)
                        
                        if sizing['quantity'] > 0:
                            # DB: Enregistrement du trade
                            from core.models import Trade
                            trade_id = self.open_trade_db(Trade.Side.BUY, current_close, sizing['quantity'], sizing['sl'], sizing['tp'], confidence_score)
                            
                            self.position = (current_close, sizing['quantity'], sizing['sl'], sizing['tp'], confidence_score, trade_id)

            # Mise à jour de la courbe d'équité
            if self.position is not None:
                entry_price = self.position[0]
                quantity = self.position[1]
                current_value = self.capital + (current_close - entry_price) * quantity
                self.equity_curve.append(current_value)
            else:
                self.equity_curve.append(self.capital)

        # Fin du Backtest : Affichage des résultats
        results = Metrics(self.equity_curve, self.initial_capital, self.trades_log).calculate_key_stats()
        
        print("\n" + "="*50)
        print("📈 RÉSULTATS DU BACKTEST")
        print("="*50)
        for key, value in results.items():
            print(f"- {key} : {value}")
        print("="*50 + "\n")

    def open_trade_db(self, side, entry, size, sl, tp, confidence):
        """ Enregistre l'ouverture du trade en DB """
        from core.models import Trade
        from decimal import Decimal
        try:
            trade = Trade.objects.create(
                asset=self.asset,
                side=side,
                entry_price=Decimal(str(entry)),
                size=Decimal(str(size)),
                stop_loss=Decimal(str(sl)),
                take_profit=Decimal(str(tp)),
                confidence_score=confidence,
                status=Trade.Status.OPEN,
                opened_at=pd.Timestamp.now(tz='UTC')
            )
            return trade.id
        except Exception as e:
            print(f"❌ Erreur DB (Open): {e}")
            return None

    def close_trade_db(self, trade_id, exit_price, pnl):
        """ Enregistre la fermeture du trade en DB """
        from core.models import Trade
        from decimal import Decimal
        try:
            trade = Trade.objects.get(id=trade_id)
            trade.status = Trade.Status.CLOSED
            trade.exit_price = Decimal(str(exit_price))
            trade.pnl = Decimal(str(pnl))
            trade.closed_at = pd.Timestamp.now(tz='UTC')
            trade.save()
        except Exception as e:
            print(f"❌ Erreur DB (Close): {e}")

if __name__ == "__main__":
    import os
    import sys
    import django

    # Setup Django Environment
    sys.path.append(os.getcwd())
    os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
    django.setup()

    SYMBOL_LIST = ["AAPL", "R_100"]
    
    # Nettoyage global avant de commencer
    try:
        from core.models import Trade
        Trade.objects.all().delete()
        print("🧹 Base de données nettoyée (Trades Reset).")
    except Exception:
        pass

    for symbol in SYMBOL_LIST:
        try:
            print(f"\n--- Backtesting {symbol} ---")
            engine = RiskManagedBacktestEngine(symbol, initial_capital=10000.0)
            engine.run_strategy_macrossover(fast_period=50, slow_period=200)
        except ValueError as e:
            print(f"⚠️ Apparement pas de données pour {symbol}: {e}")
        except Exception as e:
            print(f"❌ Erreur sur {symbol} : {e}")
