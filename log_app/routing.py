
from django.urls import re_path
from log_app.consumers import LogConsumer

websocket_urlpatterns = [
    re_path(r'ws/fetch_logs/',LogConsumer.as_asgi())
]