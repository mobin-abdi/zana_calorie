import 'package:dio/dio.dart';
import 'package:zana_calorie/features/history/data/model/history_model.dart';

abstract class IHistoryDataSource {
  Future<HistoryModel> getHistoryData({String? startDate, String? endDate});
}

class HistoryRemoteDataSource implements IHistoryDataSource {
  final Dio dio;

  HistoryRemoteDataSource({required this.dio});

  @override
  Future<HistoryModel> getHistoryData({String? startDate, String? endDate}) async {
    try {
      final response = await dio.get(
        "history/",
        queryParameters: {
          if (startDate != null) 'start_date': startDate,
          if (endDate != null) 'end_date': endDate,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        // اصلاح این خط: پاس دادن مستقیم مپِ ریسپانس به کانستراکتور مدل
        return HistoryModel.fromJson(data);
      } else {
        throw Exception('خطا در دریافت تاریخچه از سرور');
      }
    } on DioException catch (e) {
      throw Exception(e.message ?? 'خطای شبکه رخ داده است');
    }
  }
}