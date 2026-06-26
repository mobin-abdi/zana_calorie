import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class IAuthDataSource {
  Future<Map<String, dynamic>> login(String username, String password);

  Future<Map<String, dynamic>> register(
    String username,
    String email,
    String password,
    String name,
  );
}

class AuthRemoteDataSource implements IAuthDataSource {
  final Dio dio;

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  AuthRemoteDataSource({required this.dio});

  @override
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await dio.post(
        "auth/login/",
        data: {'username': username, 'password': password},
      );

      if (response.statusCode == 200) {
        await _saveTokens(response.data);
        return response.data;
      } else {
        throw Exception("خطا در ورود : ${response.statusCode}");
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> register(
    String username,
    String email,
    String password,
    String name,
  ) async {
    try {
      final response = await dio.post(
        "auth/register/",
        data: {
          'username': username,
          'email': email,
          'password': password,
          'name': name,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await _saveTokens(response.data);
        return response.data;
      } else {
        throw Exception("خطا در ثبت نام: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> _saveTokens(dynamic responseData) async {
    if (responseData != null && responseData is Map<String, dynamic>) {
      final accessToken = responseData['access'];
      final refreshToken = responseData['refresh'];

      print("--- ذخیره توکن‌ها ---");
      print("Access: $accessToken");

      if (accessToken != null) {
        await _storage.write(key: "access_token", value: accessToken);
      }
      if (refreshToken != null) {
        await _storage.write(key: "refresh_token", value: refreshToken);
      }
    }
  }
}
