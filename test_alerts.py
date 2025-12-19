import os
import django
from decimal import Decimal

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from core.models import Asset, MarketAlert, User, PriceHistory
from django.utils import timezone

def test_alerts():
    print("🚀 TESTING ALERTS SYSTEM...")
    user = User.objects.first()
    asset = Asset.objects.filter(symbol="AAPL").first()
    if not asset:
        asset = Asset.objects.create(symbol="AAPL", name="Apple Inc")
    
    # 1. Create an alert: Below 200
    alert = MarketAlert.objects.create(
        user=user,
        asset=asset,
        target_price=Decimal("190.0"),
        condition=MarketAlert.Condition.BELOW
    )
    print(f"Created alert for {asset.symbol} Below 190.0")

    # 2. Simulate price update to 185.0
    print("Updating price to 185.0...")
    ph = PriceHistory.objects.create(
        asset=asset,
        datetime=timezone.now(),
        open=Decimal("185.0"),
        high=Decimal("186.0"),
        low=Decimal("184.0"),
        close=Decimal("185.0"),
        volume=1000
    )
    
    # 3. Check if alert is triggered
    alert.refresh_from_db()
    if alert.is_triggered:
        print("✅ ALERT TRIGGERED SUCCESSFULLY!")
    else:
        print("❌ ALERT NOT TRIGGERED.")

if __name__ == "__main__":
    test_alerts()
