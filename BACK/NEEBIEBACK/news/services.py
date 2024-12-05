import requests
from datetime import datetime, timedelta
import openai
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity
from pytz import utc
from django.conf import settings
import json
from .models import News, UserInteractions
# Configuración de la API de noticias
BASE_URL = "https://newsapi.org/v2/top-headlines"
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
        'pageSize': 100,
        'from': (datetime.now() - timedelta(days=7)).strftime("%Y-%m-%d"),
    }
    response = requests.get(BASE_URL, params=params)
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
        result = response['choices'][0]['message']['content'].strip()
        return json.loads(result)
    except Exception as e:
        print(f"Error al clasificar la noticia: {e}")
        return {"category": "Desconocido", "keywords": []}


def process_and_save_news(news_data):
    """
    Process, classify, and save news articles into the database.
    """
    for article in news_data.get('articles', []):
        title = article.get('title', 'Título no disponible')
        content = article.get('content', None)
        summary = article.get('description', 'Sin resumen')
        url = article.get('url', '')
        published_at = article.get('publishedAt', None)

        if published_at:
            try:
                published_at = datetime.strptime(published_at, "%Y-%m-%dT%H:%M:%SZ").replace(tzinfo=utc)
            except ValueError:
                published_at = None

        if not content:
            print(f"Noticia ignorada: {title} (sin contenido)")
            continue

        classification = classify_news_with_gpt(title, content)

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


def fetch_and_process_news_multiple_categories(country='us', categories=None):
    """
    Fetch news from the API for multiple categories and save them to the database.
    """
    if categories is None:
        # Lista de categorías a analizar
        categories = ['technology', 'business', 'sports', 'health', 'science', 'entertainment']

    for category in categories:
        try:
            print(f"Procesando noticias para la categoría: {category}")
            news_data = fetch_news_from_api(country=country, category=category)
            process_and_save_news(news_data)
            print(f"Noticias procesadas exitosamente para la categoría: {category}")
        except Exception as e:
            print(f"Error al procesar noticias para la categoría {category}: {e}")

# Recomendaciones basadas en contenido
def generate_similarity_matrix():
    """
    Genera una matriz de similitud entre todas las noticias utilizando TF-IDF.
    """
    news_data = list(News.objects.all())
    news_texts = [" ".join(news.categories + news.keywords) for news in news_data]

    vectorizer = TfidfVectorizer()
    news_vectors = vectorizer.fit_transform(news_texts)

    similarity_matrix = cosine_similarity(news_vectors)

    return similarity_matrix, news_data
def recommend_news_content_based(user):
    from django.db.models import Q

    # Obtener interacciones del usuario
    user_interactions = UserInteractions.objects.filter(user=user)
    liked_news_ids = list(user_interactions.filter(liked=True).values_list('news__id', flat=True))

    # Obtener noticias no vistas
    all_news = News.objects.exclude(Q(id__in=liked_news_ids) | Q(processed=False))

    if not all_news.exists():
        return all_news[:5]  # Devuelve las primeras 5 noticias si no hay datos

    # Preparar textos para TF-IDF
    liked_texts = [" ".join(news.categories + news.keywords) for news in News.objects.filter(id__in=liked_news_ids)]
    news_texts = [" ".join(news.categories + news.keywords) for news in all_news]

    if not liked_texts:
        return all_news[:5]  # Devuelve las primeras noticias si no hay interacciones

    try:
        # Generar vectores TF-IDF
        vectorizer = TfidfVectorizer()
        all_vectors = vectorizer.fit_transform(news_texts + liked_texts)
        liked_vectors = all_vectors[-len(liked_texts):]
        all_vectors = all_vectors[:-len(liked_texts)]

        # Calcular similitudes
        similarity_matrix = cosine_similarity(all_vectors, liked_vectors)
        similarity_scores = similarity_matrix.mean(axis=1)

        # Ordenar noticias por similitud
        sorted_indices = similarity_scores.argsort()[::-1]
        recommended_news = [all_news[idx] for idx in sorted_indices[:20]]
        return recommended_news
    except Exception as e:
        print(f"[ERROR] Error en recomendaciones: {e}")
        return all_news[:5]  # Devuelve noticias base en caso de error