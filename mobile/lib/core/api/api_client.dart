import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/app_config.dart';
import '../constants/app_constants.dart';
import '../constants/error_codes.dart';
import 'api_interceptors.dart';
import 'api_exceptions.dart';

class ApiClient {
  static ApiClient? _instance;
  late Dio _dio;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  ApiClient._() {
    _dio = Dio();
    _setupInterceptors();
    _configureOptions();
  }

  static ApiClient get instance {
    _instance ??= ApiClient._();
    return _instance!;
  }

  Dio get dio => _dio;

  void _configureOptions() {
    _dio.options = BaseOptions(
      baseUrl: AppConfig.apiUrl,
      connectTimeout: AppConstants.connectionTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      sendTimeout: AppConstants.sendTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
  }

  void _setupInterceptors() {
    // Add auth interceptor
    _dio.interceptors.add(AuthInterceptor(_secureStorage));
    
    // Add certificate pinning interceptor
    _dio.interceptors.add(CertificatePinningInterceptor());
    
    // Add error handling interceptor
    _dio.interceptors.add(ErrorHandlingInterceptor());
    
    // Add logging interceptor for debug mode
    if (AppConfig.isDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: false,
        error: true,
      ));
    }
    
    // Add performance monitoring interceptor
    _dio.interceptors.add(PerformanceInterceptor());
  }

  // Generic GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      if (AppConfig.isDebugMode) {
        debugPrint('🚨 API GET Error for $path: $e');
      }
      throw _handleError(e);
    }
  }

  // Generic POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Generic PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Generic DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  // File upload request (POST)
  Future<Response<T>> upload<T>(
    String path,
    FormData formData, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      // Let Dio automatically set multipart/form-data with proper boundary
      final uploadOptions = options ?? Options();
      
      return await _dio.post<T>(
        path,
        data: formData,
        queryParameters: queryParameters,
        options: uploadOptions,
        onSendProgress: onSendProgress,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  // File upload request (PUT) for updates
  Future<Response<T>> putUpload<T>(
    String path,
    FormData formData, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      // Let Dio automatically set multipart/form-data with proper boundary
      final uploadOptions = options ?? Options();
      
      return await _dio.put<T>(
        path,
        data: formData,
        queryParameters: queryParameters,
        options: uploadOptions,
        onSendProgress: onSendProgress,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  // File download request
  Future<Response> download(
    String path,
    String savePath, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.download(
        path,
        savePath,
        queryParameters: queryParameters,
        options: options,
        onReceiveProgress: onReceiveProgress,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Error handler
  ApiException _handleError(dynamic error) {
    if (AppConfig.isDebugMode) {
      debugPrint('🔍 Handling API error: ${error.runtimeType} - $error');
    }
    
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return NetworkException(
            message: 'Connection timeout. Please check your internet connection.',
            code: ErrorCodes.connectionTimeout,
          );
        case DioExceptionType.badResponse:
          return _handleResponseError(error);
        case DioExceptionType.cancel:
          return ApiException(
            message: 'Request was cancelled',
            code: ErrorCodes.unknownError,
          );
        case DioExceptionType.connectionError:
          return NetworkException(
            message: 'No internet connection. Please check your network settings.',
            code: ErrorCodes.networkError,
          );
        case DioExceptionType.badCertificate:
          return SecurityException(
            message: 'Certificate validation failed. Connection is not secure.',
            code: ErrorCodes.networkError,
          );
        default:
          return ApiException(
            message: 'An unexpected error occurred',
            code: ErrorCodes.unknownError,
          );
      }
    }
    
    return ApiException(
      message: error.toString(),
      code: ErrorCodes.unknownError,
    );
  }

  ApiException _handleResponseError(DioException error) {
    final response = error.response;
    if (response == null) {
      return ServerException(
        message: 'Server error occurred',
        code: ErrorCodes.serverError,
      );
    }

    final statusCode = response.statusCode ?? 0;
    final data = response.data;

    // Try to extract error from response
    String message = 'An error occurred';
    String code = ErrorCodes.serverError;

    if (data is Map<String, dynamic>) {
      if (data.containsKey('error')) {
        final errorData = data['error'];
        if (errorData is Map<String, dynamic>) {
          message = errorData['message'] ?? message;
          code = errorData['code'] ?? code;
        } else if (errorData is String) {
          message = errorData;
        }
      } else if (data.containsKey('message')) {
        message = data['message'] ?? message;
      }
    }

    switch (statusCode) {
      case 400:
        return ValidationException(
          message: message,
          code: code,
          details: data,
        );
      case 401:
        return AuthException(
          message: message,
          code: ErrorCodes.unauthorizedAccess,
        );
      case 403:
        return AuthException(
          message: message,
          code: ErrorCodes.permissionDenied,
        );
      case 404:
        return ApiException(
          message: message,
          code: ErrorCodes.unknownError,
        );
      case 422:
        return ValidationException(
          message: message,
          code: ErrorCodes.validationError,
          details: data,
        );
      case 500:
        // Check if this is actually an auth error disguised as 500
        if (message.toLowerCase().contains('authorization') || 
            message.toLowerCase().contains('token') ||
            message.toLowerCase().contains('auth')) {
          return AuthException(
            message: 'Authentication required. Please login again.',
            code: ErrorCodes.unauthorizedAccess,
          );
        }
        return ServerException(
          message: 'Server error. Please try again later.',
          code: ErrorCodes.serverError,
        );
      case 502:
      case 503:
      case 504:
        return ServerException(
          message: 'Server error. Please try again later.',
          code: ErrorCodes.serverError,
        );
      default:
        return ApiException(
          message: message,
          code: code,
        );
    }
  }

  // Update base URL (useful for environment switching)
  void updateBaseUrl(String baseUrl) {
    _dio.options.baseUrl = baseUrl;
  }

  // Clear client instance (useful for logout)
  static void clearInstance() {
    _instance = null;
  }
}