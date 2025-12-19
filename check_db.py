import os
import sys
import django

# Setup Django
sys.path.append(os.getcwd())
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from core.models import Asset, PriceHistory

def check():
    print(f"Total Assets: {Asset.objects.count()}")
    for asset in Asset.objects.all():
        prices = PriceHistory.objects.filter(asset=asset).count()
        print(f"Asset: {asset.symbol} ({asset.asset_type}), Prices: {prices}")

if __name__ == "__main__":
    check()
