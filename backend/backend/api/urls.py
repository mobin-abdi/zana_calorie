from django.urls import path
from .views import *
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView

urlpatterns = [
    path('home/', HomeScreenAPIView.as_view()),
    path('history/', MealHistoryView.as_view()),
    path('profile/', UserProfileView.as_view()),
    path('ai/scan-create/', AIScanAndCreateView.as_view()),
    path('auth/register/', RegisterAPIView.as_view()),
    path('auth/login/', TokenObtainPairView.as_view()),
    path('auth/token/refresh', TokenRefreshView.as_view()),
]