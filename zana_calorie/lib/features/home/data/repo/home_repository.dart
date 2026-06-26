import 'package:zana_calorie/features/home/data/model/home_model.dart';
import 'package:zana_calorie/features/home/data/source/home_data_source.dart';


abstract class IHomeRepository {
  Future<DashboardModel> getDashboardData();
}

class HomeRepository implements IHomeRepository {
  final IHomeDataSource dataSource;

  HomeRepository({required this.dataSource});

  @override
  Future<DashboardModel> getDashboardData() => dataSource.getDashboardData();
}