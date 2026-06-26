part of 'scan_bloc.dart';

sealed class ScanState extends Equatable {
  const ScanState();
}

final class ScanInitial extends ScanState {
  @override
  List<Object> get props => [];
}

class ScanLoading extends ScanState {
  @override
  List<Object?> get props => [];
}

class ScanSuccess extends ScanState {
  final Map<String, dynamic> responseData;
  ScanSuccess(this.responseData);

  @override
  List<Object?> get props => [];
}

class ScanError extends ScanState {
  final String message;
  ScanError(this.message);

  @override
  List<Object?> get props => [];
}