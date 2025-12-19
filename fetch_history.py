import os
import sys
import django
from datetime import datetime, timedelta

# Setup Django
sys.path.append(os.getcwd())
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from alpaca_data_collector import AlpacaDataCollector

def run():
    print("🚀 Démarrage de la récupération d'historique (1 An) ...")
    
    collector = AlpacaDataCollector()
    symbol = "AAPL"
    end_date = datetime.now().strftime("%Y-%m-%d")
    start_date = (datetime.now() - timedelta(days=365)).strftime("%Y-%m-%d")
    
    print(f"📅 Période : {start_date} -> {end_date}")
    
    # Nettoyage des données existantes (pour éviter le mélange Synthétique/Réel)
    from core.models import Asset, PriceHistory
    try:
        aapl = Asset.objects.get(symbol=symbol)
        PriceHistory.objects.filter(asset=aapl).delete()
        print(f"🧹 Anciennes données pour {symbol} supprimées.")
    except Asset.DoesNotExist:
        pass

    df = collector.fetch_historical_data(symbol, "1Day", start_date, end_date)
    
    if df is not None and not df.empty:
        collector.save_to_db(df, symbol)
        print("✅ Données sauvegardées avec succès.")
    else:
        print("❌ Echec de récupération des données.")

if __name__ == "__main__":
    run()
