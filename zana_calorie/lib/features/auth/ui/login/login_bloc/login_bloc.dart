
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:zana_calorie/features/auth/data/repo/auth_repository.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final IAuthRepository authRepository;
  LoginBloc({required this.authRepository}) : super(LoginInitial()) {
    on<LoginStarted>((event, emit) async {
      emit(LoginLoading());
      try {
        await authRepository.login(event.username, event.password);
        emit(LoginLoaded());
      } catch (e) {
        emit(LoginError(message: e.toString()));
      }
    });
  }
}
