import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:zana_calorie/features/scan/data/repo/scan_repository.dart';

part 'scan_event.dart';
part 'scan_state.dart';

class ScanBloc extends Bloc<ScanEvent, ScanState> {
  final IScanRepository scanRepository;

  ScanBloc({required this.scanRepository}) : super(ScanInitial()) {
    on<ScanSubmitted>((event, emit) async {
      emit(ScanLoading());
      try {
        final result = await scanRepository.uploadAndCreateMeal(
          event.imagePath,
          event.mealType,
        );
        emit(ScanSuccess(result));
      } catch (e) {
        emit(ScanError(e.toString().replaceAll('Exception: ', '')));
      }
    });
    on<ScanResetEvent>((event, emit) {
      emit(ScanInitial());
    });
  }
}
