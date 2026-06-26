import 'package:dio/dio.dart';
import 'package:zana_calorie/features/profile/data/model/profile_model.dart';

abstract class IProfileDataSource {
  Future<ProfileModel> getProfileData();
  Future<ProfileModel> updateProfileGoals(Map<String, dynamic> goalsData);
}

class ProfileRemoteDataSource implements IProfileDataSource {
  final Dio dio;

  ProfileRemoteDataSource({required this.dio});

  @override
  Future<ProfileModel> getProfileData() async {
    try {
      final response = await dio.get("profile/");

      if (response.statusCode == 200) {
        return ProfileModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('خطا در دریافت اطلاعات پروفایل از سرور');
      }
    } on DioException catch (e) {
      throw Exception(e.message ?? 'خطای شبکه در لود پروفایل');
    }
  }

  @override
  Future<ProfileModel> updateProfileGoals(Map<String, dynamic> goalsData) async {
    try {
      final response = await dio.patch("profile/", data: {"goals": goalsData});

      if (response.statusCode == 200) {
        return ProfileModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('خطا در بروزرسانی اطلاعات');
      }
    } on DioException catch (e) {
      throw Exception(e.message ?? 'خطای شبکه رخ داده است');
    }
  }
}