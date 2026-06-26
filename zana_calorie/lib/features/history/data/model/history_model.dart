import 'package:zana_calorie/features/home/data/model/home_model.dart';

class HistoryModel {
  final String dateRange;
  final List<MealModel> meals;

  HistoryModel.fromJson(Map<String, dynamic> json)
      : dateRange = json["range"] ?? "",
        meals = (json["meals"] as List? ?? [])
            .map((e) => MealModel.fromJson(e as Map<String, dynamic>))
            .toList();
}