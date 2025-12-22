from rest_framework import viewsets, permissions, filters
from rest_framework.decorators import action
from rest_framework.response import Response
from django_filters.rest_framework import DjangoFilterBackend
from .models import (
    Asset, PriceHistory, Trade, Signal, UserWallet, WalletTransaction, 
    UserPreference, UserProfile, MarketAlert, StrategyProfile, RiskConfig,
    Challenge, UserChallenge, Badge, UserBadge
)
from .serializers import (
    AssetSerializer,
    PriceHistorySerializer,
    TradeSerializer,
    SignalSerializer,
    UserWalletSerializer,
    WalletTransactionSerializer,
    DepositRequestSerializer,
    TransferRequestSerializer,
    UserPreferenceSerializer,
    UserProfileSerializer,
    MarketAlertSerializer,
    StrategyProfileSerializer,
    RiskConfigSerializer,
    ChallengeSerializer,
    UserChallengeSerializer,
    BadgeSerializer,
    UserBadgeSerializer
)
from .services.payment_service import PaymentService

class AssetViewSet(viewsets.ReadOnlyModelViewSet):
    """
    API endpoint to list and retrieve Assets.
    Read-only for mobile clients.
    """
    queryset = Asset.objects.all()
    serializer_class = AssetSerializer
    permission_classes = [permissions.AllowAny] # Change to IsAuthenticated in production
    filter_backends = [filters.SearchFilter, DjangoFilterBackend]
    search_fields = ['symbol', 'name']
    filterset_fields = ['asset_type', 'is_active']

    @action(detail=True, methods=['get'])
    def signals(self, request, pk=None):
        """
        Custom action to get signals for a specific asset.
        URL: /api/v1/assets/{id}/signals/
        """
        asset = self.get_object()
        signals = asset.signals.all().order_by('-generated_at')
        serializer = SignalSerializer(signals, many=True)
        return Response(serializer.data)

class PriceHistoryViewSet(viewsets.ReadOnlyModelViewSet):
    """
    API endpoint to view historical data for a specific asset.
    Usually filtered by 'asset' query param.
    """
    queryset = PriceHistory.objects.all().order_by('-datetime')
    serializer_class = PriceHistorySerializer
    permission_classes = [permissions.AllowAny]
    filter_backends = [DjangoFilterBackend]
    filterset_fields = ['asset']

class TradeViewSet(viewsets.ModelViewSet):
    """
    API endpoint to view and manage Trades.
    Flutter app can list trades (Dashboard).
    """
    queryset = Trade.objects.all().order_by('-opened_at')
    serializer_class = TradeSerializer
    permission_classes = [permissions.AllowAny] 
    filter_backends = [DjangoFilterBackend]
    filterset_fields = ['asset', 'status', 'side']

    def perform_create(self, serializer):
        from django.contrib.auth.models import User
        # Use authenticated user or first user for demo
        user = self.request.user if self.request.user.is_authenticated else User.objects.first()
        serializer.save(user=user)

