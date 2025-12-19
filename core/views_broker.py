from rest_framework import viewsets, permissions
from .models import BrokerAccount
from rest_framework import serializers

class BrokerAccountSerializer(serializers.ModelSerializer):
    class Meta:
        model = BrokerAccount
        fields = ['id', 'name', 'broker_type', 'account_id', 'is_active', 'is_test_account', 'balance']
        read_only_fields = ['id', 'balance']

class BrokerViewSet(viewsets.ModelViewSet):
    serializer_class = BrokerAccountSerializer
    permission_classes = [permissions.AllowAny]

    def get_queryset(self):
        # Demo logic: return all if demo user, else filter by user
        from django.contrib.auth.models import User
        user = self.request.user
        if not user.is_authenticated:
            user = User.objects.first()
        return BrokerAccount.objects.filter(user=user)

    def perform_create(self, serializer):
        from django.contrib.auth.models import User
        user = self.request.user
        if not user.is_authenticated:
            user = User.objects.first()
        serializer.save(user=user)
