import pandas as pd
import numpy as np
import talib # Nécessaire pour les calculs d'indicateurs
from pathlib import Path

# =================================================================
# 1. CLASSE DE GESTION DES PERFORMANCES (KPIs PROFESSIONNELS)
# =================================================================
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
        # Calcule le pic (maximum cumulé)
        peak = self.equity_curve.cummax()
        # Calcule le Drawdown (perte du pic)
        drawdown = (self.equity_curve - peak) / peak
        return drawdown.min() * 100 # Retourne en pourcentage

    def calculate_sharpe_ratio(self, risk_free_rate=0.0):
        """ Calcule le Ratio de Sharpe (Rendement ajusté au risque). """
        # Rendement quotidien
        returns = self.equity_curve.pct_change().dropna()
        # Annualisation (si données journalières)
        annual_returns = returns.mean() * 252 # 252 jours de trading par an
        annual_std = returns.std() * np.sqrt(252)

        if annual_std == 0:
            return np.nan # Évite la division par zéro

        return (annual_returns - risk_free_rate) / annual_std

    def calculate_key_stats(self):
        """ Compile tous les KPIs. """
        final_capital = self.equity_curve.iloc[-1]
        total_return = (final_capital - self.initial_capital) / self.initial_capital
        
        # Statistiques des trades
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

# =================================================================
# 2. MOTEUR DE BACKTEST (SIMULATION)
# =================================================================
# =================================================================
# 2. MOTEUR DE BACKTEST (SIMULATION)
# =================================================================
class BacktestEngine:
    def __init__(self, symbol, initial_capital=10000.0):
        # Setup Django access
        from core.models import Asset, PriceHistory
        
        try:
            self.asset = Asset.objects.get(symbol=symbol)
        except Asset.DoesNotExist:
            raise ValueError(f"❌ Actif non trouvé : {symbol}")

        print(f"🔄 Chargement des données pour {symbol} depuis la base de données...")
        
        # Chargement rapide via Pandas et Django ORM
        # On récupère les QuerySet values pour créer le DataFrame
        qs = PriceHistory.objects.filter(asset=self.asset).order_by('datetime').values('datetime', 'open', 'high', 'low', 'close', 'volume')
        
        if not qs.exists():
            raise ValueError(f"❌ Aucune donnée historique pour {symbol}")

        self.data = pd.DataFrame.from_records(qs)
        self.data.set_index('datetime', inplace=True)
        self.data.sort_index(inplace=True)
        
        self.capital = initial_capital
        self.initial_capital = initial_capital
        self.equity_curve = [initial_capital]
        self.trades_log = []
        self.position = None # (Prix d'entrée, quantité)

    def run_strategy_macrossover(self, fast_period=50, slow_period=200):
        """
        Stratégie de Croisement de Moyennes Mobiles (MACrossover).
        Achat: MA Courte > MA Longue | Vente: MA Courte < MA Longue
        """
        print(f"\n🚀 Lancement du Backtest : {self.data_path.name} ({len(self.data)} périodes)")

        # Calcul des MAs (Moving Averages) via TA-Lib
        self.data['MA_Fast'] = talib.SMA(self.data['close'], timeperiod=fast_period)
        self.data['MA_Slow'] = talib.SMA(self.data['close'], timeperiod=slow_period)
        
        # Suppression des lignes initiales où les MAs ne sont pas encore calculées
        self.data.dropna(inplace=True)

        for index, row in self.data.iterrows():
            current_close = row['close']
            
            # Vérification du signal d'ACHAT (MA Courte coupe MA Longue par le haut)
            # MA_Fast > MA_Slow sur la période actuelle
            if row['MA_Fast'] > row['MA_Slow']:
                # Si le bot n'est pas en position, on achète
                if self.position is None:
                    # Calcul de la quantité achetée (simplifié: tout le capital disponible)
                    quantity = self.capital / current_close
                    self.position = (current_close, quantity)
                    # print(f"ACHAT @ {current_close:.2f} le {index.date()}")

            # Vérification du signal de VENTE (MA Courte coupe MA Longue par le bas)
            elif row['MA_Fast'] < row['MA_Slow']:
                # Si le bot est en position, on vend
                if self.position is not None:
                    entry_price, quantity = self.position
                    exit_price = current_close
                    
                    pnl_raw = (exit_price - entry_price) * quantity
                    pnl_percent = (exit_price / entry_price - 1) * 100
                    
                    self.capital += pnl_raw # Mise à jour du capital
                    
                    # Enregistrement du trade
                    entry_date = self.data.index[self.data['close'] == entry_price].min().date() if not np.isnan(entry_price) else index.date()
                    self.trades_log.append({
                        'Entry Date': entry_date,
                        'Exit Date': index.date(),
                        'Entry Price': entry_price,
                        'Exit Price': exit_price,
                        'PnL': pnl_raw,
                        'PnL %': pnl_percent
                    })
                    self.position = None # Fermeture de la position
                    # print(f"VENTE @ {exit_price:.2f} le {index.date()} | PnL: {pnl_raw:.2f} $")

            # Mise à jour de la courbe d'équité (même si pas de trade, pour le Drawdown)
            if self.position is not None:
                # Capital + (Gain/Perte latente)
                current_value = self.capital + (current_close - self.position[0]) * self.position[1]
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

# ==========================================
# EXÉCUTION DU SCRIPT
# ==========================================
if __name__ == "__main__":
    import os
    import sys
    import django

    # Setup Django Environment
    sys.path.append(os.getcwd())
    os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
    django.setup()
    
    # Configuration
    SYMBOL = "AAPL" 
    
    try:
        # Lancement du moteur avec 10 000 $ de capital virtuel
        # Note: on passe maintenant le SYMBOL et non le chemin du fichier
        engine = BacktestEngine(SYMBOL, initial_capital=10000.0)
        
        # Test de la stratégie (50 jours vs 200 jours)
        engine.run_strategy_macrossover(fast_period=50, slow_period=200)

    except ValueError as e:
        print(e)
    except Exception as e:
        print(f"Une erreur inattendue est survenue : {e}")
