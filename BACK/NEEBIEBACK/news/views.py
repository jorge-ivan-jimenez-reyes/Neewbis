from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from django.contrib.auth.models import User
from rest_framework.permissions import IsAuthenticated
from django.core.exceptions import ObjectDoesNotExist
from .models import News, UserInteractions
from .serializers import NewsSerializer
from .services import fetch_and_process_news_multiple_categories, recommend_news_content_based

class FetchAndClassifyNewsAPIView(APIView):
    """
    API View para obtener noticias, clasificarlas con GPT y guardarlas en la base de datos.
    """
    def get(self, request):
        try:
            fetch_and_process_news_multiple_categories(
                country='us',
                categories=['technology', 'sports', 'business', 'health']
            )
            return Response({"message": "Noticias procesadas y clasificadas exitosamente"}, status=status.HTTP_200_OK)
        except Exception as e:
            return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


class NewsListAPIView(APIView):
    """
    API View para listar noticias almacenadas en la base de datos.
    """
    def get(self, request):
        try:
            news = News.objects.filter(processed=True).order_by('-published_at')
            serializer = NewsSerializer(news, many=True)
            return Response(serializer.data, status=status.HTTP_200_OK)
        except Exception as e:
            return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


class UserInteractionAPIView(APIView):
    """
    API View para registrar interacciones de los usuarios con las noticias.
    """
    def post(self, request):
        try:
            user_id = request.data.get('user_id')  # ID del usuario
            news_id = request.data.get('news_id')  # ID de la noticia
            liked = request.data.get('liked')  # True o False

            if not all([user_id, news_id, liked is not None]):
                return Response({"error": "Faltan datos obligatorios (user_id, news_id, liked)"}, status=status.HTTP_400_BAD_REQUEST)

            # Validar existencia del usuario y la noticia
            user = User.objects.get(id=user_id)
            news = News.objects.get(id=news_id)

            # Crear o actualizar la interacción
            interaction, created = UserInteractions.objects.update_or_create(
                user=user,
                news=news,
                defaults={'liked': liked}
            )

            # Actualizar las recomendaciones del usuario
            recommendations = recommend_news_content_based(user)

            message = "Interacción creada" if created else "Interacción actualizada"
            return Response({
                "message": message,
                "interaction": {
                    "user": user.username,
                    "news": news.title,
                    "liked": interaction.liked,
                },
                "recommendations": [
                    {
                        "id": rec.id,
                        "title": rec.title,
                        "summary": rec.summary,
                    } for rec in recommendations
                ]
            }, status=status.HTTP_201_CREATED)
        except User.DoesNotExist:
            return Response({"error": "Usuario no encontrado"}, status=status.HTTP_404_NOT_FOUND)
        except News.DoesNotExist:
            return Response({"error": "Noticia no encontrada"}, status=status.HTTP_404_NOT_FOUND)
        except Exception as e:
            return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


class ContentBasedRecommendationAPIView(APIView):
    """
    API View para obtener recomendaciones basadas en contenido.
    """
    permission_classes = [IsAuthenticated]

    def get(self, request):
        try:
            user = request.user
            recommendations = recommend_news_content_based(user)

            if not recommendations:
                return Response({"message": "No hay recomendaciones disponibles."}, status=status.HTTP_200_OK)

            data = [
                {
                    "id": news.id,
                    "title": news.title,
                    "summary": news.summary,
                }
                for news in recommendations
            ]

            return Response({"recommendations": data}, status=status.HTTP_200_OK)
        except ObjectDoesNotExist:
            return Response({"error": "Usuario no encontrado."}, status=status.HTTP_404_NOT_FOUND)
        except Exception as e:
            print(f"[ERROR] {e}")
            return Response({"error": "Error interno del servidor."}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)