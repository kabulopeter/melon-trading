from django.db import models
from django.utils.translation import gettext_lazy as _
from core.models import Asset

class AIModelMetadata(models.Model):
    class ModelType(models.TextChoices):
        LSTM = 'LSTM', _('Long Short-Term Memory')
        GRU = 'GRU', _('Gated Recurrent Unit')
        RF = 'RF', _('Random Forest')
        XGB = 'XGBOOST', _('XGBoost')

    name = models.CharField(max_length=100)
    model_type = models.CharField(max_length=20, choices=ModelType.choices)
    version = models.CharField(max_length=20, default="1.0.0")
    asset_type = models.CharField(max_length=20, null=True, blank=True) # CRYPTO, FOREX, etc.
    
    accuracy = models.FloatField(null=True, blank=True)
    last_trained = models.DateTimeField(auto_now=True)
    is_active = models.BooleanField(default=True)
    
    file_path = models.CharField(max_length=255, null=True, blank=True, help_text="Path to saved model weights")

    def __str__(self):
        return f"{self.name} ({self.version}) - {self.model_type}"
