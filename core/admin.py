from django.contrib import admin
from .models import (
    Asset, PriceHistory, Trade, Signal, UserWallet, WalletTransaction, 
    UserProfile, StrategyProfile, RiskConfig, Challenge, Badge, 
    UserChallenge, UserBadge
)

@admin.register(Asset)
class AssetAdmin(admin.ModelAdmin):
    list_display = ('symbol', 'name', 'asset_type', 'is_active')
    list_filter = ('asset_type', 'is_active')
    search_fields = ('symbol', 'name')

@admin.register(PriceHistory)
class PriceHistoryAdmin(admin.ModelAdmin):
    list_display = ('asset', 'datetime', 'close', 'volume')
    list_filter = ('asset',)
    date_hierarchy = 'datetime'

@admin.register(Trade)
class TradeAdmin(admin.ModelAdmin):
    list_display = ('side', 'asset', 'entry_price', 'status', 'pnl', 'confidence_score', 'opened_at')
    list_filter = ('side', 'status', 'asset')
    date_hierarchy = 'opened_at'
    search_fields = ('asset__symbol', 'deriv_contract_id')

@admin.register(UserProfile)
class UserProfileAdmin(admin.ModelAdmin):
    list_display = ('user', 'full_name', 'kyc_status', 'level', 'xp')
    list_filter = ('kyc_status', 'level')

@admin.register(StrategyProfile)
class StrategyProfileAdmin(admin.ModelAdmin):
    list_display = ('name', 'user', 'is_active', 'min_confidence')
    list_filter = ('is_active',)

@admin.register(RiskConfig)
class RiskConfigAdmin(admin.ModelAdmin):
    list_display = ('user', 'risk_per_trade_percent', 'daily_max_loss_amount')

@admin.register(Challenge)
class ChallengeAdmin(admin.ModelAdmin):
    list_display = ('title', 'challenge_type', 'target_value', 'xp_reward', 'is_active')

@admin.register(Badge)
class BadgeAdmin(admin.ModelAdmin):
    list_display = ('name', 'category', 'icon_name')

@admin.register(UserChallenge)
class UserChallengeAdmin(admin.ModelAdmin):
    list_display = ('user', 'challenge', 'current_value', 'is_completed')
    list_filter = ('is_completed', 'challenge')

@admin.register(UserBadge)
class UserBadgeAdmin(admin.ModelAdmin):
    list_display = ('user', 'badge', 'earned_at')
