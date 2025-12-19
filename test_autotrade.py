import os
import django
from decimal import Decimal

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from django.contrib.auth.models import User
from core.models import Signal, Asset, UserPreference, BrokerAccount, Trade

def test_autotrade_flow():
    print("--- TESTING AUTO-TRADE BOT FLOW ---")
    
    # 1. Setup User & Preferences
    user = User.objects.first()
    if not user:
        user = User.objects.create_user(username='bot_tester', password='password123')
    
    # Create an active broker account if not exists
    broker, _ = BrokerAccount.objects.get_or_create(
        user=user, 
        name="AutoBot-Account",
        defaults={'broker_type':BrokerAccount.BrokerType.DERIV, 'api_key': 'fake_key', 'is_active': True, 'balance': 500.0}
    )
    broker.is_active = True
    broker.save()

    # Enable Auto-Trade
    prefs, _ = UserPreference.objects.get_or_create(user=user)
    prefs.auto_trade = True
    prefs.min_confidence = 0.85
    prefs.max_risk_per_trade = Decimal("25.00")
    prefs.save()
    
    print(f"User: {user.username} | Auto-Trade: {prefs.auto_trade} | Min Conf: {prefs.min_confidence}")

    # 2. Get an Asset
    asset = Asset.objects.filter(symbol="AAPL").first()
    if not asset:
        asset = Asset.objects.create(symbol="AAPL", name="Apple Inc", asset_type=Asset.AssetType.STOCK)

    # 3. Simulate a high-confidence signal
    print("\n--- Simulating AI Signal (Confidence 0.92) ---")
    sig = Signal.objects.create(
        asset=asset,
        signal_type=Signal.SignalType.BUY,
        confidence=0.92,
        predicted_price=Decimal("185.50")
    )
    print(f"Signal Created: {sig.asset.symbol} {sig.signal_type} @ {sig.confidence}")

    # 4. Verify if a Trade was automatically created
    trade = Trade.objects.filter(signal=sig).first()
    if trade:
        print(f"\n✅ SUCCESS: Trade automatically created by Bot!")
        print(f"Trade Detail: {trade.side} {trade.asset.symbol} | Size: ${trade.size} | Strategy: {trade.strategy}")
    else:
        print("\n❌ FAILURE: No trade was created.")

if __name__ == "__main__":
    test_autotrade_flow()
