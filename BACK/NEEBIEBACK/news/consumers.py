import json
from channels.generic.websocket import AsyncWebsocketConsumer
from asgiref.sync import sync_to_async
from .services import recommend_news_content_based
from django.contrib.auth.models import User


class RecommendationConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        self.user = self.scope["user"]
        if not self.user.is_authenticated:
            await self.close()
        else:
            await self.accept()

    async def disconnect(self, close_code):
        pass

    async def receive(self, text_data):
        try:
            text_data_json = json.loads(text_data)
            action = text_data_json.get('action')

            if action == 'get_recommendations':
                recommendations = await self.get_recommendations()
                await self.send(json.dumps({"recommendations": recommendations}))
            else:
                await self.send(json.dumps({"error": "Invalid action"}))
        except Exception as e:
            await self.send(json.dumps({"error": str(e)}))

    async def get_recommendations(self):
        try:
            # Llama a la función de recomendaciones en un hilo separado si es síncrona
            recommendations = await sync_to_async(recommend_news_content_based)(self.user)
            return [
                {"id": news.id, "title": news.title, "summary": news.summary}
                for news in recommendations
            ]
        except Exception as e:
            return [{"error": f"Failed to fetch recommendations: {str(e)}"}]