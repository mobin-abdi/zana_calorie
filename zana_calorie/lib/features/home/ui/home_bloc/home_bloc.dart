import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:zana_calorie/features/home/data/model/home_model.dart';
import 'package:zana_calorie/features/home/data/repo/home_repository.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final IHomeRepository homeRepository;
  HomeBloc({required this.homeRepository}) : super(HomeInitial()) {
    on<HomeStarted>((event, emit) async {
      emit(HomeLoading());

      try {
        final data = await homeRepository.getDashboardData();
        emit(HomeLoaded(data: data));
      } catch (e) {
        final errorMessage = e.toString().replaceAll('Exception:', '').trim();
        emit(HomeError(message: errorMessage));
      }
    });
  }
}
