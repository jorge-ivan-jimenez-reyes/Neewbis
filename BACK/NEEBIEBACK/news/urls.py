from django.urls import path
from .views import FetchAndClassifyNewsAPIView, NewsListAPIView, UserInteractionAPIView, RecommendationContentBasedAPIView
from rest_framework.authtoken.views import obtain_auth_token
urlpatterns = [
    path('fetch-classify-news/', FetchAndClassifyNewsAPIView.as_view(), name='fetch-classify-news'),
    path('news/', NewsListAPIView.as_view(), name='news-list'),
    path('user-interaction/', UserInteractionAPIView.as_view(), name='user-interaction'),  # Nuevo endpoint
    path('recommendations/content-based/', RecommendationContentBasedAPIView.as_view(),
         name='recommendations-content-based'),
    path('api-token-auth/', obtain_auth_token, name='api_token_auth'),
]
