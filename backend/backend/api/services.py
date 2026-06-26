from datetime import date
from .models import Meal, UserGoal
from django.db import  models

class DashboardService():
    @staticmethod
    def get_daily_summary(user, target_date=None):
        if target_date is None:
            target_date = date.today()

        goal, _ = UserGoal.objects.get_or_create(user=user)

        meals_summary = Meal.objects.filter(user=user, created_at=target_date).aggregate(
            total_cal=models.Sum('calories'),
            total_carbs=models.Sum('carbs'),
            total_protein=models.Sum('protein'),
            total_fat=models.Sum('fat')
        )

        total_cal = meals_summary['total_cal'] or 0
        carbs = meals_summary['total_carbs'] or 0
        protein = meals_summary['total_protein'] or 0
        fat = meals_summary['total_fat'] or 0

        return {
            "date": target_date,
            "summary": {
                "total_calories": total_cal,
                "remaining_calories": max(0, goal.target_calories - total_cal),
                "target_calories": goal.target_calories
            },
            "macros": {
                "carbs": {"current": carbs, "target": goal.target_carbs, "percentage": min(1.0, carbs/goal.target_carbs if goal.target_carbs else 0)},
                "protein": {"current": protein, "target": goal.target_protein, "percentage": min(1.0, protein/goal.target_protein if goal.target_protein else 0)},
                "fat": {"current": fat, "target": goal.target_fat, "percentage": min(1.0, fat/goal.target_fat if goal.target_fat else 0)}
            },
            "today_meals": Meal.objects.filter(user=user, created_at=target_date)
        }

