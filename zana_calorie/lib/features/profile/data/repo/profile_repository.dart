import 'package:zana_calorie/features/profile/data/model/profile_model.dart';
import 'package:zana_calorie/features/profile/data/source/profile_data_source.dart';

abstract class IProfileRepository {
  Future<ProfileModel> fetchProfile();

  Future<ProfileModel> updateProfileGoals(Map<String, dynamic> goalsData);
}

class ProfileRepository implements IProfileRepository {
  final IProfileDataSource dataSource;

  ProfileRepository({required this.dataSource});

  @override
  Future<ProfileModel> fetchProfile() => dataSource.getProfileData();

  @override
  Future<ProfileModel> updateProfileGoals(Map<String, dynamic> goalsData) =>
      dataSource.updateProfileGoals(goalsData);
}
