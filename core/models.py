from django.db import models
from django.contrib.auth.models import User
from django.utils.translation import gettext_lazy as _

class BrokerAccount(models.Model):
    class BrokerType(models.TextChoices):
        DERIV = 'DERIV', _('Deriv')
        ALPACA = 'ALPACA', _('Alpaca')
        BINANCE = 'BINANCE', _('Binance')
        OANDA = 'OANDA', _('Oanda')
        MT5 = 'MT5', _('MetaTrader 5')

    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='broker_accounts')
    name = models.CharField(max_length=100)
    broker_type = models.CharField(max_length=20, choices=BrokerType.choices)
    account_id = models.CharField(max_length=100)
    api_key = models.CharField(max_length=255, help_text="Encrypted API Key or Token")
    api_secret = models.CharField(max_length=255, null=True, blank=True, help_text="Encrypted Secret")
    is_active = models.BooleanField(default=True)
    is_test_account = models.BooleanField(default=True)
    balance = models.DecimalField(max_digits=20, decimal_places=4, default=0.0)
    currency = models.CharField(max_length=10, default='USD')
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.name} ({self.broker_type}) - {'TEST' if self.is_test_account else 'REAL'}"

class UserWallet(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='wallet')
    balance = models.DecimalField(max_digits=20, decimal_places=4, default=0.0)
    currency = models.CharField(max_length=10, default='USD')
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"Wallet {self.user.username} - {self.balance} {self.currency}"

class UserPreference(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='preferences')
    auto_trade = models.BooleanField(default=False, help_text="Enable AI Auto-Trading")
    min_confidence = models.FloatField(default=0.90, help_text="Minimum confidence score for auto-trading")
    max_risk_per_trade = models.DecimalField(max_digits=10, decimal_places=2, default=10.00, help_text="Max amount to risk per trade in USD")
    
    def __str__(self):
        return f"Prefs: {self.user.username} (Auto: {self.auto_trade})"

class UserProfile(models.Model):
    class KYCStatus(models.TextChoices):
        NOT_SUBMITTED = 'NOT_SUBMITTED', _('Not Submitted')
        PENDING = 'PENDING', _('Pending')
        VERIFIED = 'VERIFIED', _('Verified')
        REJECTED = 'REJECTED', _('Rejected')

    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='profile')
    full_name = models.CharField(max_length=255, null=True, blank=True)
    kyc_status = models.CharField(max_length=20, choices=KYCStatus.choices, default=KYCStatus.NOT_SUBMITTED)
    kyc_document_id = models.CharField(max_length=100, null=True, blank=True)
    country = models.CharField(max_length=100, null=True, blank=True)
    
    avatar_url = models.URLField(max_length=500, null=True, blank=True)
    
    # Gamification
    xp = models.IntegerField(default=0)
    level = models.IntegerField(default=1)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"Profile: {self.user.username} (Lvl {self.level}, KYC: {self.kyc_status})"

class Asset(models.Model):
    class AssetType(models.TextChoices):
        CRYPTO = 'CRYPTO', _('Crypto')
        FOREX = 'FOREX', _('Forex')
        STOCK = 'STOCK', _('Stock')
        INDICE = 'INDICE', _('Indice')
        SYNTHETIC = 'SYNTHETIC', _('Synthetic')

    symbol = models.CharField(max_length=20, unique=True)
    name = models.CharField(max_length=100)
    asset_type = models.CharField(max_length=20, choices=AssetType.choices)
    sector = models.CharField(max_length=100, null=True, blank=True)
    industry = models.CharField(max_length=100, null=True, blank=True)
    is_active = models.BooleanField(default=True)
    
    def __str__(self):
        return f"{self.symbol} ({self.asset_type})"

class PriceHistory(models.Model):
    """
    Stores OHLCV data.
    """
    asset = models.ForeignKey(Asset, on_delete=models.CASCADE, related_name='prices')
    datetime = models.DateTimeField() # Primary time dimension
    open = models.DecimalField(max_digits=20, decimal_places=10)
    high = models.DecimalField(max_digits=20, decimal_places=10)
    low = models.DecimalField(max_digits=20, decimal_places=10)
    close = models.DecimalField(max_digits=20, decimal_places=10)
    volume = models.DecimalField(max_digits=24, decimal_places=4, default=0)
    
    class Meta:
        unique_together = ('asset', 'datetime')
        indexes = [
            models.Index(fields=['asset', 'datetime']),
        ]
        ordering = ['-datetime']

    def __str__(self):
        return f"{self.asset.symbol} @ {self.datetime}"

