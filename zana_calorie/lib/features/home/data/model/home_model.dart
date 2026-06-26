class DashboardModel {
  final String date;
  final SummaryModel summary;
  final MacrosModel macros;
  final List<MealModel> todayMeals;

  DashboardModel.fromJson(Map<String, dynamic> json)
    : date = json["date"] ?? "",
      summary = SummaryModel.fromJson(json["summary"] ?? {}),
      macros = MacrosModel.fromJson(json["macros"] ?? {}, json["goals"] ?? {}),
      todayMeals = (json["today_meals"] as List? ?? [])
          .map((e) => MealModel.fromJson(e as Map<String, dynamic>))
          .toList();
}

class SummaryModel {
  final int totalCalories;
  final int remainingCalories;
  final int targetCalories;

  SummaryModel.fromJson(Map<String, dynamic> json)
    : totalCalories = json["today_calories"] ?? 0,
      targetCalories = json["target_calories"] ?? 2000,
      remainingCalories =
          (json["target_calories"] ?? 2000) - (json["today_calories"] ?? 0);
}

class MacrosModel {
  final MacroDetail carbs;
  final MacroDetail protein;
  final MacroDetail fat;

  MacrosModel.fromJson(Map<String, dynamic> json, Map<String, dynamic> goals)
    : carbs = MacroDetail.fromValues(
        current: json["carbs"] ?? 0,
        target: goals["target_carbs"] ?? 300,
      ),
      protein = MacroDetail.fromValues(
        current: json["protein"] ?? 0,
        target: goals["target_protein"] ?? 150,
      ),
      fat = MacroDetail.fromValues(
        current: json["fat"] ?? 0,
        target: goals["target_fat"] ?? 70,
      );
}

class MacroDetail {
  final int current;
  final int target;
  final double percentage;

  MacroDetail.fromValues({required this.current, required this.target})
    : percentage = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
}

class MealModel {
  final int id;
  final String mealType;
  final String title;
  final int calories;
  final String? image;

  MealModel.fromJson(Map<String, dynamic> json)
    : id = json["id"] ?? 0,
      mealType = json["meal_type"] ?? "",
      title = json["title"] ?? "",
      calories = json["calories"] ?? 0,
      image = json["image"];
}
