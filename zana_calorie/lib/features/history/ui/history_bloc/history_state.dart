part of 'history_bloc.dart';

sealed class HistoryState extends Equatable {
  const HistoryState();
}

final class HistoryInitial extends HistoryState {
  @override
  List<Object> get props => [];
}

class HistoryLoading extends HistoryState {
  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();
}

class HistoryLoaded extends HistoryState {
  final String dateRange;
  final List<MealModel> meals;

  const HistoryLoaded({required this.dateRange, required this.meals});

  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();
}

class HistoryError extends HistoryState {
  final String message;
  const HistoryError(this.message);

  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();
}