class Signal(models.Model):
    class SignalType(models.TextChoices):
        BUY = 'BUY', _('Buy')
        SELL = 'SELL', _('Sell')
        NEUTRAL = 'NEUTRAL', _('Neutral')

    asset = models.ForeignKey(Asset, on_delete=models.CASCADE, related_name='signals')
    generated_at = models.DateTimeField(auto_now_add=True)
    signal_type = models.CharField(max_length=10, choices=SignalType.choices)
    confidence = models.FloatField(help_text="0.0 to 1.0")
    predicted_price = models.DecimalField(max_digits=20, decimal_places=10, null=True, blank=True)
    
    technical_indicators = models.JSONField(default=dict, help_text="RSI, MACD values at time of signal")
    model_version = models.CharField(max_length=50, default="v1")
    
    is_processed = models.BooleanField(default=False)
    
    def __str__(self):
        return f"{self.asset.symbol} {self.signal_type} ({self.confidence})"

class Trade(models.Model):
    class Side(models.TextChoices):
        BUY = 'BUY', _('Buy')
        SELL = 'SELL', _('Sell')
    
    class Status(models.TextChoices):
        PENDING = 'PENDING', _('Pending')
        OPEN = 'OPEN', _('Open')
        CLOSED = 'CLOSED', _('Closed')
        CANCELLED = 'CANCELLED', _('Cancelled')
        ERROR = 'ERROR', _('Error')

    broker_account = models.ForeignKey(BrokerAccount, on_delete=models.SET_NULL, null=True, blank=True, related_name='trades')
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='trades', null=True, blank=True)
    asset = models.ForeignKey(Asset, on_delete=models.CASCADE, related_name='trades')
    signal = models.ForeignKey(Signal, on_delete=models.SET_NULL, null=True, blank=True, related_name='trades')
    
    side = models.CharField(max_length=4, choices=Side.choices)
    entry_price = models.DecimalField(max_digits=20, decimal_places=10)
    exit_price = models.DecimalField(max_digits=20, decimal_places=10, null=True, blank=True)
    size = models.DecimalField(max_digits=20, decimal_places=10) # Amount or Quantity
    
    stop_loss = models.DecimalField(max_digits=20, decimal_places=10)
    take_profit = models.DecimalField(max_digits=20, decimal_places=10)
    
    confidence_score = models.FloatField(help_text="AI Confidence Score (0-1)")
    strategy = models.CharField(max_length=100, default="Standard")
    
    opened_at = models.DateTimeField(auto_now_add=True)
    closed_at = models.DateTimeField(null=True, blank=True)
    
    status = models.CharField(max_length=20, choices=Status.choices, default=Status.PENDING)
    pnl = models.DecimalField(max_digits=20, decimal_places=10, null=True, blank=True)
    
    broker_order_id = models.CharField(max_length=100, null=True, blank=True)
    deriv_contract_id = models.CharField(max_length=100, null=True, blank=True)
    
    error_message = models.TextField(null=True, blank=True)
    
    def __str__(self):
        return f"{self.side} {self.asset.symbol} ({self.status})"

class MarketAlert(models.Model):
    class Condition(models.TextChoices):
        ABOVE = 'ABOVE', _('Price Above')
        BELOW = 'BELOW', _('Price Below')

    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='alerts')
    asset = models.ForeignKey(Asset, on_delete=models.CASCADE)
    target_price = models.DecimalField(max_digits=20, decimal_places=10)
    condition = models.CharField(max_length=10, choices=Condition.choices)
    is_active = models.BooleanField(default=True)
    is_triggered = models.BooleanField(default=False)
    
    created_at = models.DateTimeField(auto_now_add=True)
    triggered_at = models.DateTimeField(null=True, blank=True)

    def __str__(self):
        return f"Alert: {self.asset.symbol} {self.condition} {self.target_price}"

class Notification(models.Model):
    class Type(models.TextChoices):
        INFO = 'INFO', _('Info')
        WARNING = 'WARNING', _('Warning')
        ERROR = 'ERROR', _('Error')
        SUCCESS = 'SUCCESS', _('Success')
        TRADE = 'TRADE', _('Trade Alert')

    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='notifications')
    title = models.CharField(max_length=255)
    message = models.TextField()
    notification_type = models.CharField(max_length=20, choices=Type.choices, default=Type.INFO)
    is_read = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    
    data = models.JSONField(default=dict, blank=True) # Extra data link trade_id etc.

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.title} - {self.user.username}"

