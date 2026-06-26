import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:zana_calorie/features/profile/data/model/profile_model.dart';
import 'package:zana_calorie/features/profile/data/repo/profile_repository.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final IProfileRepository profileRepository;

  ProfileBloc({required this.profileRepository}) : super(ProfileInitial()) {
    on<ProfileStarted>((event, emit) async {
      emit(ProfileLoading());
      try {
        final profile = await profileRepository.fetchProfile();
        emit(ProfileLoaded(profile));
      } catch (e) {
        emit(ProfileError(e.toString().replaceAll('Exception: ', '')));
      }
    });
    on<ProfileUpdateGoals>((event, emit) async {
      emit(ProfileLoading()); // نمایش لودینگ در حین آپدیت
      try {
        final updatedProfile = await profileRepository.updateProfileGoals(event.goalsData);
        emit(ProfileLoaded(updatedProfile)); // لود مجدد صفحه با دیتای جدید
      } catch (e) {
        emit(ProfileError(e.toString().replaceAll('Exception: ', '')));
      }
    });
  }
}