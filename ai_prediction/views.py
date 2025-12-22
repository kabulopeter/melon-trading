from rest_framework import viewsets, permissions
from rest_framework.decorators import action
from rest_framework.response import Response
from .services import PredictionService
from core.serializers import SignalSerializer
from core.models import Asset, Signal
from core.tasks import analyze_market_trends

class AIViewSet(viewsets.ViewSet):
    permission_classes = [permissions.AllowAny]

    @action(detail=False, methods=['post'], url_path='')
    def predict(self, request):
        """
        Get or trigger AI prediction for a specific symbol.
        POST /api/v1/ai/predict/ {"symbol": "BTCUSD", "refresh": false}
        """
        symbol = request.data.get('symbol')
        refresh = request.data.get('refresh', False)
        
        if not symbol:
            return Response({"error": "Symbol is required"}, status=400)
        
        try:
            asset = Asset.objects.get(symbol=symbol)
        except Asset.DoesNotExist:
            return Response({"error": f"Asset {symbol} not found"}, status=404)

        if refresh:
            signal = PredictionService.run_prediction(symbol)
            if signal:
                return Response(SignalSerializer(signal).data)
        else:
            # Return latest cached signal
            signal = Signal.objects.filter(asset=asset).order_by('-generated_at').first()
            if signal:
                return Response(SignalSerializer(signal).data)
            
            # If no signal exists, generate one now
            signal = PredictionService.run_prediction(symbol)
            if signal:
                return Response(SignalSerializer(signal).data)
        
        return Response({"error": f"Failed to generate prediction for {symbol}."}, status=500)

    @action(detail=False, methods=['get'], url_path='batch')
    def batch_predict(self, request):
        """
        Return latest cached predictions for all active assets.
        GET /api/v1/ai/batch/
        """
        assets = Asset.objects.filter(is_active=True)
        results = []
        for asset in assets:
            latest_signal = Signal.objects.filter(asset=asset).order_by('-generated_at').first()
            if latest_signal:
                results.append(SignalSerializer(latest_signal).data)
        
        return Response(results)

    @action(detail=False, methods=['post'], url_path='refresh')
    def refresh_all(self, request):
        """
        Trigger a background task to recalculate all signals.
        POST /api/v1/ai/refresh/
        """
        task = analyze_market_trends.delay()
        return Response({
            "status": "Task triggered",
            "task_id": task.id,
            "message": "AI Market analysis is running in background. Refresh the page in a few moments."
        })