class WalletTransaction(models.Model):
    class TransactionType(models.TextChoices):
        DEPOSIT = 'DEPOSIT', _('Deposit')
        WITHDRAWAL = 'WITHDRAWAL', _('Withdrawal')
        TRANSFER = 'TRANSFER', _('Transfer')
    
    class Status(models.TextChoices):
        PENDING = 'PENDING', _('Pending')
        PROCESSING = 'PROCESSING', _('Processing')
        COMPLETED = 'COMPLETED', _('Completed')
        FAILED = 'FAILED', _('Failed')

    class PaymentMethod(models.TextChoices):
        MPESA = 'MPESA', _('M-Pesa')
        AIRTEL = 'AIRTEL', _('Airtel Money')
        CARD = 'CARD', _('Credit/Debit Card')
        WALLET = 'WALLET', _('Internal Wallet')

    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='transactions')
    wallet = models.ForeignKey(UserWallet, on_delete=models.SET_NULL, null=True, blank=True, related_name='transactions')
    broker_account = models.ForeignKey(BrokerAccount, on_delete=models.SET_NULL, null=True, blank=True, related_name='transactions')
    
    amount = models.DecimalField(max_digits=20, decimal_places=4)
    transaction_type = models.CharField(max_length=20, choices=TransactionType.choices)
    payment_method = models.CharField(max_length=20, choices=PaymentMethod.choices, default=PaymentMethod.MPESA)
    status = models.CharField(max_length=20, choices=Status.choices, default=Status.PENDING)
    
    phone_number = models.CharField(max_length=20, null=True, blank=True, help_text="For Mobile Money")
    provider_ref = models.CharField(max_length=100, null=True, blank=True, unique=True)
    description = models.CharField(max_length=255, null=True, blank=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    completed_at = models.DateTimeField(null=True, blank=True)
    
    def __str__(self):
        return f"{self.transaction_type} ({self.payment_method}) - {self.amount} - {self.status}"

class StrategyProfile(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='strategy_profiles')
    name = models.CharField(max_length=100)
    is_active = models.BooleanField(default=False)
    
    # AI Confidence
    min_confidence = models.FloatField(default=0.75, help_text="0.0 to 1.0")
    
    # Technical Indicators (JSON to keep it flexible)
    # Example: {"rsi": {"enabled": true, "length": 14, "overbought": 70, "oversold": 30}, ...}
    indicators_config = models.JSONField(default=dict, blank=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.name} - {self.user.username}"

class RiskConfig(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='risk_config')
    
    risk_per_trade_percent = models.DecimalField(max_digits=5, decimal_places=2, default=2.0)
    default_stop_loss_percent = models.DecimalField(max_digits=5, decimal_places=2, default=5.0)
    default_take_profit_percent = models.DecimalField(max_digits=5, decimal_places=2, default=10.0)
    
    # Circuit Breakers
    daily_max_loss_amount = models.DecimalField(max_digits=20, decimal_places=4, default=150.0)
    daily_max_loss_is_percent = models.BooleanField(default=True)
    drawdown_threshold_percent = models.DecimalField(max_digits=5, decimal_places=2, default=15.0)
    
    # Toggles
    auto_sizing_enabled = models.BooleanField(default=True)
    risk_notifications_enabled = models.BooleanField(default=True)
    
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"RiskConfig: {self.user.username}"

class Challenge(models.Model):
    class Type(models.TextChoices):
        DEPOSIT = 'DEPOSIT', _('First Deposit')
        TRADE_COUNT = 'TRADE_COUNT', _('Trade Count Streak')
        PNL_TARGET = 'PNL_TARGET', _('PnL Target')
        VOLUME = 'VOLUME', _('Trading Volume')

    title = models.CharField(max_length=100)
    description = models.TextField()
    xp_reward = models.IntegerField(default=100)
    challenge_type = models.CharField(max_length=20, choices=Type.choices)
    target_value = models.FloatField() # e.g. 5 trades, 100 USD, 5.0 %
    
    is_active = models.BooleanField(default=True)
    icon_name = models.CharField(max_length=50, default="military_tech")

    def __str__(self):
        return self.title

class UserChallenge(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='challenges')
    challenge = models.ForeignKey(Challenge, on_delete=models.CASCADE)
    
    current_value = models.FloatField(default=0.0)
    is_completed = models.BooleanField(default=False)
    completed_at = models.DateTimeField(null=True, blank=True)
    
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        unique_together = ('user', 'challenge')

    def __str__(self):
        return f"{self.user.username} - {self.challenge.title} ({self.current_value}/{self.challenge.target_value})"

class Badge(models.Model):
    name = models.CharField(max_length=100)
    description = models.TextField()
    icon_name = models.CharField(max_length=50)
    category = models.CharField(max_length=50, default="Trading")

    def __str__(self):
        return self.name

class UserBadge(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='badges')
    badge = models.ForeignKey(Badge, on_delete=models.CASCADE)
    earned_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ('user', 'badge')

    def __str__(self):
        return f"{self.user.username} - {self.badge.name}"
