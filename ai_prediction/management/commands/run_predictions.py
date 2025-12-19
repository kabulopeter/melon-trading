from django.core.management.base import BaseCommand
from ai_prediction.services import PredictionService
from core.models import Asset
import logging

logger = logging.getLogger(__name__)

class Command(BaseCommand):
    help = 'Runs AI predictions for all active assets'

    def handle(self, *args, **options):
        self.stdout.write("Starting AI Prediction Process...")
        
        assets = Asset.objects.filter(is_active=True)
        if not assets.exists():
            self.stdout.write(self.style.WARNING("No active assets found."))
            return

        for asset in assets:
            self.stdout.write(f"Analyzing {asset.symbol}...")
            try:
                signal = PredictionService.run_prediction(asset.symbol)
                if signal:
                    self.stdout.write(self.style.SUCCESS(
                        f"SUCCESS: Generated {signal.signal_type} for {asset.symbol} "
                        f"(Confidence: {signal.confidence*100:.1f}%)"
                    ))
                else:
                    self.stdout.write(self.style.WARNING(f"SKIP: No signal for {asset.symbol}"))
            except Exception as e:
                self.stdout.write(self.style.ERROR(f"ERROR: Failed predicting {asset.symbol}: {e}"))
        
        self.stdout.write(self.style.SUCCESS("AI Prediction Process Finished."))
