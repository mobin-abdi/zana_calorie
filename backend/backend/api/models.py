from django.db import models
from django.contrib.auth.models import User

class UserGoal(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    target_calories = models.IntegerField(default=2000)
    target_carbs = models.IntegerField(default=300)
    target_protein = models.IntegerField(default=150)
    target_fat = models.IntegerField(default=70)

class Meal(models.Model):
    MEAL_TYPES = [('BREAKFAST', 'صبحانه'), ('LUNCH', 'ناهار'), ('DINNER', 'شام'), ('SNACK', 'میان‌وعده')]
    
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name="meals")
    title = models.CharField(max_length=100)
    meal_type = models.CharField(max_length=20, choices=MEAL_TYPES)
    calories = models.IntegerField()
    carbs = models.IntegerField()
    fat = models.IntegerField()
    protein = models.IntegerField()
    image = models.ImageField(upload_to='meals/', null=True, blank=True)
    created_at = models.DateField(auto_now_add=True)
