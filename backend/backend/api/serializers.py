from rest_framework import serializers
from django.contrib.auth.models import User
from .models import Meal, UserGoal
from rest_framework_simplejwt.tokens import RefreshToken

class MealSerializer(serializers.ModelSerializer):
    class Meta: 
        model = Meal
        fields = ['id', 'meal_type', 'title', 'calories', 'carbs', 'fat', 'protein', 'image']


class MacrosSerializer(serializers.Serializer):
    carbs = serializers.IntegerField()
    protein = serializers.IntegerField()
    fat = serializers.IntegerField()

class SummarySerializer(serializers.Serializer):
    today_calories = serializers.IntegerField()
    target_calories = serializers.IntegerField()

class DashboardSerializer(serializers.Serializer):
    date = serializers.DateField()
    summary = SummarySerializer()
    macros = MacrosSerializer()
    today_meals = MealSerializer(many=True)

class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)
    name = serializers.CharField(write_only=True, required=True)
    
    access = serializers.CharField(read_only=True)
    refresh = serializers.CharField(read_only=True)

    class Meta:
        model = User
        fields = ['username', 'password', 'email', 'name', 'access', 'refresh']

    def validate_email(self, value):
        if value and User.objects.filter(email=value).exists():
            raise serializers.ValidationError("این ایمیل قبلاً ثبت شده است.")
        return value

    def create(self, validated_data):
        user = User.objects.create_user(
            username=validated_data['username'],
            email=validated_data.get('email', ''),
            password=validated_data['password'],
            first_name=validated_data.get('name', '')
        )

        UserGoal.objects.create(user=user)

        refresh = RefreshToken.for_user(user)

        user.access = str(refresh.access_token)
        user.refresh = str(refresh)

        return user
    
class UserGoalSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserGoal
        fields = ['target_calories', 'target_carbs', 'target_protein', 'target_fat']

class ProfileSerializer(serializers.ModelSerializer):
    name = serializers.CharField(source='first_name', required=False)
    goals = UserGoalSerializer(required=False)

    class Meta:
        model = User
        fields = ["id", "username", "email", "name", "date_joined", "goals"]

    def update(self, instance, validated_data):
        request = self.context.get('request')
        
        if request and 'goals' in request.data:
            goals_data = request.data.get('goals')
            
            goals_queryset = UserGoal.objects.filter(user=instance)
            if goals_queryset.exists():
                goal = goals_queryset.last()
            else:
                goal = UserGoal.objects.create(user=instance)
            
            goal.target_calories = goals_data.get('target_calories', goal.target_calories)
            goal.target_carbs = goals_data.get('target_carbs', goal.target_carbs)
            goal.target_protein = goals_data.get('target_protein', goal.target_protein)
            goal.target_fat = goals_data.get('target_fat', goal.target_fat)
            goal.save()

        instance.first_name = validated_data.get('first_name', instance.first_name)
        instance.email = validated_data.get('email', instance.email)
        instance.save()
        
        return instance