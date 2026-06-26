import 'package:zana_calorie/features/scan/data/source/scan_data_source.dart).dart';

abstract class IScanRepository {
  Future<Map<String, dynamic>> uploadAndCreateMeal(String imagePath, String mealType);
}

class ScanRepository implements IScanRepository {
  final IScanDataSource dataSource;

  ScanRepository({required this.dataSource});

  @override
  Future<Map<String, dynamic>> uploadAndCreateMeal(String imagePath, String mealType) {
    return dataSource.uploadAndCreateMeal(imagePath, mealType);
  }
}