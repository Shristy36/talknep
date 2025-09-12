import 'package:dio/dio.dart';
import 'package:talknep/main.dart';

class ApiService {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://talknep.com/api/',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Accept': 'application/json'},
    ),
  );

  /// Add token if needed
  static void setToken(String token) {
    _dio.options.headers["Authorization"] = "Bearer $token";
  }

  static void clearToken() {
    _dio.options.headers.remove("Authorization");
  }

  /// POST request
  static Future<Response?> post(
    String path,
    Map<String, dynamic> data, {
    Map<String, dynamic>? headers,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        options: Options(headers: headers),
      );
      return response;
    } on DioException catch (e) {
      logger.e("❌ POST Error: ${e.response?.data ?? e.message}");
      return e.response;
    }
  }

  /// GET request
  static Future<Response?> get(
    String path, {
    Map<String, dynamic>? query,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: query,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      logger.e("❌ GET Error: ${e.response?.data ?? e.message}");
      return e.response;
    }
  }

  /// PUT (Full Update)
  static Future<Response?> put(String path, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(path, data: data);
      return response;
    } on DioException catch (e) {
      logger.e("❌ PUT Error: ${e.response?.data ?? e.message}");
      return e.response;
    }
  }

  /// PATCH (Partial Update)
  static Future<Response?> patch(String path, Map<String, dynamic> data) async {
    try {
      final response = await _dio.patch(path, data: data);

      return response;
    } on DioException catch (e) {
      logger.e("❌ PATCH Error: ${e.response?.data ?? e.message}");
      return e.response;
    }
  }

  /// DELETE
  static Future<Response?> delete(
    String path, [
    Map<String, dynamic>? data,
  ]) async {
    try {
      final response = await _dio.delete(
        path,
        data: data != null ? {"data": data} : null,
      );
      return response;
    } on DioException catch (e) {
      logger.e("❌ DELETE Error: ${e.response?.data ?? e.message}");
      return e.response;
    }
  }

  /// Multipart request
  static Future<Response?> postMultipart(
    String path,
    Map<String, dynamic> fields,
    Map<String, MultipartFile> files,
  ) async {
    try {
      final formData = FormData.fromMap({...fields, ...files});
      final response = await _dio.post(path, data: formData);
      return response;
    } on DioException catch (e) {
      logger.e("❌ Multipart Error: ${e.response?.data ?? e.message}");
      return e.response;
    }
  }
}
