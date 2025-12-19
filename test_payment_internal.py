import os
import django
import sys
from decimal import Decimal

# Set up Django environment
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from django.contrib.auth.models import User
from core.models import UserWallet, WalletTransaction, BrokerAccount
from core.services.payment_service import PaymentService

def test_internal_payment_flow():
    print("--- TESTING INTERNAL PAYMENT LOGIC (No Web Server) ---")
    
    # 0. Clean up
    User.objects.filter(username="testuser_payment").delete()
    
    # 1. Setup User
    user, _ = User.objects.get_or_create(username="testuser_payment")
    print(f"User: {user.username}")
    
    # 2. Initiate Deposit
    print("\n1. Initiating Deposit of 100.00 via AIRTEL...")
    tx = PaymentService.initiate_deposit(
        user=user,
        amount=Decimal("100.00"),
        method=WalletTransaction.PaymentMethod.AIRTEL,
        phone_number="0998877665"
    )
    
    if not tx:
        print("FAILED to create transaction")
        return
    
    print(f"SUCCESS: Transaction created. Method: {tx.get_payment_method_display()}, Status: {tx.status}")
    print(f"Initial Wallet Balance: {tx.wallet.balance}")
    
    # 3. Process Callback (Success)
    print(f"\n2. Processing success callback for {tx.provider_ref}...")
    tx = PaymentService.process_callback(tx.provider_ref, success=True)
    
    print(f"Transaction Status: {tx.status}")
    print(f"New Wallet Balance: {tx.wallet.balance}")
    
    if tx.status == WalletTransaction.Status.COMPLETED and tx.wallet.balance == Decimal("100.00"):
        print("✅ DEPOSIT LOGIC VERIFIED.")
    else:
        print("❌ DEPOSIT LOGIC FAILED.")
        return

    # 4. Transfer to Broker
    # Create a mock broker account
    broker, _ = BrokerAccount.objects.get_or_create(
        user=user, 
        name="Test Broker", 
        broker_type="DERIV",
        account_id="CR12345"
    )
    
    # Refresh wallet to get the balance from DB
    user.wallet.refresh_from_db()
    
    print(f"\n3. Transferring 40.00 from Wallet to Broker Account '{broker.name}'...")
    success = PaymentService.transfer_to_broker(user, Decimal("40.00"), broker.id)
    
    if success:
        user.wallet.refresh_from_db()
        broker.refresh_from_db()
        print(f"Transfer Successful!")
        print(f"Final Wallet Balance: {user.wallet.balance}")
        print(f"Final Broker Balance: {broker.balance}")
        print("✅ TRANSFER LOGIC VERIFIED.")
    else:
        print("❌ TRANSFER LOGIC FAILED.")

if __name__ == "__main__":
    test_internal_payment_flow()
