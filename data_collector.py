import os
import requests
import pandas as pd
from datetime import datetime, timedelta
from dotenv import load_dotenv

# Chargement des variables d'environnement
load_dotenv()

class MarketDataCollector:
    def __init__(self, api_provider="polygon"):
        self.api_provider = api_provider
        self.api_key = os.getenv("POLYGON_API_KEY")
        self.base_url = "https://api.polygon.io/v2/aggs/ticker"
        
        if not self.api_key:
            raise ValueError("ERREUR : La clé API Polygon n'est pas configurée dans le fichier .env")

    def fetch_historical_data(self, ticker, multiplier, timespan, from_date, to_date):
        """
        Récupère les données historiques (Bougies/Bars).
        Exemple: ticker='AAPL', multiplier=1, timespan='day' (pour D1) ou 'minute' (pour M1)
        """
        print(f"[FETCH] Connexion à Polygon.io pour récupérer {ticker} ...")
        
        # Construction de l'URL pour l'API Polygon
        # Endpoint: /v2/aggs/ticker/{stocksTicker}/range/{multiplier}/{timespan}/{from}/{to}
        url = f"{self.base_url}/{ticker}/range/{multiplier}/{timespan}/{from_date}/{to_date}"
        
        params = {
            "adjusted": "true", # Ajuster pour les splits/dividendes (CRUCIAL pour la rentabilité)
            "sort": "asc",
            "limit": 50000,
            "apiKey": self.api_key
        }

        try:
            response = requests.get(url, params=params)
            data = response.json()

            if data['status'] not in ['OK', 'DELAYED']:
                print(f"[ERROR] Erreur API : {data}")
                return None

            if 'results' not in data:
                print("[WARN] Aucune donnée trouvée pour cette période.")
                return None

            # Création du DataFrame
            df = pd.DataFrame(data['results'])
            
            # Renommer les colonnes pour standardiser (Open, High, Low, Close, Volume)
            # Polygon renvoie : v (volume), o (open), c (close), h (high), l (low), t (timestamp), n (transactions)
            df = df.rename(columns={
                't': 'timestamp',
                'o': 'open',
                'h': 'high',
                'l': 'low',
                'c': 'close',
                'v': 'volume',
                'n': 'transactions'
            })

            # Conversion du timestamp (ms) en date lisible
            df['datetime'] = pd.to_datetime(df['timestamp'], unit='ms')
            df.set_index('datetime', inplace=True)
            df.drop(columns=['timestamp'], inplace=True)

            print(f"[OK] {len(df)} bougies récupérées avec succès.")
            return df

        except Exception as e:
            print(f"[ERROR] Erreur critique lors de la requête : {e}")
            return None

    def clean_data(self, df):
        """
        Nettoyage des données pour garantir la fiabilité des tests.
        """
        if df is None: return None
        initial_count = len(df)
        
        # 1. Supprimer les doublons (arrive parfois avec les APIs)
        df = df[~df.index.duplicated(keep='first')]
        
        # 2. Supprimer les lignes avec des valeurs manquantes (NaN)
        df = df.dropna()
        
        # 3. Supprimer les bougies avec volume = 0 (marché fermé ou erreur)
        df = df[df['volume'] > 0]

        cleaned_count = len(df)
        print(f"[CLEAN] Nettoyage terminé : {initial_count - cleaned_count} lignes supprimées (doublons/erreurs).")
        
        return df

    def save_to_db(self, df, ticker, asset_type='STOCK'):
        """
        Sauvegarde les données dans la base de données Django (TimescaleDB).
        """
        from core.models import Asset, PriceHistory
        
        if df is None or df.empty:
            print("[ERROR] Pas de données à sauvegarder.")
            return

        print(f"[SAVE] Sauvegarde de {len(df)} enregistrements pour {ticker}...")

        # 1. Récupérer ou créer l'actif
        asset, created = Asset.objects.get_or_create(
            symbol=ticker,
            defaults={'name': ticker, 'asset_type': asset_type}
        )
        if created:
            print(f"[NEW] Nouvel actif créé : {asset}")

        # 2. Préparer les objets PriceHistory
        price_history_batch = []
        for index, row in df.iterrows():
            # Utiliser update_or_create est lent pour les gros volumes, 
            # ici on utilise bulk_create avec ignore_conflicts=True pour la performance
            price_history_batch.append(
                PriceHistory(
                    asset=asset,
                    datetime=index, # L'index est le datetime
                    open=row['open'],
                    high=row['high'],
                    low=row['low'],
                    close=row['close'],
                    volume=row['volume']
                )
            )

        # 3. Insertion en masse (Batch size 5000)
        try:
            PriceHistory.objects.bulk_create(
                price_history_batch, 
                batch_size=5000, 
                ignore_conflicts=True # Ignore les doublons (unique_together)
            )
            print("[OK] Sauvegarde en base de données terminée.")
            
            # 4. Trigger Alerts Check
            try:
                from core.signals import check_market_alerts
                last_price = df['close'].iloc[-1]
                check_market_alerts(asset, last_price)
                print(f"[ALERTS] Checked for {asset.symbol} at {last_price}")
            except Exception as e:
                print(f"[ALERTS ERROR] {e}")

        except Exception as e:
            print(f"[ERROR] Erreur lors de la sauvegarde DB : {e}")

# ==========================================
# EXÉCUTION DU SCRIPT
# ==========================================
if __name__ == "__main__":
    import sys
    # Setup Django Environment
    import django
    
    # Add project root to path
    sys.path.append(os.getcwd())
    os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
    django.setup()
    
    # Imports après setup Django
    from core.models import Asset, PriceHistory

    # Configuration du test
    SYMBOL = "AAPL" 
    START_DATE = "2023-01-01"
    END_DATE = datetime.now().strftime("%Y-%m-%d")
    
    # Instanciation du collecteur
    collector = MarketDataCollector()
    
    # 1. Récupération
    raw_data = collector.fetch_historical_data(SYMBOL, 1, "day", START_DATE, END_DATE)
    
    # 2. Nettoyage
    clean_df = collector.clean_data(raw_data)
    
    # 3. Sauvegarde en DB (MODIFICATION)
    collector.save_to_db(clean_df, SYMBOL)
