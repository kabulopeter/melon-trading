from celery import shared_task
from datetime import datetime, timedelta
from data_collector import MarketDataCollector
import logging

logger = logging.getLogger(__name__)

@shared_task(queue='data_collection')
def collect_market_data(symbol="AAPL", days=1):
    """
    Tâche Celery pour collecter les données de marché quotidiennes.
    """
    logger.info(f"🚀 Démarrage de la tâche de collecte pour {symbol}")
    
    try:
        from .models import Asset
        # Choix du collecteur
        use_alpaca = False
        try:
            asset = Asset.objects.get(symbol=symbol)
            if asset.asset_type == Asset.AssetType.STOCK:
                use_alpaca = True
        except Asset.DoesNotExist:
            # Si l'actif n'existe pas, on suppose Polygon par défaut, 
            # sauf si on a une logique de détection plus avancée.
            pass

        if use_alpaca:
             from alpaca_data_collector import AlpacaDataCollector
             collector = AlpacaDataCollector()
             logger.info(f"🇺🇸 Using Alpaca Data for {symbol}")
        else:
             collector = MarketDataCollector()
        end_date = datetime.now()
        start_date = end_date - timedelta(days=days)
        
        # Formatage dates
        start_str = start_date.strftime("%Y-%m-%d")
        end_str = end_date.strftime("%Y-%m-%d")
        
        # 1. Fetch
        logger.info(f"Fetching data from {start_str} to {end_str}")
        df = collector.fetch_historical_data(symbol, 1, "day", start_str, end_str)
        
        # 2. Clean
        df = collector.clean_data(df)
        
        # 3. Save
        collector.save_to_db(df, symbol)
        
        logger.info(f"✅ Tâche terminée avec succès pour {symbol}")
        return f"Collected {len(df) if df is not None else 0} records for {symbol}"

    except Exception as e:
        logger.error(f"❌ Erreur dans la tâche de collecte : {e}")
        logger.error(f"❌ Erreur dans la tâche de collecte : {e}")
        return f"Error: {e}"

@shared_task(queue='trading')
def execute_trade_task(trade_id):
    """
    Exécute un trade via TradeService.
    """
    logger.info(f"⚙️ Traitement du Trade ID: {trade_id}")
    
    from core.services.trade_service import TradeService
    success = TradeService.execute_pending_trade(trade_id)
    
    if success:
        logger.info(f"✅ Trade {trade_id} execution started successfully.")
    else:
        logger.warning(f"⚠️ Trade {trade_id} execution failed or not pending.")

@shared_task(queue='strategy')
def analyze_market_trends():
    """
    Periodic task to analyze all active assets using the new AI Prediction Service.
    """
    from .models import Asset
    from ai_prediction.services import PredictionService
    
    logger.info("🧠 Starting AI Market Analysis...")
    active_assets = Asset.objects.filter(is_active=True)
    
    results = []
    for asset in active_assets:
        try:
            signal = PredictionService.run_prediction(asset.symbol)
            if signal:
                logger.info(f"AI signal generated for {asset.symbol}: {signal.signal_type} ({signal.confidence*100:.1f}%)")
                results.append(asset.symbol)
        except Exception as e:
            logger.error(f"Error in AI prediction for {asset.symbol}: {e}")
            
    return f"AI Analyzed {len(active_assets)} assets. Signals updated for: {', '.join(results)}"

@shared_task(queue='strategy')
def run_system_update():
    """
    Master task to fetch fresh data for all assets and then run AI predictions.
    """
    from .models import Asset
    from .tasks import collect_market_data
    from ai_prediction.services import PredictionService
    
    logger.info("🔄 Starting System-Wide Data Update & AI Prediction...")
    active_assets = Asset.objects.filter(is_active=True)
    
    for asset in active_assets:
        # 1. Collect fresh data (last 1 day)
        collect_market_data.delay(asset.symbol, days=1)
        
        # 2. Prediction will be naturally fresher as collect_market_data is async,
        # but for a strict sequence we could chain them.
        # For simplicity in this demo, we run them in parallel or sequence.
        # We'll call run_prediction directly after for each asset.
        try:
            PredictionService.run_prediction(asset.symbol)
        except Exception as e:
            logger.error(f"Post-update prediction failed for {asset.symbol}: {e}")
            
    return f"Update triggered for {active_assets.count()} assets."
