import requests
from datetime import datetime
import openai
from .models import News
from django.conf import settings
from pytz import utc
import json
# Configuración de la API de noticias
BASE_URL = "https://newsapi.org/v2/top-headlines"  # Asegúrate de que BASE_URL está definido aquí
API_KEY = settings.NEWS_API_KEY

# Configuración de OpenAI
openai.api_key = settings.OPENAI_API_KEY

def fetch_news_from_api(country='us', category=None):
    """
    Fetch news from NewsAPI and return the JSON response.
    """
    params = {
        'apiKey': API_KEY,
        'country': country,
        'category': category,
        'pageSize': 100,  # Limita la cantidad de resultados
    }
    response = requests.get(BASE_URL, params=params)  # BASE_URL está accesible aquí
    if response.status_code == 200:
        return response.json()
    else:
        response.raise_for_status()


def classify_news_with_gpt(title, content):
    """
    Send news to GPT and get classifications.
    """
    prompt = f"""
    Clasifica la siguiente noticia en una categoría y genera palabras clave asociadas:

    Título: {title}
    Contenido: {content}

    Devuelve un JSON con este formato:
    {{
        "category": "Categoría principal",
        "keywords": ["palabra clave 1", "palabra clave 2"]
    }}
    """
    try:
        response = openai.ChatCompletion.create(
            model="gpt-3.5-turbo",
            messages=[
                {"role": "system", "content": "Eres un modelo útil para clasificar noticias."},
                {"role": "user", "content": prompt},
            ]
        )
        # Muestra la respuesta completa para depuración
        print("Respuesta GPT:", response['choices'][0]['message']['content'])

        # Intenta convertir directamente desde JSON en lugar de usar eval
        result = response['choices'][0]['message']['content'].strip()
        return json.loads(result)  # Usa json.loads para manejar JSON de forma segura
    except Exception as e:
        print(f"Error al clasificar la noticia: {e}")
        return {"category": "Desconocido", "keywords": []}
def process_and_save_news(news_data):
    """
    Process, classify, and save news articles into the database.
    """
    for article in news_data.get('articles', []):
        title = article.get('title', 'Título no disponible')
        content = article.get('content', None)  # Verifica si el contenido está presente
        summary = article.get('description', 'Sin resumen')
        url = article.get('url', '')
        published_at = article.get('publishedAt', None)

        # Verifica y convierte la fecha publicada
        if published_at:
            try:
                published_at = datetime.strptime(published_at, "%Y-%m-%dT%H:%M:%SZ").replace(tzinfo=utc)
            except ValueError:
                published_at = None

        # Si no hay contenido, ignora esta noticia
        if not content:
            print(f"Noticia ignorada: {title} (sin contenido)")
            continue

        # Clasifica la noticia con GPT
        classification = classify_news_with_gpt(title, content)

        # Guarda la noticia en la base de datos
        news, created = News.objects.get_or_create(
            title=title,
            defaults={
                'summary': summary,
                'content': content,
                'published_at': published_at,
                'url': url,
                'processed': True,
                'categories': [classification['category']],
                'keywords': classification['keywords'],
            }
        )
        if created:
            print(f"Noticia guardada: {news.title}")
        else:
            print(f"Noticia ya existente: {news.title}")
def fetch_and_process_news(country='us', category='technology'):
    """
    Fetch news from the API and save them to the database.
    """
    try:
        news_data = fetch_news_from_api(country=country, category=category)
        process_and_save_news(news_data)
        print("Noticias procesadas exitosamente.")
    except Exception as e:
        print(f"Error al procesar las noticias: {e}")