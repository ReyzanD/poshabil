import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';
import 'api_exceptions.dart';

class ApiClient {
  late final Dio _dio;
  String? _token;
  static const String _tokenKey = 'auth_token';

  /// In-memory fallback when SharedPreferences is unavailable (e.g. web).
  final _memoryStore = <String, String>{};
  SharedPreferences? _prefs;
  bool _prefsReady = false;

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Accept': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_token != null) {
          options.headers['Authorization'] = 'Bearer $_token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          handler.reject(DioException(
            requestOptions: error.requestOptions,
            error: UnauthorizedException(),
          ));
          return;
        }
        handler.next(error);
      },
    ));
  }

  Future<void> _initPrefs() async {
    if (_prefsReady) return;
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (_) {
      // SharedPreferences unavailable (e.g. web without plugin registration).
      _prefs = null;
    }
    _prefsReady = true;
  }

  Future<void> setToken(String? token) async {
    _token = token;
    await _initPrefs();
    if (_prefs != null) {
      if (token != null) {
        await _prefs!.setString(_tokenKey, token);
      } else {
        await _prefs!.remove(_tokenKey);
      }
    } else if (token != null) {
      _memoryStore[_tokenKey] = token;
    } else {
      _memoryStore.remove(_tokenKey);
    }
  }

  Future<String?> restoreToken() async {
    await _initPrefs();
    if (_prefs != null) {
      _token = _prefs!.getString(_tokenKey);
    } else {
      _token = _memoryStore[_tokenKey];
    }
    return _token;
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? queryParams}) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParams);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> post(String path, {dynamic data}) async {
    try {
      final response = await _dio.post(path, data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> put(String path, {dynamic data}) async {
    try {
      final response = await _dio.put(path, data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> delete(String path) async {
    try {
      final response = await _dio.delete(path);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  ApiException _handleError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return ConnectionException();
    }
    if (e.error is ApiException) return e.error as ApiException;
    final message = e.response?.data?['message'] ?? e.message;
    return ApiException(message.toString(), statusCode: e.response?.statusCode);
  }
}