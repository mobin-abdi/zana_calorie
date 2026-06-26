import 'package:zana_calorie/features/auth/data/source/auth_data_source.dart';

abstract class IAuthRepository {
  Future<Map<String, dynamic>> login(String username, String password);

  Future<Map<String, dynamic>> register(
    String username,
    String email,
    String password,
    String name,
  );
}

class AuthRepository implements IAuthRepository {
  final IAuthDataSource dataSource;

  AuthRepository({required this.dataSource});

  @override
  Future<Map<String, dynamic>> login(String username, String password) =>
      dataSource.login(username, password);

  @override
  Future<Map<String, dynamic>> register(
    String username,
    String email,
    String password,
    String name,
  ) => dataSource.register(username, email, password, name);
}
