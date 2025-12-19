import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from core.models import WalletTransaction

def list_transactions():
    txs = WalletTransaction.objects.all().order_by('-created_at')[:10]
    print(f"{'ID'} | {'Ref'} | {'Status'} | {'Type'} | {'Phone'} | {'Amount'}")
    print("-" * 85)
    for tx in txs:
        ref = str(tx.provider_ref) if tx.provider_ref else "None"
        phone = str(tx.phone_number) if tx.phone_number else "None"
        print(f"{tx.id} | {ref} | {tx.status} | {tx.transaction_type} | {phone} | {tx.amount}")

if __name__ == "__main__":
    list_transactions()
