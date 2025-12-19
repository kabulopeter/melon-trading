from rest_framework import serializers
from drf_spectacular.utils import extend_schema_field
from .models import (
    Asset, PriceHistory, Trade, Signal, UserWallet, WalletTransaction, UserPreference, UserProfile,
    MarketAlert
)

class MarketAlertSerializer(serializers.ModelSerializer):
    asset_symbol = serializers.ReadOnlyField(source='asset.symbol')
    
    class Meta:
        model = MarketAlert
        fields = ['id', 'asset', 'asset_symbol', 'target_price', 'condition', 'is_active', 'is_triggered', 'created_at']
        read_only_fields = ['id', 'is_triggered', 'created_at']

class UserProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserProfile
        fields = ['full_name', 'kyc_status', 'kyc_document_id', 'country', 'avatar_url']
        read_only_fields = ['kyc_status']

class UserPreferenceSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserPreference
        fields = ['auto_trade', 'min_confidence', 'max_risk_per_trade']

class AssetSerializer(serializers.ModelSerializer):
    last_price = serializers.SerializerMethodField()

    class Meta:
        model = Asset
        fields = ['id', 'symbol', 'name', 'asset_type', 'is_active', 'last_price']
        read_only_fields = ['id']


    @extend_schema_field(serializers.FloatField(allow_null=True))
    def get_last_price(self, obj):
        last_history = obj.prices.order_by('-datetime').first()
        if last_history:
            return float(last_history.close)
        return None # No data

class PriceHistorySerializer(serializers.ModelSerializer):
    class Meta:
        model = PriceHistory
        fields = ['datetime', 'open', 'high', 'low', 'close', 'volume']
        # Datetime is read-only here as it's usually historical data
        read_only_fields = ['datetime', 'open', 'high', 'low', 'close', 'volume']

class TradeSerializer(serializers.ModelSerializer):
    asset = serializers.PrimaryKeyRelatedField(queryset=Asset.objects.all())

    class Meta:
        model = Trade
        fields = [
            'id', 'asset', 'side', 'status', 
            'entry_price', 'exit_price', 'size', 
            'stop_loss', 'take_profit', 'pnl', 
            'confidence_score', 'opened_at', 'closed_at', 
            'deriv_contract_id'
        ]

class SignalSerializer(serializers.ModelSerializer):
    class Meta:
        model = Signal
        fields = ['id', 'asset', 'generated_at', 'signal_type', 'confidence', 'predicted_price', 'technical_indicators']
        read_only_fields = ['id', 'generated_at']

class UserWalletSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserWallet
        fields = ['id', 'balance', 'currency', 'updated_at']

class WalletTransactionSerializer(serializers.ModelSerializer):
    class Meta:
        model = WalletTransaction
        fields = '__all__'

class DepositRequestSerializer(serializers.Serializer):
    amount = serializers.DecimalField(max_digits=20, decimal_places=4)
    payment_method = serializers.ChoiceField(choices=WalletTransaction.PaymentMethod.choices)
    phone_number = serializers.CharField(max_length=20)

class TransferRequestSerializer(serializers.Serializer):
    amount = serializers.DecimalField(max_digits=20, decimal_places=4)
    broker_account_id = serializers.IntegerField()
