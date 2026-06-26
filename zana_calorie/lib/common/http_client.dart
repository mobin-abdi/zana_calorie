import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;

  late final Dio dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  DioClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: "http://10.0.2.2:8000/api/v1/",
        headers: {'Content-Type': 'application/json'},
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onError: _onError,
      ),
    );
  }

  Future<void> _onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (options.path.contains('auth/login') || options.path.contains('auth/register')) {
      return handler.next(options);
    }

    final accessToken = await _storage.read(key: "access_token");
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    return handler.next(options);
  }

  Future<void> _onError(DioException error, ErrorInterceptorHandler handler) async {
    if (error.response?.statusCode == 401) {
      final refreshToken = await _storage.read(key: "refresh_token");

      if (refreshToken != null) {
        try {
          final refreshDio = Dio(BaseOptions(baseUrl: dio.options.baseUrl));

          final response = await refreshDio.post(
            "auth/token/refresh/",
            data: {'refresh': refreshToken},
          );

          if (response.statusCode == 200) {
            final newAccessToken = response.data['access'];

            await _storage.write(key: "access_token", value: newAccessToken);

            final requestOptions = error.requestOptions;
            requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

            final options = Options(
              method: requestOptions.method,
              headers: requestOptions.headers,
            );

            final clonedResponse = await dio.request(
              requestOptions.path,
              data: requestOptions.data,
              queryParameters: requestOptions.queryParameters,
              options: options,
            );

            return handler.resolve(clonedResponse);
          }
        } catch (e) {
          await _storage.deleteAll();
          return handler.next(error);
        }
      }
    }
    return handler.next(error);
  }
}

final httpClient = DioClient().dio;