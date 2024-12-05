from django.urls import path
from .views import FetchAndClassifyNewsAPIView, NewsListAPIView, UserInteractionAPIView, RecommendationContentBasedAPIView

urlpatterns = [
    path('fetch-classify-news/', FetchAndClassifyNewsAPIView.as_view(), name='fetch-classify-news'),
    path('news/', NewsListAPIView.as_view(), name='news-list'),
    path('user-interaction/', UserInteractionAPIView.as_view(), name='user-interaction'),  # Nuevo endpoint
    path('recommendations/content-based/', RecommendationContentBasedAPIView.as_view(),
         name='recommendations-content-based'),

]