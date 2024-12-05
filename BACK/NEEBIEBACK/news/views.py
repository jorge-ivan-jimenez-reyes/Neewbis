from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from .models import News
from .serializers import NewsSerializer
from .services import fetch_and_process_news

class FetchAndClassifyNewsAPIView(APIView):
    """
    API View para obtener noticias, clasificarlas con GPT y guardarlas en la base de datos.
    """
    def get(self, request):
        try:
            fetch_and_process_news(country='us', category='technology')
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