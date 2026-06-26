part of 'scan_bloc.dart';

sealed class ScanEvent extends Equatable {
  const ScanEvent();
}

class ScanSubmitted extends ScanEvent {
  final String imagePath;
  final String mealType;

  ScanSubmitted({required this.imagePath, required this.mealType});

  @override
  List<Object?> get props => [imagePath, mealType];
}

class ScanResetEvent extends ScanEvent {
  @override
  List<Object?> get props => [];
}