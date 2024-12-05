from django.db import models
from django.contrib.auth.models import User

# Modelo para las noticias
class News(models.Model):
    title = models.CharField(max_length=255)
    summary = models.TextField()
    content = models.TextField()
    published_at = models.DateTimeField(db_index=True)  # Índice en la fecha
    url = models.URLField(unique=True)  # Evita duplicados
    source = models.CharField(max_length=255, null=True, blank=True)  # Fuente opcional
    processed = models.BooleanField(default=False)
    categories = models.JSONField(null=True, blank=True)
    keywords = models.JSONField(null=True, blank=True)

    def __str__(self):
        return self.title
def is_recent(self):
    return self.published_at > timezone.now() - timedelta(days=7)
# Modelo para las preferencias de los usuarios
class UserPreferences(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    preferred_categories = models.JSONField(default=list)
    preferred_keywords = models.JSONField(default=list)
    updated_at = models.DateTimeField(auto_now=True)  # Fecha de última actualización

    def __str__(self):
        return self.user.username
# Modelo para registrar las interacciones de los usuarios
class UserInteractions(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, db_index=True)
    news = models.ForeignKey(News, on_delete=models.CASCADE, db_index=True)
    liked = models.BooleanField()
    timestamp = models.DateTimeField(auto_now_add=True)
    action = models.CharField(max_length=50, null=True, blank=True)  # Para otras acciones

    def __str__(self):
        return f"{self.user.username} - {self.news.title} - {'Liked' if self.liked else 'Disliked'}"