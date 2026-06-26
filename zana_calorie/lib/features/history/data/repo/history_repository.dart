import 'package:zana_calorie/features/history/data/model/history_model.dart';
import 'package:zana_calorie/features/history/data/source/history_data_source.dart';

abstract class IHistoryRepository {
  Future<HistoryModel> fetchHistory({String? startDate, String? endDate});
}

class HistoryRepository implements IHistoryRepository {
  final IHistoryDataSource dataSource;

  HistoryRepository({required this.dataSource});

  @override
  Future<HistoryModel> fetchHistory({String? startDate, String? endDate}) => dataSource.getHistoryData();

}