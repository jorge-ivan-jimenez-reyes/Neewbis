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
    user_interactions = UserInteractions.objects.filter(user=user, liked=True)
    user_preferred_news = [interaction.news for interaction in user_interactions]

    if not user_preferred_news:
        return News.objects.none()  # No hay noticias preferidas, devuelve un queryset vacío

    user_keywords = []
    for news in user_preferred_news:
        user_keywords.extend(news.keywords)
    user_keywords_text = " ".join(user_keywords)

    all_news = News.objects.exclude(userinteractions__user=user)  # Excluye noticias ya vistas
    all_news_texts = [" ".join(news.keywords) for news in all_news]

    vectorizer = TfidfVectorizer()
    vectors = vectorizer.fit_transform([user_keywords_text] + all_news_texts)

    similarity_matrix = cosine_similarity(vectors[0:1], vectors[1:]).flatten()
    recommended_indices = similarity_matrix.argsort()[::-1]  # Orden descendente

    # Convertir índices a int y obtener las noticias recomendadas
    recommended_news = [all_news[int(idx)] for idx in recommended_indices[:60]]
    return recommended_news
