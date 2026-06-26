class ProfileModel {
  final int id;
  final String username;
  final String email;
  final String name;
  final String dateJoined;
  final ProfileGoalsModel goals;

  ProfileModel.fromJson(Map<String, dynamic> json)
      : id = json["id"] ?? 0,
        username = json["username"] ?? "",
        email = json["email"] ?? "",
        name = json["name"] ?? "",
        dateJoined = json["date_joined"] ?? "",
        goals = ProfileGoalsModel.fromJson(json["goals"] ?? {});
}

class ProfileGoalsModel {
  final int targetCalories;
  final int targetCarbs;
  final int targetProtein;
  final int targetFat;

  ProfileGoalsModel.fromJson(Map<String, dynamic> json)
      : targetCalories = json["target_calories"] ?? 2000,
        targetCarbs = json["target_carbs"] ?? 300,
        targetProtein = json["target_protein"] ?? 150,
        targetFat = json["target_fat"] ?? 70;
}