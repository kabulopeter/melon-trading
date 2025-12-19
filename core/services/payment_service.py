import logging
import uuid
from decimal import Decimal
from django.utils import timezone
from core.models import WalletTransaction, UserWallet, BrokerAccount

logger = logging.getLogger(__name__)

class PaymentService:
    @staticmethod
    def initiate_deposit(user, amount, method, phone_number):
        """
        Initiates a deposit via M-Pesa or Airtel Money.
        In real world, this would call the provider's API for Push USSD.
        """
        try:
            # 1. Get or Create Wallet
            wallet, created = UserWallet.objects.get_or_create(user=user)
            
            # 2. Create Transaction record with unique reference
            tx_ref = f"TX-{method}-{uuid.uuid4().hex[:8].upper()}"
            
            transaction = WalletTransaction.objects.create(
                user=user,
                wallet=wallet,
                amount=amount,
                transaction_type=WalletTransaction.TransactionType.DEPOSIT,
                payment_method=method,
                status=WalletTransaction.Status.PENDING,
                phone_number=phone_number,
                provider_ref=tx_ref,
                description=f"Dépôt via {method}"
            )
            
            # 3. Simulation of API Call to Provider
            logger.info(f"Initiating {method} Push for {phone_number} - Amount: {amount}")
            # simulate_provider_callback(transaction.id) # In real world, the callback comes later
            
            return transaction
        except Exception as e:
            logger.error(f"Deposit Error: {e}")
            return None

    @staticmethod
    def process_callback(provider_ref, success=True, external_id=None):
        """
        Simulates the response from M-Pesa/Airtel after user enters PIN.
        """
        try:
            tx = WalletTransaction.objects.get(provider_ref=provider_ref)
            if tx.status != WalletTransaction.Status.PENDING:
                return tx

            if success:
                tx.status = WalletTransaction.Status.COMPLETED
                tx.completed_at = timezone.now()
                if external_id:
                    tx.provider_ref = external_id # Update with real provider ID if needed
                
                # Update User Wallet Balance
                wallet = tx.wallet
                wallet.balance += Decimal(str(tx.amount))
                wallet.save()
                
                logger.info(f"Transaction {provider_ref} SUCCEEDED. New Balance: {wallet.balance}")
            else:
                tx.status = WalletTransaction.Status.FAILED
                logger.warning(f"Transaction {provider_ref} FAILED by provider.")
            
            tx.save()
            return tx
        except WalletTransaction.DoesNotExist:
            logger.error(f"Callback Error: Transaction {provider_ref} not found.")
            return None

    @staticmethod
    def transfer_to_broker(user, amount, broker_account_id):
        """
        Transfers funds from User Wallet to a specific Broker Account.
        """
        try:
            wallet = user.wallet
            if wallet.balance < Decimal(str(amount)):
                raise ValueError("Solde insuffisant dans le portefeuille.")

            broker = BrokerAccount.objects.get(id=broker_account_id, user=user)
            
            # Atomic swap (simplified)
            wallet.balance -= Decimal(str(amount))
            wallet.save()
            
            broker.balance += Decimal(str(amount))
            broker.save()
            
            # Log Transaction
            WalletTransaction.objects.create(
                user=user,
                wallet=wallet,
                broker_account=broker,
                amount=amount,
                transaction_type=WalletTransaction.TransactionType.TRANSFER,
                payment_method=WalletTransaction.PaymentMethod.WALLET,
                status=WalletTransaction.Status.COMPLETED,
                description=f"Transfert vers {broker.name}",
                completed_at=timezone.now()
            )
            return True
        except Exception as e:
            logger.error(f"Transfer Error: {e}")
            return False

    @staticmethod
    def initiate_withdrawal(user, amount, method, phone_number):
        """
        Initiates a withdrawal from Wallet to Mobile Money.
        Check balance first.
        """
        try:
            wallet = user.wallet
            if wallet.balance < Decimal(str(amount)):
                raise ValueError("Solde insuffisant pour le retrait.")
                
            tx_ref = f"WD-{method}-{uuid.uuid4().hex[:8].upper()}"
            
            # Logic: Deduct balance first (Block funds)
            wallet.balance -= Decimal(str(amount))
            wallet.save()
            
            transaction = WalletTransaction.objects.create(
                user=user,
                wallet=wallet,
                amount=amount,
                transaction_type=WalletTransaction.TransactionType.WITHDRAWAL,
                payment_method=method,
                status=WalletTransaction.Status.PROCESSING,
                phone_number=phone_number,
                provider_ref=tx_ref,
                description=f"Retrait vers {method} {phone_number}"
            )
            
            logger.info(f"Initiating {method} Withdrawal for {phone_number} - Amount: {amount}")
            # Call provider B2C API here
            
            return transaction
        except Exception as e:
            logger.error(f"Withdrawal Error: {e}")
            return None
