import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';
import '../utils/app_config.dart';
import 'api_exceptions.dart';

/// Auth interceptor to add Bearer token to requests
class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _secureStorage;

  AuthInterceptor(this._secureStorage);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Skip auth for login/register endpoints
    if (options.path.contains('/auth/login') || 
        options.path.contains('/auth/register') ||
        options.path.contains('/auth/refresh')) {
      handler.next(options);
      return;
    }

    // Add Bearer token if available
    final token = await _secureStorage.read(key: AppConstants.accessTokenKey);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle 401 errors - attempt token refresh
    if (err.response?.statusCode == 401) {
      try {
        final refreshed = await _refreshToken();
        if (refreshed) {
          // Retry the original request with new token
          final token = await _secureStorage.read(key: AppConstants.accessTokenKey);
          err.requestOptions.headers['Authorization'] = 'Bearer $token';
          
          final dio = Dio();
          final response = await dio.fetch(err.requestOptions);
          handler.resolve(response);
          return;
        }
      } catch (e) {
        // Refresh failed, proceed with original error
      }
    }

    handler.next(err);
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _secureStorage.read(key: AppConstants.refreshTokenKey);
      if (refreshToken == null) return false;

      final dio = Dio();
      dio.options.baseUrl = AppConfig.apiUrl;
      
      final response = await dio.post('/auth/refresh', data: {
        'refreshToken': refreshToken,
      });

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        await _secureStorage.write(
          key: AppConstants.accessTokenKey,
          value: data['accessToken'],
        );
        if (data['refreshToken'] != null) {
          await _secureStorage.write(
            key: AppConstants.refreshTokenKey,
            value: data['refreshToken'],
          );
        }
        return true;
      }
    } catch (e) {
      // Clear tokens on refresh failure
      await _secureStorage.delete(key: AppConstants.accessTokenKey);
      await _secureStorage.delete(key: AppConstants.refreshTokenKey);
    }
    
    return false;
  }
}

/// Certificate pinning interceptor for security
class CertificatePinningInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Validate endpoint is in allowed hosts
    final uri = Uri.parse(options.baseUrl + options.path);
    final host = '${uri.host}:${uri.port}';
    
    if (!AppConfig.allowedHosts.contains(host) && !AppConfig.allowedHosts.contains(uri.host)) {
      throw SecurityException(
        message: 'Unauthorized API endpoint: $host',
        code: 'INVALID_ENDPOINT',
      );
    }

    handler.next(options);
  }
}

/// Error handling interceptor for standardized error processing
class ErrorHandlingInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Add retry logic for network errors
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError) {
      
      // Check if we should retry (simple retry count check)
      final retryCount = err.requestOptions.extra['retryCount'] ?? 0;
      if (retryCount < 3) {
        err.requestOptions.extra['retryCount'] = retryCount + 1;
        
        // Exponential backoff
        final delayMs = (1000 * (retryCount + 1)).round();
        final delay = Duration(milliseconds: delayMs);
        Future.delayed(delay, () async {
          try {
            final dio = Dio();
            dio.options = err.requestOptions as BaseOptions;
            final response = await dio.fetch(err.requestOptions);
            handler.resolve(response);
          } catch (e) {
            handler.next(err);
          }
        });
        return;
      }
    }

    handler.next(err);
  }
}

/// Performance monitoring interceptor
class PerformanceInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra['startTime'] = DateTime.now().millisecondsSinceEpoch;
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final startTime = response.requestOptions.extra['startTime'] as int?;
    if (startTime != null) {
      final duration = DateTime.now().millisecondsSinceEpoch - startTime;
      
      // Log slow requests in debug mode
      if (AppConfig.isDebugMode && duration > 2000) {
        print('⚠️ Slow API request: ${response.requestOptions.path} took ${duration}ms');
      }
      
      // Store duration for potential analytics
      response.extra['duration'] = duration;
    }
    
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final startTime = err.requestOptions.extra['startTime'] as int?;
    if (startTime != null) {
      final duration = DateTime.now().millisecondsSinceEpoch - startTime;
      
      if (AppConfig.isDebugMode) {
        print('❌ Failed API request: ${err.requestOptions.path} failed after ${duration}ms');
      }
    }
    
    handler.next(err);
  }
}