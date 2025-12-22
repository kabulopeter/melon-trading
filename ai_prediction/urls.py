from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import AIViewSet

router = DefaultRouter()
router.register(r'predict', AIViewSet, basename='ai-predict')

urlpatterns = [
    path('', include(router.urls)),
]
