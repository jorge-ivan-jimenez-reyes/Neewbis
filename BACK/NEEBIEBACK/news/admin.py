from django.contrib import admin

# Register your models here.
from django.contrib import admin
from .models import News, UserPreferences, UserInteractions

# Registra los modelos en el administrador
admin.site.register(News)
admin.site.register(UserPreferences)
admin.site.register(UserInteractions)