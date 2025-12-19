import os
import django
import sys

# Setup Django
sys.path.append(os.getcwd())
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from core.models import Asset, PriceHistory

def analyze():
    print("--- Current Data Distribution ---")
    assets = Asset.objects.all()
    for asset in assets:
        count = PriceHistory.objects.filter(asset=asset).count()
        last_price = PriceHistory.objects.filter(asset=asset).order_by('-datetime').first()
        print(f"Asset: {asset.symbol} ({asset.asset_type})")
        print(f"  - Price Records: {count}")
        if last_price:
            print(f"  - Latest Price: {last_price.close} at {last_price.datetime}")
        else:
            print(f"  - Latest Price: NONE")

if __name__ == "__main__":
    analyze()
