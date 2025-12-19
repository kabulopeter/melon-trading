from core.models import Notification
from django.contrib.auth.models import User
import logging

logger = logging.getLogger(__name__)

class NotificationService:
    @staticmethod
    def send_to_user(user: User, title: str, message: str, type=Notification.Type.INFO):
        """
        Creates a notification DB entry and sends via Channels/Email/SMS.
        """
        # 1. create DB entry
        n = Notification.objects.create(
            user=user,
            title=title,
            message=message,
            notification_type=type
        )
        
        # 2. Push to WebSocket
        try:
            from channels.layers import get_channel_layer
            from asgiref.sync import async_to_sync
            
            channel_layer = get_channel_layer()
            async_to_sync(channel_layer.group_send)(
                "dashboard_updates",
                {
                    "type": "dashboard.message",
                    "message": {
                        "title": title,
                        "body": message,
                        "type": type,
                        "timestamp": n.created_at.isoformat()
                    }
                }
            )
        except Exception as e:
            logger.error(f"WebSocket send failed: {e}")
            
        # 3. Send Email (TODO - mock for now)
        # We can implement SendGrid/Twilio later if API keys appear
        
        return n

    @staticmethod
    def notify_admins(title, message):
        admins = User.objects.filter(is_superuser=True)
        for admin in admins:
            NotificationService.send_to_user(admin, title, message, Notification.Type.WARNING)
