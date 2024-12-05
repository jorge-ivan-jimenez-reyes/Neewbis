from django.urls import path
from .views import FetchAndClassifyNewsAPIView, NewsListAPIView, UserInteractionAPIView, \
     ContentBasedRecommendationAPIView
from rest_framework.authtoken.views import obtain_auth_token
urlpatterns = [
    path('fetch-classify-news/', FetchAndClassifyNewsAPIView.as_view(), name='fetch-classify-news'),
    path('news/', NewsListAPIView.as_view(), name='news-list'),
    path('user-interaction/', UserInteractionAPIView.as_view(), name='user-interaction'),
    path('recommendations/content-based/', ContentBasedRecommendationAPIView.as_view(), name='content-based-recommendations'),
]