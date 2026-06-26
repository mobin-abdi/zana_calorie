import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zana_calorie/features/home/data/model/home_model.dart';
import 'package:dio/dio.dart';

part 'history_state.dart';
part 'history_event.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final Dio dio;

  HistoryBloc({required this.dio}) : super(HistoryInitial()) {
    on<HistoryStarted>((event, emit) async {
      emit(HistoryLoading());
      try {
        final response = await dio.get(
          "history/",
          queryParameters: {
            if (event.startDate != null) 'start_date': event.startDate,
            if (event.endDate != null) 'end_date': event.endDate,
          },
        );

        if (response.statusCode == 200) {
          final data = response.data as Map<String, dynamic>;
          final String range = data["range"] ?? "";
          final List<MealModel> meals = (data["meals"] as List? ?? [])
              .map((e) => MealModel.fromJson(e as Map<String, dynamic>))
              .toList();

          emit(HistoryLoaded(dateRange: range, meals: meals));
        } else {
          emit(HistoryError('خطا در دریافت تاریخچه از سرور'));
        }
      } on DioException catch (e) {
        emit(HistoryError(e.message ?? 'خطای شبکه رخ داده است'));
      } catch (e) {
        emit(HistoryError('خطای ناشناخته: $e'));
      }
    });
  }
}