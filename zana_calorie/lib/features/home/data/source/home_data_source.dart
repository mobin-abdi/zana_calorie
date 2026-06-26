import 'package:dio/dio.dart';
import 'package:zana_calorie/features/home/data/model/home_model.dart';

abstract class IHomeDataSource {
  Future<DashboardModel> getDashboardData();
}

class HomeRemoteDataSource implements IHomeDataSource {
  final Dio dio;

  HomeRemoteDataSource({required this.dio});

  @override
  Future<DashboardModel> getDashboardData() async {
    try {
      final response = await dio.get("home/");

      if (response.statusCode == 200) {
        return DashboardModel.fromJson(response.data);
      } else {
        throw Exception('خطا در دریافت اطلاعات از سرور');
      }
    } on DioException catch (e) {
      throw Exception(e.message ?? 'خطای شبکه رخ داده است');
    } catch (e) {
      throw Exception('خطای ناشناخته: $e');
    }
  }
}