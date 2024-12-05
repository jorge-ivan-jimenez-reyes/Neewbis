from django.db import models
from django.contrib.auth.models import User

# Modelo para las noticias
class News(models.Model):
    title = models.CharField(max_length=255)
    summary = models.TextField()
    content = models.TextField()
    published_at = models.DateTimeField()
    url = models.URLField()
    processed = models.BooleanField(default=False)
    categories = models.JSONField(null=True, blank=True)
    keywords = models.JSONField(null=True, blank=True)

    def __str__(self):
        return self.title

# Modelo para las preferencias de los usuarios
class UserPreferences(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    preferred_categories = models.JSONField(default=list)
    preferred_keywords = models.JSONField(default=list)

    def __str__(self):
        return self.user.username

# Modelo para registrar las interacciones de los usuarios
class UserInteractions(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    news = models.ForeignKey(News, on_delete=models.CASCADE)
    liked = models.BooleanField()
    timestamp = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.user.username} - {self.news.title}"