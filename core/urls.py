from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import (
    AssetViewSet, PriceHistoryViewSet, TradeViewSet, 
    WalletViewSet, PreferenceViewSet, ProfileViewSet,
    AnalyticsViewSet, AlertViewSet, ChallengeViewSet,
    BadgeViewSet, StrategyProfileViewSet, RiskConfigViewSet
)
from .views_broker import BrokerViewSet

router = DefaultRouter()
router.register(r'assets', AssetViewSet)
router.register(r'prices', PriceHistoryViewSet)
router.register(r'trades', TradeViewSet)
router.register(r'wallet', WalletViewSet, basename='wallet')
router.register(r'preferences', PreferenceViewSet, basename='preferences')
router.register(r'profile', ProfileViewSet, basename='profile')
router.register(r'brokers', BrokerViewSet, basename='brokers')
router.register(r'analytics', AnalyticsViewSet, basename='analytics')
router.register(r'alerts', AlertViewSet, basename='alerts')
router.register(r'challenges', ChallengeViewSet, basename='challenges')
router.register(r'badges', BadgeViewSet, basename='badges')
router.register(r'strategies', StrategyProfileViewSet, basename='strategies')
router.register(r'risk-config', RiskConfigViewSet, basename='risk-config')

urlpatterns = [
    path('', include(router.urls)),
]
