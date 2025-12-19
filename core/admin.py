from django.contrib import admin
from .models import Asset, PriceHistory, Trade

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
