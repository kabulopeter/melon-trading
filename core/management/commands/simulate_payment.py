from django.core.management.base import BaseCommand
from core.models import WalletTransaction
from core.services.payment_service import PaymentService

class Command(BaseCommand):
    help = 'Simulates a successful payment callback for a pending transaction'

    def add_arguments(self, parser):
        parser.add_argument('ref', type=str, help='Transaction reference (TX-...)')

    def handle(self, *args, **options):
        ref = options['ref']
        self.stdout.write(f"Simulating callback for {ref}...")
        
        # Try to find by provider_ref first, then phone_number if it's a number
        try:
            tx = WalletTransaction.objects.get(provider_ref=ref)
        except WalletTransaction.DoesNotExist:
            tx = WalletTransaction.objects.filter(phone_number=ref, status=WalletTransaction.Status.PENDING).first()

        if not tx:
            self.stdout.write(self.style.ERROR(f"No pending transaction found for {ref}"))
            return

        tx = PaymentService.process_callback(tx.provider_ref, success=True)
        
        if tx and tx.status == WalletTransaction.Status.COMPLETED:
            self.stdout.write(self.style.SUCCESS(f"Successfully completed transaction {tx.provider_ref}!"))
            self.stdout.write(f"New Wallet Balance: {tx.wallet.balance}")
        else:
            self.stdout.write(self.style.ERROR(f"Failed to process callback for {tx.provider_ref}"))
