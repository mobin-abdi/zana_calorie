import base64
from datetime import date
import json
from django.db.models import Sum
from openai import OpenAI
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, AllowAny
from .models import Meal, UserGoal
from .serializers import DashboardSerializer, MealSerializer, RegisterSerializer, ProfileSerializer
from rest_framework import status
from drf_spectacular.utils import extend_schema
from datetime import datetime
from rest_framework.generics import RetrieveUpdateAPIView
from rest_framework.parsers import MultiPartParser, FormParser
from django.core.files.storage import default_storage
from django.core.files.base import ContentFile
import logging

client = OpenAI(
    api_key="sk-sIzik2N3A0QKesOVDJz3b3eYM12LOzMeuI0OZbAG6qh7OXuu",
    base_url="https://api.gapgpt.app/v1"
)
logger = logging.getLogger(__name__)

class HomeScreenAPIView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        user = request.user
        today = date.today()

        today_meals = Meal.objects.filter(user=user, created_at=today)

        totals = today_meals.aggregate(
            total_cal=Sum('calories'),
            total_carbs=Sum('carbs'),
            total_protein=Sum('protein'),
            total_fat=Sum('fat')
        )

        goal = UserGoal.objects.filter(user=user).first()
        
        target_cal = goal.target_calories if goal else 2000
        target_carbs = goal.target_carbs if goal else 300
        target_protein = goal.target_protein if goal else 150
        target_fat = goal.target_fat if goal else 70

        dashboard_data = {
            "date": today,
            "summary": {
                "today_calories": totals['total_cal'] or 0,
                "target_calories": target_cal
            },
            "macros": {
                "carbs": totals['total_carbs'] or 0,
                "protein": totals['total_protein'] or 0,
                "fat": totals['total_fat'] or 0
            },
            "goals": {
                "target_carbs": target_carbs,
                "target_protein": target_protein,
                "target_fat": target_fat
            },
            "today_meals": today_meals
        }

        serializer = DashboardSerializer(dashboard_data)
        return Response(serializer.data)
    
class RegisterAPIView(APIView):
    permission_classes = [AllowAny]

    @extend_schema(responses={201: RegisterSerializer})
    def post(self, request):
        serializer = RegisterSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class MealHistoryView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        user = request.user

        start_date_str = request.query_params.get('start_date')
        end_date_str = request.query_params.get('end_date')

        meals = Meal.objects.filter(user=user).order_by('-created_at')

        if start_date_str and end_date_str:
            try:
                start_date = datetime.strptime(start_date_str, '%Y-%m-%d').date()
                end_date = datetime.strptime(end_date_str, '%Y-%m-%d').date()
                meals = meals.filter(created_at__range=[start_date, end_date])
            except ValueError:
                return Response({"error": "فرمت تاریخ باید YYYY-MM-DD باشد"}, status=400)
        
        serializer = MealSerializer(meals, many=True)
        return Response({
            "range": f"از تاریخ {start_date_str or 'ابتدا'} تا {end_date_str or 'امروز'}",
            "meals": serializer.data
        })
    

class UserProfileView(RetrieveUpdateAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = ProfileSerializer

    def get_object(self):
        return self.request.user
    
class AIScanAndCreateView(APIView):
    permission_classes = [IsAuthenticated]
    parser_classes = (MultiPartParser, FormParser)

    def post(self, request):
        file_obj = request.data.get('image')
        meal_type = request.data.get('meal_type', 'صبحانه')
        
        if not file_obj:
            return Response({"error": "عکسی دریافت نشد"}, status=400)

        meal = Meal.objects.create(
            user=request.user,
            meal_type=meal_type,
            image=file_obj,
            title="در حال آنالیز...",
            calories=0,
            carbs=0,
            protein=0,
            fat=0
        )

        try:
            file_obj.seek(0)
            image_bytes = file_obj.read()
            base64_image = base64.b64encode(image_bytes).decode('utf-8')
            
            prompt = """
            این تصویر یک وعده غذایی است. آن را تحلیل کن و نام غذا، تخمین کالری کل، 
            کربوهیدرات (به گرم)، پروتئین (به گرم) و چربی (به گرم) را دقیقاً در قالب فرمت JSON زیر برگردان.
            هیچ متن اضافی یا توضیحات یا فرمت مارک‌داون (مثل ```json) قبل و بعد از آن اضافه نکن. فقط خود لود جیسون:
            {"title": "نام فارسی غذا", "calories": 250, "carbs": 30, "protein": 15, "fat": 10}
            """
            
            response = client.chat.completions.create(
                model="gapgpt-qwen-3.5", 
                messages=[
                    {
                        "role": "user",
                        "content": [
                            {"type": "text", "text": prompt},
                            {
                                "type": "image_url",
                                "image_url": {
                                    "url": f"data:image/jpeg;base64,{base64_image}"
                                }
                            }
                        ]
                    }
                ],
                response_format={"type": "json_object"} # اجبار به خروجی جیسون معتبر
            )
            
            response_text = response.choices[0].message.content.strip()
            ai_data = json.loads(response_text)
            
            def safe_int(val):
                try:
                    return int(float(str(val).split()[0]))
                except:
                    return 0

            meal.title = ai_data.get('title', 'وعده اسکن شده')
            meal.calories = safe_int(ai_data.get('calories', 0))
            meal.carbs = safe_int(ai_data.get('carbs', 0))
            meal.protein = safe_int(ai_data.get('protein', 0))
            meal.fat = safe_int(ai_data.get('fat', 0))
            meal.save()

            return Response({
                "status": "success",
                "meal_id": meal.id,
                "title": meal.title,
                "calories": meal.calories,
                "image_url": meal.image.url
            }, status=201)

        except Exception as e:
            logger.error(f"Zana OpenAI Scan Error: {str(e)}")
            
            meal.title = "وعده ناشناس (خطا در آنالیز)"
            meal.save()
            
            return Response({
                "status": "partial_success",
                "message": "عکس آپلود شد اما سرور هوش مصنوعی پاسخ نداد.",
                "meal_id": meal.id,
                "title": meal.title,
                "calories": 0,
                "image_url": meal.image.url
            }, status=200)