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
    If Auto-Trade is enabled, it automatically takes positions.
    """
    from .models import Asset, UserPreference, Trade
    from .tasks import collect_market_data
    from ai_prediction.services import PredictionService
    from django.contrib.auth.models import User
    
    logger.info("🔄 Starting System-Wide Data Update & AI Prediction...")
    active_assets = Asset.objects.filter(is_active=True)
    
    # Global Demo User for now
    user = User.objects.first()
    prefs, _ = UserPreference.objects.get_or_create(user=user)
    
    for asset in active_assets:
        # 1. Collect fresh data (last 1 day)
        collect_market_data.delay(asset.symbol, days=1)
        
        # 2. Run Prediction
        try:
            signal = PredictionService.run_prediction(asset.symbol)
            
            # 3. Auto-Trading Logic
            if prefs.auto_trade and signal:
                if signal.confidence >= prefs.min_confidence:
                    logger.info(f"🤖 AUTO-TRADE: HIGH CONFIDENCE ({signal.confidence*100:.1f}%) for {asset.symbol}")
                    
                    # Prevent duplicate trades if one is already open for this asset
                    existing_trade = Trade.objects.filter(user=user, asset=asset, status=Trade.Status.OPEN).exists()
                    if not existing_trade:
                        Trade.objects.create(
                            user=user,
                            asset=asset,
                            signal=signal,
                            side=signal.signal_type,
                            entry_price=signal.technical_indicators.get('current_price', 0),
                            size=1.0,
                            stop_loss=float(signal.technical_indicators.get('current_price', 0)) * 0.95,
                            take_profit=float(signal.technical_indicators.get('current_price', 0)) * 1.10,
                            confidence_score=signal.confidence,
                            status=Trade.Status.OPEN,
                            strategy="AI_AUTO_V1"
                        )
                        logger.info(f"🚀 AUTO-TRADE: Position OPENED for {asset.symbol}")
                    else:
                        logger.info(f"⏭️ AUTO-TRADE: Position already open for {asset.symbol}, skipping.")
                        
        except Exception as e:
            logger.error(f"Post-update prediction failed for {asset.symbol}: {e}")
            
    return f"Update & Auto-Trade triggered for {active_assets.count()} assets."
