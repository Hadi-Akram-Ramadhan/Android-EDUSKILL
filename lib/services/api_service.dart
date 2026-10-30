import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/helpers.dart';
import '../core/exceptions/app_exceptions.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late final Dio _dio;

  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: Duration(milliseconds: AppConstants.connectTimeout),
      receiveTimeout: Duration(milliseconds: AppConstants.receiveTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Auto attach saved token
        if (options.headers['Authorization'] == null) {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString(AppConstants.tokenKey);
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        }
        logger.d('=> \${options.method} \${options.path}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        logger.i('<= \${response.statusCode} \${response.requestOptions.path}');
        return handler.next(response);
      },
      onError: (DioException error, handler) {
        logger.e('!! \${error.response?.statusCode} \${error.requestOptions.path}: \${error.message}');
        if (error.response?.statusCode == 401) {
          handler.reject(DioException(
            requestOptions: error.requestOptions,
            error: const UnauthorizedException(),
            response: error.response,
          ));
          return;
        }
        final serverMsg = _extractServerMsg(error.response?.data);
        handler.reject(DioException(
          requestOptions: error.requestOptions,
          error: ApiException(serverMsg, statusCode: error.response?.statusCode),
          response: error.response,
        ));
      },
    ));
  }

  String _extractServerMsg(dynamic data) {
    if (data is Map) return (data['message'] as String?) ?? 'Server error';
    return 'Terjadi kesalahan. Coba lagi.';
  }

  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer \$token';
  }

  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.post(path, data: data, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<Response> put(String path, {dynamic data}) async {
    try {
      return await _dio.put(path, data: data);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Exception _mapError(DioException e) {
    if (e.error is ApiException) return e.error as ApiException;
    if (e.error is UnauthorizedException) return e.error as UnauthorizedException;
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.connectionError) {
      return NetworkException();
    }
    return ApiException(e.message ?? 'Unknown error', statusCode: e.response?.statusCode);
  }
}
