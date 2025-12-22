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
            # Fallback to the first available user for demo purposes
            user = User.objects.first()
            
        if user:
            serializer.save(user=user)
        else:
            # This should not happen if ensure_user.py was run, but good to handle
            raise serializers.ValidationError({"detail": "No user found in the system. Please create a user first."})
