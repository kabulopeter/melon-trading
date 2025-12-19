from core.models import BrokerAccount, Trade
import json
import random
import logging
import asyncio
import websockets
from django.conf import settings

logger = logging.getLogger(__name__)

class BrokerService:
    @staticmethod
    def execute_order(trade: Trade):
        """
        Routes the trade to the correct broker implementation.
        """
        account = trade.broker_account
        if not account:
            logger.warning(f"No broker account for trade {trade.id}")
            return False
            
        try:
            # DEMO MODE: If no API key or name contains MOCK, simulate success
            if not account.api_key or "MOCK" in account.name.upper():
                logger.info(f"🕶️ MOCK EXECUTION for {trade.asset.symbol}")
                trade.broker_order_id = f"mock_{random.randint(1000, 9999)}"
                trade.status = Trade.Status.OPEN
                trade.save()
                return True

            if account.broker_type == BrokerAccount.BrokerType.DERIV:
                return BrokerService._execute_deriv(account, trade)
            elif account.broker_type == BrokerAccount.BrokerType.ALPACA:
                return BrokerService._execute_alpaca(account, trade)
        except Exception as e:
            logger.error(f"Broker execution failed: {e}")
            trade.status = Trade.Status.ERROR
            trade.error_message = str(e)
            trade.save()
            return False
        
        return False

    @staticmethod
    def _execute_deriv(account, trade):
        """
        Execute trade on Deriv using WebSocket.
        Note: This runs an async loop synchronously.
        """
        token = account.api_key
        # Deriv specific logic
        signal = {
            'symbol': trade.asset.symbol,
            'side': trade.side.lower(),
            'amount': float(trade.size),
            'sl_price': float(trade.stop_loss) if trade.stop_loss else None,
            'tp_price': float(trade.take_profit) if trade.take_profit else None
        }

        async def run_deriv():
            uri = "wss://ws.binaryws.com/websockets/v3?app_id=1089" # Use App ID from env ideally
            async with websockets.connect(uri) as websocket:
                # Auth
                await websocket.send(json.dumps({"authorize": token}))
                auth_res = json.loads(await websocket.recv())
                if 'error' in auth_res:
                    raise Exception(f"Deriv Auth Error: {auth_res['error']['message']}")
                
                # Buy/Sell
                req = {
                    "buy": 1,
                    "price": signal['amount'],
                    "parameters": dict(
                         amount=1, 
                         basis="stake", 
                         contract_type="CALL" if signal['side'] == 'buy' else "PUT", 
                         currency="USD", 
                         symbol=signal['symbol'], 
                         duration=1, 
                         duration_unit="m" # Default 1m for demo
                    )
                }
                
                await websocket.send(json.dumps(req))
                res = json.loads(await websocket.recv())
                if 'error' in res:
                    raise Exception(f"Deriv Order Error: {res['error']['message']}")
                
                return res

        # Run async code
        try:
            loop = asyncio.new_event_loop()
            asyncio.set_event_loop(loop)
            result = loop.run_until_complete(run_deriv())
            loop.close()
            
            if result and 'buy' in result:
                trade.broker_order_id = result['buy']['contract_id']
                trade.status = Trade.Status.OPEN
                trade.save()
                logger.info(f"Deriv Trade Executed: {trade.broker_order_id}")
                return True
        except Exception as e:
            logger.error(f"Deriv Async Error: {e}")
            raise e

        return False

    @staticmethod
    def _execute_alpaca(account, trade):
        import alpaca_trade_api as tradeapi
        
        api = tradeapi.REST(account.api_key, account.api_secret, "https://paper-api.alpaca.markets", api_version='v2')
        
        try:
            qty = float(trade.size)
            
            order = api.submit_order(
                symbol=trade.asset.symbol,
                qty=qty, 
                side=trade.side.lower(),
                type='market',
                time_in_force='gtc'
            )
            
            trade.broker_order_id = order.id
            trade.status = Trade.Status.OPEN
            trade.save()
            logger.info(f"Alpaca Trade Executed: {order.id}")
            return True
            
        except Exception as e:
            logger.error(f"Alpaca Error: {e}")
            raise e
