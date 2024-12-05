from django.urls import path
from .views import FetchAndClassifyNewsAPIView, NewsListAPIView

urlpatterns = [
    path('fetch-classify-news/', FetchAndClassifyNewsAPIView.as_view(), name='fetch-classify-news'),
    path('news/', NewsListAPIView.as_view(), name='news-list'),
]