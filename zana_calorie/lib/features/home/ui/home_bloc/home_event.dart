part of 'home_bloc.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();
}

class HomeStarted extends HomeEvent {
  @override
  List<Object?> get props => [];
}