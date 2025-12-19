from core.models import Trade, Signal, Asset
import logging

logger = logging.getLogger(__name__)

class TradeService:
    @staticmethod
    def create_trade_from_signal(signal: Signal, size: float = 10.0, broker_account=None):
        """
        Creates a Trade object from a Signal and attempts execution.
        """
        if signal.signal_type == Signal.SignalType.NEUTRAL:
            return None
            
        side = Trade.Side.Buy if signal.signal_type == Signal.SignalType.BUY else Trade.Side.SELL
        
        # 1. Money Management / Risk Calculation (Placeholder)
        # TODO: Implement ATR based SL/TP or % capital
        stop_loss = 0.0 
        take_profit = 0.0
        
        # Check if we have a default broker account if none provided
        if not broker_account:
            # Pick the first active test account (safety first)
            broker_account = BrokerAccount.objects.filter(is_active=True, is_test_account=True).first()
            
        if not broker_account:
            logger.error("No active broker account found for execution.")
            return None

        trade = Trade.objects.create(
            asset=signal.asset,
            signal=signal,
            broker_account=broker_account,
            side=side,
            size=size,
            entry_price=0.0, # Will be filled by execution
            stop_loss=stop_loss,
            take_profit=take_profit,
            confidence_score=signal.confidence,
            status=Trade.Status.PENDING
        )
        
        # Trigger Execution Task immediately
        from core.tasks import execute_trade_task
        execute_trade_task.delay(trade.id)
        
        return trade

    @staticmethod
    def execute_pending_trade(trade_id):
        try:
            trade = Trade.objects.get(id=trade_id)
        except Trade.DoesNotExist:
            return False
            
        if trade.status != Trade.Status.PENDING:
            return False
            
        from core.services.broker_service import BrokerService
        return BrokerService.execute_order(trade)
