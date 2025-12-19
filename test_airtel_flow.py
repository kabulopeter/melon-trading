import os
import django
import sys
from decimal import Decimal

# Set up Django environment
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from django.contrib.auth.models import User
from core.models import UserWallet, WalletTransaction
from core.services.payment_service import PaymentService

def test_airtel_money_flow():
    print("--- TESTING AIRTEL MONEY PAYMENT FLOW ---")
    
    # 1. Setup User
    user, _ = User.objects.get_or_create(username="testuser_airtel")
    print(f"User: {user.username}")
    
    # Clean up previous transactions for this test
    WalletTransaction.objects.filter(user=user).delete()
    if hasattr(user, 'wallet'):
        user.wallet.balance = Decimal("0.00")
        user.wallet.save()
    else:
        UserWallet.objects.create(user=user, balance=Decimal("0.00"))

    # 2. Initiate Deposit via Airtel
    print("\n1. Initiating Deposit of 75.00 via AIRTEL MONEY...")
    tx = PaymentService.initiate_deposit(
        user=user,
        amount=Decimal("75.00"),
        method=WalletTransaction.PaymentMethod.AIRTEL,
        phone_number="0970001122"
    )
    
    if not tx:
        print("FAILED to create transaction")
        return
    
    print(f"SUCCESS: Transaction created. Method: {tx.get_payment_method_display()}")
    print(f"Provider Ref: {tx.provider_ref}")
    print(f"Current Status: {tx.status}")

    # 3. Simulate PIN entry and success callback
    print(f"\n2. Simulating Airtel Money success callback for {tx.provider_ref}...")
    tx_final = PaymentService.process_callback(tx.provider_ref, success=True)
    
    if tx_final.status == WalletTransaction.Status.COMPLETED:
        print(f"Transaction Result: {tx_final.status}")
        print(f"New Wallet Balance: {tx_final.wallet.balance} USD")
        print("\n✅ AIRTEL MONEY INTEGRATION VERIFIED!")
    else:
        print("\n❌ AIRTEL MONEY FLOW FAILED.")

if __name__ == "__main__":
    test_airtel_money_flow()