class WalletViewSet(viewsets.ViewSet):
    """
    ViewSet for Wallet operations: Balance, Deposit, Withdraw.
    """
    permission_classes = [permissions.AllowAny] 

    def get_user(self, request):
        if request.user.is_authenticated:
            return request.user
        # For demo purposes, use the first user or create one
        from django.contrib.auth.models import User
        user = User.objects.first()
        if not user:
            user = User.objects.create_user(username='demo_user', password='password123')
        return user

    def get_object(self):
        user = self.get_user(self.request)
        wallet, _ = UserWallet.objects.get_or_create(user=user)
        return wallet

    @action(detail=False, methods=['get'])
    def balance(self, request):
        user = self.get_user(request)
        wallet, _ = UserWallet.objects.get_or_create(user=user)
        return Response(UserWalletSerializer(wallet).data)

    @action(detail=False, methods=['post'])
    def deposit(self, request):
        """
        Initiate a Mobile Money deposit.
        """
        user = self.get_user(request)
        serializer = DepositRequestSerializer(data=request.data)
        if serializer.is_valid():
            tx = PaymentService.initiate_deposit(
                user=user,
                amount=serializer.validated_data['amount'],
                method=serializer.validated_data['payment_method'],
                phone_number=serializer.validated_data['phone_number']
            )
            if tx:
                return Response(WalletTransactionSerializer(tx).data, status=201)
            return Response({"error": "Failed to initiate deposit"}, status=400)
        return Response(serializer.errors, status=400)

    @action(detail=False, methods=['post'])
    def transfer(self, request):
        """
        Transfer funds from main wallet to professional trading account (Broker).
        """
        user = self.get_user(request)
        serializer = TransferRequestSerializer(data=request.data)
        if serializer.is_valid():
            success = PaymentService.transfer_to_broker(
                user=user,
                amount=serializer.validated_data['amount'],
                broker_account_id=serializer.validated_data['broker_account_id']
            )
            if success:
                return Response({"message": "Transfer successful"})
            return Response({"error": "Transfer failed (insufficient balance or invalid broker)"}, status=400)
        return Response(serializer.errors, status=400)

    @action(detail=False, methods=['post'])
    def withdraw(self, request):
        """
        Initiate a Mobile Money withdrawal.
        """
        user = self.get_user(request)
        profile, _ = UserProfile.objects.get_or_create(user=user)
        
        if profile.kyc_status != UserProfile.KYCStatus.VERIFIED:
            return Response(
                {"error": "Vérification KYC requise pour effectuer un retrait. Veuillez soumettre vos documents dans votre profil."}, 
                status=403
            )

        serializer = DepositRequestSerializer(data=request.data)
        if serializer.is_valid():
            tx = PaymentService.initiate_withdrawal(
                user=user,
                amount=serializer.validated_data['amount'],
                method=serializer.validated_data['payment_method'],
                phone_number=serializer.validated_data['phone_number']
            )
            if tx:
                return Response(WalletTransactionSerializer(tx).data, status=201)
            return Response({"error": "Withdrawal failed (insufficient balance or provider error)"}, status=400)
        return Response(serializer.errors, status=400)

    @action(detail=False, methods=['get'])
    def transactions(self, request):
        """
        List user transactions.
        """
        user = self.get_user(request)
        txs = WalletTransaction.objects.filter(user=user).order_by('-created_at')
        return Response(WalletTransactionSerializer(txs, many=True).data)

class PreferenceViewSet(viewsets.ViewSet):
    permission_classes = [permissions.AllowAny]

    def get_user(self, request):
        if request.user.is_authenticated:
            return request.user
        from django.contrib.auth.models import User
        user = User.objects.first()
        if not user:
            user = User.objects.create_user(username='demo_user', password='password123')
        return user

    @action(detail=False, methods=['get', 'patch'], url_path='settings')
    def settings(self, request):
        user = self.get_user(request)
        prefs, _ = UserPreference.objects.get_or_create(user=user)
        
        if request.method == 'PATCH':
            serializer = UserPreferenceSerializer(prefs, data=request.data, partial=True)
            if serializer.is_valid():
                serializer.save()
                return Response(serializer.data)
            return Response(serializer.errors, status=400)
            
        serializer = UserPreferenceSerializer(prefs)
        return Response(serializer.data)

class ProfileViewSet(viewsets.ViewSet):
    permission_classes = [permissions.AllowAny]

    def get_user(self, request):
        if request.user.is_authenticated:
            return request.user
        from django.contrib.auth.models import User
        user = User.objects.first()
        if not user:
            user = User.objects.create_user(username='demo_user', password='password123')
        return user

    @action(detail=False, methods=['get', 'patch'])
    def me(self, request):
        user = self.get_user(request)
        profile, _ = UserProfile.objects.get_or_create(user=user)
        
        if request.method == 'PATCH':
            serializer = UserProfileSerializer(profile, data=request.data, partial=True)
            if serializer.is_valid():
                # Simuler une vérification automatique si un numéro de document est fourni
                if 'kyc_document_id' in serializer.validated_data:
                    profile.kyc_status = UserProfile.KYCStatus.PENDING
                serializer.save()
                return Response(UserProfileSerializer(profile).data)
            return Response(serializer.errors, status=400)
            
        return Response(UserProfileSerializer(profile).data)

