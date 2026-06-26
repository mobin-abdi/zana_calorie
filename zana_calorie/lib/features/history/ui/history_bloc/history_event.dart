part of 'history_bloc.dart';

sealed class HistoryEvent extends Equatable {
  const HistoryEvent();
}

class HistoryStarted extends HistoryEvent {
  final String? startDate;
  final String? endDate;

  const HistoryStarted({this.startDate, this.endDate});

  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();
}