import 'package:dio/dio.dart';

abstract class IScanDataSource {
  Future<Map<String, dynamic>> uploadAndCreateMeal(String imagePath, String mealType);
}

class ScanRemoteDataSource implements IScanDataSource {
  final Dio dio;
  ScanRemoteDataSource({required this.dio});

  @override
  Future<Map<String, dynamic>> uploadAndCreateMeal(String imagePath, String mealType) async {
    try {
      FormData formData = FormData.fromMap({
        "image": await MultipartFile.fromFile(imagePath),
        "meal_type": mealType,
      });

      final response = await dio.post(
        "ai/scan-create/",
        data: formData,
        options: Options(contentType: "multipart/form-data"),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(e.message ?? "خطا در ساخت وعده غذایی");
    }
  }
}