class AnalyticsViewSet(viewsets.ViewSet):
    permission_classes = [permissions.AllowAny]

    def get_user(self, request):
        if request.user.is_authenticated:
            return request.user
        from django.contrib.auth.models import User
        return User.objects.first()

    @action(detail=False, methods=['get'])
    def stats(self, request):
        user = self.get_user(request)
        trades = Trade.objects.filter(user=user, status=Trade.Status.CLOSED)
        
        total_trades = trades.count()
        if total_trades == 0:
            return Response({
                "win_rate": 0,
                "total_pnl": 0,
                "profit_factor": 0,
                "max_drawdown": 0,
                "total_trades": 0,
                "equity_curve": []
            })

        winning_trades = trades.filter(pnl__gt=0)
        losing_trades = trades.filter(pnl__lt=0)
        
        win_rate = (winning_trades.count() / total_trades) * 100
        total_pnl = sum(t.pnl for t in trades if t.pnl)
        
        gross_profit = float(sum(t.pnl for t in winning_trades if t.pnl))
        gross_loss = abs(float(sum(t.pnl for t in losing_trades if t.pnl)))
        profit_factor = gross_profit / gross_loss if gross_loss > 0 else (gross_profit if gross_profit > 0 else 0)

        # Equity Curve & Drawdown
        equity = 0
        peak = 0
        max_drawdown = 0
        equity_curve = []
        
        for t in trades.order_by('closed_at'):
            equity += float(t.pnl or 0)
            equity_curve.append({
                "date": t.closed_at.isoformat() if t.closed_at else None,
                "equity": round(equity, 2)
            })
            if equity > peak:
                peak = equity
            
            drawdown = peak - equity
            if drawdown > max_drawdown:
                max_drawdown = drawdown

        return Response({
            "win_rate": round(win_rate, 2),
            "total_pnl": round(float(total_pnl), 2),
            "profit_factor": round(profit_factor, 2),
            "max_drawdown": round(max_drawdown, 2),
            "total_trades": total_trades,
            "equity_curve": equity_curve
        })

class AlertViewSet(viewsets.ModelViewSet):
    serializer_class = MarketAlertSerializer
    permission_classes = [permissions.AllowAny]

    def get_queryset(self):
        if self.request.user.is_authenticated:
            return MarketAlert.objects.filter(user=self.request.user)
        # Demo
        from django.contrib.auth.models import User
        return MarketAlert.objects.filter(user=User.objects.first())

    def perform_create(self, serializer):
        if self.request.user.is_authenticated:
            serializer.save(user=self.request.user)
        else:
            from django.contrib.auth.models import User
            serializer.save(user=User.objects.first())

class StrategyProfileViewSet(viewsets.ModelViewSet):
    serializer_class = StrategyProfileSerializer
    permission_classes = [permissions.AllowAny]

    def get_queryset(self):
        user = self.get_user(self.request)
        return StrategyProfile.objects.filter(user=user)

    def get_user(self, request):
        if request.user.is_authenticated: return request.user
        from django.contrib.auth.models import User
        return User.objects.first()

    def perform_create(self, serializer):
        serializer.save(user=self.get_user(self.request))

class RiskConfigViewSet(viewsets.GenericViewSet):
    serializer_class = RiskConfigSerializer
    permission_classes = [permissions.AllowAny]

    def get_user(self, request):
        if request.user.is_authenticated: return request.user
        from django.contrib.auth.models import User
        return User.objects.first()

    @action(detail=False, methods=['get', 'patch'])
    def current(self, request):
        user = self.get_user(request)
        config, _ = RiskConfig.objects.get_or_create(user=user)
        if request.method == 'PATCH':
            # Verify if user has enough level for some aggressive settings
            serializer = RiskConfigSerializer(config, data=request.data, partial=True)
            if serializer.is_valid():
                serializer.save()
                return Response(serializer.data)
            return Response(serializer.errors, status=400)
        return Response(RiskConfigSerializer(config).data)

class ChallengeViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Challenge.objects.filter(is_active=True)
    serializer_class = ChallengeSerializer
    permission_classes = [permissions.AllowAny]

    def get_user(self, request):
        if request.user.is_authenticated: return request.user
        from django.contrib.auth.models import User
        return User.objects.first()

    @action(detail=False, methods=['get'])
    def mine(self, request):
        user = self.get_user(request)
        user_challenges = UserChallenge.objects.filter(user=user)
        # Ensure all active challenges exist for user
        active_challenges = Challenge.objects.filter(is_active=True)
        for c in active_challenges:
            UserChallenge.objects.get_or_create(user=user, challenge=c)
        
        serializer = UserChallengeSerializer(user_challenges, many=True)
        return Response(serializer.data)

    @action(detail=False, methods=['get'])
    def leaderboard(self, request):
        # Leaderboard by XP
        top_profiles = UserProfile.objects.all().order_by('-xp')[:10]
        data = []
        for p in top_profiles:
            data.append({
                "username": p.user.username,
                "xp": p.xp,
                "level": p.level,
                "avatar_url": p.avatar_url
            })
        return Response(data)

class BadgeViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Badge.objects.all()
    serializer_class = BadgeSerializer
    permission_classes = [permissions.AllowAny]

    def get_user(self, request):
        if request.user.is_authenticated: return request.user
        from django.contrib.auth.models import User
        return User.objects.first()

    @action(detail=False, methods=['get'])
    def mine(self, request):
        user = self.get_user(request)
        user_badges = UserBadge.objects.filter(user=user)
        serializer = UserBadgeSerializer(user_badges, many=True)
        return Response(serializer.data)
