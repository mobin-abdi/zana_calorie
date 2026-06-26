part of 'profile_bloc.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();
}

class ProfileStarted extends ProfileEvent {
  @override
  List<Object?> get props => [];
}

class ProfileUpdateGoals extends ProfileEvent {
  final Map<String, dynamic> goalsData;
  ProfileUpdateGoals(this.goalsData);

  @override
  List<Object?> get props => [goalsData];
}