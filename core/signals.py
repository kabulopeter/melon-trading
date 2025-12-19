from django.db.models.signals import post_save
from django.dispatch import receiver
from .models import Trade, WalletTransaction, Signal, UserPreference, BrokerAccount, PriceHistory
from .tasks import execute_trade_task
from asgiref.sync import async_to_sync
from channels.layers import get_channel_layer
from decimal import Decimal
import logging

logger = logging.getLogger(__name__)

@receiver(post_save, sender=Trade)
def trigger_trade_execution(sender, instance, created, **kwargs):
    """
    Déclenche l'exécution d'un trade via Celery lorsque celui-ci est créé avec le statut PENDING.
    """
    if created and instance.status == Trade.Status.PENDING:
        logger.info(f"⚡ Signal reçu pour le trade {instance.id} ({instance.asset.symbol}). Déclenchement de l'exécution async.")
        # Appel de la tâche Celery
        execute_trade_task.delay(instance.id)

@receiver(post_save, sender=WalletTransaction)
def notify_payment_status(sender, instance, created, **kwargs):
    """
    Notifie le WebSocket du tableau de bord lorsqu'une transaction change de statut.
    """
    if not created and instance.status == WalletTransaction.Status.COMPLETED:
        channel_layer = get_channel_layer()
        message = {
            "title": "Paiement Réussi",
            "body": f"Votre dépôt de {instance.amount} {instance.wallet.currency} via {instance.payment_method} a été confirmé.",
            "type": "PAYMENT_SUCCESS",
            "amount": str(instance.amount)
        }
        
        try:
            async_to_sync(channel_layer.group_send)(
                "dashboard_updates",
                {
                    "type": "dashboard_message",
                    "message": message
                }
            )
        except Exception as e:
            logger.warning(f"Could not send notification: {e}")
        logger.info(f"🔔 Notification de paiement envoyée pour {instance.provider_ref}")

@receiver(post_save, sender=Signal)
def notify_new_signal(sender, instance, created, **kwargs):
    """
    Notifie le UI en temps réel lors de l'arrivée d'un nouveau signal.
    """
    if created:
        channel_layer = get_channel_layer()
        message = {
            "title": f"Nouveau Signal: {instance.asset.symbol}",
            "body": f"Signal {instance.signal_type} détecté avec une confiance de {int(instance.confidence * 100)}%.",
            "type": "NEW_SIGNAL",
            "symbol": instance.asset.symbol,
            "side": instance.signal_type,
            "confidence": instance.confidence
        }
        
        try:
            async_to_sync(channel_layer.group_send)(
                "dashboard_updates",
                {
                    "type": "dashboard_message",
                    "message": message
                }
            )
        except Exception as e:
            logger.warning(f"Could not send WebSocket notification: {e}")
        
        logger.info(f"📡 Signal envoyé au WebSocket pour {instance.asset.symbol}")

        # --- AUTO-TRADING LOGIC ---
        # Get users with auto-trade enabled for this confidence level
        auto_trade_prefs = UserPreference.objects.filter(
            auto_trade=True, 
            min_confidence__lte=instance.confidence
        )

        for pref in auto_trade_prefs:
            user = pref.user
            # Get an active broker account for this user
            broker = BrokerAccount.objects.filter(user=user, is_active=True).first()
            if not broker:
                logger.warning(f"Auto-trade failed for {user.username}: No active broker account.")
                continue

            # Create the trade
            new_trade = Trade.objects.create(
                user=user,
                broker_account=broker,
                asset=instance.asset,
                signal=instance,
                side=instance.signal_type, # BUY/SELL match
                entry_price=instance.predicted_price or instance.asset.last_price or Decimal('0'),
                size=pref.max_risk_per_trade,
                stop_loss=(instance.predicted_price or instance.asset.last_price or Decimal('0')) * Decimal('0.95'), # Simple SL
                take_profit=(instance.predicted_price or instance.asset.last_price or Decimal('0')) * Decimal('1.10'), # Simple TP
                confidence_score=instance.confidence,
                status=Trade.Status.PENDING,
                strategy="AI-Bot Auto-Trade"
            )
            logger.info(f"🤖 Auto-Trade EXECUTED for {user.username}: {new_trade.side} {instance.asset.symbol}")
            
            # Notify user about auto-execution
            try:
                async_to_sync(channel_layer.group_send)(
                    "dashboard_updates",
                    {
                        "type": "dashboard_message",
                        "message": {
                            "title": "Auto-Trade Exécuté 🤖",
                            "body": f"L'IA a passé un ordre {new_trade.side} pour {instance.asset.symbol} automatiquement.",
                            "type": "AUTO_TRADE_EXECUTED",
                            "trade_id": new_trade.id
                        }
                    }
                )
            except Exception as e:
                logger.warning(f"Could not send auto-trade notification: {e}")

@receiver(post_save, sender=PriceHistory)
def check_price_alerts(sender, instance, created, **kwargs):
    if created:
        check_market_alerts(instance.asset, instance.close)

def check_market_alerts(asset, current_price):
    from core.models import MarketAlert, Notification
    from decimal import Decimal
    
    current_price = Decimal(str(current_price))
    alerts = MarketAlert.objects.filter(asset=asset, is_active=True, is_triggered=False)
    
    for alert in alerts:
        triggered = False
        if alert.condition == MarketAlert.Condition.ABOVE and current_price >= alert.target_price:
            triggered = True
        elif alert.condition == MarketAlert.Condition.BELOW and current_price <= alert.target_price:
            triggered = True
            
        if triggered:
            alert.is_triggered = True
            alert.is_active = False
            from django.utils import timezone
            alert.triggered_at = timezone.now()
            alert.save()
            
            # Send notification
            message = f"🔔 Alerte: {asset.symbol} a atteint {current_price} (Cible: {alert.target_price})"
            Notification.objects.create(
                user=alert.user,
                title="Alerte de Prix",
                message=message,
                notification_type=Notification.Type.SUCCESS
            )
            
            # Push via WebSocket
            try:
                from channels.layers import get_channel_layer
                from asgiref.sync import async_to_sync
                channel_layer = get_channel_layer()
                if channel_layer:
                    async_to_sync(channel_layer.group_send)(
                        f"user_notifications_{alert.user.id}",
                        {
                            "type": "notification_update",
                            "data": {
                                "id": alert.id,
                                "title": "Alerte de Prix",
                                "message": message,
                                "type": "ALERT_TRIGGERED"
                            }
                        }
                    )
            except Exception as e:
                print(f"WS Alert Error: {e}")
